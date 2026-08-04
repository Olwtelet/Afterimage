/**
 * Integração com o Discord.
 *
 * REGRA QUE NÃO SE QUEBRA: nada aqui concede permissão. Avatar, banner, nickname
 * e pertencimento ao servidor são espelhados para serem EXIBIDOS. Nenhuma
 * política do banco lê essas colunas e nenhuma rota decide acesso a partir
 * delas — quem decide é `is_admin()`, contra a tabela `admins`, no Postgres.
 *
 * Vale insistir: se algo vindo do Discord liberasse recurso aqui, a segurança da
 * plataforma passaria a depender de quem administra o servidor de lá. São dois
 * sistemas com donos diferentes.
 *
 * Tudo é tolerante a falha. Sem bot configurado, sem rede, ou com o Discord fora
 * do ar, o perfil apenas fica sem o selo de membro — o login funciona igual.
 */
import type { Session } from '@supabase/supabase-js';

import {
  DISCORD_BOT_TOKEN,
  DISCORD_GUILD_ID,
  DISCORD_SESSION_WEBHOOK,
} from 'astro:env/server';

import { elevated } from './db/server';

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
  nick?: string | null;
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

  const { guild_member, nickname } = await readGuildStanding(user.id);

  const db = elevated();
  await db
    .from('profiles')
    .update({
      discord_id: user.id,
      display_name: nickname ?? user.global_name ?? user.username,
      avatar_url: avatarUrl(user),
      banner_url: bannerUrl(user),
      guild_member,
      updated_at: new Date().toISOString(),
    })
    .eq('id', session.user.id);
}

interface GuildStanding {
  guild_member: boolean;
  nickname: string | null;
}

/**
 * Consulta pertencimento ao servidor pelo bot.
 *
 * Pelo bot, e não pelo token do usuário, porque o token de usuário lista os
 * servidores dele mas não confirma a associação do ponto de vista do servidor.
 * Sem bot configurado, devolve o estado neutro e o login segue normal.
 *
 * Os CARGOS eram lidos aqui e foram removidos: nada na plataforma os exibia mais,
 * e manter a busca custaria uma segunda ida à API do Discord dentro do fluxo de
 * login para alimentar uma coluna que ninguém lê.
 */
async function readGuildStanding(discordId: string): Promise<GuildStanding> {
  const neutral: GuildStanding = { guild_member: false, nickname: null };

  if (!DISCORD_BOT_TOKEN || !DISCORD_GUILD_ID) return neutral;

  try {
    const member = (await discordFetch(
      `/guilds/${DISCORD_GUILD_ID}/members/${discordId}`,
      DISCORD_BOT_TOKEN,
      'Bot',
    )) as GuildMember | null;

    // 404 do Discord vira `null` aqui: a pessoa simplesmente não é membro.
    if (!member) return neutral;

    return { guild_member: true, nickname: member.nick ?? null };
  } catch {
    return neutral;
  }
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
