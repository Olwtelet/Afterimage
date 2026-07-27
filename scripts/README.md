# Scripts do Filmes HD Online Grátis

Scripts auxiliares pra gerenciar o site.

## 📸 Scripts de Gerenciamento de Imagens

Esses scripts ajudam a encontrar e integrar imagens estéticas no site.

### 1. `image-scraper.py`

Baixa imagens estéticas de múltiplas fontes (Unsplash, Pexels, Pixabay).

**Uso:**
```bash
python3 scripts/image-scraper.py
```

**Recursos:**
- 🎨 Busca por vaporwave, cyberpunk, glitch art, etc.
- 🌈 Filtra pela paleta de cores (roxo, rosa, ciano)
- 📝 Salva créditos dos fotógrafos automaticamente
- 🖼️ Cria uma galeria HTML pra pré-visualizar as imagens
- ⚡ Funciona com ou sem chaves de API

**Chaves de API (necessárias pra Pexels/Pixabay):**

1. **Copie `.env.example` pra `.env`:**
```bash
   cp .env.example .env
```

2. **Consiga chaves de API gratuitas:**
   - Pexels: https://www.pexels.com/api/
   - Pixabay: https://pixabay.com/api/docs/
   - Unsplash: https://unsplash.com/developers (opcional)

3. **Adicione suas chaves no `.env`:**
PEXELS_API_KEY=sua_chave_aqui
PIXABAY_API_KEY=sua_chave_aqui

**Importante:** Nunca suba seu arquivo `.env` pro git! Ele já está no `.gitignore`.

### 2. `image-integration.sh`

Roda o scraper e copia as imagens pro site.

**Uso:**
```bash
./scripts/image-integration.sh
```

Isso vai:
1. Rodar o scraper de imagens
2. Copiar as imagens pra `src/assets/images/`
3. Copiar os créditos pra `src/assets/images/image-credits.txt`

### 3. `update-post-images.py`

Atualiza as fichas de filme pra usar as imagens baixadas localmente.

**Uso:**
```bash
python3 scripts/update-post-images.py
```

Isso vai:
1. Encontrar todas as imagens em `src/assets/images/`
2. Atribuir imagens aleatoriamente às fichas de filme
3. Atualizar o campo `featured_image` em cada ficha

### 4. `generate-sitemap.js`

Gera o sitemap automaticamente depois do build (roda via `npm run build`).

## 🚀 Fluxo de Trabalho Rápido

### Conseguir Imagens pro Site

```bash
# Passo 1: Baixar imagens
python3 scripts/image-scraper.py

# Passo 2: Copiar pro site e atualizar as fichas
./scripts/image-integration.sh
python3 scripts/update-post-images.py

# Passo 3: Pré-visualizar
npm run dev
```

### Ver as Imagens Baixadas Antes de Usar

```bash
# Depois de rodar o scraper, abra a galeria:
open moodboard/gallery.html
```

## 📁 Estrutura de Diretórios
scripts/
├── image-scraper.py            # Scraper de imagens
├── update-post-images.py       # Atualizador de fichas
├── image-integration.sh        # Script de integração
├── generate-sitemap.js         # Gerador de sitemap
└── README.md                   # Este arquivo
moodboard/                      # Imagens baixadas (fora do git)
├── *.jpg                       # Imagens
├── credits.txt                 # Créditos dos fotógrafos
└── gallery.html                # Galeria de pré-visualização
src/assets/images/               # Imagens do site
├── *.jpg                       # Imagens integradas
└── image-credits.txt          # Créditos

## 🎨 Customizando o Scraper

Edite os termos de busca em `image-scraper.py`:

```python
self.search_terms = [
    "vaporwave",
    "cyberpunk neon",
    "sua busca customizada",
    # Adicione mais...
]
```

## 📝 Créditos das Imagens

Sempre dê os créditos! O scraper automaticamente:
- Salva os nomes dos fotógrafos
- Registra as URLs de origem
- Cria um arquivo credits.txt

Inclua os créditos no rodapé do site ou na página Sobre.

## 🔒 Chaves de API

O scraper funciona sem chaves de API, mas com limites de requisição. Consiga chaves gratuitas pra melhores resultados:

1. **Unsplash** (~50 requisições/hora sem chave, 5000/hora com chave)
```python
   headers = {"Authorization": "Client-ID SUA_CHAVE"}
```

2. **Pexels** (já configurado no código)
```python
   api_key = "SUA_CHAVE_DO_PEXELS"
```

3. **Pixabay** (já configurado no código)
```python
   api_key = "SUA_CHAVE_DO_PIXABAY"
```

## 💡 Dicas

- **Qualidade sobre quantidade**: baixe 20-30 imagens ótimas em vez de 100 medianas
- **Variedade**: misture termos de busca diferentes pra uma estética diversa
- **Otimize**: use o plugin de imagem do 11ty pra otimização automática
- **Créditos**: sempre credite os fotógrafos (está na licença!)
- **Backup**: mantenha a pasta original `moodboard` guardada

## 🎯 Próximos Passos

1. Rode o scraper pra conseguir imagens
2. Revise na galeria HTML
3. Integre no site
4. Atualize as fichas de filme
5. Builde e faça o deploy!

---

**Boa caçada de imagens! 📼✨**