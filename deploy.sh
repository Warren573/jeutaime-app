#!/bin/bash

# 🚀 Script de Build et Déploiement JeuTaime
# Usage: ./deploy.sh [web|android|ios]

set -e  # Exit on any error

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'affichage
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Configuration
PROJECT_NAME="JeuTaime"
BUILD_MODE="release"
PLATFORM=${1:-web}

log_info "🚀 Démarrage du build $PROJECT_NAME pour $PLATFORM"

# Vérification des prérequis
check_flutter() {
    log_info "Vérification de Flutter..."
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé. Veuillez installer Flutter SDK."
        exit 1
    fi
    
    flutter --version
    log_success "Flutter est installé et accessible"
}

# Nettoyage des builds précédents
clean_build() {
    log_info "Nettoyage des builds précédents..."
    flutter clean
    rm -rf build/
    log_success "Nettoyage terminé"
}

# Installation des dépendances
install_dependencies() {
    log_info "Installation des dépendances..."
    flutter pub get
    log_success "Dépendances installées"
}

# Analyse du code
analyze_code() {
    log_info "Analyse du code..."
    flutter analyze --no-fatal-infos
    log_success "Analyse du code terminée"
}

# Tests
run_tests() {
    log_info "Exécution des tests..."
    if [ -d "test" ]; then
        flutter test
        log_success "Tests passés avec succès"
    else
        log_warning "Aucun test trouvé"
    fi
}

# Build Web
build_web() {
    log_info "Build Web en cours..."
    flutter build web --$BUILD_MODE \
        --web-renderer canvaskit \
        --source-maps \
        --dart-define=FLUTTER_WEB_USE_SKIA=true
    
    log_success "Build Web terminé avec succès"
    log_info "Fichiers générés dans: build/web/"
}

# Build Android
build_android() {
    log_info "Build Android en cours..."
    flutter build apk --$BUILD_MODE \
        --split-per-abi \
        --target-platform android-arm,android-arm64,android-x64
    
    log_success "Build Android terminé avec succès"
    log_info "APK générés dans: build/app/outputs/flutter-apk/"
}

# Build iOS
build_ios() {
    log_info "Build iOS en cours..."
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "Build iOS uniquement disponible sur macOS"
        exit 1
    fi
    
    flutter build ios --$BUILD_MODE --no-codesign
    log_success "Build iOS terminé avec succès"
    log_info "App générée dans: build/ios/iphoneos/"
}

# Optimisation des assets
optimize_assets() {
    log_info "Optimisation des assets..."
    
    # Compression des images si ImageMagick est disponible
    if command -v convert &> /dev/null; then
        find assets/images -name "*.png" -exec convert {} -strip -quality 85 {} \;
        log_success "Images PNG optimisées"
    fi
    
    # Vérification de la taille des assets
    ASSETS_SIZE=$(du -sh assets/ 2>/dev/null | cut -f1 || echo "N/A")
    log_info "Taille des assets: $ASSETS_SIZE"
}

# Génération du rapport de build
generate_report() {
    log_info "Génération du rapport de build..."
    
    BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    BUILD_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    
    cat > build_report.md << EOF
# 📊 Rapport de Build - $PROJECT_NAME

## 📋 Informations Générales
- **Date de build**: $BUILD_DATE
- **Plateforme**: $PLATFORM
- **Mode**: $BUILD_MODE
- **Commit**: $BUILD_HASH
- **Flutter**: $(flutter --version | head -n1)

## 📁 Fichiers Générés
EOF

    if [ "$PLATFORM" = "web" ]; then
        cat >> build_report.md << EOF
- **Build Web**: \`build/web/\`
- **Taille bundle**: $(du -sh build/web 2>/dev/null | cut -f1 || echo "N/A")
- **Fichiers principaux**:
  - \`index.html\`
  - \`main.dart.js\` $(ls -lh build/web/main.dart.js 2>/dev/null | awk '{print $5}' || echo "N/A")
  - \`flutter.js\`
  - \`assets/\`
EOF
    fi

    cat >> build_report.md << EOF

## ✅ Statut
Build terminé avec succès ✨

---
*Généré automatiquement par le script de déploiement*
EOF

    log_success "Rapport généré: build_report.md"
}

# Déploiement Firebase (si configuré)
deploy_firebase() {
    log_info "Préparation du déploiement Firebase..."
    
    if [ ! -f "firebase.json" ]; then
        log_warning "firebase.json non trouvé. Création d'une configuration par défaut..."
        cat > firebase.json << EOF
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(png|jpg|jpeg|gif|ico|svg)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
EOF
        log_success "Configuration Firebase créée"
    fi
    
    if command -v firebase &> /dev/null; then
        log_info "Déploiement sur Firebase Hosting..."
        firebase deploy --only hosting
        log_success "Déploiement Firebase terminé"
    else
        log_warning "Firebase CLI non installé. Installez avec: npm install -g firebase-tools"
        log_info "Pour déployer manuellement:"
        log_info "1. Installez Firebase CLI: npm install -g firebase-tools"
        log_info "2. Connectez-vous: firebase login"
        log_info "3. Initialisez: firebase init hosting"
        log_info "4. Déployez: firebase deploy"
    fi
}

# Fonction principale
main() {
    echo "🎯 $PROJECT_NAME - Script de Build et Déploiement"
    echo "=================================================="
    
    check_flutter
    clean_build
    install_dependencies
    analyze_code
    # run_tests  # Désactivé car pas de tests pour le moment
    optimize_assets
    
    case $PLATFORM in
        "web")
            build_web
            generate_report
            read -p "Voulez-vous déployer sur Firebase? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                deploy_firebase
            fi
            ;;
        "android")
            build_android
            generate_report
            ;;
        "ios")
            build_ios
            generate_report
            ;;
        *)
            log_error "Plateforme non supportée: $PLATFORM"
            log_info "Plateformes disponibles: web, android, ios"
            exit 1
            ;;
    esac
    
    echo
    log_success "🎉 Build $PLATFORM terminé avec succès!"
    log_info "📊 Consultez le rapport: build_report.md"
    
    if [ "$PLATFORM" = "web" ]; then
        log_info "🌐 Pour tester localement: python -m http.server 8080 -d build/web"
    fi
}

# Exécution du script principal
main "$@"