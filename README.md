## Customização

### Cores

Edite as variáveis CSS em `src/assets/css/styles.css`:

```css
:root {
  --neon-purple: #9D00FF;
  --hot-pink: #FF10F0;
  --cyber-blue: #00F0FF;
  --acid-green: #39FF14;
  /* ... mais cores */
}
```

### Informações do Site

Atualize `src/_data/site.json`:

```json
{
  "title": "Filmes HD Online Grátis",
  "description": "Sua descrição",
  "url": "https://filmeshdonlinegratis.com",
  "author": "Olwtelet"
}
```

### Navegação

Modifique `src/_data/navigation.json` pra mudar os itens do menu.

### Tipografia

O site usa Google Fonts por padrão:
- **Press Start 2P** - Títulos em pixel
- **Jersey 10** - Fonte de terminal
- Mude as fontes em `src/_includes/partials/head.njk`.

## Criando Conteúdo

### Nova Ficha de Filme

Crie um novo arquivo Markdown em `src/filmes/`:

```markdown
---
title: "Título do Filme"
date: 2026-07-17
tags: 
  - terror
  - cult
category: "sessão-especial"
featured_image: "/assets/images/nome-do-filme.jpg"
excerpt: "Descrição curta"
color_scheme: "#FF10F0"
layout: "layouts/post.njk"
---

Seu conteúdo aqui...
```

### Nova Página

Crie um arquivo Markdown (ou `.njk`) em `src/pages/`:

```markdown
---
layout: layouts/page.njk
title: "Título da Página"
permalink: /caminho-da-pagina/
---

Conteúdo da página...
```

## Easter Eggs

Tente o **Código Konami** na página inicial:  
`↑ ↑ ↓ ↓ ← → ← → B A`

Desbloqueia o modo glitch extremo!

## Deploy

### Netlify (Recomendado)

1. Suba pro GitHub
2. Conecte ao Netlify
3. Comando de build: `npm run build`
4. Diretório de publicação: `_site`

O `netlify.toml` já está configurado!

### Outras Plataformas

O site funciona em qualquer hospedagem estática:
- Vercel
- GitHub Pages
- Cloudflare Pages
- Render

## Gerenciamento de Imagens

### Consiga Imagens Estéticas

O projeto inclui um scraper de imagens customizado pra baixar imagens vaporwave/cyberpunk:

```bash
# Baixe imagens estéticas
npm run scrape-images

# Copie pro site e atualize as fichas
npm run integrate-images
npm run update-images
```

**O que ele faz:**
- Baixa imagens do Unsplash, Pexels, Pixabay
- Busca por: vaporwave, cyberpunk, glitch art, etc.
- Filtra pela sua paleta de cores (roxo, rosa, ciano)
- Salva os créditos dos fotógrafos automaticamente
- Cria uma galeria HTML pra pré-visualizar

**Pré-visualize as imagens antes de usar:**
```bash
open moodboard/gallery.html
```

### Configurando as Chaves de API

O scraper de imagens usa chaves de API gratuitas dos provedores. Pra configurar:

1. **Copie o arquivo de ambiente de exemplo:**
```bash
   cp .env.example .env
```

2. **Consiga chaves de API gratuitas em:**
   - **Pexels**: https://www.pexels.com/api/ (grátis, sem cartão de crédito)
   - **Pixabay**: https://pixabay.com/api/docs/ (grátis, sem cartão de crédito)

3. **Adicione suas chaves no `.env`:**
```bash
   PEXELS_API_KEY=sua_chave_do_pexels_aqui
   PIXABAY_API_KEY=sua_chave_do_pixabay_aqui
```

4. **Rode o scraper:**
```bash
   npm run scrape-images
```

**Nota:** O arquivo `.env` está fora do git pra manter suas chaves privadas. Nunca suba chaves de API pro git!

Veja `scripts/README.md` pra documentação detalhada.

## Desenvolvimento

### Scripts Disponíveis

- `npm run dev` - Inicia o servidor de desenvolvimento
- `npm run build` - Builda pra produção
- `npm run build:min` - Builda e minifica os assets
- `npm run debug` - Builda com saída de debug
- `npm run clean` - Remove a pasta de build
- `npm run scrape-images` - Baixa imagens estéticas
- `npm run integrate-images` - Copia imagens pro site
- `npm run update-images` - Atualiza as fichas com imagens

### Modo Watch

O servidor de dev observa mudanças em:
- Templates (.njk, .md)
- Arquivos CSS
- Arquivos JavaScript

## Performance

O site é otimizado pra velocidade:

- Geração de HTML estático
- CSS crítico inline
- Lazy loading de imagens
- Assets minificados (em produção)

Metas de pontuação no Lighthouse:
- Performance: 90+
- Acessibilidade: 100
- Boas Práticas: 90+
- SEO: 100

## Acessibilidade

Construído com acessibilidade em mente:

- HTML semântico
- Labels ARIA onde necessário
- Suporte a navegação por teclado
- Suporte a `prefers-reduced-motion`
- Contraste de cores WCAG AA
- Compatível com leitor de tela

## Créditos

### Construído Com

- **[Eleventy](https://www.11ty.dev/)** - Gerador de site estático
- **[Nunjucks](https://mozilla.github.io/nunjucks/)** - Motor de templates
- **[Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P)** & **[Jersey 10](https://fonts.google.com/specimen/Jersey+10)** - Fontes do Google
- **[Pexels](https://www.pexels.com/)** & **[Pixabay](https://pixabay.com/)** - Fotos gratuitas de banco de imagens
- **[Supabase](https://supabase.com/)** - Banco de dados do Mural

### Inspiração

- Design web do fim dos anos 90/início dos 2000 (GeoCities, Angelfire)
- Estética vaporwave e Y2K
- Barras de teste SMPTE Color Bars
- Cultura de sinal de TV fora do ar

## Apoie Este Projeto

Se esse site foi útil pra você, considere apoiar:

<div align="center">

[![Ko-fi](https://img.shields.io/badge/Ko--fi-Apoie%20o%20Olwtelet-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/Olwtelet)
[![Discord](https://img.shields.io/badge/Discord-Entre%20no%20Servidor-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/wSSJEJAJgt)

</div>

Seu apoio ajuda a:
- Manter e melhorar esse site e o servidor
- Escolher e curar mais filmes toda semana
- Manter tudo funcionando

Até uma pequena contribuição faz diferença! Obrigado!

## Licença

Todos os direitos reservados — código e conteúdo de propriedade de Olwtelet.

---

<div align="center">

**Curadoria por [Olwtelet](https://discord.gg/wSSJEJAJgt)**

*Feito com 💜, café e neon além da conta.*

[Servidor do Discord](https://discord.gg/wSSJEJAJgt) • [YouTube](https://www.youtube.com/@FilmesHDOn-lineGrátis) • [Steam](https://steamcommunity.com/groups/FilmesHDOnlineGratis)

</div>