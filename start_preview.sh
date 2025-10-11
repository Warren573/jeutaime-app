#!/bin/bash

# 🚀 JeuTaime - Script de Lancement Automatique
clear
echo "🎮💕 JeuTaime - Lancement de l'Aperçu"
echo "===================================="
echo ""

# Fonction pour vérifier si un port est libre
check_port() {
    if command -v lsof >/dev/null 2>&1; then
        if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
            return 1  # Port occupé
        else
            return 0  # Port libre
        fi
    else
        return 0  # lsof pas disponible, on essaie quand même
    fi
}

# Fonction pour trouver un port libre
find_free_port() {
    for port in 8080 8000 3000 8888 9000; do
        if check_port $port; then
            echo $port
            return
        fi
    done
    echo 8080  # Par défaut si aucun test possible
}

# Trouver un port libre
PORT=$(find_free_port)

echo "🔍 Vérification de l'environnement..."

# Vérifier Python
if command -v python3 >/dev/null 2>&1; then
    echo "✅ Python3 détecté"
    SERVER_CMD="python3 -m http.server"
elif command -v python >/dev/null 2>&1; then
    echo "✅ Python détecté"  
    SERVER_CMD="python -m http.server"
elif command -v node >/dev/null 2>&1; then
    echo "✅ Node.js détecté, installation de 'serve'..."
    if ! command -v serve >/dev/null 2>&1; then
        npm install -g serve 2>/dev/null || echo "⚠️ Installation serve échouée, on continue..."
    fi
    SERVER_CMD="npx serve . -p"
elif command -v php >/dev/null 2>&1; then
    echo "✅ PHP détecté"
    SERVER_CMD="php -S localhost:"
else
    echo "❌ Aucun serveur web trouvé (Python, Node.js, PHP)"
    echo ""
    echo "📥 INSTALLATION RAPIDE :"
    echo "   Ubuntu/Debian: sudo apt install python3"
    echo "   macOS: brew install python3"
    echo "   Windows: winget install Python.Python.3"
    echo ""
    exit 1
fi

echo ""
echo "📂 Versions disponibles :"
echo ""

# Lister les versions disponibles avec détails
if [ -f "build/web/index.html" ]; then
    echo "   🎮 build/web/ - Flutter App compilée (RECOMMANDÉE)"
fi

if [ -f "index.html" ]; then
    echo "   🌐 index.html - Version HTML complète (663 lignes)"
fi

if [ -f "demo_simple.html" ]; then
    echo "   🎯 demo_simple.html - Version démo simplifiée"
fi

if [ -f "jeutaime_mobile_local.html" ]; then
    echo "   📱 jeutaime_mobile_local.html - Optimisée mobile"
fi

if [ -f "apercu_app_interactif.html" ]; then
    echo "   📊 apercu_app_interactif.html - Documentation technique"
fi

echo ""
echo "🚀 Sélection automatique de la meilleure version..."

# Choisir la meilleure version automatiquement
if [ -f "build/web/index.html" ]; then
    CHOSEN_DIR="build/web"
    CHOSEN_DESC="Flutter App compilée"
    cd build/web 2>/dev/null || cd .
else
    CHOSEN_DIR="."
    CHOSEN_DESC="Version HTML complète"
fi

echo "   ✅ Choix: $CHOSEN_DESC"
echo ""

# Démarrer le serveur
echo "🌐 Démarrage du serveur web..."
echo "   Port: $PORT"
echo "   Dossier: $CHOSEN_DIR"
echo ""

# Afficher les URLs d'accès
echo "📱 URLS D'ACCÈS :"
echo "   🔗 Local: http://localhost:$PORT"
echo "   🔗 Réseau: http://$(hostname -I | awk '{print $1}' 2>/dev/null || echo "IP"):$PORT"

# Si on est dans un environnement cloud
if [ -n "$CODESPACE_NAME" ]; then
    echo "   ☁️  Codespace: https://$CODESPACE_NAME-$PORT.preview.app.github.dev"
elif [ -n "$GITPOD_WORKSPACE_URL" ]; then
    GITPOD_URL=$(echo $GITPOD_WORKSPACE_URL | sed "s/https:\/\//https:\/\/$PORT-/")
    echo "   ☁️  Gitpod: $GITPOD_URL"
fi

echo ""
echo "⚡ FONCTIONNALITÉS À TESTER :"
echo "   🎮 8 Jeux complets (Réactivité, Puzzle, Memory, Snake...)"
echo "   🍸 5 Bars thématiques (Romantique, Humoristique, Pirates...)"
echo "   💝 Système d'adoption (Incarnation + Élevage)"
echo "   👤 Profil utilisateur (XP, niveaux, achievements)"
echo "   📱 Design responsive (mobile/tablet/desktop)"
echo ""

echo "🎯 NAVIGATION :"
echo "   🏠 Accueil → Dashboard principal + profil"
echo "   👤 Profils → Système de swipe"
echo "   👥 Social → Bars + Jeux + Adoption" 
echo "   ✨ Magie → Collection des 5 bars"
echo "   💌 Lettres → Messagerie élégante"
echo ""

# Message de lancement
echo "🚀 Lancement du serveur..."
echo "   Commande: $SERVER_CMD $PORT"
echo ""
echo "⏰ Le serveur va démarrer dans 3 secondes..."
echo "   Appuyez sur Ctrl+C pour arrêter"
echo ""

sleep 3

# Démarrer le serveur selon l'outil disponible
if [[ $SERVER_CMD == *"python"* ]]; then
    echo "🐍 Serveur Python démarré !"
    $SERVER_CMD $PORT
elif [[ $SERVER_CMD == *"serve"* ]]; then
    echo "📦 Serveur Node.js démarré !"
    $SERVER_CMD $PORT
elif [[ $SERVER_CMD == *"php"* ]]; then
    echo "🐘 Serveur PHP démarré !"
    $SERVER_CMD$PORT
fi