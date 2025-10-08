#!/bin/bash
# 🤖 Script d'organisation automatique des captures d'écran
# Basé sur l'identification faite dans l'aperçu

set -e

echo "🚀 Organisation automatique des captures d'écran JeuTaime..."
echo "========================================================="

# Créer les dossiers si nécessaire
mkdir -p assets/screenshots/features/{auth,profile,letters,bars,economy,home}

# Fonction de renommage et déplacement
organize_screenshot() {
    local old_name="$1"
    local category="$2" 
    local screen_type="$3"
    local version="${4:-v1}"
    
    local new_name="${category}_${screen_type}_${version}.png"
    local old_path="assets/screenshots/mobile/${old_name}"
    local new_path="assets/screenshots/features/${category}/${new_name}"
    
    if [ -f "$old_path" ]; then
        echo "📸 $old_name → $new_name"
        mv "$old_path" "$new_path"
        return 0
    else
        echo "❌ Fichier non trouvé: $old_path"
        return 1
    fi
}

echo "📱 Organisation des captures par fonctionnalité..."
echo ""

# Écrans d'accueil (basé sur ce que je vois dans votre aperçu)
echo "🏠 Écrans d'accueil..."
organize_screenshot "IMG_2960.PNG" "home" "main"
organize_screenshot "IMG_2961.PNG" "home" "welcome" 
organize_screenshot "IMG_2962.PNG" "home" "profile_discovery"

# Écrans de profil (basé sur ce que j'ai vu précédemment)
echo "👤 Écrans de profil..."
organize_screenshot "IMG_2971.PNG" "profile" "edit"

# Supposons une organisation logique pour les autres...
# Vous pourrez ajuster après si nécessaire

# Écrans d'authentification (généralement les premiers)
echo "🔐 Écrans d'authentification..."
organize_screenshot "IMG_2963.PNG" "auth" "login"
organize_screenshot "IMG_2964.PNG" "auth" "signup"

# Écrans de lettres
echo "💌 Système de lettres..."
organize_screenshot "IMG_2965.PNG" "letters" "list"
organize_screenshot "IMG_2966.PNG" "letters" "write"
organize_screenshot "IMG_2967.PNG" "letters" "read"
organize_screenshot "IMG_2968.PNG" "letters" "memory_box"

# Écrans de bars
echo "🍸 Système de bars..."
organize_screenshot "IMG_2969.PNG" "bars" "list"
organize_screenshot "IMG_2970.PNG" "bars" "main"
organize_screenshot "IMG_2972.PNG" "bars" "mini_games"
organize_screenshot "IMG_2973.PNG" "bars" "create_private"

# Écrans d'économie
echo "💎 Système d'économie..."
organize_screenshot "IMG_2974.PNG" "economy" "shop"
organize_screenshot "IMG_2975.PNG" "economy" "points"
organize_screenshot "IMG_2976.PNG" "economy" "transaction_history"
organize_screenshot "IMG_2977.PNG" "economy" "rewards"

# Écrans de profil additionnels
echo "👤 Profil (suite)..."
organize_screenshot "IMG_2978.PNG" "profile" "view"
organize_screenshot "IMG_2979.PNG" "profile" "settings"

# Les petites images (probablement des éléments UI)
echo "🎨 Éléments UI..."
organize_screenshot "IMG_2980.PNG" "ui" "element1"
organize_screenshot "IMG_2981.PNG" "ui" "element2" 
organize_screenshot "IMG_2982.PNG" "ui" "element3"
organize_screenshot "IMG_2983.PNG" "ui" "element4"
organize_screenshot "IMG_2984.PNG" "ui" "element5"
organize_screenshot "IMG_2985.PNG" "ui" "element6"

echo ""
echo "📊 Vérification de l'organisation..."
echo "===================================="

# Afficher la nouvelle structure
echo "📁 Structure organisée:"
tree assets/screenshots/features/ 2>/dev/null || find assets/screenshots/features/ -type f | sort

echo ""
echo "✅ Organisation terminée !"
echo ""
echo "🎯 Prochaines étapes:"
echo "1. Vérifiez que l'organisation correspond à vos écrans"
echo "2. Ajustez les noms si nécessaire avec 'mv'"  
echo "3. Mettez à jour le README: ./scripts/update_readme_screenshots.sh"
echo "4. Commitez: git add . && git commit -m '📸 Organize screenshots'"