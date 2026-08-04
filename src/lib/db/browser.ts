/**
 * Cliente do Supabase para o navegador.
 *
 * Vive num arquivo só dele, e não junto dos clientes de servidor, por um motivo
 * que o build ensinou: basta o módulo REFERENCIAR `astro:env/server` para que
 * importar qualquer coisa dele a partir de uma ilha quebre a compilação — mesmo
 * que a função que toca o segredo nunca seja chamada, e mesmo por import
 * dinâmico. O grafo de módulos é analisado inteiro.
 *
 * A separação é física, portanto, não convencional. Deste arquivo não há
 * caminho até uma chave secreta.
 *
 * Usa a chave `publishable`, que é feita para viver no cliente. Quem impõe as
 * regras é o RLS do Postgres.
 */
import { createBrowserClient } from '@supabase/ssr';
import type { SupabaseClient } from '@supabase/supabase-js';
import {
  PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  PUBLIC_SUPABASE_URL,
} from 'astro:env/client';

export type Db = SupabaseClient;

/** A sessão vem dos cookies gravados pelo fluxo de login. */
export function browser(): Db {
  return createBrowserClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_PUBLISHABLE_KEY);
}
