# Filmes HD Online Grátis

Site de curadoria de cinema. Uma sessão por sábado, escolhida a dedo, com o
motivo da escolha registrado. O site é o arquivo público dessas escolhas — a
exibição em si acontece ao vivo, na sala do Discord.

**Não é streaming.** O site não hospeda nem distribui nenhum filme.

---

## O conceito: carta de ajuste

A identidade vem das barras de teste SMPTE — o padrão que a televisão exibia
quando não havia programa no ar. Ele não é usado como enfeite retrô; é a
gramática do projeto:

- **As sete barras são a grade.** `--bars: 7` ancora o layout.
- **Os cinzas vêm do PLUGE**, a faixa de calibração abaixo das barras, que marca
  os pretos contra os quais tudo mais é medido. Toda superfície escura do site
  sai dali, o que dá aos cinzas uma origem concreta em vez de uma escolha
  arbitrária.
- **Cada filme recebe uma barra.** O campo `tone` de cada ficha — a cor curada
  daquela sessão — é mapeado para a barra SMPTE de matiz mais próximo
  (`src/lib/smpte.ts`). A página inteira é tingida por ela. Lido de uma vez, o
  catálogo remonta a carta.

### Cada barra tem duas formas

```
--bar-*   SMPTE literal a 75%.  Para gráfico. Nunca em texto.
--ink-*   A mesma cor elevada.  Para texto: ≥4.5:1 sobre o fundo.
```

A separação não é preciosismo: azul e vermelho a 75% rendem **1.7:1** e
**3.1:1** sobre preto. Mantê-los em duas formas é o que permite usar o padrão
literal sem sacrificar contraste em lugar nenhum.

---

## Rodando

```bash
npm install
npm run dev
```

| Comando | O que faz |
| --- | --- |
| `npm run dev` | Servidor de desenvolvimento |
| `npm run build` | Build de produção em `dist/` |
| `npm run preview` | Serve o build local |
| `npm run check` | Diagnóstico do Astro + TypeScript |
| `npm run verify` | `check` + `build` — rode antes de abrir PR |
| `npm run assets:social` | Regera `og.png` e `apple-touch-icon.png` |

---

## Publicando uma sessão

Crie um `.md` em `src/content/films/`. O schema é validado no build
(`src/content.config.ts`), então um campo faltando ou malformado quebra o build
em vez de virar uma página torta.

```yaml
---
headline: "A manchete editorial — a provocação, não o nome do filme"
kicker: "Frase de fecho da ficha"            # opcional
summary: "Resumo curto, até 300 caracteres."
poster: "../../assets/films/nome-do-arquivo.jpg"
posterAlt: "Descrição da imagem"
tone: "#556B2F"                              # define a barra SMPTE da sessão
session:
  date: 2026-07-18                           # data de calendário, autoritativa
  time: "20:30"                              # horário de Brasília
  room: "Sala 24"
  roomUrl: "https://discord.gg/..."
features:
  - title: "Nome real do filme"
    year: 2025
    director: "Direção"
    runtime: 118                             # minutos
    rating: "18"                             # L | 10 | 12 | 14 | 16 | 18
    genres: ["Suspense", "Ficção Científica"]
tags: ["suspense", "perturbador"]
---

O texto editorial, em Markdown.
```

Sessão dupla: acrescente uma segunda entrada em `features`, cada uma com seu
`time`.

Nada mais precisa ser tocado. Data, duração, classificação, contagem regressiva,
posição na grade, gêneros, busca, feed e JSON-LD saem daí.

### Duas noções de tempo

`session.date` é uma **data de calendário** e é formatada em UTC. `startsAt` é um
**instante**, montado a partir dela mais o horário de Brasília, e é formatado no
fuso da sessão. Confundir as duas desloca tudo em um dia — está documentado em
`src/lib/format.ts`.

---

## Arquitetura

```
src/
  content/films/     fichas em Markdown, validadas por zod
  content.config.ts  o schema
  lib/
    site.ts          identidade do site — fonte única de verdade
    smpte.ts         as sete barras e o mapeamento tom -> barra
    catalog.ts       sessões, estados, próxima sessão, gêneros
    format.ts        datas, durações, códigos
    slug.ts          slugs com acento transliterado
  components/
    signal/          carta de ajuste, faixa de sinal, textura
    ui/              cabeçalho, rodapé, cards, slates
    islands/         o pouco que precisa de JavaScript
  layouts/Base.astro
  pages/
  styles/            tokens, reset, base, componentes
supabase/migrations/ RLS do mural e função da audiência
```

### Camadas de CSS

`@layer reset, tokens, base, components, utilities` é declarado uma vez, em
`styles/global.css`. A partir daí a especificidade deixa de ser uma corrida:
componente sempre vence base, utilitário sempre vence componente,
independentemente de quantos seletores cada regra tenha.

