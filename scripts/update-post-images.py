#!/usr/bin/env python3
"""
Atualiza as fichas de filme com imagens baixadas localmente
"""

import os
import random
import re
from pathlib import Path

def get_available_images(images_dir="src/assets/images"):
    """Pega a lista de imagens baixadas"""
    img_dir = Path(images_dir)
    if not img_dir.exists():
        print(f"❌ Diretório de imagens não encontrado: {images_dir}")
        return []
    
    images = list(img_dir.glob("*.jpg")) + list(img_dir.glob("*.png"))
    images = [img for img in images if img.stem != 'image-credits']
    return [f"/assets/images/{img.name}" for img in images]

def update_post_featured_image(post_path, new_image_url):
    """Atualiza o featured_image no front matter de uma ficha de filme"""
    with open(post_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Atualiza a URL do featured_image
    pattern = r'featured_image:\s*"[^"]*"'
    replacement = f'featured_image: "{new_image_url}"'
    
    updated_content = re.sub(pattern, replacement, content)
    
    with open(post_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)
    
    print(f"✅ Atualizado: {post_path.name}")
    print(f"   Imagem: {new_image_url}")

def main():
    print("🖼️  Atualizador de Imagens das Fichas - Filmes HD Online Grátis")
    print("=" * 50)
    print()
    
    # Pega as imagens disponíveis
    images = get_available_images()
    
    if not images:
        print("⚠️  Nenhuma imagem encontrada. Rode o scraper primeiro:")
        print("   python3 scripts/image-scraper.py")
        return
    
    print(f"📊 {len(images)} imagens encontradas")
    print()
    
    # Pega todas as fichas de filme
    posts_dir = Path("src/filmes")
    if not posts_dir.exists():
        print("❌ Diretório de filmes não encontrado: src/filmes")
        return
    
    posts = list(posts_dir.glob("*.md"))
    
    if not posts:
        print("⚠️  Nenhuma ficha encontrada em src/filmes/")
        return
    
    print(f"📝 {len(posts)} fichas de filme encontradas")
    print()
    
    # Atualiza cada ficha com uma imagem aleatória
    used_images = []
    
    for post in posts:
        # Escolhe uma imagem aleatória ainda não usada
        available = [img for img in images if img not in used_images]
        
        if not available:
            # Se já usamos todas as imagens, reinicia
            used_images = []
            available = images
        
        chosen_image = random.choice(available)
        used_images.append(chosen_image)
        
        update_post_featured_image(post, chosen_image)
    
    print()
    print("=" * 50)
    print("✨ Todas as fichas atualizadas com imagens locais!")
    print()
    print("💡 Próximos passos:")
    print("   1. Rode 'npm run dev' pra pré-visualizar")
    print("   2. Faça o commit e o deploy quando estiver pronto")
    print()

if __name__ == "__main__":
    main()