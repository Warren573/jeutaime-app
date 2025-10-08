#!/bin/bash
# 📱 Script de prévisualisation rapide des captures d'écran
# Génère un aperçu HTML pour identifier facilement les écrans

set -e

MOBILE_DIR="assets/screenshots/mobile"
OUTPUT_FILE="assets/screenshots/preview.html"

echo "🔍 Génération de l'aperçu des captures d'écran..."

# Créer le fichier HTML d'aperçu
cat > "$OUTPUT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📸 Aperçu Captures JeuTaime</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            color: #333;
        }
        .gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        .screenshot-card {
            background: white;
            border-radius: 12px;
            padding: 15px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transition: transform 0.2s ease;
        }
        .screenshot-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .screenshot-img {
            width: 100%;
            max-width: 200px;
            height: auto;
            border-radius: 8px;
            display: block;
            margin: 0 auto 10px;
            border: 1px solid #ddd;
        }
        .screenshot-info {
            text-align: center;
        }
        .filename {
            font-weight: 600;
            color: #2563eb;
            margin-bottom: 5px;
        }
        .filesize {
            color: #64748b;
            font-size: 0.9em;
        }
        .suggested-name {
            background: #f1f5f9;
            color: #334155;
            padding: 8px;
            border-radius: 6px;
            margin-top: 10px;
            font-size: 0.85em;
            border-left: 3px solid #3b82f6;
        }
        .category {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 20px;
            font-size: 0.75em;
            font-weight: 500;
            margin-top: 5px;
        }
        .auth { background: #fef3c7; color: #92400e; }
        .profile { background: #dbeafe; color: #1e40af; }
        .letters { background: #f3e8ff; color: #7c2d12; }
        .bars { background: #dcfce7; color: #166534; }
        .economy { background: #fce7f3; color: #be185d; }
        .unknown { background: #f1f5f9; color: #475569; }
        
        .analysis-form {
            background: white;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
        }
        .form-group {
            margin-bottom: 10px;
        }
        label {
            display: block;
            font-weight: 500;
            margin-bottom: 5px;
            color: #374151;
        }
        select, input {
            width: 100%;
            padding: 8px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 0.9em;
        }
        .rename-button {
            background: #3b82f6;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.85em;
        }
        .rename-button:hover {
            background: #2563eb;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📸 JeuTaime - Aperçu des Captures d'Écran</h1>
        <p>Identifiez et organisez vos captures d'écran par fonctionnalité</p>
    </div>
    
    <div class="gallery">
EOF

# Ajouter chaque image à la galerie
for img in "$MOBILE_DIR"/IMG_*.PNG; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        filesize=$(du -h "$img" | cut -f1)
        
        # Chemin relatif pour l'HTML
        relative_path="mobile/$filename"
        
        cat >> "$OUTPUT_FILE" << EOF
        <div class="screenshot-card">
            <img src="$relative_path" alt="$filename" class="screenshot-img" 
                 onclick="this.style.maxWidth = this.style.maxWidth === '100%' ? '200px' : '100%'">
            <div class="screenshot-info">
                <div class="filename">$filename</div>
                <div class="filesize">Taille: $filesize</div>
                <div class="category unknown">À identifier</div>
                
                <div class="analysis-form">
                    <div class="form-group">
                        <label for="category-$filename">Fonctionnalité:</label>
                        <select id="category-$filename">
                            <option value="unknown">🔍 À identifier</option>
                            <option value="auth">🔐 Authentification</option>
                            <option value="profile">👤 Profil</option>
                            <option value="letters">💌 Lettres</option>
                            <option value="bars">🍸 Bars</option>
                            <option value="economy">💎 Économie</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="screen-$filename">Type d'écran:</label>
                        <input type="text" id="screen-$filename" placeholder="ex: home, list, edit, detail...">
                    </div>
                    <button class="rename-button" onclick="suggestRename('$filename')">
                        💡 Suggérer un nom
                    </button>
                    <div class="suggested-name" id="suggestion-$filename" style="display:none;">
                        Nom suggéré apparaîtra ici
                    </div>
                </div>
            </div>
        </div>
EOF
    fi
done

# Ajouter le JavaScript pour l'interactivité
cat >> "$OUTPUT_FILE" << 'EOF'
    </div>
    
    <script>
        function suggestRename(filename) {
            const category = document.getElementById(`category-${filename}`).value;
            const screen = document.getElementById(`screen-${filename}`).value;
            const suggestionDiv = document.getElementById(`suggestion-${filename}`);
            
            if (category === 'unknown' || !screen) {
                alert('Veuillez sélectionner une fonctionnalité et saisir un type d\'écran');
                return;
            }
            
            const newName = `${category}_${screen}_v1.png`;
            const command = `mv mobile/${filename} features/${category}/${newName}`;
            
            suggestionDiv.style.display = 'block';
            suggestionDiv.innerHTML = `
                <strong>Nom suggéré:</strong> ${newName}<br>
                <strong>Commande:</strong> <code>${command}</code><br>
                <button onclick="copyToClipboard('${command}')" style="margin-top:5px; padding:4px 8px; background:#10b981; color:white; border:none; border-radius:4px; cursor:pointer;">
                    📋 Copier la commande
                </button>
            `;
        }
        
        function copyToClipboard(text) {
            navigator.clipboard.writeText(text).then(() => {
                alert('Commande copiée ! Exécutez-la dans votre terminal.');
            });
        }
        
        // Mise à jour de la catégorie visuelle
        document.addEventListener('change', function(e) {
            if (e.target.tagName === 'SELECT') {
                const card = e.target.closest('.screenshot-card');
                const categoryElement = card.querySelector('.category');
                const value = e.target.value;
                
                categoryElement.className = `category ${value}`;
                
                const labels = {
                    auth: '🔐 Authentification',
                    profile: '👤 Profil', 
                    letters: '💌 Lettres',
                    bars: '🍸 Bars',
                    economy: '💎 Économie',
                    unknown: '🔍 À identifier'
                };
                
                categoryElement.textContent = labels[value] || '🔍 À identifier';
            }
        });
    </script>
</body>
</html>
EOF

echo "✅ Aperçu généré: $OUTPUT_FILE"
echo ""
echo "🌐 Pour voir l'aperçu:"
echo "1. Ouvrez le fichier dans votre navigateur:"
echo "   file://$(pwd)/$OUTPUT_FILE"
echo ""
echo "2. Ou utilisez un serveur local:"
echo "   cd assets/screenshots && python3 -m http.server 8000"
echo "   puis allez sur: http://localhost:8000/preview.html"
echo ""
echo "🎯 Instructions d'utilisation:"
echo "- Cliquez sur une image pour l'agrandir"
echo "- Sélectionnez la fonctionnalité et le type d'écran"  
echo "- Cliquez 'Suggérer un nom' pour obtenir la commande de renommage"
echo "- Copiez et exécutez les commandes dans votre terminal"