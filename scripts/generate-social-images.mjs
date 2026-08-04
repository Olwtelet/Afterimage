/**
 * Gera as imagens de compartilhamento a partir do mesmo vocabulário do site:
 * carta de ajuste, tipografia e a linha de identificação.
 *
 * Roda sob demanda (`npm run assets:social`), não a cada build — o resultado é
 * determinístico e fica versionado em public/.
 *
 * São três coisas:
 *
 *   public/og.png              o cartão do site
 *   public/apple-touch-icon    o ícone
 *   public/og/<slug>.png       um cartão POR SESSÃO
 *
 * O terceiro é o que mais importa na prática: quase todo link compartilhado é o
 * de uma ficha, e um cartão com o pôster daquele filme diz muito mais que a
 * marca genérica repetida catorze vezes.
 */
import { mkdir, readdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';
import YAML from 'yaml';

const PUBLIC_DIR = fileURLToPath(new URL('../public/', import.meta.url));
const OG_DIR = fileURLToPath(new URL('../public/og/', import.meta.url));
const FILMS_DIR = fileURLToPath(new URL('../src/content/films/', import.meta.url));
const POSTERS_DIR = fileURLToPath(new URL('../src/assets/films/', import.meta.url));

const BARS = ['#C0C0C0', '#C0C000', '#00C0C0', '#00C000', '#C000C0', '#C00000', '#0000C0'];
const VOID = '#050506';
const INK = '#E8E9EA';
const MUTE = '#7A8087';

const W = 1200;
const H = 630;

/** Barras verticais cobrindo uma faixa. */
const barsRect = (x, y, width, height, opacity = 1) =>
  BARS.map(
    (color, index) =>
      `<rect x="${x + (width / 7) * index}" y="${y}" width="${width / 7 + 0.5}" height="${height}" fill="${color}" opacity="${opacity}"/>`,
  ).join('');

/** `&` e `<` quebrariam o SVG; títulos de filme têm os dois. */
const esc = (text) =>
  String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

/**
 * Quebra o texto em linhas.
 *
 * SVG não quebra texto sozinho — `<text>` sai numa linha só e transborda a
 * imagem. A medida é estimada por largura média de caractere, que basta porque
 * a fonte é conhecida e o limite é generoso.
 */
function wrap(text, maxChars, maxLines) {
  const words = String(text).split(/\s+/);
  const lines = [];
  let current = '';

  for (const word of words) {
    const candidate = current ? `${current} ${word}` : word;
    if (candidate.length > maxChars && current) {
      lines.push(current);
      current = word;
      if (lines.length === maxLines) break;
    } else {
      current = candidate;
    }
  }
  if (lines.length < maxLines && current) lines.push(current);

  // Reticências quando sobrou texto de fora.
  const used = lines.join(' ').length;
  if (used < text.length - 1 && lines.length === maxLines) {
    lines[maxLines - 1] = `${lines[maxLines - 1].replace(/[\s,;:.–—-]+$/, '')}…`;
  }
  return lines;
}

/* --- Cartão do site -------------------------------------------------------- */
const siteCard = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <rect width="${W}" height="${H}" fill="${VOID}"/>

  ${barsRect(0, 0, W, H, 0.14)}

  <defs>
    <linearGradient id="veil" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="${VOID}" stop-opacity="0.97"/>
      <stop offset="0.62" stop-color="${VOID}" stop-opacity="0.86"/>
      <stop offset="1" stop-color="${VOID}" stop-opacity="0.55"/>
    </linearGradient>
  </defs>
  <rect width="${W}" height="${H}" fill="url(#veil)"/>

  ${barsRect(0, 0, W, 10)}

  <text x="72" y="150" fill="${MUTE}" font-family="monospace" font-size="20" letter-spacing="6">
    CARTA DE AJUSTE · CANAL 01
  </text>

  <text x="72" y="292" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="104" font-weight="800" letter-spacing="-3">As ideias são</text>
  <text x="72" y="392" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="104" font-weight="800" letter-spacing="-3">à prova de balas</text>

  <rect x="72" y="440" width="1056" height="1" fill="#23262A"/>

  <text x="72" y="486" fill="${MUTE}" font-family="monospace" font-size="22" letter-spacing="2">
    Curadoria semanal de cinema · Sábados, 20:30
  </text>

  <text x="72" y="562" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="26" font-weight="700" letter-spacing="4">FILMES HD ONLINE GRÁTIS</text>

  ${barsRect(0, H - 10, W, 10)}
</svg>`;

/* --- Ícone ----------------------------------------------------------------- */
const icon = `<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180" viewBox="0 0 180 180">
  <rect width="180" height="180" fill="${VOID}"/>
  ${barsRect(18, 34, 144, 96)}
  <rect x="18" y="130" width="144" height="16" fill="#0A0B0C"/>
</svg>`;

/* --- Cartão de sessão ------------------------------------------------------
   O pôster ocupa a imagem inteira, dessaturado e coberto por um véu que desce
   da esquerda — a mesma composição do slate da ficha. A barra da sessão entra
   como filete vertical junto ao texto, e as sete barras fecham topo e base.  */
function sessionOverlay({ headline, films, when, tone }) {
  const lines = wrap(headline, 30, 3);
  const size = lines.length >= 3 ? 62 : 76;
  const top = lines.length >= 3 ? 300 : 330;

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <defs>
    <linearGradient id="veil" x1="0" y1="0" x2="1" y2="0.35">
      <stop offset="0" stop-color="${VOID}" stop-opacity="0.97"/>
      <stop offset="0.55" stop-color="${VOID}" stop-opacity="0.88"/>
      <stop offset="1" stop-color="${VOID}" stop-opacity="0.42"/>
    </linearGradient>
  </defs>

  <rect width="${W}" height="${H}" fill="url(#veil)"/>

  ${barsRect(0, 0, W, 10)}

  <rect x="72" y="${top - size + 6}" width="4" height="${lines.length * (size + 12)}" fill="${tone}"/>

  <text x="100" y="150" fill="${tone}" font-family="monospace" font-size="19" letter-spacing="6">
    ${esc(when)}
  </text>

  ${lines
    .map(
      (line, index) =>
        `<text x="100" y="${top + index * (size + 12)}" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif" font-size="${size}" font-weight="800" letter-spacing="-2">${esc(line)}</text>`,
    )
    .join('\n  ')}

  <text x="100" y="${top + lines.length * (size + 12) + 34}" fill="${MUTE}"
        font-family="monospace" font-size="21" letter-spacing="2">${esc(films)}</text>

  <text x="72" y="${H - 44}" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="22" font-weight="700" letter-spacing="4">FILMES HD ONLINE GRÁTIS</text>

  ${barsRect(0, H - 10, W, 10)}
