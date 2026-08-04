/**
 * Leitura e escrita do catálogo pelo painel.
 *
 * Todas as funções recebem o cliente de SESSÃO, não o elevado. É proposital: as
 * escritas continuam passando pelo RLS, e a política `is_admin()` no Postgres
 * decide de novo, por conta própria, o que a rota já decidiu. Se a checagem da
 * rota tivesse um furo, o banco recusaria mesmo assim.
 *
 * O cliente elevado existe no projeto, mas usá-lo aqui trocaria duas barreiras
 * por uma.
 */
import type { Db } from './db/server';
import type { Film, FilmFeature, FilmLink } from './db/types';

export interface AdminFilm extends Film {
  readonly film_features: readonly FilmFeature[];
}

const FILM_COLUMNS =
  'id, slug, headline, kicker, summary, body, poster_url, banner_url, trailer_url, ' +
  'tone, session_at, room, room_url, genres, tags, links, published, created_at, updated_at';

/** Catálogo inteiro, publicado ou não, do mais recente ao mais antigo. */
export async function listFilms(db: Db): Promise<AdminFilm[]> {
  const { data } = await db
    .from('films')
    .select(`${FILM_COLUMNS}, film_features(*)`)
    .order('session_at', { ascending: false, nullsFirst: false })
    .returns<AdminFilm[]>();

  return data ?? [];
}

export async function findFilm(db: Db, id: string): Promise<AdminFilm | null> {
  const { data } = await db
    .from('films')
    .select(`${FILM_COLUMNS}, film_features(*)`)
    .eq('id', id)
    .maybeSingle<AdminFilm>();

  return data ?? null;
}

/* -------------------------------------------------------------------------- */
/* Formulário -> banco                                                        */
/* -------------------------------------------------------------------------- */

export interface FilmDraft {
  slug: string;
  headline: string;
  kicker: string | null;
  summary: string;
  body: string | null;
  poster_url: string | null;
  banner_url: string | null;
  trailer_url: string | null;
  tone: string;
  session_at: string | null;
  room: string | null;
  room_url: string | null;
  genres: string[];
  tags: string[];
  links: FilmLink[];
  published: boolean;
}

export interface FeatureDraft {
  position: number;
  title: string;
  year: number | null;
  director: string | null;
  cast_list: string[];
  runtime: number | null;
  rating: string | null;
  genres: string[];
  starts_at: string | null;
}

const text = (form: FormData, key: string): string => String(form.get(key) ?? '').trim();
const orNull = (value: string): string | null => (value === '' ? null : value);

/** Campo de lista: uma entrada por linha, ou separadas por vírgula. */
const list = (raw: string): string[] =>
  raw
    .split(/[\n,]/)
    .map((item) => item.trim())
    .filter(Boolean);

const number = (raw: string): number | null => {
  const parsed = Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : null;
};

/**
 * Lê o formulário.
 *
 * Nada aqui confia no que chegou: os campos que o banco valida por constraint
 * (`slug`, `tone`) são normalizados antes de tentar gravar, para o erro voltar
 * como mensagem em vez de exceção do Postgres.
 */
export function readFilmForm(form: FormData): FilmDraft {
  const links = list(text(form, 'links'))
    .map((line) => {
      const [label, url] = line.split('|').map((part) => part.trim());
      return label && url ? { label, url } : null;
    })
    .filter((link): link is FilmLink => link !== null);

  const date = text(form, 'session_date');
  const time = text(form, 'session_time') || '20:30';

  return {
    slug: text(form, 'slug')
      .toLowerCase()
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .replace(/[^a-z0-9-]+/g, '-')
      .replace(/^-+|-+$/g, ''),
    headline: text(form, 'headline'),
    kicker: orNull(text(form, 'kicker')),
    summary: text(form, 'summary'),
    body: orNull(text(form, 'body')),
    poster_url: orNull(text(form, 'poster_url')),
    banner_url: orNull(text(form, 'banner_url')),
    trailer_url: orNull(text(form, 'trailer_url')),
    // A constraint exige seis dígitos hexadecimais; um valor curto viraria erro
    // do banco em vez de aviso na tela.
    tone: /^#[0-9a-f]{6}$/i.test(text(form, 'tone')) ? text(form, 'tone') : '#C0C0C0',
    session_at: date ? `${date}T${time}:00-03:00` : null,
    room: orNull(text(form, 'room')),
    room_url: orNull(text(form, 'room_url')),
    genres: list(text(form, 'genres')),
    tags: list(text(form, 'tags')),
    links,
    published: form.get('published') === 'on',
  };
}

