/**
 * Clientes do Supabase para rotas de servidor.
 *
 * Este arquivo alcança segredos e por isso NUNCA pode ser importado de uma ilha.
 * O Astro impõe a regra: qualquer import a partir de código de navegador quebra
 * o build com ServerOnlyModule. O cliente do navegador vive em `./browser.ts`.
 *
 * São dois, e a distinção é de segurança:
 *
 *   server()   — age COMO o usuário logado, lendo a sessão dos cookies.
 *                Continua sujeito a RLS, que é o que impede uma rota mal escrita
 *                de virar um contorno das regras do banco. É o padrão.
 *
 *   elevated() — IGNORA RLS. Só para o que o banco não consegue autorizar
 *                sozinho: gravar no perfil o que veio do Discord, anunciar
 *                sessões. Nunca deriva permissão do que o cliente enviou.
 */
import {
  createServerClient,
  parseCookieHeader,
  type CookieOptions,
} from '@supabase/ssr';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import {
  PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  PUBLIC_SUPABASE_URL,
} from 'astro:env/client';
import { SUPABASE_SERVICE_ROLE_KEY } from 'astro:env/server';

export type Db = SupabaseClient;

interface AstroCookieLike {
  get(name: string): { value: string } | undefined;
  set(name: string, value: string, options?: CookieOptions): void;
  delete(name: string, options?: CookieOptions): void;
}

/**
 * Cliente amarrado aos cookies da requisição. Respeita RLS.
 *
 * `getAll` devolve TODOS os cookies, lidos do cabeçalho bruto. A versão anterior
 * tentava adivinhar os nomes numa lista fixa (`sb-<ref>-auth-token` e alguns
 * fragmentos numerados) e quebrou o login inteiro: o PKCE grava o verificador em
 * `...-auth-token-code-verifier`, `...-flows-code-verifier` e
 * `...-flow-<hash>-code-verifier`, nenhum deles na lista. O callback não
 * encontrava o verificador e a troca do código falhava com "PKCE code verifier
 * not found in storage".
 *
 * A lição é geral: quando a biblioteca escolhe os nomes, enumerá-los é apostar
 * contra uma implementação que pode mudar sem aviso. Entregar o conjunto
 * completo e deixar a biblioteca filtrar não tem esse risco — e é para isso que
 * ela exporta `parseCookieHeader`.
 *
 * Recebe `headers` porque a interface de cookies do Astro sabe buscar por nome,
 * mas não sabe listar.
 */
export function server(cookies: AstroCookieLike, headers: Headers): Db {
  return createServerClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_PUBLISHABLE_KEY, {
    cookies: {
      getAll() {
        return parseCookieHeader(headers.get('cookie') ?? '').map(({ name, value }) => ({
          name,
          value: value ?? '',
        }));
      },
      setAll(list) {
        for (const { name, value, options } of list) {
          cookies.set(name, value, { ...options, path: '/' });
        }
      },
    },
  });
}

/** Cliente com service role. IGNORA RLS — use com parcimônia. */
export function elevated(): Db {
  return createClient(PUBLIC_SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
