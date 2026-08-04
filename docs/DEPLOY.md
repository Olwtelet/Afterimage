# Deploy na Vercel

Do repositório ao ar. Leva cerca de 15 minutos.

Faça primeiro o [`CONFIGURACAO.md`](CONFIGURACAO.md) — Discord, Supabase e
migrações precisam estar prontos, senão o build falha por falta de variável.

---

## Antes de começar

Você vai precisar destes quatro valores em mãos:

| Valor | Onde pegar |
|---|---|
| `PUBLIC_SUPABASE_URL` | Supabase → Settings → API → *Project URL* |
| `PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Supabase → Settings → API → *Publishable key* |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Settings → API → *service_role* (clique em **Reveal**) |
| `ADMIN_DISCORD_ID` | Discord → botão direito no seu nome → *Copiar ID* |

Os três opcionais do Discord (`DISCORD_BOT_TOKEN`, `DISCORD_GUILD_ID`,
`DISCORD_SESSION_WEBHOOK`) podem ficar para depois.

> **O build falha se faltar um dos quatro obrigatórios.** É de propósito: melhor
> quebrar no deploy do que descobrir em produção que a autenticação nunca
> funcionou.

---

## 1. Subir para o GitHub

```bash
git remote add origin https://github.com/SEU-USUARIO/SEU-REPO.git
git push -u origin main
```

Confira que o `.env` **não** subiu — ele está no `.gitignore`, mas vale olhar:

```bash
git ls-files | grep -c "^\.env$"
```

Precisa responder `0`. Se responder `1`, pare: a chave `service_role` estaria
pública. Remova com `git rm --cached .env`, refaça o commit, e **redefina a
chave** no painel do Supabase.

---

## 2. Importar na Vercel

Em [vercel.com/new](https://vercel.com/new), escolha *Import Git Repository* e
selecione o repositório.

A Vercel detecta o Astro sozinho. **Não altere** Framework Preset, Build Command,
Output Directory nem Install Command — o `vercel.json` do projeto já define o que
precisa ser definido.

---

## 3. Variáveis de ambiente

Ainda na tela de importação, abra **Environment Variables** e adicione as quatro.

Para cada uma, marque os três ambientes: **Production**, **Preview** e
**Development**.

```
PUBLIC_SUPABASE_URL                 https://SEU-REF.supabase.co
PUBLIC_SUPABASE_PUBLISHABLE_KEY     sb_publishable_...
SUPABASE_SERVICE_ROLE_KEY           sb_secret_...
ADMIN_DISCORD_ID                    000000000000000000
```

> As duas primeiras chegam ao navegador — é para isso que existem, e quem protege
> o banco é o RLS. As duas últimas **nunca** saem do servidor: o Astro se recusa a
> compilar se forem importadas de código de cliente.

Clique em **Deploy** e espere. O primeiro build leva de 2 a 4 minutos.

---

## 4. Fechar o círculo do login

Sem este passo o login quebra em produção, mesmo funcionando local.

Anote o domínio que a Vercel te deu — algo como
`seu-projeto.vercel.app`. Então, no Supabase:

**Authentication → URL Configuration**

- **Site URL**: `https://seu-projeto.vercel.app`
- **Redirect URLs**: adicione, com o `/**` no final:

```
https://seu-projeto.vercel.app/**
```

Mantenha também `http://localhost:4321/**` na lista, senão você perde o ambiente
de desenvolvimento.

> O `/**` não é enfeite. Sem ele o Supabase recusa o retorno com
> `requested path is invalid`.

---

## 5. Conferir

Abra o site e verifique, nesta ordem:

| Teste | Esperado |
|---|---|
| Home carrega | Carta de ajuste, próxima sessão, catálogo |
| **Entrar** no cabeçalho | Leva ao Discord e volta logado |
| Seu avatar aparece | No lugar do botão Entrar |
| Menu → **Painel** | Abre (só para você) |
| `/admin/` numa aba anônima | **404** |
| Favoritar numa ficha | Marca e aparece em `/favoritos/` |
| `/mural/` | Carrega recados, aceita envio |
| Contador de audiência | Mostra número, não traços |

Se algo falhar, **Vercel → Deployments → o deploy → Runtime Logs** mostra o erro
real. Para falhas de login, **Supabase → Logs → Auth**.

---

## Domínio próprio

**Vercel → Settings → Domains** → adicione o domínio e siga as instruções de DNS.

Depois que ele propagar, volte a **dois** lugares e troque o endereço:

1. Supabase → *URL Configuration* → Site URL e Redirect URLs
2. `src/lib/site.ts` → a constante `SITE_URL` (hoje aponta para o domínio .vercel.app)

O segundo importa mais do que parece: é dele que saem canonical, Open Graph,
sitemap e RSS. Ficar para trás significa o buscador indexando o domínio antigo.

Commite e faça deploy de novo.

---

## O que acontece a cada push

A Vercel reconstrói sozinha:

- push na `main` → **produção**
- push em outra branch ou PR → **preview**, com URL própria

Como o catálogo mora no banco, editar uma sessão pelo painel **não** exige
deploy — a mudança vale na hora. Deploy só é necessário quando muda código.

---

## Quando der errado

| Sintoma | Causa quase sempre |
|---|---|
| Build falha citando variável | Faltou uma das quatro, ou não foi marcada para *Production* |
| Login volta sem sessão | Domínio de produção fora das *Redirect URLs* |
| `requested path is invalid` | Faltou o `/**` no fim da Redirect URL |
| `Invalid OAuth2 redirect_uri` | O redirect no Discord aponta para o seu site em vez de para o Supabase |
| Painel dá 404 estando logado | Seu Discord ID não está na tabela `admins` |
| Mural e contador mudos | Migrações não aplicadas — rode `supabase/verificar.sql` |
| Imagens 404 | Falta `public/posters/` no commit |

---

## Nota sobre custo

Tudo cabe no plano gratuito das duas plataformas, e a arquitetura foi desenhada
para isso: **43 rotas são estáticas**, servidas do CDN sem invocar função nenhuma.
Apenas 10 chegam a executar no servidor — autenticação, perfis, listas pessoais,
ranking e painel.

Ou seja: quem chega pelo buscador, lê uma ficha e vai embora não consome
invocação nenhuma.
