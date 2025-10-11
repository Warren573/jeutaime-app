#!/bin/bash

echo "🚀 JeuTaime - Guide de Lancement de l'Aperçu"
echo "============================================="
echo ""

echo "📱 MÉTHODES POUR LANCER L'APPLICATION :"
echo ""

echo "1️⃣ VIA SERVEUR LOCAL (Recommandé)"
echo "   cd /workspaces/jeutaime-app"
echo "   python3 -m http.server 8080"
echo "   → Puis ouvrir: http://localhost:8080"
echo ""

echo "2️⃣ VIA NODE.JS/NPX"
echo "   cd /workspaces/jeutaime-app" 
echo "   npx serve . -p 8080"
echo "   → Puis ouvrir: http://localhost:8080"
echo ""

echo "3️⃣ VIA PHP (si disponible)"
echo "   cd /workspaces/jeutaime-app"
echo "   php -S localhost:8080"
echo "   → Puis ouvrir: http://localhost:8080"
echo ""

echo "4️⃣ FICHIERS DIRECTS DISPONIBLES :"
echo "   📄 index.html - App principale complète"
echo "   📄 demo_simple.html - Version simplifiée"
echo "   📄 jeutaime_mobile_local.html - Version mobile"
echo "   📄 apercu_app_interactif.html - Aperçu détaillé"
echo ""

echo "5️⃣ VERSION DEPLOYÉE EN LIGNE :"
echo "   🌐 https://jeutaime-app.vercel.app (si déployé)"
echo "   🌐 Firebase hosting URL (si configuré)"
echo ""

echo "📋 VERSIONS DISPONIBLES LOCALEMENT :"
echo ""

# Lister les fichiers HTML disponibles
if [ -f "index.html" ]; then
    echo "   ✅ index.html - Application principale (663 lignes)"
fi

if [ -f "demo_simple.html" ]; then
    echo "   ✅ demo_simple.html - Version démo simplifiée"
fi

if [ -f "jeutaime_mobile_local.html" ]; then  
    echo "   ✅ jeutaime_mobile_local.html - Version mobile optimisée"
fi

if [ -f "apercu_app_interactif.html" ]; then
    echo "   ✅ apercu_app_interactif.html - Aperçu technique avec animations"
fi

if [ -f "presentation.html" ]; then
    echo "   ✅ presentation.html - Page de présentation"
fi

echo ""
echo "🎯 COMMANDE RAPIDE RECOMMANDÉE :"
echo "   python3 -m http.server 8080 &"
echo "   echo 'Serveur démarré sur http://localhost:8080'"
echo ""

echo "⚠️  NOTES IMPORTANTES :"
echo "   - Les fichiers HTML nécessitent un serveur web (pas en file://)"
echo "   - Le port 8080 peut être changé (ex: 3000, 8000, etc.)"
echo "   - Vérifiez que le port n'est pas déjà utilisé"
echo ""

echo "🔧 DÉPANNAGE :"
echo "   Port occupé → Changer le port: python3 -m http.server 3000"
echo "   Python manquant → Utiliser: npx serve . -p 8080"
echo "   Problème CORS → Utiliser un serveur, pas file://"
echo ""

# Vérifier si un serveur est déjà en cours
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Un serveur tourne déjà sur le port 8080"
    echo "   → Ouvrez directement http://localhost:8080"
else
    echo "💡 Aucun serveur détecté sur 8080, vous pouvez le démarrer !"
fi

echo ""
echo "🚀 Prêt à lancer JeuTaime ! 🎮💕"