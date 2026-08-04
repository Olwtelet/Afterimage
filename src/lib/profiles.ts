/**
 * Leitura de perfil público.
 *
 * Tudo aqui é público de propósito — perfis, contagens e posição no ranking são
 * legíveis por quem não está logado, e é o RLS que garante isso, não este
 * arquivo. O cliente usado é o de sessão, então as mesmas regras valem para o
 * servidor: uma consulta escrita errada aqui não vira um contorno das políticas.
 */
import type { Db } from './db/server';
import type { Film, Profile, RankingRow, Score } from './db/types';

/** Um filme como aparece nas listas do perfil. */
export type FilmCard = Pick<
  Film,
  'id' | 'slug' | 'headline' | 'summary' | 'poster_url' | 'tone'
>;

const FILM_COLUMNS = 'id, slug, headline, summary, poster_url, tone';

export interface ProfileStats {
  readonly watched: number;
  readonly favorites: number;
  readonly ratings: number;
  readonly comments: number;
  readonly score: number;
  /** Posição na comunidade, 1 = maior participação. `null` sem atividade. */
  readonly position: number | null;
  readonly total: number;
}

export interface ProfileComment {
  readonly id: string;
  readonly body: string;
  readonly edited: boolean;
  readonly created_at: string;
  readonly film: Pick<Film, 'slug' | 'headline'> | null;
  readonly score: Score | null;
}

export interface ProfilePage {
  readonly profile: Profile;
  readonly stats: ProfileStats;
  readonly favorites: readonly FilmCard[];
  readonly watched: readonly (FilmCard & { watched_at: string; score: Score | null })[];
  readonly comments: readonly ProfileComment[];
}

/** Perfil por username, ou `null` quando não existe. */
export async function findProfile(db: Db, username: string): Promise<Profile | null> {
  const { data } = await db
    .from('profiles')
    .select('*')
    .eq('username', username.toLowerCase())
    .maybeSingle<Profile>();

  return data ?? null;
}

/**
 * Monta a página inteira em paralelo.
 *
 * São seis consultas independentes; encadeá-las somaria as latências sem motivo,
 * já que nenhuma depende do resultado da outra.
 */
export async function loadProfilePage(db: Db, profile: Profile): Promise<ProfilePage> {
  const [ranking, favorites, watched, ratings, comments] = await Promise.all([
    db
      .from('community_ranking')
      .select('id, score')
      .order('score', { ascending: false })
      .returns<Pick<RankingRow, 'id' | 'score'>[]>(),

    db
      .from('favorites')
      .select(`created_at, films!inner(${FILM_COLUMNS})`)
      .eq('user_id', profile.id)
      .order('created_at', { ascending: false })
      .limit(12),

    db
      .from('watched')
      .select(`watched_at, films!inner(${FILM_COLUMNS})`)
      .eq('user_id', profile.id)
      .order('watched_at', { ascending: false })
      .limit(24),

    db.from('ratings').select('film_id, score').eq('user_id', profile.id),

    db
      .from('comments')
      .select('id, body, edited, created_at, film_id, films!inner(slug, headline)')
      .eq('user_id', profile.id)
      .order('created_at', { ascending: false })
      .limit(8),
  ]);

  /* A view devolve toda a comunidade ordenada; a posição é o índice da pessoa.
     Fazer isso no cliente evita uma window function e, com uma comunidade desta
     escala, a diferença é irrelevante. */
  const rows = ranking.data ?? [];
  const index = rows.findIndex((row) => row.id === profile.id);
  const mine = index >= 0 ? rows[index] : undefined;

  const scoreByFilm = new Map<string, Score>(
    (ratings.data ?? []).map((row) => [row.film_id as string, row.score as Score]),
  );

  /* O PostgREST tipa relação embutida como array mesmo quando é um-para-um. */
  const unwrap = <T,>(value: T | T[] | null): T | null =>
    Array.isArray(value) ? (value[0] ?? null) : value;

  return {
    profile,

    stats: {
      watched: countOf(watched.data),
      favorites: countOf(favorites.data),
      ratings: (ratings.data ?? []).length,
      comments: countOf(comments.data),
      score: mine?.score ?? 0,
      // Sem nenhuma atividade não há posição — zero não é um lugar na fila.
      position: mine && mine.score > 0 ? index + 1 : null,
      total: rows.filter((row) => row.score > 0).length,
    },

    favorites: (favorites.data ?? [])
      .map((row) => unwrap(row.films as unknown as FilmCard))
      .filter((film): film is FilmCard => film !== null),

    watched: (watched.data ?? [])
      .map((row) => {
        const film = unwrap(row.films as unknown as FilmCard);
        return film
          ? { ...film, watched_at: row.watched_at as string, score: scoreByFilm.get(film.id) ?? null }
          : null;
      })
      .filter((row): row is FilmCard & { watched_at: string; score: Score | null } => row !== null),

    comments: (comments.data ?? []).map((row) => ({
      id: row.id as string,
      body: row.body as string,
      edited: row.edited as boolean,
      created_at: row.created_at as string,
      film: unwrap(row.films as unknown as Pick<Film, 'slug' | 'headline'>),
      score: scoreByFilm.get(row.film_id as string) ?? null,
    })),
  };
}

const countOf = (rows: unknown[] | null): number => (rows ?? []).length;