</svg>`;
}

/** A barra SMPTE mais próxima do tom curado — mesmo critério de lib/smpte.ts. */
function barFor(hex) {
  const value = hex.replace('#', '');
  const r = parseInt(value.slice(0, 2), 16) / 255;
  const g = parseInt(value.slice(2, 4), 16) / 255;
  const b = parseInt(value.slice(4, 6), 16) / 255;

  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = max - min;
  const lightness = (max + min) / 2;
  const saturation = delta === 0 ? 0 : delta / (1 - Math.abs(2 * lightness - 1));

  if (saturation < 0.18 || lightness < 0.06 || lightness > 0.94) return '#C0C0C0';

  let hue;
  if (max === r) hue = 60 * (((g - b) / delta) % 6);
  else if (max === g) hue = 60 * ((b - r) / delta + 2);
  else hue = 60 * ((r - g) / delta + 4);
  hue = (hue + 360) % 360;

  const hues = [
    [60, '#C0C000'],
    [180, '#00C0C0'],
    [120, '#00C000'],
    [300, '#C000C0'],
    [0, '#C00000'],
    [240, '#0000C0'],
  ];

  let best = '#C0C000';
  let smallest = Infinity;
  for (const [target, color] of hues) {
    const raw = Math.abs(hue - target) % 360;
    const distance = raw > 180 ? 360 - raw : raw;
    if (distance < smallest) {
      smallest = distance;
      best = color;
    }
  }
  return best;
}

const MONTHS = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

/* --- Execução -------------------------------------------------------------- */
await mkdir(PUBLIC_DIR, { recursive: true });
await mkdir(OG_DIR, { recursive: true });

await writeFile(
  new URL('og.png', `file://${PUBLIC_DIR}`),
  await sharp(Buffer.from(siteCard)).png({ compressionLevel: 9 }).toBuffer(),
);

await writeFile(
  new URL('apple-touch-icon.png', `file://${PUBLIC_DIR}`),
  await sharp(Buffer.from(icon)).png({ compressionLevel: 9 }).toBuffer(),
);

const posters = await readdir(POSTERS_DIR);
let made = 0;

for (const file of (await readdir(FILMS_DIR)).filter((name) => name.endsWith('.md'))) {
  const slug = file.replace(/\.md$/, '');
  const raw = await readFile(new URL(file, `file://${FILMS_DIR}`), 'utf8');
  const match = raw.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) continue;

  const data = YAML.parse(match[1]);
  const poster = posters.find((name) => name.startsWith(`${slug}.`));
  if (!poster) continue;

  const date = new Date(`${String(data.session?.date).slice(0, 10)}T12:00:00Z`);
  const when = `${String(date.getUTCDate()).padStart(2, '0')} ${MONTHS[date.getUTCMonth()]} ${date.getUTCFullYear()} · ${data.session?.time ?? ''}`;

  const films = (data.features ?? [])
    .map((feature) => `${feature.title} (${feature.year})`)
    .join('  +  ');

  const overlay = sessionOverlay({
    headline: data.headline ?? '',
    films,
    when: when.toUpperCase(),
    tone: barFor(data.tone ?? '#C0C0C0'),
  });

  const base = await sharp(new URL(poster, `file://${POSTERS_DIR}`).pathname.slice(1))
    .resize(W, H, { fit: 'cover', position: 'attention' })
    .modulate({ saturation: 0.45 })
    .toBuffer();

  /* JPEG, não PNG: o fundo é fotografia, e o PNG guardava cada grão do pôster
     sem ganho visível nenhum — 6,8 MB para catorze cartões, versionados. */
  await writeFile(
    new URL(`${slug}.jpg`, `file://${OG_DIR}`),
    await sharp(base)
      .composite([{ input: Buffer.from(overlay) }])
      .jpeg({ quality: 82, mozjpeg: true })
      .toBuffer(),
  );

  made += 1;
}

console.log(`Geradas: public/og.png, public/apple-touch-icon.png, ${made} cartões em public/og/`);
