import type { APIRoute } from 'astro';

import { server } from '~/lib/db/server';

export const prerender = false;

/**
 * Encerra a sessão.
 *
 * Só POST. Um logout em GET é acionável por qualquer `<img src>` de terceiro, e
 * derrubar a sessão de alguém à revelia é um incômodo que não precisa existir.
 */
export const POST: APIRoute = async ({ cookies, redirect, request }) => {
  const db = server(cookies, request.headers);
  await db.auth.signOut();
  return redirect('/', 302);
};
