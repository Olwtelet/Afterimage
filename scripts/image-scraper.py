"""
Scraper de Imagens Estéticas
Baixa imagens aleatórias combinando com a estética vaporwave/cybercore/Y2K
Usa a API do Unsplash (gratuita, sem autenticação necessária pro uso básico)
"""

import requests
import os
import time
import random
from pathlib import Path
from datetime import datetime

class AestheticImageScraper:
    def __init__(self, output_dir="moodboard"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
        # Endpoint da API do Unsplash (sem chave necessária pra busca básica)
        self.unsplash_api = "https://api.unsplash.com/search/photos"
        
        # Termos de busca baseados no moodboard visual
        self.search_terms = [
            "vaporwave",
            "cyberpunk neon",
            "glitch art",
            "retrowave",
            "synthwave aesthetic",
            "holographic",
            "y2k aesthetic",
            "cyber grunge",
            "digital art neon",
            "psychedelic glitch",
            "neon grid",
            "80s computer graphics",
            "pixel art cyber",
            "matrix aesthetic",
            "chrome aesthetic",
            "iridescent holographic",
            "crt screen",
            "terminal aesthetic",
            "arcade neon",
            "futuristic purple pink"
        ]
        
        # Filtros de cor baseados na sua paleta
        self.color_filters = [
            "purple",
            "magenta", 
            "cyan",
            "pink"
        ]
    
    def download_from_unsplash(self, num_images=20):
        """
        Baixa imagens da API do Unsplash
        Nota: pra uso em produção, pegue uma chave gratuita em unsplash.com/developers
        """
        print(f"🎨 Buscando imagens no Unsplash...")
        
        downloaded = 0
        
        for term in random.sample(self.search_terms, min(5, len(self.search_terms))):
            if downloaded >= num_images:
                break
                
            print(f"\n🔍 Buscando por: {term}")
            
            try:
                # Nota: adicione sua chave da API do Unsplash aqui pra limites melhores
                headers = {}
                # headers = {"Authorization": "Client-ID SUA_CHAVE_DE_ACESSO"}
                
                params = {
                    "query": term,
                    "per_page": 10,
                    "orientation": "landscape"
                }
                
                # Adiciona filtro de cor aleatoriamente
                if random.random() > 0.5:
                    params["color"] = random.choice(self.color_filters)
                
                response = requests.get(
                    self.unsplash_api,
                    params=params,
                    headers=headers,
                    timeout=10
                )
                
                if response.status_code == 200:
                    data = response.json()
                    results = data.get("results", [])
                    
                    for img in results[:3]:  # Pega 3 imagens por termo de busca
                        if downloaded >= num_images:
                            break
                        
                        img_url = img["urls"]["regular"]  # Alta qualidade mas não gigante
                        img_id = img["id"]
                        photographer = img["user"]["name"]
                        
                        # Baixa a imagem
                        self._download_image(
                            img_url, 
                            f"unsplash_{term.replace(' ', '_')}_{img_id}.jpg",
                            photographer
                        )
                        
                        downloaded += 1
                        time.sleep(1)  # Pra não sobrecarregar a API
                
                elif response.status_code == 403:
                    print("⚠️  Limite de requisições atingido. Considere adicionar uma chave de API do Unsplash.")
                    print("   Consiga uma gratuita em: https://unsplash.com/developers")
                    break
                    
            except Exception as e:
                print(f"❌ Erro buscando '{term}': {e}")
                continue
        
        return downloaded
    
    def download_from_pexels(self, num_images=20):
        """
        Baixa imagens da API do Pexels
        Consiga uma chave gratuita em: https://www.pexels.com/api/
        """
        print(f"\n🎨 Buscando imagens no Pexels...")
        
        # Pega a chave da API da variável de ambiente
        api_key = os.environ.get("PEXELS_API_KEY", "SUA_CHAVE_DO_PEXELS")
        
        if api_key == "SUA_CHAVE_DO_PEXELS":
            print("⚠️  Adicione sua chave da API do Pexels pra usar essa fonte")
            print("   Consiga uma gratuita em: https://www.pexels.com/api/")
            print("   Defina como variável de ambiente: export PEXELS_API_KEY=sua_chave_aqui")
            return 0
        
        headers = {"Authorization": api_key}
        downloaded = 0
        
        for term in random.sample(self.search_terms, min(5, len(self.search_terms))):
            if downloaded >= num_images:
                break
            
            print(f"\n🔍 Buscando por: {term}")
            
            try:
                response = requests.get(
                    "https://api.pexels.com/v1/search",
                    params={
                        "query": term,
                        "per_page": 10,
                        "orientation": "landscape"
                    },
                    headers=headers,
                    timeout=10
                )
                
                if response.status_code == 200:
                    data = response.json()
                    photos = data.get("photos", [])
                    
                    for photo in photos[:3]:
                        if downloaded >= num_images:
                            break
                        
                        img_url = photo["src"]["large"]
                        img_id = photo["id"]
                        photographer = photo["photographer"]
                        
                        self._download_image(
                            img_url,
                            f"pexels_{term.replace(' ', '_')}_{img_id}.jpg",
                            photographer
                        )
                        
                        downloaded += 1
                        time.sleep(1)
                        
            except Exception as e:
                print(f"❌ Erro buscando '{term}': {e}")
                continue
        
        return downloaded
    
    def download_from_pixabay(self, num_images=20):
        """
        Baixa imagens da API do Pixabay
        Consiga uma chave gratuita em: https://pixabay.com/api/docs/
        """
        print(f"\n🎨 Buscando imagens no Pixabay...")
        
        # Pega a chave da API da variável de ambiente
        api_key = os.environ.get("PIXABAY_API_KEY", "SUA_CHAVE_DO_PIXABAY")
        
        if api_key == "SUA_CHAVE_DO_PIXABAY":
            print("⚠️  Adicione sua chave da API do Pixabay pra usar essa fonte")
            print("   Consiga uma gratuita em: https://pixabay.com/api/docs/")
            print("   Defina como variável de ambiente: export PIXABAY_API_KEY=sua_chave_aqui")
            return 0
        
        downloaded = 0
        
        for term in random.sample(self.search_terms, min(5, len(self.search_terms))):
            if downloaded >= num_images:
                break
            
            print(f"\n🔍 Buscando por: {term}")
            
            try:
                response = requests.get(
                    "https://pixabay.com/api/",
                    params={
                        "key": api_key,
                        "q": term,
                        "image_type": "photo",
                        "per_page": 10,
                        "orientation": "horizontal"
                    },
                    timeout=10
                )
                
                if response.status_code == 200:
                    data = response.json()
                    hits = data.get("hits", [])
                    
                    for hit in hits[:3]:
                        if downloaded >= num_images:
                            break
                        
                        img_url = hit["largeImageURL"]
                        img_id = hit["id"]
                        photographer = hit.get("user", "pixabay")
                        
                        self._download_image(
                            img_url,
                            f"pixabay_{term.replace(' ', '_')}_{img_id}.jpg",
                            photographer
                        )
                        
                        downloaded += 1
                        time.sleep(1)
                        
            except Exception as e:
                print(f"❌ Erro buscando '{term}': {e}")
                continue
        
        return downloaded
    
    def _download_image(self, url, filename, photographer=None):
        """Baixa uma única imagem"""
        try:
            response = requests.get(url, timeout=15)
            
            if response.status_code == 200:
                filepath = self.output_dir / filename
                
                with open(filepath, 'wb') as f:
                    f.write(response.content)
                
                credit = f" por {photographer}" if photographer else ""
                print(f"✅ Baixado: {filename}{credit}")
                
                # Salva os créditos num arquivo de texto
                self._save_credit(filename, url, photographer)
                
                return True
            else:
                print(f"❌ Falha ao baixar {filename}: Status {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ Erro baixando {filename}: {e}")
            return False
    
    def _save_credit(self, filename, url, photographer):
        """Salva os créditos da imagem num arquivo de texto"""
        credits_file = self.output_dir / "credits.txt"
        
        with open(credits_file, 'a', encoding='utf-8') as f:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            f.write(f"\n{filename}\n")
            f.write(f"  Fotógrafo: {photographer}\n")
            f.write(f"  URL de origem: {url}\n")
            f.write(f"  Baixado em: {timestamp}\n")
    
    def create_html_gallery(self):
        """Cria uma galeria HTML simples pra visualizar as imagens baixadas"""
        images = list(self.output_dir.glob("*.jpg")) + list(self.output_dir.glob("*.png"))
        
        html = """
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Galeria de Moodboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #0a0a0a;
            color: #00f0ff;
            font-family: 'Courier New', monospace;
            padding: 20px;
        }
        
        h1 {
            text-align: center;
            margin-bottom: 30px;
            text-shadow: 0 0 10px #00f0ff;
            font-size: 2em;
            text-transform: uppercase;
            letter-spacing: 3px;
        }
        
        .gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .image-card {
            position: relative;
            overflow: hidden;
            border: 2px solid #9d00ff;
            border-radius: 8px;
            box-shadow: 0 0 20px rgba(157, 0, 255, 0.3);
            transition: transform 0.3s ease;
        }
        
        .image-card:hover {
            transform: scale(1.05);
            box-shadow: 0 0 30px rgba(157, 0, 255, 0.6);
        }
        
        .image-card img {
            width: 100%;
            height: 250px;
            object-fit: cover;
            display: block;
        }
        
        .image-info {
            padding: 10px;
            background: rgba(10, 10, 10, 0.9);
            font-size: 12px;
        }
        
        .count {
            text-align: center;
            margin-top: 30px;
            font-size: 14px;
            color: #ff10f0;
        }
    </style>
</head>
<body>
    <h1>📼 Galeria de Moodboard 📼</h1>
    <div class="gallery">
"""
        
        for img in images:
            html += f"""
        <div class="image-card">
            <img src="{img.name}" alt="{img.stem}" loading="lazy">
            <div class="image-info">{img.stem}</div>
        </div>
"""
        
        html += f"""
    </div>
    <div class="count">
        <p>Total de Imagens: {len(images)}</p>
    </div>
</body>
</html>
"""
        
        gallery_file = self.output_dir / "gallery.html"
        with open(gallery_file, 'w', encoding='utf-8') as f:
            f.write(html)
        
        print(f"\n✨ Galeria criada: {gallery_file}")
        print(f"   Abra no navegador pra ver todas as imagens!")


def main():
    print("=" * 60)
    print("📼 SCRAPER DE IMAGENS ESTÉTICAS 📼")
    print("=" * 60)
    print()
    
    # Inicializa o scraper
    scraper = AestheticImageScraper(output_dir="moodboard")
    
    # Escolha quantas imagens você quer
    num_images = 30
    
    print(f"📥 Baixando {num_images} imagens...")
    print()
    
    # Tenta diferentes fontes
    # Usa Pexels e Pixabay (você tem chaves de API!)
    downloaded = scraper.download_from_pexels(num_images // 2)
    downloaded += scraper.download_from_pixabay(num_images // 2)
    
    # Unsplash funciona sem chave de API mas tem limites de requisição
    # downloaded += scraper.download_from_unsplash(10)
    
    print()
    print("=" * 60)
    print(f"✨ {downloaded} imagens baixadas com sucesso!")
    print(f"📁 Salvas em: {scraper.output_dir}")
    print()
    
    # Cria a galeria HTML
    scraper.create_html_gallery()
    
    print()
    print("💡 DICA: Pra melhores resultados, consiga chaves de API gratuitas em:")
    print("   • Unsplash: https://unsplash.com/developers")
    print("   • Pexels: https://www.pexels.com/api/")
    print("   • Pixabay: https://pixabay.com/api/docs/")
    print()
    print("📼 Créditos de todas as imagens salvos em credits.txt")
    print("=" * 60)


if __name__ == "__main__":
    main()