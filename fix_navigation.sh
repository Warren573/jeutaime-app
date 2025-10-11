#!/bin/bash
# Script temporaire pour corriger les navigations vers les bars

cd /workspaces/jeutaime-app

# Remplacer la première occurrence du bar humoristique (ligne ~829)
sed -i '829s/_showBarComingSoon('\''Bar Humoristique'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => HumorousBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart

# Remplacer la première occurrence du bar des pirates (ligne ~840) 
sed -i '840s/_showBarComingSoon('\''Bar des Pirates'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => PiratesBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart

# Changer isActive du bar des pirates de false à true (ligne ~836)
sed -i '836s/isActive: false,/isActive: true,/' lib/main_jeutaime.dart

# Répéter pour la deuxième section (lignes ~1097 et ~1108)
sed -i '1097s/_showBarComingSoon('\''Bar Humoristique'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => HumorousBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart
sed -i '1108s/_showBarComingSoon('\''Bar des Pirates'\'')/Navigator.push(context, MaterialPageRoute(builder: (context) => PiratesBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),),/' lib/main_jeutaime.dart
sed -i '1104s/isActive: false,/isActive: true,/' lib/main_jeutaime.dart

echo "✅ Corrections appliquées avec succès !"