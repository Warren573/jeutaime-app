#!/bin/bash
# 📷 Script automatique de prise de captures d'écran JeuTaime
# Usage: ./scripts/take_screenshots.sh

set -e

# Configuration
SCREENSHOT_DIR="assets/screenshots"
DATE=$(date +%Y%m%d_%H%M%S)
PROJECT_NAME="jeutaime"

# Couleurs pour les logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📷 JeuTaime - Prise de captures d'écran automatique${NC}"
echo -e "${BLUE}=================================================${NC}"

# Vérifier que les dossiers existent
if [ ! -d "$SCREENSHOT_DIR" ]; then
    echo -e "${YELLOW}📁 Création du dossier screenshots...${NC}"
    mkdir -p "$SCREENSHOT_DIR"/{mobile,web,features}/{ios,android}
fi

# Fonction de capture iOS
capture_ios() {
    echo -e "${GREEN}📱 Vérification du simulateur iOS...${NC}"
    
    if xcrun simctl list devices | grep -q "Booted"; then
        DEVICE_INFO=$(xcrun simctl list devices | grep "Booted" | head -1)
        echo -e "${GREEN}✅ Simulateur détecté: $DEVICE_INFO${NC}"
        
        # Capture écran d'accueil
        echo -e "${GREEN}📸 Capture écran d'accueil iOS...${NC}"
        xcrun simctl io booted screenshot "$SCREENSHOT_DIR/mobile/ios_home_$DATE.png"
        
        # Capturer la status bar proprement
        xcrun simctl status_bar booted override --time "9:41" --dataNetwork "wifi" --wifiMode active --batteryState charged --batteryLevel 100
        
        echo -e "${GREEN}✅ Capture iOS terminée${NC}"
        return 0
    else
        echo -e "${RED}❌ Aucun simulateur iOS démarré${NC}"
        echo -e "${YELLOW}💡 Démarrez un simulateur avec: open -a Simulator${NC}"
        return 1
    fi
}

# Fonction de capture Android
capture_android() {
    echo -e "${GREEN}🤖 Vérification de l'émulateur Android...${NC}"
    
    if adb devices | grep -q "emulator"; then
        DEVICE_INFO=$(adb devices | grep "emulator" | head -1)
        echo -e "${GREEN}✅ Émulateur détecté: $DEVICE_INFO${NC}"
        
        # Capture écran d'accueil
        echo -e "${GREEN}📸 Capture écran d'accueil Android...${NC}"
        adb exec-out screencap -p > "$SCREENSHOT_DIR/mobile/android_home_$DATE.png"
        
        echo -e "${GREEN}✅ Capture Android terminée${NC}"
        return 0
    else
        echo -e "${RED}❌ Aucun émulateur Android détecté${NC}"
        echo -e "${YELLOW}💡 Démarrez un émulateur avec: flutter emulators --launch <emulator_id>${NC}"
        return 1
    fi
}

# Fonction de capture web
capture_web() {
    echo -e "${GREEN}🌐 Capture web (nécessite interaction manuelle)...${NC}"
    echo -e "${YELLOW}💡 Instructions:${NC}"
    echo -e "${YELLOW}   1. Ouvrez Chrome et allez sur localhost:xxxxx${NC}"
    echo -e "${YELLOW}   2. F12 → Mode responsive → Choisir iPhone 12${NC}"
    echo -e "${YELLOW}   3. Ctrl+Shift+P → 'Capture screenshot'${NC}"
    echo -e "${YELLOW}   4. Sauvegardez dans: $SCREENSHOT_DIR/web/${NC}"
}

# Fonction principale
main() {
    echo -e "${BLUE}🚀 Démarrage des captures...${NC}"
    echo ""
    
    ios_success=false
    android_success=false
    
    # Capturer iOS si disponible
    if capture_ios; then
        ios_success=true
    fi
    
    echo ""
    
    # Capturer Android si disponible
    if capture_android; then
        android_success=true
    fi
    
    echo ""
    
    # Instructions pour le web
    capture_web
    
    echo ""
    echo -e "${BLUE}📊 Résumé des captures:${NC}"
    echo -e "${BLUE}======================${NC}"
    
    if $ios_success; then
        echo -e "${GREEN}✅ iOS: Capture réussie${NC}"
    else
        echo -e "${RED}❌ iOS: Échec ou non disponible${NC}"
    fi
    
    if $android_success; then
        echo -e "${GREEN}✅ Android: Capture réussie${NC}"
    else
        echo -e "${RED}❌ Android: Échec ou non disponible${NC}"
    fi
    
    echo -e "${YELLOW}⚠️  Web: Capture manuelle requise${NC}"
    
    echo ""
    echo -e "${BLUE}📁 Captures sauvegardées dans: $SCREENSHOT_DIR${NC}"
    
    # Lister les fichiers créés
    if ls "$SCREENSHOT_DIR"/mobile/*_"$DATE".png 1> /dev/null 2>&1; then
        echo -e "${GREEN}📸 Nouveaux fichiers:${NC}"
        ls -la "$SCREENSHOT_DIR"/mobile/*_"$DATE".png
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Script terminé !${NC}"
}

# Vérifications préliminaires
check_requirements() {
    echo -e "${BLUE}🔍 Vérification des prérequis...${NC}"
    
    # Vérifier que Flutter est installé
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter n'est pas installé ou pas dans le PATH${NC}"
        exit 1
    fi
    
    # Vérifier qu'on est dans un projet Flutter
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ Ce script doit être exécuté à la racine d'un projet Flutter${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prérequis validés${NC}"
    echo ""
}

# Point d'entrée
check_requirements
main

echo ""
echo -e "${BLUE}💡 Prochaines étapes:${NC}"
echo -e "${BLUE}- Organisez les captures dans les sous-dossiers par fonctionnalité${NC}"
echo -e "${BLUE}- Mettez à jour le README.md avec les nouveaux screenshots${NC}"
echo -e "${BLUE}- Utilisez le guide dans docs/SCREENSHOT_GUIDE.md pour plus d'options${NC}"