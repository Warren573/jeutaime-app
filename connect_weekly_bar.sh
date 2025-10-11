#!/bin/bash
# Script pour connecter le Bar Hebdomadaire

cd /workspaces/jeutaime-app

# Remplacer les occurrences du bar hebdomadaire (lignes ~853 et ~1121)
sed -i '853s/_showBarComingSoon('\''Bar Hebdomadaire'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => WeeklyBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart
sed -i '1121s/_showBarComingSoon('\''Bar Hebdomadaire'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => WeeklyBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart

echo "✅ Bar Hebdomadaire connecté avec succès !"