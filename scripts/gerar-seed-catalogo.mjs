/**
 * Gera a migração que semeia o catálogo a partir das fichas em Markdown.
 *
 * Roda uma vez, na máquina de quem desenvolve, e o SQL resultante entra no
 * repositório. Assim o banco de qualquer ambiente nasce com o catálogo, sem
 * depender de alguém executar um script com credenciais na mão.
 */
import { readdirSync, readFileSync, writeFileSync } from 'node:fs';
import YAML from 'yaml';

const DIR = new URL('../src/content/films/', import.meta.url);
const OUT = new URL('../supabase/migrations/0003_catalogo.sql', import.meta.url);

/** Escapa uma string para literal do Postgres. */
const q = (value) =>
  value === null || value === undefined ? 'null' : `'${String(value).replace(/'/g, "''")}'`;

/** Array de texto do Postgres. */
const arr = (list) => (!list?.length ? `'{}'` : `array[${list.map(q).join(', ')}]`);

/**
 * Front matter é YAML, e YAML tem mais casos de borda do que parece.
 *
 * A primeira versão deste arquivo trazia um parser escrito à mão, e ele leu as
 * `tags` de topo como exibições — as duas são itens de lista na mesma
 * indentação — produzindo cinco exibições vazias na sessão dupla. Um parser de
 * verdade simplesmente não tem essa classe de erro.
 */
function parseFrontMatter(raw) {
  const match = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
  if (!match) throw new Error('sem front matter');
  return { data: YAML.parse(match[1]), body: match[2].trim() };
}

const rows = [];

for (const file of readdirSync(DIR).filter((f) => f.endsWith('.md'))) {
  const slug = file.replace(/\.md$/, '');
  const { data, body } = parseFrontMatter(readFileSync(new URL(file, DIR), 'utf8'));

  const posterFile = String(data.poster ?? '').split('/').pop();
  const sessionAt = data.session?.date
    ? `${String(data.session.date).slice(0, 10)}T${data.session.time ?? '20:30'}:00-03:00`
    : null;

  // Gêneros da ficha: a união dos gêneros de cada exibição, sem repetir.
  const genres = [...new Set((data.features ?? []).flatMap((f) => f.genres ?? []))];

  rows.push({ slug, data, body, poster: `/posters/${posterFile}`, sessionAt, genres });
}

rows.sort((a, b) => String(a.sessionAt).localeCompare(String(b.sessionAt)));

const statements = rows.map(({ slug, data, body, poster, sessionAt, genres }) => {
  const features = (data.features ?? [])
    .map((f, index) =>
      `  ((select id from public.films where slug = ${q(slug)}), ${index + 1}, ` +
      `${q(f.title)}, ${f.year ?? 'null'}, ${q(f.director ?? null)}, ${arr(f.genres)}, ` +
      `${f.runtime ?? 'null'}, ${q(f.rating ?? null)}, ${f.time ? q(f.time) : 'null'})`,
    )
    .join(',\n');

  return `
-- ${slug} · ${(data.features ?? []).length} exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  ${q(slug)},
  ${q(data.headline)},
  ${q(data.kicker ?? null)},
  ${q(data.summary)},
  ${q(body)},
  ${q(poster)},
  ${q(data.tone)},
  ${sessionAt ? `${q(sessionAt)}::timestamptz` : 'null'},
  ${q(data.session?.room ?? null)},
  ${q(data.session?.roomUrl ?? null)},
  ${arr(genres)},
  ${arr(data.tags)},
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
${features}
on conflict (film_id, position) do nothing;`;
});

const sql = `-- =============================================================================
-- Catálogo inicial
--
-- Gerado a partir das 14 fichas em src/content/films/. As páginas públicas
-- continuam sendo renderizadas do Markdown; estas linhas existem para dar às
-- interações — favoritos, assistidos, avaliações, comentários — uma chave
-- estável para referenciar, e para o painel administrativo ter o que editar.
--
-- Idempotente: \`on conflict do nothing\` em tudo. Rodar de novo não duplica nem
-- sobrescreve o que o painel já tiver alterado.
--
-- Aplicar depois de 0002_plataforma.sql.
-- =============================================================================
${statements.join('\n')}
`;

writeFileSync(OUT, sql, 'utf8');

const total = rows.reduce((sum, r) => sum + (r.data.features ?? []).length, 0);
console.log(`${rows.length} fichas, ${total} exibições -> ${'0003_catalogo.sql'}\n`);
console.log(
  rows
    .map((r) => `  ${r.slug.padEnd(36)} ${(r.data.features ?? []).length}x  ${r.sessionAt}`)
    .join('\n'),
);
