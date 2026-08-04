import type { APIRoute } from 'astro';

import { server } from '~/lib/db/server';
import { DISCORD_SCOPES } from '~/lib/auth';

export const prerender = false;

/**
 * Início do fluxo OAuth.
 *
 * Existe como rota de servidor, e não como um botão que chama o SDK no
 * navegador, porque o destino pós-login é decidido AQUI: o cliente pede, o
 * servidor valida e escolhe. É o que impede a rota de virar um redirecionador
 * aberto (ver a checagem de `next` abaixo).
 *
 * Os cookies desta etapa não são HttpOnly, e isso é da arquitetura do
 * @supabase/ssr, não um descuido: o cliente do navegador lê a sessão de
 * `document.cookie` para saber quem está logado. Marcá-los HttpOnly quebraria o
 * cabeçalho, que resolve o estado de login no cliente justamente porque as
 * páginas são estáticas. O que protege aqui é o PKCE — o `code_verifier` só
 * serve junto do `code` que o Discord devolve, e este chega uma vez só.
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
