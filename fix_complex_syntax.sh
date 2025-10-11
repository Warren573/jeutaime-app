#!/bin/bash
# Script de correction complète du fichier main_jeutaime.dart

cd /workspaces/jeutaime-app

# Sauvegarder
cp lib/main_jeutaime.dart lib/main_jeutaime.dart.broken

# Remplacer ligne par ligne de manière sécurisée
sed -i 's/onTap: () => Navigator\.push(context, MaterialPageRoute(builder: (context) => HumorousBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),,/onTap: () => Navigator.push(\
                    context,\
                    MaterialPageRoute(\
                      builder: (context) => HumorousBarScreen(\
                        onCoinsUpdated: _updateCoins,\
                        currentCoins: _coins,\
                      ),\
                    ),\
                  ),/g' lib/main_jeutaime.dart

sed -i 's/onTap: () => Navigator\.push(context, MaterialPageRoute(builder: (context) => PiratesBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),,/onTap: () => Navigator.push(\
                    context,\
                    MaterialPageRoute(\
                      builder: (context) => PiratesBarScreen(\
                        onCoinsUpdated: _updateCoins,\
                        currentCoins: _coins,\
                      ),\
                    ),\
                  ),/g' lib/main_jeutaime.dart

sed -i 's/onTap: () => Navigator\.push(context, MaterialPageRoute(builder: (context) => WeeklyBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),,/onTap: () => Navigator.push(\
                    context,\
                    MaterialPageRoute(\
                      builder: (context) => WeeklyBarScreen(\
                        onCoinsUpdated: _updateCoins,\
                        currentCoins: _coins,\
                      ),\
                    ),\
                  ),/g' lib/main_jeutaime.dart

sed -i 's/onTap: () => Navigator\.push(context, MaterialPageRoute(builder: (context) => SecretBarScreen(onCoinsUpdated: _updateCoins, currentCoins: _coins,),),,/onTap: () => Navigator.push(\
                    context,\
                    MaterialPageRoute(\
                      builder: (context) => SecretBarScreen(\
                        onCoinsUpdated: _updateCoins,\
                        currentCoins: _coins,\
                      ),\
                    ),\
                  ),/g' lib/main_jeutaime.dart

# Activer le bar secret aussi
sed -i 's/isActive: false,/isActive: true,/g' lib/main_jeutaime.dart

echo "✅ Correction complexe terminée !"