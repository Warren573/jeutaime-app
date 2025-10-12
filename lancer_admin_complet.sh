#!/bin/bash

echo "🔧 JeuTaime - Compilation avec Interface Admin"
echo "=============================================="
echo ""

# Vérifier Flutter
echo "📋 Vérification de Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter non trouvé, ajout au PATH..."
    export PATH="$PATH:/tmp/flutter_sdk/bin"
fi

echo "✅ Flutter détecté"
echo ""

# Nettoyer et préparer
echo "🧹 Nettoyage des anciens builds..."
flutter clean > /dev/null 2>&1

echo "📦 Récupération des dépendances..."
flutter pub get > /dev/null 2>&1

echo "🔧 Compilation avec les boutons admin..."
echo ""
echo "📍 Boutons admin ajoutés :"
echo "   • En-tête : Bouton 🔧 Admin (avec effet lumineux)"
echo "   • Écran principal : Section outils"
echo "   • Paramètres : Section Administration"
echo ""

# Compilation pour le web
echo "🌐 Compilation Flutter Web..."
flutter build web --target=lib/main_jeutaime.dart --web-renderer html --no-tree-shake-icons

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ COMPILATION RÉUSSIE !"
    echo ""
    echo "🚀 Lancement du serveur..."
    
    # Lancer le serveur
    cd build/web && python3 -m http.server 8080 &
    SERVER_PID=$!
    
    echo ""
    echo "🎯 Application JeuTaime avec interface admin disponible sur :"
    echo "   http://localhost:8080"
    echo ""
    echo "📍 Cherchez les boutons 🔧 Admin dans :"
    echo "   1. En-tête (à côté des coins 💰)"
    echo "   2. Écran principal (section outils)"
    echo "   3. Onglet Paramètres ⚙️"
    echo ""
    echo "Appuyez sur Ctrl+C pour arrêter le serveur"
    
    # Attendre l'interruption
    trap "kill $SERVER_PID; exit" SIGINT
    wait $SERVER_PID
    
else
    echo ""
    echo "❌ ERREUR DE COMPILATION"
    echo ""
    echo "🔄 Tentative avec Flutter run..."
    flutter run -d web-server --web-port=8080 --target=lib/main_jeutaime.dart
fi