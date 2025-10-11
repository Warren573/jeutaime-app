#!/bin/bash
# Correction finale des doubles virgules
cd /workspaces/jeutaime-app

# Corriger les doubles virgules pour le bar secret
sed -i 's/),),),/),),/g' lib/main_jeutaime.dart

echo "✅ Toutes les corrections appliquées !"