### Passo 4: Atualizar as Fichas de Filme

```bash
npm run update-images
```

Isso automaticamente:
- Encontra todos os arquivos `.md` em `src/filmes/`
- Atualiza o campo `featured_image`
- Usa imagens locais em vez de URLs externas
- Atribui imagens diferentes pra cada ficha

**Antes:**
```markdown
featured_image: "https://images.unsplash.com/photo-123..."
```

**Depois:**
```markdown
featured_image: "/assets/images/unsplash_vaporwave_abc123.jpg"
```

### Passo 5: Pré-visualizar & Buildar

```bash
# Ver as imagens em ação
npm run dev

# Buildar pra produção
npm run build
```

## 🎯 Uso Avançado

### Termos de Busca Customizados

Edite os termos em `scripts/image-scraper.py`:

```python
self.search_terms = [
    "vaporwave",
    "sua busca customizada",
    "outra estética",
    # Adicione as suas!
]
```

### Baixar Mais Imagens

```bash
# Edite o script pra mudar o num_images
# Padrão é 30, pode aumentar pra 50, 100, etc.
npm run scrape-images
```

### Usar Imagens Específicas

Em vez de atribuir automaticamente, edite manualmente o front matter da ficha:

```markdown
---
featured_image: "/assets/images/sua-imagem-favorita.jpg"
---
```

### Adicionar Chaves de API pra Melhores Resultados

O scraper funciona sem chaves de API mas tem limites de requisição.

**Consiga chaves de API gratuitas:**
1. **Unsplash**: https://unsplash.com/developers
2. **Pexels**: Já configurado! ✅
3. **Pixabay**: Já configurado! ✅

**Adicione a chave do Unsplash:**
Edite `scripts/image-scraper.py` na linha 72:
```python
headers = {"Authorization": "Client-ID SUA_CHAVE_DE_ACESSO"}
```

## 📊 O que é Baixado?

### Fontes de Imagem
- **Unsplash** — alta qualidade, sem chave de API necessária (com limite de requisições)
- **Pexels** — sua chave já está no código
- **Pixabay** — sua chave já está no código

### Tipos de Imagem
Todas as imagens são:
- ✅ Alta resolução (1200px+ de largura)
- ✅ Orientação paisagem (perfeita pra cabeçalhos)
- ✅ Filtradas por cor (roxo, rosa, ciano, magenta)
- ✅ Gratuitas pra usar com atribuição
- ✅ Combinando com a estética Y2K/vaporwave

### Créditos
Sempre incluídos em:
- `moodboard/credits.txt` (área de preparação)
- `src/assets/images/image-credits.txt` (site)

## 🎨 Dicas de Fluxo de Trabalho

### 1. Cure Antes de Integrar
```bash
npm run scrape-images
open moodboard/gallery.html
# Apague as imagens que você não quer
npm run integrate-images
```

### 2. Mantenha o Moodboard Separado
O diretório `moodboard/` está fora do git. Mantenha como sua área de preparação:
- Baixe novas imagens a qualquer momento
- Revise na galeria
- Só copie as favoritas pro site

### 3. Download em Lote
```bash
# Baixe 50 imagens de uma vez
python3 scripts/image-scraper.py
# (Edite o script pra definir num_images = 50)
```

### 4. Organize por Categoria
Depois de baixar, você pode organizar manualmente:
```bash
mkdir -p src/assets/images/hero
mkdir -p src/assets/images/filmes
mkdir -p src/assets/images/backgrounds

# Mova as imagens pras categorias
mv src/assets/images/vaporwave* src/assets/images/hero/
```

## 📝 Credite Suas Fontes

O scraper salva os créditos automaticamente, mas você deve:

1. **Incluir no site**
   Adicione em `src/pages/creditos.md`:
```markdown
   ---
   layout: layouts/page.njk
   title: Créditos das Imagens
   ---
   
   ## Créditos de Fotografia
   
   Imagens de Unsplash, Pexels e Pixabay.
   
   [Ver créditos detalhados](/assets/images/image-credits.txt)
```

2. **Linkar no rodapé**
   Já tem um rodapé? Adicione:
```html
   <a href="/creditos/">Créditos das Imagens</a>
```

## 🚨 Solução de Problemas

### "Nenhuma imagem encontrada"
```bash
# Confira se a biblioteca requests está instalada
pip3 install requests

# Rode o scraper manualmente
python3 scripts/image-scraper.py
```

### "Limite de requisições atingido"
Adicione chaves de API ou espere uma hora e tente de novo.

### "Imagens não aparecem nas fichas"
```bash
# Rode o script de atualização de novo
npm run update-images

# Confira se as imagens existem
ls -la src/assets/images/
```

### "A galeria não abre"
```bash
# Confira o caminho
ls moodboard/gallery.html

# Abra diretamente
open moodboard/gallery.html
```

## 🎉 Tudo Pronto!

O site agora tem:
- ✅ Scraper de imagens customizado
- ✅ Fluxo de trabalho automatizado
- ✅ Imagens estéticas Y2K
- ✅ Créditos corretos
- ✅ Galeria de pré-visualização
- ✅ Scripts npm fáceis de usar

**Boa caçada de imagens! 📼✨**

---

Precisa de mais ajuda? Confira `scripts/README.md` pra documentação detalhada.