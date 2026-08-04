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
  /** Uma linha por parágrafo. Frase isolada não leva ponto final. */
  readonly lede: readonly string[];
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
  tagline: 'As ideias são à prova de balas',
  lede: [
    'Uma sessão por sábado, escolhida por alguém que assistiu',
    'Nunca pelo que fez sucesso — sempre pelo que ficou',
  ],
  description:
    'Curadoria semanal de cinema. Uma sessão por sábado, escolhida por quem assistiu, com o motivo da escolha registrado.',
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
  { label: 'Ranking', href: '/ranking/', channel: '04' },
  { label: 'Dossiê', href: '/dossie/', channel: '05' },
  { label: 'Sobre', href: '/sobre/', channel: '06' },
] as const;

/** Playlist que toca na transmissão da sidebar. */
export const RADIO_PLAYLIST_ID = '1UXKrx2Yq0VZoDrjOhoIQw';
