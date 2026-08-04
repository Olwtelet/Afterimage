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

import { server } from './db/server';
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
export async function readSession(
  cookies: AstroCookies,
  headers: Headers,
): Promise<Session | null> {
  const db = server(cookies, headers);

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

/**
 * URL do avatar, com recuo para o avatar padrão do Discord.
 *
 * O Discord deriva o avatar padrão de `(snowflake >> 22) % 6`. O identificador
 * nem sempre é um snowflake — a view de ranking, por exemplo, expõe o id do
 * perfil, que é um UUID — e `BigInt()` num UUID LANÇA, derrubando a página
 * inteira por causa de uma imagem de recuo.
 *
 * Por isso os dígitos são extraídos antes: qualquer entrada produz um índice
 * estável, e nenhuma produz exceção. Uma função de fallback que quebra é uma
 * contradição.
 */
export function avatarOf(profile: {
  avatar_url: string | null;
  discord_id?: string | null;
}): string {
  if (profile.avatar_url) return profile.avatar_url;

  const digits = (profile.discord_id ?? '').replace(/\D/g, '');
  const index = digits ? Number((BigInt(digits) >> 22n) % 6n) : 0;
  return `https://cdn.discordapp.com/embed/avatars/${index}.png`;
}
