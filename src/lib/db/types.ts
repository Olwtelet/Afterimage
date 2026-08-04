/**
 * Tipos do banco, escritos à mão a partir de supabase/migrations/0002_plataforma.sql.
 *
 * São mantidos manualmente de propósito: o gerador do Supabase precisa de
 * credenciais e de uma conexão viva, o que tornaria o `astro check` dependente
 * da rede e do estado de um projeto remoto. Alterar o schema é alterar este
 * arquivo — e o compilador cobra a consistência em todo lugar que consome.
 */

/** Escala de três. Ver a constraint `ratings_score_range`. */
export type Score = 1 | 2 | 3;

export interface Profile {
  readonly id: string;
  readonly discord_id: string;
  readonly username: string;
  readonly display_name: string;
  readonly avatar_url: string | null;
  readonly banner_url: string | null;
  readonly bio: string | null;
  /** Espelho do Discord. Informativo: nenhuma permissão deriva daqui. */
  readonly guild_member: boolean;
  readonly guild_roles: readonly DiscordRole[];
  readonly created_at: string;
  readonly updated_at: string;
}

/** Cargo do Discord. Existe para ser exibido, nunca para autorizar. */
export interface DiscordRole {
  readonly id: string;
  readonly name: string;
  /** Inteiro de 24 bits vindo do Discord; convertido para hex na exibição. */
  readonly color: number;
}

export interface FilmFeature {
  readonly id: string;
  readonly film_id: string;
  readonly position: number;
  readonly title: string;
  readonly year: number | null;
  readonly director: string | null;
  readonly cast_list: readonly string[];
  readonly runtime: number | null;
  readonly rating: string | null;
  readonly genres: readonly string[];
  readonly starts_at: string | null;
}

export interface FilmLink {
  readonly label: string;
  readonly url: string;
}

export interface Film {
  readonly id: string;
  readonly slug: string;
  readonly headline: string;
  readonly kicker: string | null;
  readonly summary: string;
  readonly body: string | null;
  readonly poster_url: string | null;
  readonly banner_url: string | null;
  readonly trailer_url: string | null;
  readonly tone: string;
  readonly session_at: string | null;
  readonly room: string | null;
  readonly room_url: string | null;
  readonly genres: readonly string[];
  readonly tags: readonly string[];
  readonly links: readonly FilmLink[];
  readonly published: boolean;
  readonly created_at: string;
  readonly updated_at: string;
}

export interface FilmWithFeatures extends Film {
  readonly film_features: readonly FilmFeature[];
}

export interface Favorite {
  readonly user_id: string;
  readonly film_id: string;
  readonly created_at: string;
}

export interface Watched {
  readonly user_id: string;
  readonly film_id: string;
  readonly watched_at: string;
}

export interface Rating {
  readonly user_id: string;
  readonly film_id: string;
  readonly score: Score;
  readonly created_at: string;
  readonly updated_at: string;
}

export interface Comment {
  readonly id: string;
  readonly user_id: string;
  readonly film_id: string;
  readonly body: string;
  readonly edited: boolean;
  readonly created_at: string;
  readonly updated_at: string;
}

/** Comentário já acompanhado do autor e da nota dele, como a ficha exibe. */
export interface CommentWithAuthor extends Comment {
  readonly profiles: Pick<
    Profile,
    'username' | 'display_name' | 'avatar_url'
  > | null;
}

/** Agregados por filme. View `film_stats`. */
export interface FilmStats {
  readonly film_id: string;
  readonly slug: string;
  readonly favorite_count: number;
  readonly watched_count: number;
  readonly rating_count: number;
  readonly rating_average: number | null;
  readonly comment_count: number;
}

/**
 * Linha do ranking. View `community_ranking`.
 *
 * `score` descreve participação e nada mais: não é lido por nenhuma política de
 * acesso, não altera permissão e não desbloqueia recurso.
 */
export interface RankingRow {
  readonly id: string;
  readonly username: string;
  readonly display_name: string;
  readonly avatar_url: string | null;
  readonly created_at: string;
  readonly watched_count: number;
  readonly favorite_count: number;
  readonly rating_count: number;
  readonly comment_count: number;
  readonly score: number;
}