### JavaScript

Zero por padrão. As ilhas são cinco — busca, mural, transmissão, audiência,
calibração — e somam **~5 KB embutidos** na home, sem nenhum bundle externo.
A transição entre páginas usa `@view-transition` nativo do CSS; o progresso de
leitura usa `animation-timeline: scroll()`. Nenhum dos dois custa um byte de JS.

---

## A plataforma

Entrar é só pelo Discord. Não há login por e-mail, senha, Google ou GitHub, e a
ausência é deliberada — a identidade aqui é a do servidor.

| Rota | O que é |
|---|---|
|  | Perfil público: participação, favoritos, assistidos, anotações |
|  ·  | Suas listas, com busca, filtro e ordenação |
|  | Participação da comunidade |
|  | Monta uma classificação e exporta em PNG |
|  | Painel do catálogo — responde 404 para quem não administra |

### Duas regras que atravessam tudo

**Permissão nunca vem do cliente.** Toda pergunta de autorização é respondida no
servidor, contra o banco, a cada requisição. O painel confere na rota E a escrita
usa o cliente de sessão, então o RLS pergunta de novo no Postgres — um furo na
primeira não vira gravação.

**O ranking não vale nada além dele mesmo.** A pontuação é uma view derivada que
não aparece em nenhuma política de acesso. Conta nova e primeiro lugar têm os
mesmos direitos, por construção e não por promessa.

### Peso

O SDK do Supabase tem 217 kB e só é carregado quando existe cookie de sessão.
Quem chega deslogado — a maioria, e quem vem do buscador — não paga por ele:
nenhuma das 43 rotas passa de 13 kB de JavaScript. As leituras públicas de
comentários vão por  direto no PostgREST.

---

## Banco de dados

> **Primeira vez?** [`docs/CONFIGURACAO.md`](docs/CONFIGURACAO.md) leva do zero
> ao ar: Discord, Supabase, migrações, administrador e deploy na Vercel.

O mural, o contador e a plataforma falam com o Supabase pelo navegador, com a
chave `publishable` — que é feita para isso. **Quem impõe as regras é o RLS**,
não o JavaScript do cliente.

### Colocar no ar

**1. Conferir o projeto.** `src/lib/site.ts` aponta para o Supabase herdado da
versão anterior do site. Se o projeto for outro, troque `url` e
`publishableKey` (painel → *Settings* → *API*) antes de seguir.

**2. Aplicar a migração.** No SQL Editor do projeto, cole
`supabase/migrations/0001_audience.sql` e execute. Com a CLI configurada,
`supabase db push` faz o mesmo.

A migração é segura de rodar mais de uma vez, e reconcilia a tabela que a versão
anterior do site pode ter deixado no mesmo projeto: `create table if not exists`
pularia a tabela inteira, então há um bloco que garante os defaults e as
constraints mesmo quando ela já existe.

**3. Verificar.** Cole `supabase/verificar.sql` no SQL Editor. São 14 checagens,
cada uma respondendo `ok` ou `FALHOU` — cobrem existência, defaults, RLS e, o
que mais importa, a ausência de policy de `UPDATE`/`DELETE` para o cliente.

Sem a migração nada quebra: o mural mostra um aviso e o contador exibe traços.

### Moderar

Recados nascem com `approved = false` e não aparecem no site até serem
liberados. A fila e o comando de aprovação estão comentados no fim de
`supabase/verificar.sql`; pelo painel, basta marcar a coluna `approved` em
*Table Editor* → `mural_entries`.

O cliente não tem policy de `UPDATE` nem de `DELETE`: aprovar é uma ação que só
existe com acesso ao painel ou à `service_role`.

---

## Acessibilidade

- Anel de foco global em `:focus-visible`, na cor de acento da página.
- Um `<h1>` por página, sem salto de nível de heading — verificado nas 41 rotas.
- Toda imagem sai com `width`/`height`.
- `prefers-reduced-motion` desligado na raiz, não regra a regra.
- Menus e diálogos em `<dialog>`: gestão de foco, `Esc` e inércia do fundo pela
  plataforma.
- Contraste conferido nos elementos renderizados; o mais apertado é a etiqueta
  técnica de 9px, com 5.26:1.

---

## Deploy

Netlify, configurado em `netlify.toml`: CSP, `Permissions-Policy`, cache
imutável apenas para assets com hash, e os 301 que preservam as rotas do site
anterior. Funciona igual em Vercel, Cloudflare Pages ou qualquer host estático —
basta publicar `dist/`.

---

## Comunidade

[Discord](https://discord.gg/wSSJEJAJgt) ·
[YouTube](https://www.youtube.com/@FilmesHDOn-lineGrátis) ·
[Steam](https://steamcommunity.com/groups/FilmesHDOnlineGratis)

Curadoria por **Olwtelet**. Código e conteúdo de propriedade do autor.
