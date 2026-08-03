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

## Banco de dados

O mural e o contador falam direto com o Supabase pelo navegador, com a chave
`publishable` — que é feita para isso. **Quem impõe as regras é o RLS**, não o
JavaScript do cliente. Aplique a migração antes de esperar que funcionem:

```bash
supabase db push
```

Ou cole `supabase/migrations/0001_audience.sql` no SQL Editor do projeto. Sem
ela, o mural mostra um aviso e o contador exibe traços — nenhum dos dois quebra
a página.

Recados nascem com `approved = false`. Para publicar um, marque `approved` no
painel do Supabase.

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
