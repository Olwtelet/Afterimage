import type { APIRoute } from 'astro';

import { getSessions } from '~/lib/catalog';
import { shortDateOf } from '~/lib/format';

/**
 * Índice de busca gerado no build.
 *
 * O campo `terms` já vem normalizado sem acentos, então o cliente não precisa
 * dobrar nada em tempo de digitação — e "acao" encontra "ação".
 */
const fold = (value: string): string =>
  value
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase();

export const GET: APIRoute = async () => {
  const sessions = await getSessions();

  const docs = sessions.map((session) => {
    const { headline, summary, features, tags } = session.entry.data;
    const title = features.map((feature) => feature.title).join(' + ');

    return {
      title,
      headline,
      summary,
      href: session.href,
      date: shortDateOf(session.entry.data.session.date),
      bar: session.bar.bar,
      terms: fold(
        [
          title,
          headline,
          summary,
          ...tags,
          ...features.flatMap((feature) => [
            feature.director,
            String(feature.year),
            ...feature.genres,
          ]),
        ].join(' '),
      ),
    };
  });

  return new Response(JSON.stringify(docs), {
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'public, max-age=0, must-revalidate',
    },
  });
};
