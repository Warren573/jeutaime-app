#!/bin/bash
# 📝 Script de mise à jour automatique du README avec les captures d'écran
# Usage: ./scripts/update_readme_screenshots.sh

set -e

# Configuration
README_FILE="README.md"
SCREENSHOT_DIR="assets/screenshots"

# Couleurs pour les logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📝 Mise à jour automatique du README avec captures d'écran${NC}"
echo -e "${BLUE}========================================================${NC}"

# Fonction pour vérifier si un fichier d'image existe
check_image_exists() {
    local image_path="$1"
    if [ -f "$image_path" ]; then
        echo -e "${GREEN}✅ Trouvé: $image_path${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Manquant: $image_path${NC}"
        return 1
    fi
}

# Fonction pour remplacer un placeholder par une vraie image
replace_placeholder() {
    local section="$1"
    local feature="$2" 
    local image_name="$3"
    local description="$4"
    
    local image_path="$SCREENSHOT_DIR/features/$section/$image_name"
    
    if check_image_exists "$image_path"; then
        # Remplacer le placeholder dans le README
        sed -i.bak "s|🔄 \*À venir\*|![${description}](${image_path})|g" "$README_FILE"
        echo -e "${GREEN}✅ Mis à jour: $feature -> $image_path${NC}"
    else
        echo -e "${RED}❌ Image manquante pour: $feature${NC}"
        echo -e "${YELLOW}💡 Créez l'image: $image_path${NC}"
    fi
}

# Fonction principale de mise à jour
update_readme() {
    echo -e "${BLUE}🔍 Recherche des captures d'écran disponibles...${NC}"
    echo ""
    
    # Sauvegarder le README original
    cp "$README_FILE" "${README_FILE}.backup"
    echo -e "${YELLOW}💾 Sauvegarde créée: ${README_FILE}.backup${NC}"
    echo ""
    
    # Système de lettres
    echo -e "${BLUE}💌 Mise à jour section Lettres...${NC}"
    replace_placeholder "letters" "Liste des conversations" "conversations_list_mobile_v1.png" "Conversations"
    replace_placeholder "letters" "Écriture d'une lettre" "write_letter_mobile_v1.png" "Écriture"
    replace_placeholder "letters" "Boîte à souvenirs" "memory_box_mobile_v1.png" "Souvenirs"
    echo ""
    
    # Bars virtuels
    echo -e "${BLUE}🍸 Mise à jour section Bars...${NC}"
    replace_placeholder "bars" "Interface principale" "bar_main_mobile_v1.png" "Bar Interface"
    replace_placeholder "bars" "Mini-jeux" "mini_games_mobile_v1.png" "Mini-jeux"
    replace_placeholder "bars" "Bar privé" "create_private_bar_mobile_v1.png" "Bar Privé"
    echo ""
    
    # Système d'économie
    echo -e "${BLUE}💎 Mise à jour section Économie...${NC}"
    replace_placeholder "economy" "Profil avec points" "profile_points_mobile_v1.png" "Profil Points"
    replace_placeholder "economy" "Boutique d'offrandes" "offerings_shop_mobile_v1.png" "Boutique"
    replace_placeholder "economy" "Historique" "transaction_history_mobile_v1.png" "Historique"
    echo ""
    
    # Profil utilisateur
    echo -e "${BLUE}👤 Mise à jour section Profil...${NC}"
    replace_placeholder "profile" "Vue du profil" "profile_view_mobile_v1.png" "Profil"
    replace_placeholder "profile" "Édition du profil" "profile_edit_mobile_v1.png" "Édition"
    replace_placeholder "profile" "Paramètres" "settings_mobile_v1.png" "Paramètres"
    replace_placeholder "profile" "Badges et réalisations" "badges_mobile_v1.png" "Badges"
    echo ""
    
    # Authentification
    echo -e "${BLUE}🔐 Mise à jour section Auth...${NC}"
    replace_placeholder "auth" "Écran de connexion" "login_screen_mobile_v1.png" "Login"
    replace_placeholder "auth" "Écran d'inscription" "signup_screen_mobile_v1.png" "Signup"
    replace_placeholder "auth" "Processus d'onboarding" "onboarding_mobile_v1.png" "Onboarding"
    echo ""
}

