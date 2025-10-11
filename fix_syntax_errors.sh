#!/bin/bash
# Script pour corriger toutes les erreurs de syntaxe

cd /workspaces/jeutaime-app

# Faire une sauvegarde
cp lib/main_jeutaime.dart lib/main_jeutaime.dart.backup

# Corriger les doubles virgules et les problèmes de syntaxe
sed -i 's/),),,/),),/g' lib/main_jeutaime.dart
sed -i 's/ _coins,),),/ _coins,\n                    ),\n                  ),/g' lib/main_jeutaime.dart

echo "✅ Correction des erreurs de syntaxe terminée !"