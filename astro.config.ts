import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

import { SITE_URL } from './src/lib/site';

/**
 * O site é 100% estático. Nenhuma rota precisa de servidor: o mural, a busca e o
 * contador são ilhas que conversam direto com o Supabase a partir do navegador.
 */
export default defineConfig({
  site: SITE_URL,
  trailingSlash: 'always',

  image: {
    // `constrained` gera srcset + sizes automaticamente e sempre emite width/height,
    // que é o que elimina CLS nos pôsteres.
    layout: 'constrained',
    responsiveStyles: true,
  },

  integrations: [
    sitemap({
      filter: (page) => !page.includes('/404'),
      changefreq: 'weekly',
      lastmod: new Date(),
    }),
  ],

  build: {
    inlineStylesheets: 'auto',
  },

  vite: {
    build: {
      cssMinify: 'lightningcss',
    },
  },
});
