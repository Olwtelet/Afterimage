import { defineMiddleware } from 'astro:middleware';

import { readSession } from '~/lib/auth';

/**
 * Resolve a sessão uma vez por requisição e a deixa em `Astro.locals`.
 *
 * Sem isto, cada página que precisa saber quem está logado faria a própria ida
 * ao Supabase — e uma ficha que mostra cabeçalho, interações e comentários faria
 * três.
 *
 * O `isPrerendered` não é otimização, é correção: o middleware TAMBÉM roda
 * durante o build, ao gerar as páginas estáticas, e ali não existe requisição —
 * ler cookies naquele momento devolve vazio e ainda emite aviso. Uma página
 * estática é um arquivo no CDN, igual para todo mundo; quem descobre a sessão
 * dela é o navegador, na ilha do cabeçalho.
 */
export const onRequest = defineMiddleware(async (context, next) => {
  context.locals.session = null;

  if (context.isPrerendered) return next();

  // O fluxo de OAuth grava os próprios cookies de sessão; lê-los antes da troca
  // do código seria trabalho jogado fora.
  if (context.url.pathname.startsWith('/auth/')) return next();

  context.locals.session = await readSession(context.cookies);
  return next();
});