# Fonction pour ajouter des images de plateforme (iOS/Android/Web)
update_platform_images() {
    echo -e "${BLUE}📱 Mise à jour des images de plateforme...${NC}"
    
    # Chercher les dernières captures par plateforme
    local latest_ios=$(ls -t "$SCREENSHOT_DIR/mobile/ios_"*.png 2>/dev/null | head -1)
    local latest_android=$(ls -t "$SCREENSHOT_DIR/mobile/android_"*.png 2>/dev/null | head -1)
    local latest_web=$(ls -t "$SCREENSHOT_DIR/web/"*.png 2>/dev/null | head -1)
    
    if [ -n "$latest_ios" ]; then
        echo -e "${GREEN}📱 iOS: $latest_ios${NC}"
        # Ici vous pourriez ajouter une logique pour mettre à jour l'image iOS dans le README
    fi
    
    if [ -n "$latest_android" ]; then
        echo -e "${GREEN}🤖 Android: $latest_android${NC}"
        # Ici vous pourriez ajouter une logique pour mettre à jour l'image Android
    fi
    
    if [ -n "$latest_web" ]; then
        echo -e "${GREEN}🌐 Web: $latest_web${NC}"
        # Ici vous pourriez ajouter une logique pour mettre à jour l'image Web
    fi
}

# Fonction pour afficher un rapport de ce qui a été fait
show_report() {
    echo -e "${BLUE}📊 Rapport de mise à jour${NC}"
    echo -e "${BLUE}========================${NC}"
    
    # Compter les placeholders restants
    local remaining_placeholders=$(grep -c "🔄 \*À venir\*" "$README_FILE" || echo "0")
    
    if [ "$remaining_placeholders" -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les placeholders ont été remplacés !${NC}"
    else
        echo -e "${YELLOW}⚠️  $remaining_placeholders placeholder(s) restant(s)${NC}"
        echo -e "${YELLOW}💡 Ajoutez plus de captures d'écran pour les compléter${NC}"
    fi
    
    # Montrer les différences
    if command -v diff &> /dev/null; then
        echo ""
        echo -e "${BLUE}📝 Changements effectués:${NC}"
        diff "${README_FILE}.backup" "$README_FILE" | head -20 || true
    fi
    
    echo ""
    echo -e "${GREEN}✅ README mis à jour avec succès !${NC}"
    echo -e "${BLUE}💾 Sauvegarde disponible: ${README_FILE}.backup${NC}"
}

# Vérifications préliminaires
check_requirements() {
    echo -e "${BLUE}🔍 Vérification des prérequis...${NC}"
    
    if [ ! -f "$README_FILE" ]; then
        echo -e "${RED}❌ $README_FILE non trouvé${NC}"
        exit 1
    fi
    
    if [ ! -d "$SCREENSHOT_DIR" ]; then
        echo -e "${RED}❌ Dossier $SCREENSHOT_DIR non trouvé${NC}"
        echo -e "${YELLOW}💡 Créez d'abord des captures avec: ./scripts/take_screenshots.sh${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prérequis validés${NC}"
    echo ""
}

# Point d'entrée principal
main() {
    check_requirements
    update_readme
    update_platform_images
    show_report
    
    echo ""
    echo -e "${BLUE}🚀 Prochaines étapes:${NC}"
    echo -e "${BLUE}- Vérifiez le résultat dans $README_FILE${NC}"
    echo -e "${BLUE}- Ajustez manuellement si nécessaire${NC}"
    echo -e "${BLUE}- Commitez les changements: git add . && git commit -m 'docs: update screenshots in README'${NC}"
}

# Gestion des arguments
case "${1:-}" in
    "--help"|"-h")
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Met à jour automatiquement le README.md en remplaçant les placeholders"
        echo "'🔄 *À venir*' par les vraies captures d'écran disponibles."
        echo ""
        echo "Options:"
        echo "  --help, -h     Affiche cette aide"
        echo "  --dry-run      Simulation sans modification"
        echo ""
        exit 0
        ;;
    "--dry-run")
        echo -e "${YELLOW}🧪 Mode simulation (pas de modifications)${NC}"
        # Ici on pourrait ajouter une logique de simulation
        ;;
    *)
        main
        ;;
esac