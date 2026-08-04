/**
 * Integração com o Discord.
 *
 * REGRA QUE NÃO SE QUEBRA: nada aqui concede permissão. Cargos, pertencimento ao
 * servidor e nickname são espelhados para serem EXIBIDOS. Nenhuma política do
 * banco lê essas colunas, e nenhuma rota decide acesso a partir delas — quem
 * decide é `is_admin()`, contra a tabela `admins`, no Postgres.
 *
 * Isso é intencional e vale insistir: se um cargo do Discord liberasse recurso
 * aqui, a segurança da plataforma passaria a depender de quem tem permissão de
 * gerenciar cargos lá. São dois sistemas com donos diferentes.
 *
 * Tudo é tolerante a falha. Sem bot configurado, sem rede, ou com o Discord
 * fora do ar, o perfil apenas fica sem o selo de membro e sem cargos.
 */
import type { Session } from '@supabase/supabase-js';

import {
  DISCORD_BOT_TOKEN,
  DISCORD_GUILD_ID,
  DISCORD_SESSION_WEBHOOK,
} from 'astro:env/server';

import { elevated } from './db/server';
import type { DiscordRole } from './db/types';

const API = 'https://discord.com/api/v10';
const CDN = 'https://cdn.discordapp.com';

/** Abandona a chamada em vez de segurar o login esperando o Discord. */
const TIMEOUT_MS = 4000;

async function discordFetch(path: string, token: string, kind: 'Bot' | 'Bearer') {
  const response = await fetch(`${API}${path}`, {
    headers: { Authorization: `${kind} ${token}` },
    signal: AbortSignal.timeout(TIMEOUT_MS),
  });
  return response.ok ? response.json() : null;
}

interface DiscordUser {
  id: string;
  username: string;
  global_name?: string | null;
  avatar?: string | null;
  banner?: string | null;
}

interface GuildMember {
  roles?: string[];
  nick?: string | null;
}

interface GuildRole {
  id: string;
  name: string;
  color: number;
  position: number;
}

const avatarUrl = (user: DiscordUser): string | null =>
  user.avatar
    ? `${CDN}/avatars/${user.id}/${user.avatar}.${user.avatar.startsWith('a_') ? 'gif' : 'png'}?size=256`
    : null;

const bannerUrl = (user: DiscordUser): string | null =>
  user.banner
    ? `${CDN}/banners/${user.id}/${user.banner}.${user.banner.startsWith('a_') ? 'gif' : 'png'}?size=1024`
    : null;

/**
 * Espelha no perfil o que o Discord informa.
 *
 * Usa o cliente elevado porque escreve colunas que o próprio dono do perfil não
 * pode alterar — é justamente o gatilho `protect_profile_columns` que impede
 * alguém de se declarar membro ou de reescrever o próprio `discord_id`.
 */
export async function syncDiscordProfile(session: Session): Promise<void> {
  const token = session.provider_token;
  if (!token) return;

  const user = (await discordFetch('/users/@me', token, 'Bearer')) as DiscordUser | null;
  if (!user) return;

  const { guild_member, guild_roles, nickname } = await readGuildStanding(user.id);

  const db = elevated();
  await db
    .from('profiles')
    .update({
      discord_id: user.id,
      display_name: nickname ?? user.global_name ?? user.username,
      avatar_url: avatarUrl(user),
      banner_url: bannerUrl(user),
      guild_member,
      guild_roles,
      updated_at: new Date().toISOString(),
    })
    .eq('id', session.user.id);
}

interface GuildStanding {
  guild_member: boolean;
  guild_roles: DiscordRole[];
  nickname: string | null;
}

/**
 * Consulta pertencimento e cargos pelo bot.
 *
 * Pelo bot, e não pelo token do usuário, porque o token de usuário só lista
 * servidores — para saber os CARGOS de alguém é preciso alguém dentro do
 * servidor perguntando. Sem bot configurado, devolve o estado neutro.
 */
async function readGuildStanding(discordId: string): Promise<GuildStanding> {
  const neutral: GuildStanding = { guild_member: false, guild_roles: [], nickname: null };

  if (!DISCORD_BOT_TOKEN || !DISCORD_GUILD_ID) return neutral;

  try {
    const member = (await discordFetch(
      `/guilds/${DISCORD_GUILD_ID}/members/${discordId}`,
      DISCORD_BOT_TOKEN,
      'Bot',
    )) as GuildMember | null;

    // 404 do Discord vira `null` aqui: a pessoa simplesmente não é membro.
    if (!member) return neutral;

    const all = (await discordFetch(
      `/guilds/${DISCORD_GUILD_ID}/roles`,
      DISCORD_BOT_TOKEN,
      'Bot',
    )) as GuildRole[] | null;

    const owned = new Set(member.roles ?? []);
    const roles = (all ?? [])
      .filter((role) => owned.has(role.id) && role.name !== '@everyone')
      // Ordem hierárquica do servidor, para o cargo principal vir primeiro.
      .sort((a, b) => b.position - a.position)
      .map(({ id, name, color }) => ({ id, name, color }));

    return { guild_member: true, guild_roles: roles, nickname: member.nick ?? null };
  } catch {
    return neutral;
  }
}

/** `#5865F2` a partir do inteiro que o Discord devolve. Cinza quando não há cor. */
export function roleColor(color: number): string {
  return color === 0 ? '#868C93' : `#${color.toString(16).padStart(6, '0')}`;
}

/**
 * Anuncia uma sessão no canal do servidor.
 *
 * Webhook em vez do bot: é um POST sem estado, não exige manter o bot online e
 * o escopo do segredo fica limitado a um único canal.
 */
export async function announceSession(payload: {
  headline: string;
  summary: string;
  url: string;
  when: string | null;
  posterUrl: string | null;
  tone: string;
}): Promise<boolean> {
  if (!DISCORD_SESSION_WEBHOOK) return false;

  const embed = {
    title: payload.headline,
    description: payload.summary,
    url: payload.url,
    color: Number.parseInt(payload.tone.replace('#', ''), 16),
    image: payload.posterUrl ? { url: payload.posterUrl } : undefined,
    fields: payload.when ? [{ name: 'Quando', value: payload.when, inline: true }] : undefined,
    footer: { text: 'Filmes HD Online Grátis · carta de ajuste' },
  };

  try {
    const response = await fetch(DISCORD_SESSION_WEBHOOK, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ embeds: [embed] }),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
    return response.ok;
  } catch {
    return false;
  }
}
