# Configuração, do zero

Guia completo para deixar login, mural, contador e painel funcionando.
Leva cerca de 25 minutos. Faça na ordem — cada etapa depende da anterior.

Você vai precisar de três abas abertas:

- [Discord Developer Portal](https://discord.com/developers/applications)
- [Supabase](https://supabase.com/dashboard)
- [Vercel](https://vercel.com/dashboard) (só no fim)

---

## Antes de tudo: segredo é segredo

Três valores deste guia **nunca** podem ser compartilhados, nem em print, nem em
mensagem, nem commitados:

| Valor | Onde vive | Se vazar |
|---|---|---|
| Client Secret do Discord | Supabase | Alguém finge ser sua aplicação no login |
| Token do bot | `.env` e Vercel | Controle do bot no seu servidor |
| `service_role` do Supabase | `.env` e Vercel | Acesso total ao banco, ignorando RLS |

Se algum aparecer numa captura de tela, **redefina o valor** — não basta apagar a
imagem. Todos os três têm botão de reset no painel de origem.

O `.env` já está no `.gitignore`. Não tire de lá.

---

## Etapa 1 — Projeto no Supabase

Se você já usa o Supabase para o mural, **use o mesmo projeto** e pule para 1.3.

**1.1** Em [supabase.com/dashboard](https://supabase.com/dashboard), clique em
**New project**. Escolha uma senha forte para o banco (guarde no gerenciador de
senhas) e a região `South America (São Paulo)` — é a mais perto do público.

**1.2** Espere o provisionamento terminar, cerca de dois minutos.

**1.3** Vá em **Settings → API** e deixe esta aba aberta. Você vai copiar três
valores daqui:

- **Project URL** — algo como `https://abcdefgh.supabase.co`
- **Publishable key** (ou `anon public`, em projetos mais antigos)
- **Service role key** — clique em *Reveal*. É a chave que ignora todas as regras
  de segurança do banco.

**1.4** Anote o **ref do projeto**: é a parte do meio da URL. Em
`https://abcdefgh.supabase.co`, o ref é `abcdefgh`. Você usa no próximo passo.

---

## Etapa 2 — Aplicação no Discord

**2.1** Em [discord.com/developers/applications](https://discord.com/developers/applications),
clique em **New Application**. Dê o nome que vai aparecer na tela de login —
sugestão: `Filmes HD Online Grátis`.

**2.2** No menu lateral, vá em **OAuth2**.

**2.3** Em **Redirects**, clique em *Add Redirect* e cole exatamente, trocando o
ref pelo seu:

```
https://SEU-REF.supabase.co/auth/v1/callback
```

> Esta URL é a do **Supabase**, não a do seu site. É um erro comum apontar para
> `filmeshd.../auth/callback` e o login falhar sem mensagem clara. O Discord
> devolve para o Supabase, e o Supabase devolve para o seu site.

Clique em **Save Changes** no rodapé.

**2.4** Ainda em OAuth2, na seção **Client information**:

- Copie o **Client ID** (não é segredo).
- Clique em **Reset Secret** e copie o **Client Secret**. Cole direto no
  Supabase no próximo passo — se ele sumir da tela, é só resetar de novo.

---

## Etapa 3 — Ligar o Discord no Supabase

**3.1** No Supabase, vá em **Authentication → Sign In / Providers → Discord**.

**3.2** Ative o provedor e preencha:

| Campo | Valor |
|---|---|
| Client ID | o do passo 2.4 |
| Client Secret | o do passo 2.4 |
| Additional Scopes | `identify guilds` |

O escopo `guilds` é o que permite conferir se a pessoa está no seu servidor. Sem
ele o login funciona, mas o selo de membro nunca aparece.

**3.3** Salve.

**3.4** Vá em **Authentication → URL Configuration** e preencha:

- **Site URL**: `http://localhost:4321` por enquanto. Você troca pelo domínio de
  produção na etapa 7.
- **Redirect URLs**: adicione as duas linhas abaixo, uma por vez.

```
http://localhost:4321/**
https://SEU-DOMINIO.vercel.app/**
```

> Sem a entrada de `localhost`, você não consegue testar na sua máquina. Sem a de
> produção, o login quebra depois do deploy.

---

## Etapa 4 — Criar as tabelas

**4.1** No Supabase, abra **SQL Editor → New query**.

**4.2** Cole o conteúdo inteiro de `supabase/migrations/0001_audience.sql` e
clique em **Run**. Isto cria o mural e o contador de audiência.

**4.3** Nova query. Cole `supabase/migrations/0002_plataforma.sql` e rode. Isto
cria perfis, catálogo, favoritos, assistidos, avaliações, comentários e ranking.

**4.4** Nova query. Cole `supabase/verificar.sql` e rode. Devem sair 14 linhas,
todas com `ok` na primeira coluna.

Se alguma disser `FALHOU`, a migração correspondente não foi aplicada por
completo — rode de novo. As duas migrações são seguras de repetir.

---

## Etapa 5 — Se declarar administrador

O painel administrativo não confia em nada que venha do navegador. Ele confere,
no banco, se o seu Discord ID está na tabela `admins`.

**5.1** Pegue o seu Discord ID:

1. No app do Discord: **Configurações do usuário → Avançado → Modo
   desenvolvedor** (ligar).
2. Volte, clique com o botão direito no seu próprio nome em qualquer lugar e
   escolha **Copiar ID do usuário**.

É um número de 17 a 19 dígitos.

**5.2** No SQL Editor, rode trocando pelo seu ID:

```sql
insert into public.admins (discord_id, note)
values ('000000000000000000', 'Olwtelet')
on conflict (discord_id) do nothing;
```

**5.3** Confira:

```sql
select * from public.admins;
```

> Para adicionar outra pessoa depois, é este mesmo insert. Para remover,
> `delete from public.admins where discord_id = '...'`. Não precisa de deploy.

---

## Etapa 6 — Rodar na sua máquina

**6.1** Na pasta do projeto, copie o arquivo de exemplo:

```bash
cp .env.example .env
```

**6.2** Abra o `.env` e preencha com o que você copiou na etapa 1.3 e na 5.1:

```
PUBLIC_SUPABASE_URL=https://SEU-REF.supabase.co
PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
SUPABASE_SERVICE_ROLE_KEY=sb_secret_...
ADMIN_DISCORD_ID=000000000000000000
```

**6.3** Instale e rode:

```bash
npm install
npm run dev
```

**6.4** Abra `http://localhost:4321` e teste o login.

Se der erro, veja a tabela de diagnóstico no fim deste guia.

---

## Etapa 7 — Publicar na Vercel

**7.1** Suba o projeto para o GitHub, se ainda não estiver.

**7.2** Em [vercel.com/new](https://vercel.com/new), importe o repositório. O
framework é detectado sozinho (Astro) — não mexa em build command nem em output.

**7.3** Ainda na tela de import, abra **Environment Variables** e adicione as
mesmas quatro do `.env`. Marque os três ambientes (Production, Preview,
Development).

> O build **falha de propósito** se faltar alguma. É melhor quebrar no deploy do
> que descobrir em produção que o login nunca funcionou.

**7.4** Clique em **Deploy** e anote a URL final.

**7.5** Volte ao Supabase, em **Authentication → URL Configuration**, e troque o
**Site URL** pelo domínio de produção. Confirme que ele também está na lista de
**Redirect URLs** com `/**` no fim.

---

## Etapa 8 — Bot e anúncios (opcional)

Sem esta etapa tudo funciona; o perfil apenas não mostra cargos nem selo de
membro, e novas sessões não são anunciadas no servidor.

### Bot

**8.1** No Developer Portal, na sua aplicação, vá em **Bot → Add Bot**.

**8.2** Em **Privileged Gateway Intents**, ligue **Server Members Intent**.

**8.3** Clique em **Reset Token** e copie. Este é o valor mais sensível de todos.

**8.4** Vá em **OAuth2 → URL Generator**:

- Em *Scopes*, marque `bot`.
- Em *Bot Permissions*, deixe tudo desmarcado — o bot só lê.
- Copie a URL gerada, abra no navegador e adicione o bot ao seu servidor.

**8.5** Pegue o ID do servidor: botão direito no ícone do servidor → **Copiar ID
do servidor**.

### Webhook de anúncios

**8.6** No canal onde as sessões devem ser anunciadas: **Editar canal →
Integrações → Webhooks → Novo webhook**. Copie a URL.

### Preencher

**8.7** Adicione ao `.env` e às variáveis da Vercel:

```
DISCORD_BOT_TOKEN=...
DISCORD_GUILD_ID=...
DISCORD_SESSION_WEBHOOK=https://discord.com/api/webhooks/...
```

**8.8** Faça um novo deploy para a Vercel pegar as variáveis novas.

> Os cargos aparecem **apenas como informação visual**. Eles não liberam nada na
> plataforma, e isso é proposital: se liberassem, a segurança do site passaria a
> depender de quem gerencia cargos no servidor.

---

## Moderar o mural

Recados nascem com `approved = false` e não aparecem até você liberar.

Pelo painel: **Table Editor → `mural_entries`** e marque a coluna `approved`.

Por SQL:

```sql
-- ver a fila
select id, name, message, created_at
from public.mural_entries
where not approved
order by created_at desc;

-- aprovar
update public.mural_entries set approved = true where id = 'cole-o-id';
```

---

## Quando der errado

| Sintoma | Causa quase sempre |
|---|---|
| `Invalid OAuth2 redirect_uri` | O redirect do passo 2.3 aponta para o seu site em vez de para o Supabase |
| Login volta para a home sem sessão | A URL do site não está em *Redirect URLs* (etapa 3.4) |
| `requested path is invalid` | Faltou o `/**` no fim da Redirect URL |
| Build falha citando variável | Alguma das quatro obrigatórias não foi preenchida na Vercel |
| Mural mostra aviso de erro | A migração 0001 não foi aplicada |
| Contador mostra traços | Idem, ou a função `bump_audience` não foi criada |
| Painel responde 404 estando logado | Seu Discord ID não está em `public.admins` (etapa 5.2) |
| Perfil sem cargos nem selo | Bot não configurado, fora do servidor, ou sem Server Members Intent |

O painel do Supabase tem **Logs → Auth** — é o primeiro lugar para olhar quando
o login falha sem mensagem.

---

## Resumo dos valores

| Variável | Onde pegar | Segredo |
|---|---|---|
| `PUBLIC_SUPABASE_URL` | Supabase → Settings → API | não |
| `PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Supabase → Settings → API | não |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Settings → API → Reveal | **sim** |
| `ADMIN_DISCORD_ID` | Discord → botão direito no seu nome | não |
| `DISCORD_BOT_TOKEN` | Developer Portal → Bot → Reset Token | **sim** |
| `DISCORD_GUILD_ID` | Botão direito no ícone do servidor | não |
| `DISCORD_SESSION_WEBHOOK` | Canal → Integrações → Webhooks | **sim** |
