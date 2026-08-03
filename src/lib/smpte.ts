/**
 * A ponte entre o conteúdo e a identidade visual.
 *
 * Cada ficha traz um `tone` — a cor curada daquele filme, escolhida quando a
 * sessão foi programada. Este módulo decide a qual das sete barras SMPTE esse
 * tom pertence, e é essa barra que tinge a página inteira.
 *
 * O resultado é um catálogo que, lido em conjunto, remonta a carta de ajuste:
 * a identidade não é aplicada por cima do conteúdo, ela é derivada dele.
 */

export const BAR_NAMES = [
  'white',
  'yellow',
  'cyan',
  'green',
  'magenta',
  'red',
  'blue',
] as const;

export type BarName = (typeof BAR_NAMES)[number];

export interface Bar {
  readonly name: BarName;
  /** Posição na carta de ajuste, da esquerda para a direita (1–7). */
  readonly index: number;
  /** SMPTE a 75% de amplitude. Para gráfico — não usar em texto. */
  readonly bar: string;
  /** Variante elevada, ≥4.5:1 sobre o fundo da página. Para texto. */
  readonly ink: string;
  /** Matiz de referência em graus. `null` para a barra branca (acromática). */
  readonly hue: number | null;
  readonly label: string;
}

export const BARS: Readonly<Record<BarName, Bar>> = {
  white: { name: 'white', index: 1, bar: '#C0C0C0', ink: '#E8E9EA', hue: null, label: 'Branco' },
  yellow: { name: 'yellow', index: 2, bar: '#C0C000', ink: '#D6D63B', hue: 60, label: 'Amarelo' },
  cyan: { name: 'cyan', index: 3, bar: '#00C0C0', ink: '#3BD6D6', hue: 180, label: 'Ciano' },
  green: { name: 'green', index: 4, bar: '#00C000', ink: '#45D145', hue: 120, label: 'Verde' },
  magenta: { name: 'magenta', index: 5, bar: '#C000C0', ink: '#E85AE8', hue: 300, label: 'Magenta' },
  red: { name: 'red', index: 6, bar: '#C00000', ink: '#F0564B', hue: 0, label: 'Vermelho' },
  blue: { name: 'blue', index: 7, bar: '#0000C0', ink: '#6E8CFF', hue: 240, label: 'Azul' },
} as const;

export const BAR_ORDER: readonly Bar[] = BAR_NAMES.map((name) => BARS[name]);

interface Hsl {
  readonly hue: number;
  readonly saturation: number;
  readonly lightness: number;
}

function hexToHsl(hex: string): Hsl {
  const value = hex.replace('#', '');
  const r = Number.parseInt(value.slice(0, 2), 16) / 255;
  const g = Number.parseInt(value.slice(2, 4), 16) / 255;
  const b = Number.parseInt(value.slice(4, 6), 16) / 255;

  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = max - min;
  const lightness = (max + min) / 2;

  if (delta === 0) return { hue: 0, saturation: 0, lightness };

  const saturation = delta / (1 - Math.abs(2 * lightness - 1));

  let hue: number;
  if (max === r) hue = 60 * (((g - b) / delta) % 6);
  else if (max === g) hue = 60 * ((b - r) / delta + 2);
  else hue = 60 * ((r - g) / delta + 4);

  return { hue: (hue + 360) % 360, saturation, lightness };
}

/** Menor distância angular entre dois matizes, em graus (0–180). */
function hueDistance(a: number, b: number): number {
  const raw = Math.abs(a - b) % 360;
  return raw > 180 ? 360 - raw : raw;
}

/**
 * Mapeia uma cor curada para a barra SMPTE correspondente.
 *
 * Tons de baixa saturação (cinzas, sépias, tons de filme dessaturado) caem na
 * barra branca, que é exatamente o que ela representa na carta de ajuste real:
 * ausência de dominante de cor.
 */
export function barFor(tone: string): Bar {
  const { hue, saturation, lightness } = hexToHsl(tone);

  if (saturation < 0.18 || lightness < 0.06 || lightness > 0.94) return BARS.white;

  let closest: Bar = BARS.yellow;
  let smallest = Number.POSITIVE_INFINITY;

  for (const bar of BAR_ORDER) {
    if (bar.hue === null) continue;
    const distance = hueDistance(hue, bar.hue);
    if (distance < smallest) {
      smallest = distance;
      closest = bar;
    }
  }

  return closest;
}

/**
 * Variáveis de acento para injetar no elemento raiz de uma página ou card.
 * Todo componente lê `--accent-bar` / `--accent-ink`, então tingir um bloco
 * inteiro custa um atributo `style`.
 */
export function accentStyle(bar: Bar): string {
  return `--accent-bar:${bar.bar};--accent-ink:${bar.ink}`;
}
