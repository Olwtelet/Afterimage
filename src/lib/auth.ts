/**
 * Sessão e permissão.
 *
 * Um único provedor: Discord. Não há login por e-mail, senha, Google ou GitHub —
 * e a ausência é deliberada, porque a identidade aqui É a do servidor.
 *
 * A regra que atravessa o arquivo: permissão nunca vem do cliente. Toda pergunta
 * de autorização é respondida no servidor, contra o banco, a cada requisição.
 */
import type { AstroCookies } from 'astro';

import { server } from './db/client';
import type { Profile } from './db/types';

/** Escopos pedidos ao Discord.
 *
 * `identify` traz avatar, username e ID. `guilds` permite conferir se a pessoa
 * está no servidor — sem ele, o selo de membro simplesmente não aparece, o que
 * é degradação aceitável. Nada além disso é pedido: escopo que não é usado é
 * escopo que não deveria ter sido pedido.
 */
export const DISCORD_SCOPES = 'identify guilds';

export interface Session {
  readonly userId: string;
  readonly profile: Profile;
  /**
   * Verificado no servidor contra a tabela `admins`, nunca contra algo que o
   * navegador tenha enviado.
   */
  readonly isAdmin: boolean;
}

/**
 * Resolve a sessão da requisição.
 *
 * Usa `getUser()`, não `getSession()`: o segundo devolve o que está no cookie
 * sem validar a assinatura no servidor de autenticação, e cookie é território do
 * cliente. A diferença é uma ida à rede em troca de a sessão ser confiável.
 */
export async function readSession(cookies: AstroCookies): Promise<Session | null> {
  const db = server(cookies);

  const {
    data: { user },
    error,
  } = await db.auth.getUser();

  if (error || !user) return null;

  const { data: profile } = await db
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle<Profile>();

  if (!profile) return null;

  // `is_admin()` roda no Postgres e consulta uma tabela que o cliente não
  // enxerga. O navegador não tem como influenciar a resposta.
  const { data: isAdmin } = await db.rpc('is_admin');

  return { userId: user.id, profile, isAdmin: isAdmin === true };
}

/**
 * Exige sessão. Devolve uma resposta de redirecionamento quando não há.
 *
 * O `next` preserva o destino para o login devolver a pessoa onde ela estava.
 */
export function requireSession(
  session: Session | null,
  url: URL,
): Response | null {
  if (session) return null;
  const next = encodeURIComponent(url.pathname + url.search);
  return new Response(null, {
    status: 302,
    headers: { Location: `/auth/entrar/?next=${next}` },
  });
}

/**
 * Exige administração.
 *
 * Responde 404, não 403: para quem não administra, o painel não existe. Um 403
 * confirmaria que há algo ali.
 */
export function requireAdmin(session: Session | null): Response | null {
  if (session?.isAdmin) return null;
  return new Response('Não encontrado', {
    status: 404,
    headers: { 'content-type': 'text/plain; charset=utf-8' },
  });
}

/** URL do avatar do Discord, com fallback para o avatar padrão da plataforma. */
export function avatarOf(profile: Pick<Profile, 'avatar_url' | 'discord_id'>): string {
  if (profile.avatar_url) return profile.avatar_url;
  const fallback = (BigInt(profile.discord_id || '0') >> 22n) % 6n;
  return `https://cdn.discordapp.com/embed/avatars/${fallback}.png`;
}
