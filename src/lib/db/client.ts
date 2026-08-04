/**
 * Clientes do Supabase.
 *
 * São três, e a distinção entre eles é de segurança, não de conveniência:
 *
 *   browser()  — roda no navegador com a chave publishable. Sujeito a RLS.
 *   server()   — roda em rota de servidor, lendo a sessão dos cookies. Age COMO
 *                o usuário logado, então continua sujeito a RLS. É o que se usa
 *                em quase todo lugar do servidor.
 *   elevated() — ignora RLS por completo. Só para o que o banco não consegue
 *                autorizar sozinho: sincronizar dados do Discord, anunciar
 *                sessões. Nunca deriva permissão do que o cliente enviou.
 *
 * O `elevated` importa a chave via `astro:env/server`, e o Astro se recusa a
 * compilar se este módulo for alcançado a partir de código de navegador. A
 * separação deixa de depender de disciplina.
 */
import { createBrowserClient, createServerClient, type CookieOptions } from '@supabase/ssr';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import {
  PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  PUBLIC_SUPABASE_URL,
} from 'astro:env/client';

export type Db = SupabaseClient;

/** Cliente para ilhas. A sessão vem dos cookies escritos no login. */
export function browser(): Db {
  return createBrowserClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_PUBLISHABLE_KEY);
}

interface AstroCookieLike {
  get(name: string): { value: string } | undefined;
  set(name: string, value: string, options?: CookieOptions): void;
  delete(name: string, options?: CookieOptions): void;
}

/**
 * Cliente de servidor amarrado aos cookies da requisição.
 *
 * Continua respeitando RLS: as políticas do banco valem igualmente para o
 * código de servidor, que é o que impede uma rota mal escrita de virar um
 * contorno das regras.
 */
export function server(cookies: AstroCookieLike): Db {
  return createServerClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_PUBLISHABLE_KEY, {
    cookies: {
      getAll() {
        // O @supabase/ssr fatia a sessão em vários cookies numerados quando ela
        // passa do limite de tamanho; devolvemos todos os que ele pedir.
        return SUPABASE_COOKIE_NAMES.flatMap((name) => {
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

/**
 * Nomes possíveis dos cookies de sessão.
 *
 * O @supabase/ssr não expõe uma API para enumerar o que gravou, e a interface de
 * cookies do Astro não lista chaves. Cobrir o nome base e alguns fragmentos é
 * suficiente: a sessão só passa de um fragmento quando carrega metadados
 * grandes, e nunca chega perto de cinco.
 */
const SUPABASE_COOKIE_BASE = (() => {
  const host = new URL(PUBLIC_SUPABASE_URL).hostname;
  const ref = host.split('.')[0] ?? 'local';
  return `sb-${ref}-auth-token`;
})();

const SUPABASE_COOKIE_NAMES = [
  SUPABASE_COOKIE_BASE,
  ...Array.from({ length: 5 }, (_, i) => `${SUPABASE_COOKIE_BASE}.${i}`),
];

/**
 * Cliente com service role. IGNORA RLS.
 *
 * Import dinâmico para que a chave nunca entre num grafo de módulos que possa
 * ser alcançado pelo cliente, mesmo por engano.
 */
export async function elevated(): Promise<Db> {
  const { SUPABASE_SERVICE_ROLE_KEY } = await import('astro:env/server');
  return createClient(PUBLIC_SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
