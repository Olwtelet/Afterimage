import type { APIRoute } from 'astro';

import { server } from '~/lib/db/client';
import { DISCORD_SCOPES } from '~/lib/auth';

export const prerender = false;

/**
 * Início do fluxo OAuth.
 *
 * Existe como rota de servidor, e não como um botão que chama o SDK no
 * navegador, por dois motivos: o destino pós-login é decidido aqui (o cliente
 * não escolhe para onde volta) e o `code_verifier` do PKCE nasce num cookie
 * HttpOnly, fora do alcance de qualquer script da página.
 */
export const GET: APIRoute = async ({ cookies, url, redirect }) => {
  const db = server(cookies);

  /*
   * `next` vem da query, ou seja, do cliente. Só caminhos internos são aceitos:
   * um `next` absoluto transformaria esta rota num redirecionador aberto, útil
   * para fazer um link deste domínio levar a pessoa a outro.
   */
  const requested = url.searchParams.get('next') ?? '/';
  const next = requested.startsWith('/') && !requested.startsWith('//') ? requested : '/';

  const { data, error } = await db.auth.signInWithOAuth({
    provider: 'discord',
    options: {
      scopes: DISCORD_SCOPES,
      redirectTo: new URL(`/auth/callback/?next=${encodeURIComponent(next)}`, url.origin).href,
    },
  });

  if (error || !data.url) {
    return redirect(`/auth/erro/?motivo=${encodeURIComponent(error?.message ?? 'desconhecido')}`, 302);
  }

  return redirect(data.url, 302);
};
