#!/bin/bash

echo "🚀 Déploiement JeuTaime PWA"
echo "=========================="

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Veuillez exécuter ce script depuis la racine du projet JeuTaime${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Étape 1: Nettoyage...${NC}"
flutter clean
flutter pub get

echo -e "${BLUE}🔨 Étape 2: Compilation pour production...${NC}"
flutter build web --target lib/main_offline.dart --base-href / --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de la compilation${NC}"
    exit 1
fi

# Copier les fichiers de configuration
echo -e "${BLUE}⚙️  Étape 3: Configuration déploiement...${NC}"
cp netlify.toml build/web/ 2>/dev/null || echo "netlify.toml non trouvé, création..."

# Créer netlify.toml si pas présent
if [ ! -f "build/web/netlify.toml" ]; then
    cat > build/web/netlify.toml << EOF
[build]
  publish = "."

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/manifest.json"
  [headers.values]
    Content-Type = "application/manifest+json"
    
[[headers]]
  for = "*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
EOF
fi

echo -e "${BLUE}📊 Étape 4: Informations build...${NC}"
BUILD_SIZE=$(du -sh build/web | cut -f1)
echo -e "${GREEN}✅ Build terminé avec succès !${NC}"
echo -e "${GREEN}📁 Taille du build: $BUILD_SIZE${NC}"
echo -e "${GREEN}📂 Dossier prêt: build/web/${NC}"

echo ""
echo -e "${YELLOW}🌐 Instructions de déploiement:${NC}"
echo ""
echo -e "${YELLOW}Netlify (recommandé):${NC}"
echo "1. Aller sur https://netlify.com"
echo "2. Drag & drop le dossier 'build/web'"
echo "3. Votre app sera en ligne en quelques secondes !"
echo ""
echo -e "${YELLOW}Vercel (alternative):${NC}"
echo "1. Installer Vercel CLI: npm i -g vercel"
echo "2. Exécuter: vercel --prod"
echo "3. Suivre les instructions"
echo ""
echo -e "${YELLOW}GitHub Pages:${NC}"
echo "1. Pousser le contenu de build/web dans une branche gh-pages"
echo "2. Activer GitHub Pages dans les paramètres du repo"

echo ""
echo -e "${GREEN}🎉 Votre PWA JeuTaime est prête pour le monde entier !${NC}"
echo -e "${BLUE}📱 Features incluses:${NC}"
echo "   ✅ Installation native (mobile/desktop)"
echo "   ✅ Mode offline/online"
echo "   ✅ Authentification complète" 
echo "   ✅ Interface moderne avec animations"
echo "   ✅ Système de bars thématiques"
echo "   ✅ Mode sombre/clair"