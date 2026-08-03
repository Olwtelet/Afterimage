import { getCollection, type CollectionEntry } from 'astro:content';

import { monthLabelOf } from './format';
import { barFor, type Bar } from './smpte';
import { slugify } from './slug';

export type FilmEntry = CollectionEntry<'films'>;

/**
 * O Brasil não observa horário de verão desde 2019, então o fuso de Brasília é
 * UTC−3 fixo. Construir o instante à mão evita arrastar uma biblioteca de fuso
 * inteira para o bundle por causa de um único deslocamento constante.
 */
const BRASILIA_UTC_OFFSET_HOURS = 3;

export type SessionState = 'exibida' | 'no-ar' | 'proxima' | 'agendada';

export interface Session {
  readonly slug: string;
  readonly href: string;
  readonly entry: FilmEntry;
  /** Barra SMPTE que tinge esta sessão. */
  readonly bar: Bar;
  /** Instante exato de início, em UTC. */
  readonly startsAt: Date;
  /** Fim estimado a partir da soma das durações das exibições. */
  readonly endsAt: Date;
  /** Duração total da sessão em minutos. */
  readonly totalRuntime: number;
}

function toInstant(date: Date, time: string): Date {
  const [hours = 0, minutes = 0] = time.split(':').map(Number);
  return new Date(
    Date.UTC(
      date.getUTCFullYear(),
      date.getUTCMonth(),
      date.getUTCDate(),
      hours + BRASILIA_UTC_OFFSET_HOURS,
      minutes,
    ),
  );
}

function toSession(entry: FilmEntry): Session {
  const { session, features, tone } = entry.data;
  const startsAt = toInstant(session.date, session.time);
  const totalRuntime = features.reduce((sum, feature) => sum + feature.runtime, 0);

  return {
    slug: entry.id,
    href: `/sessoes/${entry.id}/`,
    entry,
    bar: barFor(tone),
    startsAt,
    endsAt: new Date(startsAt.getTime() + totalRuntime * 60_000),
    totalRuntime,
  };
}

/** Todas as sessões, da mais recente para a mais antiga. */
export async function getSessions(): Promise<Session[]> {
  const entries = await getCollection('films');
  return entries.map(toSession).sort((a, b) => b.startsAt.getTime() - a.startsAt.getTime());
}

export function stateOf(session: Session, now: Date): SessionState {
  if (now >= session.startsAt && now < session.endsAt) return 'no-ar';
  return now >= session.endsAt ? 'exibida' : 'agendada';
}

/**
 * A sessão que o visitante precisa ver primeiro: a que está no ar agora ou, na
 * falta dela, a próxima agendada. Se não houver nenhuma à frente, cai na última
 * exibida — o site nunca fica sem uma sessão em destaque.
 */
export function featuredSession(sessions: readonly Session[], now: Date): Session | undefined {
  const live = sessions.find((session) => stateOf(session, now) === 'no-ar');
  if (live) return live;

  const upcoming = sessions.filter((session) => session.startsAt > now);
  return upcoming.at(-1) ?? sessions[0];
}

export interface Genre {
  readonly name: string;
  readonly slug: string;
  readonly count: number;
}

/** Tags agregadas em gêneros navegáveis, ordenadas por frequência. */
export function genresOf(sessions: readonly Session[]): Genre[] {
  const tally = new Map<string, { name: string; count: number }>();

  for (const session of sessions) {
    for (const tag of session.entry.data.tags) {
      const slug = slugify(tag);
      const current = tally.get(slug);
      if (current) current.count += 1;
      else tally.set(slug, { name: tag, count: 1 });
    }
  }

  return [...tally.entries()]
    .map(([slug, { name, count }]) => ({ slug, name, count }))
    .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name, 'pt-BR'));
}

export function sessionsWithTag(sessions: readonly Session[], tagSlug: string): Session[] {
  return sessions.filter((session) =>
    session.entry.data.tags.some((tag) => slugify(tag) === tagSlug),
  );
}

export interface MonthGroup {
  readonly key: string;
  readonly label: string;
  readonly sessions: readonly Session[];
}


/** Agrupa as sessões por mês, para a grade de programação. */
export function groupByMonth(sessions: readonly Session[]): MonthGroup[] {
  const groups = new Map<string, Session[]>();

  for (const session of sessions) {
    const date = session.entry.data.session.date;
    const key = `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}`;
    const bucket = groups.get(key);
    if (bucket) bucket.push(session);
    else groups.set(key, [session]);
  }

  return [...groups.entries()].map(([key, items]) => ({
    key,
    label: monthLabelOf(items[0]!.entry.data.session.date),
    sessions: items,
  }));
}

/** Sessões relacionadas: as que mais compartilham tags com a atual. */
export function relatedTo(
  sessions: readonly Session[],
  current: Session,
  limit = 3,
): Session[] {
  const tags = new Set(current.entry.data.tags);

  return sessions
    .filter((session) => session.slug !== current.slug)
    .map((session) => ({
      session,
      score: session.entry.data.tags.filter((tag) => tags.has(tag)).length,
    }))
    .filter(({ score }) => score > 0)
    .sort(
      (a, b) => b.score - a.score || b.session.startsAt.getTime() - a.session.startsAt.getTime(),
    )
    .slice(0, limit)
    .map(({ session }) => session);
}
