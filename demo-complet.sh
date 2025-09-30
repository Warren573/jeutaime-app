#!/bin/bash

# 🎬 LANCEUR COMPLET DÉMONSTRATION JEUTAIME
# ==========================================

clear
echo "🎉 Lancement de la démonstration complète JeuTaime"
echo "=================================================="

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Préparation de l'environnement de démonstration...${NC}"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Veuillez exécuter depuis la racine du projet JeuTaime"
    exit 1
fi

# Compiler l'application si nécessaire
if [ ! -d "build/web" ] || [ "lib/main_offline.dart" -nt "build/web/main.dart.js" ]; then
    echo -e "${YELLOW}📦 Compilation de l'application...${NC}"
    flutter build web --target lib/main_offline.dart > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Compilation réussie${NC}"
    else
        echo "❌ Erreur de compilation"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Application déjà compilée${NC}"
fi

# Démarrer le serveur de démonstration
echo -e "${BLUE}🌐 Démarrage du serveur de démonstration...${NC}"
pkill -f "python3 -m http.server 8089" 2>/dev/null
python3 -m http.server 8089 --directory build/web > /dev/null 2>&1 &
SERVER_PID=$!

# Attendre que le serveur soit prêt
sleep 2
echo -e "${GREEN}✅ Serveur prêt sur http://localhost:8089${NC}"

echo ""
echo -e "${YELLOW}🎯 DÉMONSTRATION JEUTAIME PRÊTE !${NC}"
echo "================================"
echo ""
echo "📋 Ressources disponibles :"
echo ""
echo -e "${BLUE}🎬 Démonstration interactive :${NC}"
echo "   → ./demo.sh (script avec narration)"
echo ""
echo -e "${BLUE}🌐 Application live :${NC}"
echo "   → http://localhost:8089"
echo ""
echo -e "${BLUE}📊 Présentation PowerPoint :${NC}"
echo "   → Ouvrir presentation.html dans votre navigateur"
echo ""
echo -e "${BLUE}📖 Guides disponibles :${NC}"
echo "   → GUIDE_PRESENTATION.md (captures d'écran)"
echo "   → GUIDE_BUILD_LOCAL.md (compilation Android)"
echo "   → SESSION_RECAP_27_SEPT.md (récapitulatif)"
echo ""

# Proposer les actions
echo -e "${YELLOW}🤔 Que voulez-vous faire ?${NC}"
echo ""
echo "1) 🎬 Lancer la démonstration interactive (./demo.sh)"
echo "2) 🌐 Ouvrir l'application dans le navigateur"
echo "3) 📊 Ouvrir la présentation PowerPoint"
echo "4) 📋 Voir tous les guides disponibles"
echo "5) 🚀 Lancer le déploiement en production"
echo "6) ❌ Quitter"
echo ""

read -p "Votre choix (1-6) : " choice

case $choice in
    1)
        echo -e "${GREEN}🎬 Lancement de la démonstration interactive...${NC}"
        ./demo.sh
        ;;
    2)
        echo -e "${GREEN}🌐 Ouverture de l'application...${NC}"
        if command -v xdg-open > /dev/null; then
            xdg-open http://localhost:8089
        elif command -v open > /dev/null; then
            open http://localhost:8089
        else
            echo "Ouvrez manuellement : http://localhost:8089"
        fi
        ;;
    3)
        echo -e "${GREEN}📊 Ouverture de la présentation...${NC}"
        if command -v xdg-open > /dev/null; then
            xdg-open presentation.html
        elif command -v open > /dev/null; then
            open presentation.html
        else
            echo "Ouvrez manuellement : presentation.html"
        fi
        ;;
    4)
        echo -e "${GREEN}📋 Guides disponibles :${NC}"
        ls -la *.md | grep -E "(GUIDE|SESSION|RECAP)"
        echo ""
        echo "💡 Utilisez 'cat NOMFICHIER.md' pour lire un guide"
        ;;
    5)
        echo -e "${GREEN}🚀 Lancement du déploiement...${NC}"
        ./deploy.sh
        ;;
    6)
        echo -e "${YELLOW}👋 Arrêt du serveur...${NC}"
        kill $SERVER_PID 2>/dev/null
        echo -e "${GREEN}✅ Démonstration terminée !${NC}"
        exit 0
        ;;
    *)
        echo "❌ Choix invalide"
        ;;
esac

# Garder le serveur actif
echo ""
echo -e "${BLUE}ℹ️  Le serveur reste actif sur http://localhost:8089${NC}"
echo -e "${YELLOW}💡 Ctrl+C pour arrêter le serveur${NC}"

# Attendre l'arrêt
trap "echo -e '\n${GREEN}✅ Serveur arrêté, démonstration terminée !${NC}'; kill $SERVER_PID 2>/dev/null; exit" INT

# Maintenir le serveur
wait $SERVER_PID