#!/bin/bash
# Correction des doubles virgules
cd /workspaces/jeutaime-app

# Corriger les doubles virgules problématiques
sed -i 's/),),),/),),/g' lib/main_jeutaime.dart

echo "✅ Doubles virgules corrigées !"