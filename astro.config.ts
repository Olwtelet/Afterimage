import { defineConfig, envField } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import vercel from '@astrojs/vercel';

import { SITE_URL } from './src/lib/site';

/**
 * Renderização híbrida.
 *
 * O padrão continua sendo estático: as 41 rotas de conteúdo — home, catálogo,
 * grade, gêneros, fichas — são pré-renderizadas no build e servidas do CDN, sem
 * função nenhuma no caminho. Foi assim que o site chegou ao desempenho que tem,
 * e transformar tudo em SSR para acomodar login seria pagar latência em toda
 * página por causa de um recurso que a maioria das visitas não usa.
 *
 * Só entram no servidor as rotas que não têm como ser estáticas: as de
 * autenticação, as de API e as que dependem de quem está logado. Elas declaram
 * `export const prerender = false` individualmente.
 */
export default defineConfig({
  site: SITE_URL,
  trailingSlash: 'always',

  adapter: vercel({
    // O Astro já emite width/height e srcset via astro:assets no build; deixar o
    // Vercel reprocessar a mesma imagem seria pagar duas vezes pelo mesmo pixel.
    imageService: false,
  }),

  image: {
    layout: 'constrained',
    responsiveStyles: true,
  },

  /**
   * Contrato de ambiente.
   *
   * A separação entre `client`/`server` e `public`/`secret` não é organizacional:
   * o Astro se recusa a compilar se um valor marcado como segredo for importado
   * de código que roda no navegador. A regra deixa de depender de disciplina e
   * passa a ser imposta pelo build.
   *
   * O que é público aqui é público de verdade — a chave `publishable` do Supabase
   * é feita para viver no cliente, e quem impõe as regras é o RLS.
   */
  env: {
    schema: {
      PUBLIC_SUPABASE_URL: envField.string({
        context: 'client',
        access: 'public',
        url: true,
      }),
      PUBLIC_SUPABASE_PUBLISHABLE_KEY: envField.string({
        context: 'client',
        access: 'public',
        min: 20,
      }),

      /** Ignora RLS. Só existe em rotas de servidor e jamais chega ao cliente. */
      SUPABASE_SERVICE_ROLE_KEY: envField.string({
        context: 'server',
        access: 'secret',
        min: 20,
      }),

      /**
       * Discord ID numérico de quem administra. É a única fonte de verdade do
       * acesso ao painel, verificada no servidor a cada requisição. Não é uma
       * lista: administração aqui é uma pessoa.
       */
      ADMIN_DISCORD_ID: envField.string({
        context: 'server',
        access: 'secret',
        min: 15,
      }),

      /** Token do bot, para ler cargos e pertencimento ao servidor. */
      DISCORD_BOT_TOKEN: envField.string({
        context: 'server',
        access: 'secret',
        optional: true,
      }),
      DISCORD_GUILD_ID: envField.string({
        context: 'server',
        access: 'secret',
        optional: true,
      }),
      /** Webhook do canal onde as novas sessões são anunciadas. */
      DISCORD_SESSION_WEBHOOK: envField.string({
        context: 'server',
        access: 'secret',
        optional: true,
      }),
    },
  },

  integrations: [
    sitemap({
      filter: (page) => !page.includes('/404') && !page.includes('/admin'),
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
