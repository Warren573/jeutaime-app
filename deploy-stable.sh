#!/bin/bash

echo "🚀 DÉPLOIEMENT STABLE JEUTAIME"
echo "=============================="

# Arrêter tous les serveurs existants
echo "📡 Arrêt des serveurs existants..."
pkill -f "python3 -m http.server" 2>/dev/null || true

# Nettoyer le build
echo "🧹 Nettoyage du build..."
flutter clean

# Recompiler l'application
echo "⚙️ Compilation de l'application..."
flutter build web --release --base-href="/"

# Vérifier que le build a réussi
if [ ! -f "build/web/index.html" ]; then
    echo "❌ ERREUR: La compilation a échoué!"
    exit 1
fi

echo "✅ Compilation réussie!"

# Démarrer le serveur stable
echo "🌐 Démarrage du serveur sur le port 8100..."
cd build/web
python3 -m http.server 8100 &
SERVER_PID=$!

# Attendre que le serveur démarre
sleep 2

# Tester la connectivité
if curl -s http://localhost:8100 >/dev/null; then
    echo "✅ Serveur démarré avec succès!"
    echo ""
    echo "🎉 APPLICATION DISPONIBLE À :"
    echo "https://solid-trout-jjgqg4649rg72qvrw-8100.app.github.dev/"
    echo ""
    echo "📝 IMPORTANT:"
    echo "- Utilisez Ctrl+Shift+R pour forcer le rechargement"
    echo "- Ou ouvrez en navigation privée"
    echo ""
    echo "🔧 Serveur PID: $SERVER_PID"
    echo "Pour arrêter: kill $SERVER_PID"
else
    echo "❌ ERREUR: Le serveur n'a pas pu démarrer!"
    exit 1
fi