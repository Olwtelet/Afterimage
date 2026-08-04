import { defineMiddleware } from 'astro:middleware';

import { readSession } from '~/lib/auth';

/**
 * Resolve a sessão uma vez por requisição e a deixa em `Astro.locals`.
 *
 * Sem isto, cada página que precisa saber quem está logado faria a sua própria
 * ida ao Supabase — e uma ficha que mostra cabeçalho, interações e comentários
 * faria três.
 *
 * Rotas pré-renderizadas não passam por aqui: elas são arquivos no CDN, sem
 * requisição para interceptar. É exatamente por isso que o cabeçalho resolve o
 * estado de login no cliente, e não no servidor.
 */
export const onRequest = defineMiddleware(async (context, next) => {
  const path = context.url.pathname;

  // O fluxo de OAuth escreve os próprios cookies de sessão; ler a sessão antes
  // da troca do código seria trabalho jogado fora.
  if (path.startsWith('/auth/')) return next();

  context.locals.session = await readSession(context.cookies);
  return next();
});
