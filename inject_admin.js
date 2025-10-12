// Script d'injection d'interface admin pour JeuTaime
(function() {
    console.log('🔧 Injection de l\'interface administrateur JeuTaime...');
    
    // Créer le bouton admin
    const adminButton = document.createElement('div');
    adminButton.innerHTML = `
        <div id="jeutaime-admin-btn" style="
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 999999;
            background: linear-gradient(135deg, #6A1B9A, #9C27B0);
            border: none;
            padding: 15px 25px;
            border-radius: 25px;
            color: white;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 5px 20px rgba(156, 39, 176, 0.5);
            animation: adminGlow 3s ease-in-out infinite;
            font-size: 16px;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            user-select: none;
            transition: all 0.3s ease;
        " onclick="window.open('/APERCU_INTERFACE_ADMIN.html', '_blank', 'width=1200,height=800')">
            🔧 Interface Admin
        </div>
    `;
    
    // Ajouter les styles d'animation
    const style = document.createElement('style');
    style.textContent = `
        @keyframes adminGlow {
            0%, 100% { 
                box-shadow: 0 5px 20px rgba(156, 39, 176, 0.5);
                transform: scale(1);
            }
            50% { 
                box-shadow: 0 8px 30px rgba(156, 39, 176, 0.8);
                transform: scale(1.02);
            }
        }
        
        #jeutaime-admin-btn:hover {
            transform: scale(1.05) !important;
            box-shadow: 0 8px 30px rgba(156, 39, 176, 0.8) !important;
        }
        
        #jeutaime-admin-btn:active {
            transform: scale(0.98) !important;
        }
    `;
    
    // Injecter dans la page
    document.head.appendChild(style);
    document.body.appendChild(adminButton);
    
    console.log('✅ Interface admin injectée avec succès !');
    
    // Message de confirmation après 2 secondes
    setTimeout(() => {
        console.log('🎯 Bouton admin visible en haut à droite !');
    }, 2000);
})();