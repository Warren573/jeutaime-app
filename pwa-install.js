// Script PWA pour l'installation et les notifications
let deferredPrompt;
let installButton;

window.addEventListener('beforeinstallprompt', (e) => {
  console.log('PWA Installation disponible');
  e.preventDefault();
  deferredPrompt = e;
  
  // Afficher le bouton d'installation personnalisé
  showInstallButton();
});

function showInstallButton() {
  // Créer un bouton d'installation personnalisé si pas déjà présent
  if (!document.querySelector('.pwa-install-btn')) {
    const installBtn = document.createElement('div');
    installBtn.className = 'pwa-install-btn';
    installBtn.innerHTML = `
      <div style="
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(135deg, #FF1493, #FF69B4);
        color: white;
        padding: 12px 24px;
        border-radius: 25px;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(255, 20, 147, 0.3);
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        font-size: 14px;
        font-weight: 600;
        z-index: 10000;
        transition: all 0.3s ease;
      " onclick="installPWA()">
        📱 Installer JeuTaime
      </div>
    `;
    
    document.body.appendChild(installBtn);
    installButton = installBtn;
  }
}

function installPWA() {
  if (deferredPrompt) {
    deferredPrompt.prompt();
    
    deferredPrompt.userChoice.then((choiceResult) => {
      if (choiceResult.outcome === 'accepted') {
        console.log('✅ PWA installée avec succès');
        hideInstallButton();
      } else {
        console.log('❌ Installation PWA annulée');
      }
      deferredPrompt = null;
    });
  }
}

function hideInstallButton() {
  if (installButton) {
    installButton.style.display = 'none';
  }
}

// Vérifier si l'app est déjà installée
window.addEventListener('appinstalled', (evt) => {
  console.log('✅ JeuTaime PWA installée');
  hideInstallButton();
});

// Détection du mode standalone (app installée)
if (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) {
  console.log('🚀 JeuTaime PWA en mode standalone');
  hideInstallButton();
}

// Service Worker registration
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/flutter_service_worker.js')
      .then((registration) => {
        console.log('✅ Service Worker enregistré:', registration.scope);
      })
      .catch((error) => {
        console.log('❌ Échec Service Worker:', error);
      });
  });
}

// Gestion de la connexion en ligne/hors ligne
window.addEventListener('online', () => {
  console.log('🌐 Connexion rétablie');
  showNetworkStatus('online');
});

window.addEventListener('offline', () => {
  console.log('📵 Mode hors ligne');
  showNetworkStatus('offline');
});

function showNetworkStatus(status) {
  const existingStatus = document.querySelector('.network-status');
  if (existingStatus) {
    existingStatus.remove();
  }
  
  const statusDiv = document.createElement('div');
  statusDiv.className = 'network-status';
  statusDiv.innerHTML = `
    <div style="
      position: fixed;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%);
      background: ${status === 'online' ? '#4CAF50' : '#FF5722'};
      color: white;
      padding: 10px 20px;
      border-radius: 20px;
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
      font-size: 14px;
      z-index: 10000;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    ">
      ${status === 'online' ? '🌐 Connexion rétablie' : '📵 Mode hors ligne'}
    </div>
  `;
  
  document.body.appendChild(statusDiv);
  
  setTimeout(() => {
    statusDiv.remove();
  }, 3000);
}