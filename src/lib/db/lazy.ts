/**
 * Carregamento sob demanda do cliente do Supabase.
 *
 * O SDK tem 217 kB. Importá-lo de forma estática numa ilha do cabeçalho fazia
 * TODA visita baixá-lo — inclusive a de quem nunca criou conta, que é a maioria
 * e é justamente quem chega pelo buscador. O site tinha 5 kB de JavaScript antes
 * da plataforma; passou a ter 222.
 *
 * A saída é perguntar antes de carregar. Saber se existe sessão não exige o SDK:
 * basta olhar se o cookie de autenticação está lá. Só quando ele existe é que
 * vale a pena buscar o resto.
 *
 * Quem está deslogado paga alguns bytes. Quem está logado paga o SDK uma vez, e
 * o navegador o reaproveita nas outras páginas.
 */
import type { SupabaseClient } from '@supabase/supabase-js';
import {
  PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  PUBLIC_SUPABASE_URL,
} from 'astro:env/client';

/**
 * Leitura pública sem o SDK.
 *
 * O Supabase é PostgREST por baixo: uma leitura anônima é um GET com dois
 * cabeçalhos. Para os caminhos que só leem — comentários de uma ficha, o id de
 * um filme pelo slug — isso substitui 217 kB de biblioteca por uma linha de
 * `fetch`, e o RLS continua valendo exatamente igual, porque quem aplica as
 * políticas é o banco e não o cliente.
 *
 * O SDK segue sendo carregado para escrever, onde ele de fato paga o próprio
 * peso: sessão, refresh de token e tratamento de erro.
 */
export async function readRest<T>(path: string): Promise<T[]> {
  try {
    const response = await fetch(`${PUBLIC_SUPABASE_URL}/rest/v1/${path}`, {
      headers: {
        apikey: PUBLIC_SUPABASE_PUBLISHABLE_KEY,
        Authorization: `Bearer ${PUBLIC_SUPABASE_PUBLISHABLE_KEY}`,
      },
    });
    return response.ok ? ((await response.json()) as T[]) : [];
  } catch {
    return [];
  }
}

/**
 * Há cookie de sessão?
 *
 * O @supabase/ssr nomeia os cookies como `sb-<ref>-auth-token`, com variações e
 * fragmentos numerados. Procurar o prefixo cobre todas elas sem depender do
 * formato exato — que já mudou uma vez neste projeto e quebrou o login.
 *
 * É uma checagem otimista de propósito: um cookie presente pode estar expirado.
 * Quem decide de verdade é o servidor; aqui só se decide se vale carregar código.
 */
export function hasSessionCookie(): boolean {
  return /(^|;\s*)sb-[^=]*-auth-token[^=]*=/.test(document.cookie);
}

let cached: Promise<SupabaseClient> | null = null;

/**
 * Carrega o cliente uma vez por página.
 *
 * A promessa é guardada, e não o cliente: chamadas simultâneas durante o
 * carregamento compartilham a mesma requisição em vez de dispararem várias.
 */
export function loadDb(): Promise<SupabaseClient> {
  cached ??= import('./browser').then((module) => module.browser());
  return cached;
}
