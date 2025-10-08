#!/bin/bash
# 📸 Script d'analyse et d'organisation des captures d'écran JeuTaime
# Usage: ./scripts/analyze_screenshots.sh

set -e

MOBILE_DIR="assets/screenshots/mobile"
FEATURES_DIR="assets/screenshots/features"

echo "🔍 Analyse des captures d'écran JeuTaime..."
echo "============================================"

# Créer un rapport d'analyse
REPORT_FILE="assets/screenshots/ANALYSIS_REPORT.md"

cat > "$REPORT_FILE" << 'EOF'
# 📊 Rapport d'analyse des captures d'écran

## 📱 Captures analysées

EOF

echo "📸 Captures trouvées dans mobile/:"
for img in "$MOBILE_DIR"/IMG_*.PNG; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        filesize=$(du -h "$img" | cut -f1)
        echo "  ✅ $filename ($filesize)"
        
        # Ajouter au rapport
        echo "| $filename | $filesize | À analyser | À renommer |" >> "$REPORT_FILE"
    fi
done

echo ""
echo "📋 Suggestions d'organisation:"
echo "1. Examiner chaque image pour identifier la fonctionnalité"
echo "2. Renommer selon la convention: {feature}_{screen}_{version}.png"
echo "3. Déplacer vers le bon sous-dossier de features/"

# Ajouter des suggestions au rapport
cat >> "$REPORT_FILE" << 'EOF'

## 🎯 Prochaines étapes d'organisation

### 1. Identification des écrans
- [ ] Analyser chaque capture pour identifier la fonctionnalité
- [ ] Grouper par catégorie (letters, bars, economy, profile, auth)

### 2. Renommage recommandé
Convention: `{feature}_{screen}_{version}.png`

Exemples:
- `profile_edit_v1.png` - Écran d'édition de profil
- `letters_list_v1.png` - Liste des lettres
- `bars_main_v1.png` - Interface principale des bars
- `economy_shop_v1.png` - Boutique d'offrandes

### 3. Organisation dans les dossiers
```
features/
├── auth/          # Connexion, inscription
├── profile/       # Profil, édition, paramètres  
├── letters/       # Système de lettres
├── bars/          # Bars virtuels
└── economy/       # Points, offrandes, récompenses
```

## 💡 Commandes utiles

### Renommer une image
```bash
mv mobile/IMG_XXXX.PNG features/profile/profile_edit_v1.png
```

### Voir une image (si imagemagick installé)
```bash
identify mobile/IMG_XXXX.PNG  # Infos techniques
```
EOF

echo ""
echo "📄 Rapport généré: $REPORT_FILE"
echo ""
echo "🚀 Prochaines étapes recommandées:"
echo "1. Examiner les captures pour identifier les écrans"
echo "2. Les renommer et organiser par fonctionnalité"
echo "3. Mettre à jour le README avec les vraies images"