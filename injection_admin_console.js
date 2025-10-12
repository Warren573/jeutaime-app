// 🚀 Script d'injection admin - JeuTaime
// À coller dans la console du navigateur pour ajouter le bouton admin

(function() {
    console.log('🔧 Injection de l\'interface administrateur JeuTaime...');
    
    // Supprimer ancien bouton s'il existe
    const existingBtn = document.getElementById('jeutaime-admin-btn');
    if (existingBtn) {
        existingBtn.remove();
    }
    
    // Créer le bouton admin flottant
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
            display: flex;
            align-items: center;
            gap: 8px;
        " onclick="window.open('http://localhost:3000/APERCU_INTERFACE_ADMIN.html', '_blank', 'width=1400,height=900')">
            🔧 <span>Interface Admin</span>
        </div>
    `;
    
    // Ajouter les styles d'animation
    if (!document.getElementById('admin-styles')) {
        const style = document.createElement('style');
        style.id = 'admin-styles';
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
        document.head.appendChild(style);
    }
    
    // Injecter dans la page
    document.body.appendChild(adminButton);
    
    console.log('✅ Interface admin injectée avec succès !');
    console.log('🎯 Bouton admin visible en haut à droite !');
    console.log('🖱️ Cliquez pour ouvrir l\'interface complète');
    
    // Notification visuelle
    setTimeout(() => {
        const notification = document.createElement('div');
        notification.innerHTML = `
            <div style="
                position: fixed;
                top: 80px;
                right: 20px;
                z-index: 999998;
                background: #2a2a2a;
                color: white;
                padding: 10px 15px;
                border-radius: 10px;
                font-size: 14px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.3);
                animation: slideInRight 0.5s ease-out;
            ">
                ✅ Bouton admin ajouté !
            </div>
        `;
        
        const notifStyle = document.createElement('style');
        notifStyle.textContent = `
            @keyframes slideInRight {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
        `;
        document.head.appendChild(notifStyle);
        document.body.appendChild(notification);
        
        // Supprimer la notification après 3 secondes
        setTimeout(() => {
            notification.remove();
            notifStyle.remove();
        }, 3000);
    }, 500);
    
})();

// Message de confirmation
console.log(`
🎉 INJECTION ADMIN RÉUSSIE !

📊 Interface admin disponible avec:
• Dashboard avec métriques business
• 4,287 utilisateurs (892 actifs)
• 347 abonnements premium  
• 24,160€ de revenus mensuels
• Gestion complète des bars et jeux

🎯 Cliquez sur le bouton "🔧 Interface Admin" en haut à droite !
`);