#!/bin/bash

# 🚨 SOLUTIONS DE DÉPANNAGE JEUTAIME

echo "🔧 Diagnostic du Problème de Lancement"
echo "====================================="
echo ""

echo "📊 État de l'Environnement :"
echo "- Répertoire: $(pwd)"
echo "- Utilisateur: $(whoami)"
echo "- Python3: $(which python3)"
echo ""

echo "📁 Fichiers HTML Disponibles :"
echo ""
if [ -f "index.html" ]; then
    size=$(wc -l < index.html)
    echo "✅ index.html ($size lignes) - App complète"
else
    echo "❌ index.html manquant"
fi

if [ -f "build/web/index.html" ]; then
    echo "✅ build/web/index.html - Flutter compilé"
else
    echo "❌ build Flutter Web manquant"
fi

if [ -f "demo_simple.html" ]; then
    echo "✅ demo_simple.html - Version démo"
else
    echo "❌ demo_simple.html manquant"
fi

echo ""
echo "🔧 SOLUTIONS ALTERNATIVES :"
echo ""

echo "1️⃣ MÉTHODE VS CODE LIVE SERVER"
echo "   → Installer l'extension 'Live Server'"
echo "   → Clic droit sur index.html → 'Open with Live Server'"
echo ""

echo "2️⃣ MÉTHODE GITHUB CODESPACES"
echo "   → Onglet 'Ports' dans VS Code"
echo "   → 'Forward a Port' → 8080"
echo "   → Démarrer: python3 -m http.server 8080"
echo ""

echo "3️⃣ MÉTHODE DIRECTE BROWSER"
echo "   → Dans VS Code: Ctrl+Shift+P"
echo "   → 'Simple Browser: Show'"
echo "   → URL: file://$(pwd)/index.html"
echo ""

echo "4️⃣ MÉTHODE NODE.JS"
if command -v node >/dev/null 2>&1; then
    echo "   ✅ Node.js disponible"
    echo "   → npx http-server . -p 8080"
    echo "   → npx serve . -p 8080"
else
    echo "   ❌ Node.js non disponible"
fi
echo ""

echo "5️⃣ MÉTHODE PYTHON BACKGROUND"
echo "   → nohup python3 -m http.server 8080 &"
echo "   → jobs (pour voir le processus)"
echo "   → kill %1 (pour arrêter)"
echo ""

echo "🌐 URLS PRÉVUES SELON L'ENVIRONNEMENT :"
echo ""

# Détecter l'environnement
if [ -n "$CODESPACE_NAME" ]; then
    echo "   ☁️  GitHub Codespaces détecté"
    echo "   → URL auto-générée : https://$CODESPACE_NAME-8080.preview.app.github.dev"
elif [ -n "$GITPOD_WORKSPACE_URL" ]; then
    echo "   ☁️  Gitpod détecté"
    GITPOD_URL=$(echo $GITPOD_WORKSPACE_URL | sed "s/https:\/\//https:\/\/8080-/")
    echo "   → URL Gitpod : $GITPOD_URL"
else
    echo "   🖥️  Environnement local/standard"
    echo "   → URL locale : http://localhost:8080"
fi

echo ""
echo "🎯 TEST RAPIDE - CONTENU DU FICHIER :"
echo ""
if [ -f "index.html" ]; then
    echo "📄 Premiers caractères d'index.html :"
    head -c 200 index.html
    echo ""
    echo "..."
fi

echo ""
echo "🚀 COMMANDES DE TEST SUGGÉRÉES :"
echo ""
echo "# Test 1: Serveur simple"
echo "python3 -m http.server 8080 &"
echo ""
echo "# Test 2: Avec timeout pour éviter le blocage"
echo "timeout 30 python3 -m http.server 8080"
echo ""
echo "# Test 3: Serveur Node.js alternatif"
echo "npx http-server . -p 8080"
echo ""

echo "💡 PROBLÈMES COURANTS :"
echo "   🔒 Permissions → chmod +x start_preview.sh"
echo "   🚫 Port occupé → Changer le port (3000, 8000, 9000)"
echo "   🌐 CORS → Utiliser un serveur, pas file://"
echo "   ⏰ Timeout → Serveur en background avec &"
echo ""

echo "📱 ALTERNATIVE : OUVERTURE DIRECTE"
echo "   Si les serveurs ne marchent pas :"
echo "   → VS Code : Ctrl+Shift+P → 'Simple Browser'"
echo "   → Navigateur : file://$(pwd)/index.html"
echo "   ⚠️  Certaines fonctionnalités JS peuvent être limitées"
echo ""

echo "✅ Prêt pour le dépannage !"