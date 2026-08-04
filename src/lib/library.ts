/**
 * Biblioteca pessoal: favoritas e assistidas.
 *
 * As duas tabelas têm a mesma forma — (usuário, filme, data) — e diferem apenas
 * no nome da coluna de data. Uma função só evita duas cópias que sairiam de
 * sincronia na primeira mudança.
 */
import type { Db } from './db/server';
import type { Film, Score } from './db/types';

export type LibraryKind = 'favorites' | 'watched';

export interface LibraryItem {
  readonly id: string;
  readonly slug: string;
  readonly headline: string;
  readonly summary: string;
  readonly poster_url: string | null;
  readonly tone: string;
  readonly genres: readonly string[];
  /** Quando entrou na lista. */
  readonly markedAt: string;
  readonly score: Score | null;
}

/**
 * As duas consultas são escritas por extenso, e não montadas por interpolação.
 *
 * O PostgREST deriva o tipo do resultado da STRING LITERAL do `select`; assim que
 * um pedaço dela vira `${variável}`, a inferência colapsa e o retorno deixa de
 * ser tipado. Duas linhas quase iguais custam menos que perder a checagem em
 * todo o consumo — e a lógica que de fato se repetiria continua compartilhada
 * daqui para baixo.
 */
const SELECT = {
  favorites: 'created_at, films!inner(id, slug, headline, summary, poster_url, tone, genres)',
  watched: 'watched_at, films!inner(id, slug, headline, summary, poster_url, tone, genres)',
} as const;

/** Coluna de data de cada tabela. */
const DATE_COLUMN = {
  favorites: 'created_at',
  watched: 'watched_at',
} as const satisfies Record<LibraryKind, string>;

export async function loadLibrary(
  db: Db,
  userId: string,
  kind: LibraryKind,
): Promise<LibraryItem[]> {
  const dateColumn = DATE_COLUMN[kind];

  const [entries, ratings] = await Promise.all([
    db
      .from(kind)
      .select(SELECT[kind])
      .eq('user_id', userId)
      .order(dateColumn, { ascending: false })
      .returns<Array<Record<string, unknown>>>(),

    db.from('ratings').select('film_id, score').eq('user_id', userId),
  ]);

  const scoreByFilm = new Map<string, Score>(
    (ratings.data ?? []).map((row) => [row.film_id as string, row.score as Score]),
  );

  /* O PostgREST tipa relação embutida como array mesmo quando é um-para-um. */
  const unwrap = <T,>(value: T | T[] | null): T | null =>
    Array.isArray(value) ? (value[0] ?? null) : value;

  return (entries.data ?? [])
    .map((row) => {
      const film = unwrap(row.films as unknown as Omit<LibraryItem, 'markedAt' | 'score'>);
      if (!film) return null;
      return {
        ...film,
        markedAt: row[dateColumn] as string,
        score: scoreByFilm.get(film.id) ?? null,
      };
    })
    .filter((item): item is LibraryItem => item !== null);
}

/** Gêneros presentes na lista, para alimentar o filtro. */
export function genresIn(items: readonly LibraryItem[]): string[] {
  return [...new Set(items.flatMap((item) => item.genres))].sort((a, b) =>
    a.localeCompare(b, 'pt-BR'),
  );
}

export type FilmSummary = Pick<Film, 'slug' | 'headline'>;
