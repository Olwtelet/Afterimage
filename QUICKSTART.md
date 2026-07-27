# Filmes HD Online Grátis - Guia de Início Rápido

Bem-vindo ao seu site de curadoria de cinema! 📼

## Comece em 3 Comandos

```bash
# Já feito: npm install

# Inicie o servidor de desenvolvimento
npm run dev

# Builde pra produção
npm run build
```

## O que Você Tem

✅ **Site completo** com estética Y2K/SMPTE Color Bars
✅ **Fichas de filme de exemplo** mostrando diferentes formatos
✅ **Recursos interativos** — rastro do cursor, busca, contador de estatísticas real
✅ **Mural compartilhado** — recados de verdade entre visitantes, com moderação
✅ **Easter egg** — Tente o Código Konami (↑ ↑ ↓ ↓ ← → ← → B A) na página inicial
✅ **Pronto pra produção** — SEO, feed RSS, sitemap

## Visão Geral da Estrutura de Arquivos
filmes-hd-online-gratis/
├── src/
│   ├── _includes/        # Templates & componentes
│   ├── _data/            # Configuração do site
│   ├── assets/           # CSS & JavaScript
│   ├── filmes/           # Fichas de filme (Markdown)
│   └── pages/            # Páginas estáticas
├── _site/                # Site gerado (depois do build)
└── .eleventy.js          # Configuração do Eleventy

## Customização Rápida

### 1. Atualize as Informações do Site
Edite `src/_data/site.json`:
- Mude título, descrição, autor
- Atualize os links das redes sociais

### 2. Mude as Cores
Edite as variáveis CSS em `src/assets/css/styles.css`:
```css
:root {
  --neon-purple: #9D00FF;
  --hot-pink: #FF10F0;
  --cyber-blue: #00F0FF;
  /* ... */
}
```

### 3. Adicione Novas Fichas de Filme
Crie um novo arquivo `.md` em `src/filmes/`:
```markdown
---
title: "Título do Filme"
date: 2026-07-17
tags: [terror, cult]
category: "sessão-especial"
featured_image: "/assets/images/nome-do-filme.jpg"
excerpt: "Descrição curta"
layout: "layouts/post.njk"
---

Seu conteúdo aqui...
```

### 4. Modifique a Navegação
Edite `src/_data/navigation.json`

## Desenvolvimento

```bash
# Inicia o servidor de dev (com live reload)
npm run dev
# Visite http://localhost:8080

# Builda pra produção
npm run build

# Debuga problemas de build
npm run debug
```

## Faça o Deploy no Netlify

1. Suba pro GitHub
2. Vá em [Netlify](https://netlify.com)
3. Clique em "New site from Git"
4. Selecione seu repositório
5. As configurações já estão prontas no `netlify.toml`!

Comando de build: `npm run build`  
Diretório de publicação: `_site`

## Recursos pra Testar

- **Busca** — Digite na barra de busca da página inicial
- **Rastro do Cursor** — Mova o mouse (só desktop)
- **Código Konami** — Digite o código na página inicial
- **Contador de Estatísticas** — Visualizações reais, compartilhadas entre todos os visitantes
- **Mural** — Deixe um recado (entra em fila de moderação antes de aparecer)
- **Efeitos Glitch** — Passe o mouse sobre cards e títulos
- **Responsivo** — Fica ótimo no celular

## Próximos Passos

1. **Customize o design** — Edite cores, fontes, efeitos
2. **Escreva seu conteúdo** — Adicione fichas em `src/filmes/`
3. **Adicione imagens** — Coloque em `src/assets/images/`
4. **Faça o deploy** — Suba pro GitHub e conecte ao Netlify

## Precisa de Ajuda?

Confira o `README.md` completo pra documentação detalhada!

---

**Curadoria por Olwtelet**  
*Aproveite sua experiência digital retrô!*