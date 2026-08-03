/**
 * Fonte única de verdade sobre a identidade do site.
 *
 * Antes esses dados viviam espalhados em site.json, seo.js, organization.js e
 * social.js — que discordavam entre si sobre descrição, imagem de OG e handle do
 * Twitter. Agora existe um arquivo só, tipado, e o compilador reclama se algo faltar.
 */

export const SITE_URL = 'https://filmeshdonlinegratis.netlify.app';

export interface SocialLinks {
  readonly discord: string;
  readonly youtube: string;
  readonly steam: string;
  readonly github: string;
}

export interface SiteIdentity {
  readonly name: string;
  readonly shortName: string;
  readonly tagline: string;
  readonly description: string;
  readonly url: string;
  readonly locale: string;
  readonly lang: string;
  readonly author: string;
  readonly email: string;
  readonly ogImage: string;
  readonly social: SocialLinks;
}

export const SITE: SiteIdentity = {
  name: 'Filmes HD Online Grátis',
  shortName: 'FHDOG',
  tagline: 'As ideias são à prova de balas.',
  description:
    'Curadoria semanal de cinema. Um catálogo escolhido a dedo, com sessões de sábado de obras selecionadas não pelo sucesso, mas pela marca que deixam.',
  url: SITE_URL,
  locale: 'pt_BR',
  lang: 'pt-BR',
  author: 'Olwtelet',
  email: 'filmeshdonlinegratisbr@gmail.com',
  ogImage: '/og.png',
  social: {
    discord: 'https://discord.gg/wSSJEJAJgt',
    youtube: 'https://www.youtube.com/@FilmesHDOn-lineGrátis',
    steam: 'https://steamcommunity.com/groups/FilmesHDOnlineGratis',
    github: 'https://github.com/Olwtelet',
  },
} as const;

export interface NavItem {
  readonly label: string;
  readonly href: string;
  /** Rótulo técnico curto, exibido em mono ao lado do item. */
  readonly channel: string;
}

export const NAVIGATION: readonly NavItem[] = [
  { label: 'Início', href: '/', channel: '01' },
  { label: 'Programação', href: '/programacao/', channel: '02' },
  { label: 'Mural', href: '/mural/', channel: '03' },
  { label: 'Sobre', href: '/sobre/', channel: '04' },
] as const;

/**
 * Serviço de dados compartilhados (mural e contador de audiência).
 * A chave é `publishable` — feita para viver no cliente. As regras de escrita e o
 * gate de moderação são impostos por RLS no banco, nunca por este arquivo.
 */
export const SUPABASE = {
  url: 'https://ltdmndehucnjnhdohvrz.supabase.co',
  publishableKey: 'sb_publishable_iVf5jl7Zzvaj_-ijfv6_PQ_q58Wzy4r',
  muralTable: 'mural_entries',
} as const;

/** Playlist que toca na transmissão da sidebar. */
export const RADIO_PLAYLIST_ID = '1UXKrx2Yq0VZoDrjOhoIQw';
