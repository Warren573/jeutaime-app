#!/bin/bash
# 🚀 Script de Redémarrage Rapide - JeuTaime App
# Date: 11 Octobre 2025

echo "🎉 Redémarrage de l'environnement JeuTaime..."

# Configuration des couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📂 Répertoire de travail: /workspaces/jeutaime-app${NC}"
cd /workspaces/jeutaime-app

echo -e "${YELLOW}🔍 Vérification de la structure des fichiers...${NC}"

# Vérifier les fichiers principaux
FILES_TO_CHECK=(
    "lib/main_jeutaime.dart"
    "APERCU_INTERFACE_ADMIN.html"
    "lib/utils/performance_optimizer.dart"
    "lib/widgets/optimized_widgets.dart"
    "lib/utils/feedback_system.dart"
    "lib/utils/error_handler.dart"
    "SAUVEGARDE_SESSION_11OCT2025.md"
    "OPTIMISATIONS_COMPLETE.md"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo -e "✅ $file"
    else
        echo -e "${RED}❌ Manquant: $file${NC}"
    fi
done

echo -e "\n${GREEN}🌐 Démarrage du serveur HTTP pour l'interface admin...${NC}"

# Arrêter les processus existants sur le port 3000
echo -e "${YELLOW}🔧 Nettoyage des processus existants...${NC}"
pkill -f "python3 -m http.server 3000" 2>/dev/null || true

# Démarrer le nouveau serveur
echo -e "${BLUE}🚀 Lancement du serveur sur le port 3000...${NC}"
python3 -m http.server 3000 --directory /workspaces/jeutaime-app &
SERVER_PID=$!

# Attendre un peu que le serveur démarre
sleep 2

# Vérifier que le serveur fonctionne
if ps -p $SERVER_PID > /dev/null; then
    echo -e "${GREEN}✅ Serveur HTTP démarré avec succès (PID: $SERVER_PID)${NC}"
    echo -e "${GREEN}🔗 Interface admin accessible sur: http://localhost:3000/APERCU_INTERFACE_ADMIN.html${NC}"
else
    echo -e "${RED}❌ Erreur lors du démarrage du serveur${NC}"
    exit 1
fi

echo -e "\n${BLUE}📋 INFORMATIONS DE SESSION:${NC}"
echo -e "📁 Répertoire: $(pwd)"
echo -e "🌐 Serveur admin: http://localhost:3000/APERCU_INTERFACE_ADMIN.html"
echo -e "📱 App principale: lib/main_jeutaime.dart"
echo -e "📚 Documentation: SAUVEGARDE_SESSION_11OCT2025.md"

echo -e "\n${YELLOW}🎯 OPTIONS DE TRAVAIL:${NC}"
echo -e "1️⃣  Ouvrir l'interface admin: ${BLUE}http://localhost:3000/APERCU_INTERFACE_ADMIN.html${NC}"
echo -e "2️⃣  Modifier l'app Flutter: ${BLUE}lib/main_jeutaime.dart${NC}"
echo -e "3️⃣  Voir les optimisations: ${BLUE}OPTIMISATIONS_COMPLETE.md${NC}"
echo -e "4️⃣  Injection console admin dans l'app existante"

echo -e "\n${GREEN}🔧 COMMANDES UTILES:${NC}"
echo -e "📊 Voir les logs du serveur: ${YELLOW}tail -f /dev/null${NC}"
echo -e "🛑 Arrêter le serveur: ${YELLOW}kill $SERVER_PID${NC}"
echo -e "🔄 Redémarrer: ${YELLOW}./redemarrage_rapide.sh${NC}"

echo -e "\n${GREEN}🎉 Environnement prêt ! Vous pouvez reprendre le développement.${NC}"

# Garder le script actif pour afficher les informations
echo -e "\n${BLUE}Appuyez sur Ctrl+C pour arrêter le serveur et quitter.${NC}"
trap "echo -e '\n${YELLOW}🛑 Arrêt du serveur...$NC'; kill $SERVER_PID 2>/dev/null; echo -e '${GREEN}✅ Serveur arrêté. Au revoir !${NC}'; exit 0" INT

# Attendre indéfiniment (le script reste actif)
wait $SERVER_PID