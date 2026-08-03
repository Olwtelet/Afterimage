/**
 * Formatação de datas, durações e códigos técnicos.
 *
 * Todos os `Intl` são construídos uma vez, no módulo. Instanciar um formatador
 * dentro de um laço de renderização é caro e desnecessário.
 */

const TIME_ZONE = 'America/Sao_Paulo';

const weekdayLong = new Intl.DateTimeFormat('pt-BR', { weekday: 'long', timeZone: TIME_ZONE });
const dayMonth = new Intl.DateTimeFormat('pt-BR', {
  day: '2-digit',
  month: 'short',
  timeZone: TIME_ZONE,
});
const fullDate = new Intl.DateTimeFormat('pt-BR', {
  day: '2-digit',
  month: 'long',
  year: 'numeric',
  timeZone: TIME_ZONE,
});

export const weekdayOf = (date: Date): string => weekdayLong.format(date);

export const shortDateOf = (date: Date): string => dayMonth.format(date).replace('.', '');

export const longDateOf = (date: Date): string => fullDate.format(date);

/** `2026-07-18` — para o atributo datetime de <time>. */
export function isoDateOf(date: Date): string {
  return date.toISOString().slice(0, 10);
}

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
  return `PT${hours > 0 ? `${hours}H` : ''}${rest > 0 ? `${rest}M` : ''}` || 'PT0M';
}

/** Identificador de sessão no formato de transmissão: `S-260718`. */
export function sessionCodeOf(date: Date): string {
  const yy = String(date.getUTCFullYear()).slice(2);
  const mm = String(date.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(date.getUTCDate()).padStart(2, '0');
  return `S-${yy}${mm}${dd}`;
}

export const ratingLabelOf = (rating: string): string =>
  rating === 'L' ? 'Livre' : `${rating} anos`;
