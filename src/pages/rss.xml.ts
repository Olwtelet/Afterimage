import rss from '@astrojs/rss';
import type { APIContext } from 'astro';

import { getSessions } from '~/lib/catalog';
import { runtimeOf } from '~/lib/format';
import { SITE } from '~/lib/site';

/**
 * Feed das sessões.
 *
 * O feed antigo despejava o HTML inteiro de cada ficha dentro de um CDATA. Aqui
 * cada item leva o resumo e a ficha técnica — o suficiente para decidir se vale
 * abrir, que é para o que um feed serve.
 */
export async function GET(context: APIContext): Promise<Response> {
  const sessions = await getSessions();

  return rss({
    title: SITE.name,
    description: SITE.description,
    site: context.site ?? SITE.url,
    trailingSlash: true,
    customData: `<language>${SITE.lang}</language>`,
    items: sessions.map((session) => {
      const { headline, summary, features, session: slot } = session.entry.data;
      const titles = features.map((f) => `${f.title} (${f.year})`).join(' + ');
      const directors = [...new Set(features.map((f) => f.director))].join(', ');

      return {
        title: `${titles} — ${headline}`,
        description: summary,
        link: session.href,
        pubDate: slot.date,
        categories: session.entry.data.tags,
        content: [
          `<p>${summary}</p>`,
          '<ul>',
          `<li><strong>Direção:</strong> ${directors}</li>`,
          `<li><strong>Duração:</strong> ${runtimeOf(session.totalRuntime)}</li>`,
          `<li><strong>Sessão:</strong> ${slot.time} · ${slot.room}</li>`,
          '</ul>',
        ].join(''),
      };
    }),
  });
}
