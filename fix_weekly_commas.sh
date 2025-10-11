#!/bin/bash
# Correction des doubles virgules pour le bar hebdomadaire
cd /workspaces/jeutaime-app

# Corriger les doubles virgules
sed -i 's/),),),/),),/g' lib/main_jeutaime.dart

echo "✅ Corrections appliquées !"