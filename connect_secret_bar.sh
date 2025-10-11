#!/bin/bash
# Script pour connecter le Bar Secret

cd /workspaces/jeutaime-app

# Remplacer les occurrences du bar secret (lignes ~866 et ~1134)
sed -i '866s/_showBarComingSoon('\''Bar Secret'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => SecretBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart
sed -i '1134s/_showBarComingSoon('\''Bar Secret'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => SecretBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart

# Changer isActive du bar secret de false à true
sed -i '862s/isActive: false,/isActive: true,/' lib/main_jeutaime.dart
sed -i '1130s/isActive: false,/isActive: true,/' lib/main_jeutaime.dart

echo "✅ Bar Secret connecté avec succès !"