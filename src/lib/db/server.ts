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
import { createServerClient, type CookieOptions } from '@supabase/ssr';
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
 * Nomes possíveis dos cookies de sessão.
 *
 * O @supabase/ssr fatia a sessão em cookies numerados quando ela passa do limite
 * de tamanho, e não expõe API para enumerar o que gravou. Cobrir o nome base e
 * alguns fragmentos basta: a sessão só se fragmenta com metadados grandes e
 * nunca chega perto de cinco.
 */
const COOKIE_BASE = (() => {
  const ref = new URL(PUBLIC_SUPABASE_URL).hostname.split('.')[0] ?? 'local';
  return `sb-${ref}-auth-token`;
})();

const COOKIE_NAMES = [
  COOKIE_BASE,
  ...Array.from({ length: 5 }, (_, i) => `${COOKIE_BASE}.${i}`),
];

/** Cliente amarrado aos cookies da requisição. Respeita RLS. */
export function server(cookies: AstroCookieLike): Db {
  return createServerClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_PUBLISHABLE_KEY, {
    cookies: {
      getAll() {
        return COOKIE_NAMES.flatMap((name) => {
          const cookie = cookies.get(name);
          return cookie ? [{ name, value: cookie.value }] : [];
        });
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
