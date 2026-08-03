/**
 * Gera as imagens estáticas de marca a partir do mesmo vocabulário do site:
 * carta de ajuste, tipografia e a linha de identificação.
 *
 * Roda sob demanda (`npm run assets:social`), não a cada build — o resultado é
 * determinístico e fica versionado em public/.
 */
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

const PUBLIC_DIR = fileURLToPath(new URL('../public/', import.meta.url));

const BARS = ['#C0C0C0', '#C0C000', '#00C0C0', '#00C000', '#C000C0', '#C00000', '#0000C0'];
const VOID = '#050506';
const INK = '#E8E9EA';
const MUTE = '#7A8087';

/** Barras verticais cobrindo uma faixa. */
const barsRect = (x, y, width, height, opacity = 1) =>
  BARS.map(
    (color, index) =>
      `<rect x="${x + (width / 7) * index}" y="${y}" width="${width / 7 + 0.5}" height="${height}" fill="${color}" opacity="${opacity}"/>`,
  ).join('');

/* --- Open Graph 1200×630 --------------------------------------------------- */
const og = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <rect width="1200" height="630" fill="${VOID}"/>

  ${barsRect(0, 0, 1200, 630, 0.14)}

  <rect width="1200" height="630" fill="url(#veil)"/>
  <defs>
    <linearGradient id="veil" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="${VOID}" stop-opacity="0.97"/>
      <stop offset="0.62" stop-color="${VOID}" stop-opacity="0.86"/>
      <stop offset="1" stop-color="${VOID}" stop-opacity="0.55"/>
    </linearGradient>
  </defs>

  ${barsRect(0, 0, 1200, 8)}

  <text x="72" y="150" fill="${MUTE}" font-family="monospace" font-size="20" letter-spacing="6">
    CARTA DE AJUSTE · CANAL 01
  </text>

  <text x="72" y="292" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="104" font-weight="800" letter-spacing="-3">
    As ideias são
  </text>
  <text x="72" y="392" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="104" font-weight="800" letter-spacing="-3">
    à prova de balas.
  </text>

  <rect x="72" y="440" width="1056" height="1" fill="#23262A"/>

  <text x="72" y="486" fill="${MUTE}" font-family="monospace" font-size="22" letter-spacing="2">
    Curadoria semanal de cinema · Sábados, 20:30
  </text>

  <text x="72" y="562" fill="${INK}" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="26" font-weight="700" letter-spacing="4">
    FILMES HD ONLINE GRÁTIS
  </text>

  ${barsRect(0, 622, 1200, 8)}
</svg>`;

/* --- Apple touch icon 180×180 ---------------------------------------------- */
const icon = `<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180" viewBox="0 0 180 180">
  <rect width="180" height="180" fill="${VOID}"/>
  ${barsRect(18, 34, 144, 96)}
  <rect x="18" y="130" width="144" height="16" fill="#0A0B0C"/>
</svg>`;

await mkdir(PUBLIC_DIR, { recursive: true });

await writeFile(
  new URL('og.png', `file://${PUBLIC_DIR}`),
  await sharp(Buffer.from(og)).png({ compressionLevel: 9 }).toBuffer(),
);

await writeFile(
  new URL('apple-touch-icon.png', `file://${PUBLIC_DIR}`),
  await sharp(Buffer.from(icon)).png({ compressionLevel: 9 }).toBuffer(),
);

console.log('Geradas: public/og.png, public/apple-touch-icon.png');
