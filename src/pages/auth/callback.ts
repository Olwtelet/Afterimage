import type { APIRoute } from 'astro';

import { server } from '~/lib/db/client';
import { syncDiscordProfile } from '~/lib/discord';

export const prerender = false;

/**
 * Retorno do Discord.
 *
 * Troca o `code` pela sessão, grava os cookies e sincroniza o que veio do
 * Discord no perfil. A sincronização é deliberadamente tolerante a falha: se o
 * Discord estiver fora do ar ou o bot não estiver configurado, a pessoa entra
 * mesmo assim e o perfil fica com os dados da última vez. Login não deveria
 * depender da disponibilidade de um enfeite.
 */
export const GET: APIRoute = async ({ cookies, url, redirect }) => {
  const code = url.searchParams.get('code');
  const oauthError = url.searchParams.get('error_description') ?? url.searchParams.get('error');

  if (oauthError) {
    return redirect(`/auth/erro/?motivo=${encodeURIComponent(oauthError)}`, 302);
  }

  if (!code) {
    return redirect('/auth/erro/?motivo=sem-codigo', 302);
  }

  const db = server(cookies);
  const { data, error } = await db.auth.exchangeCodeForSession(code);

  if (error || !data.session) {
    return redirect(`/auth/erro/?motivo=${encodeURIComponent(error?.message ?? 'troca-falhou')}`, 302);
  }

  try {
    await syncDiscordProfile(data.session);
  } catch {
    /* Perfil fica com o que já tinha. A sessão é válida do mesmo jeito. */
  }

  const requested = url.searchParams.get('next') ?? '/';
  const next = requested.startsWith('/') && !requested.startsWith('//') ? requested : '/';

  return redirect(next, 302);
};
