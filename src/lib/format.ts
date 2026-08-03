/**
 * Formatação de datas, durações e códigos técnicos.
 *
 * Há dois tipos de tempo neste projeto e confundi-los desloca tudo em um dia:
 *
 *   - `session.date` é uma DATA DE CALENDÁRIO. O front matter diz "2026-08-22" e
 *     o parser a materializa como meia-noite UTC. Formatá-la em America/Sao_Paulo
 *     (UTC−3) a puxaria para as 21h do dia 21 — a sessão inteira apareceria um
 *     dia antes. Datas de calendário são formatadas em UTC.
 *
 *   - `startsAt` é um INSTANTE, montado a partir da data mais o horário de
 *     Brasília. Esse sim é formatado no fuso local da sessão.
 *
 * Todos os `Intl` são construídos uma vez, no módulo: instanciar um formatador
 * dentro de um laço de renderização é caro e desnecessário.
 */

const SESSION_TIME_ZONE = 'America/Sao_Paulo';

/* --- Datas de calendário (UTC) --------------------------------------------- */

const weekdayLong = new Intl.DateTimeFormat('pt-BR', { weekday: 'long', timeZone: 'UTC' });
const dayMonth = new Intl.DateTimeFormat('pt-BR', {
  day: '2-digit',
  month: 'short',
  timeZone: 'UTC',
});
const fullDate = new Intl.DateTimeFormat('pt-BR', {
  day: '2-digit',
  month: 'long',
  year: 'numeric',
  timeZone: 'UTC',
});
const monthYear = new Intl.DateTimeFormat('pt-BR', {
  month: 'long',
  year: 'numeric',
  timeZone: 'UTC',
});

export const weekdayOf = (date: Date): string => weekdayLong.format(date);

/** `22 ago` — compacto, para metadados. */
export const shortDateOf = (date: Date): string =>
  dayMonth.format(date).replace(/\sde\s/, ' ').replace('.', '');

export const longDateOf = (date: Date): string => fullDate.format(date);

export const monthLabelOf = (date: Date): string => monthYear.format(date);

/** `2026-08-22` — para o atributo datetime de <time>. */
export const isoDateOf = (date: Date): string => date.toISOString().slice(0, 10);

/** `2026-08-22T20:30:00-03:00` — instante completo, para <time> e schema.org. */
export const isoInstantOf = (date: Date, time: string): string =>
  `${isoDateOf(date)}T${time}:00-03:00`;

/* --- Instantes (fuso da sessão) -------------------------------------------- */

const clock = new Intl.DateTimeFormat('pt-BR', {
  hour: '2-digit',
  minute: '2-digit',
  timeZone: SESSION_TIME_ZONE,
});

export const timeOf = (instant: Date): string => clock.format(instant);

/* --- Durações e códigos ----------------------------------------------------- */

/** 118 -> "1h58" */
export function runtimeOf(minutes: number): string {
  const hours = Math.floor(minutes / 60);
  const rest = minutes % 60;
  if (hours === 0) return `${rest}min`;
  return rest === 0 ? `${hours}h` : `${hours}h${String(rest).padStart(2, '0')}`;
}

/** 118 -> "PT1H58M", exigido pelo schema.org. */
export function isoDurationOf(minutes: number): string {
  const hours = Math.floor(minutes / 60);
  const rest = minutes % 60;
  if (hours === 0 && rest === 0) return 'PT0M';
  return `PT${hours > 0 ? `${hours}H` : ''}${rest > 0 ? `${rest}M` : ''}`;
}

/** Identificador de sessão no formato de transmissão: `S-260822`. */
export function sessionCodeOf(date: Date): string {
  const yy = String(date.getUTCFullYear()).slice(2);
  const mm = String(date.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(date.getUTCDate()).padStart(2, '0');
  return `S-${yy}${mm}${dd}`;
}

export const ratingLabelOf = (rating: string): string =>
  rating === 'L' ? 'Livre' : `${rating} anos`;
