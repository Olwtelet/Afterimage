#!/bin/bash
# Script pra rodar o scraper de imagens e integrar ao site

echo "📼 Filmes HD Online Grátis - Integração de Imagens 📼"
echo "=========================================="
echo ""

# Passo 1: Roda o scraper
echo "📥 Passo 1: Baixando imagens..."
python3 scripts/image-scraper.py

# Passo 2: Copia as imagens pros assets do site
echo ""
echo "📁 Passo 2: Copiando imagens pros assets do site..."
mkdir -p src/assets/images/hero
mkdir -p src/assets/images/filmes

# Copia uma seleção de imagens pra diferentes finalidades
if [ -d "moodboard" ]; then
    # Copia todas as imagens pra pasta principal
    cp moodboard/*.jpg src/assets/images/ 2>/dev/null || true
    
    # Copia os créditos
    cp moodboard/credits.txt src/assets/images/image-credits.txt 2>/dev/null || true
    
    echo "✅ Imagens copiadas pra src/assets/images/"
    echo "✅ Créditos salvos em src/assets/images/image-credits.txt"
    
    # Conta as imagens
    image_count=$(ls -1 src/assets/images/*.jpg 2>/dev/null | wc -l | tr -d ' ')
    echo "📊 Total de imagens: $image_count"
else
    echo "⚠️  Nenhuma imagem encontrada. Rode o scraper primeiro."
fi

echo ""
echo "🎨 Pronto! As imagens estão prontas pra usar no site."
echo "   Localização: src/assets/images/"
echo ""
echo "💡 Próximos passos:"
echo "   1. Atualizar as fichas de filme pra usar as imagens locais"
echo "   2. Rodar 'npm run dev' pra ver funcionando"
echo "   3. Buildar e fazer o deploy!"