/** Exibições, lidas dos campos indexados que o repetidor do formulário emite. */
export function readFeatureForms(form: FormData): FeatureDraft[] {
  const titles = form.getAll('feature_title').map((value) => String(value).trim());

  return titles
    .map((title, index) => ({
      position: index + 1,
      title,
      year: number(String(form.getAll('feature_year')[index] ?? '')),
      director: orNull(String(form.getAll('feature_director')[index] ?? '').trim()),
      cast_list: list(String(form.getAll('feature_cast')[index] ?? '')),
      runtime: number(String(form.getAll('feature_runtime')[index] ?? '')),
      rating: orNull(String(form.getAll('feature_rating')[index] ?? '').trim()),
      genres: list(String(form.getAll('feature_genres')[index] ?? '')),
      starts_at: orNull(String(form.getAll('feature_time')[index] ?? '').trim()),
    }))
    // Linha sem título é linha que o repetidor deixou em branco.
    .filter((feature) => feature.title !== '');
}

export interface SaveResult {
  ok: boolean;
  id?: string;
  error?: string;
}

/** Mensagens do Postgres traduzidas para o que dá para fazer a respeito. */
function explain(message: string): string {
  if (/films_slug_key|duplicate key/i.test(message)) {
    return 'Já existe uma sessão com esse endereço — escolha outro';
  }
  if (/films_slug_format/i.test(message)) {
    return 'O endereço aceita apenas letras minúsculas, números e hífen';
  }
  if (/films_tone_format/i.test(message)) {
    return 'A cor precisa ser hexadecimal de seis dígitos, como #C0C000';
  }
  if (/row-level security|permission denied/i.test(message)) {
    return 'Sem permissão para esta operação';
  }
  return message;
}

export async function saveFilm(
  db: Db,
  draft: FilmDraft,
  features: FeatureDraft[],
  id: string | null,
): Promise<SaveResult> {
  if (!draft.slug) return { ok: false, error: 'O endereço é obrigatório' };
  if (!draft.headline) return { ok: false, error: 'A manchete é obrigatória' };
  if (!draft.summary) return { ok: false, error: 'O resumo é obrigatório' };

  const { data, error } = id
    ? await db.from('films').update(draft).eq('id', id).select('id').maybeSingle<{ id: string }>()
    : await db.from('films').insert(draft).select('id').maybeSingle<{ id: string }>();

  if (error) return { ok: false, error: explain(error.message) };
  if (!data) return { ok: false, error: 'A gravação não retornou a sessão' };

  const filmId = data.id;

  /* Exibições são substituídas por inteiro em vez de reconciliadas linha a
     linha: a lista é curta, a ordem importa, e casar posições parcialmente é
     onde esse tipo de código costuma criar duplicatas silenciosas. */
  await db.from('film_features').delete().eq('film_id', filmId);

  if (features.length > 0) {
    const { error: featureError } = await db
      .from('film_features')
      .insert(features.map((feature) => ({ ...feature, film_id: filmId })));

    if (featureError) return { ok: false, error: explain(featureError.message) };
  }

  return { ok: true, id: filmId };
}

export async function deleteFilm(db: Db, id: string): Promise<SaveResult> {
  const { error } = await db.from('films').delete().eq('id', id);
  return error ? { ok: false, error: explain(error.message) } : { ok: true };
}
