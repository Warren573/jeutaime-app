# 🚀 Guide de Déploiement - JeuTaime

## 📋 Prérequis

### 🛠️ Outils Nécessaires
```bash
# Flutter SDK (dernière version stable)
flutter --version

# Firebase CLI
npm install -g firebase-tools

# Git (pour le versioning)
git --version

# Optionnel: Docker pour builds isolés
docker --version
```

### 🔧 Configuration Initiale
```bash
# 1. Cloner le repository
git clone https://github.com/Warren573/jeutaime-app.git
cd jeutaime-app

# 2. Installer les dépendances Flutter
flutter pub get

# 3. Se connecter à Firebase
firebase login

# 4. Sélectionner le projet Firebase
firebase use --add
```

## 🌐 Déploiement Web

### 🚀 Déploiement Automatique
```bash
# Utiliser le script automatisé
./deploy.sh web

# Ou avec déploiement Firebase direct
./deploy.sh web --deploy
```

### 📝 Déploiement Manuel
```bash
# 1. Build de production
flutter build web --release \
  --web-renderer canvaskit \
  --source-maps \
  --dart-define=FLUTTER_WEB_USE_SKIA=true

# 2. Test local
python -m http.server 8080 -d build/web

# 3. Déploiement Firebase
firebase deploy --only hosting
```

### ⚙️ Optimisations Web
```bash
# Build avec optimisations avancées
flutter build web --release \
  --web-renderer canvaskit \
  --tree-shake-icons \
  --source-maps \
  --base-href "/" \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=true
```

## 📱 Déploiement Mobile

### 🤖 Android
```bash
# 1. Build APK de production
flutter build apk --release --split-per-abi

# 2. Build AAB pour Play Store
flutter build appbundle --release

# 3. Signature (si configurée)
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore release-key.jks \
  build/app/outputs/flutter-apk/app-release.apk \
  alias_name
```

### 🍎 iOS
```bash
# 1. Build pour App Store
flutter build ios --release

# 2. Archive depuis Xcode
open ios/Runner.xcworkspace

# 3. Distribution via Xcode ou Fastlane
# Suivre les étapes dans Xcode > Product > Archive
```

## 🔧 Configuration Firebase

### 🌐 Firebase Hosting
```json
{
  "hosting": {
    "public": "build/web",
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css|wasm)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000, immutable"
          }
        ]
      }
    ]
  }
}
```

### 🔐 Règles de Sécurité Firestore
```javascript
// infra/firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users peuvent lire/écrire leur propre document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chats - accès limité aux participants
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Messages - accès via chat
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
    }
  }
}
```

### 🗄️ Règles de Sécurité Storage
```javascript
// infra/storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Images de profil
    match /profiles/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
    
    // Images de chat
    match /chats/{chatId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🔒 Variables d'Environnement

### 📝 Configuration Production
```bash
# .env.production
FLUTTER_WEB_USE_SKIA=true
FIREBASE_ENV=production
API_BASE_URL=https://api.jeutaime.app
SENTRY_DSN=your_sentry_dsn_here
ANALYTICS_ID=your_analytics_id
```

### 🧪 Configuration Staging
```bash
# .env.staging
FLUTTER_WEB_USE_SKIA=true
FIREBASE_ENV=staging
API_BASE_URL=https://staging-api.jeutaime.app
DEBUG_MODE=true
```

## 📊 Monitoring et Analytics

### 📈 Firebase Analytics
```bash
# Activation dans Firebase Console
# Performance Monitoring
# Crashlytics pour iOS/Android
```

### 🔍 Sentry (Optionnel)
```bash
# Installation
flutter pub add sentry_flutter

# Configuration dans main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN';
  },
  appRunner: () => runApp(MyApp()),
);
```

## 🚀 CI/CD avec GitHub Actions

### 📝 .github/workflows/deploy.yml
```yaml
name: Deploy JeuTaime
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Analyze code
        run: flutter analyze
        
      - name: Run tests
        run: flutter test
        
      - name: Build web
        run: flutter build web --release
        
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: your-firebase-project-id
```

## 🔍 Tests de Déploiement

### ✅ Checklist Pre-Deploy
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Build réussit sans erreurs
- [ ] Assets optimisés
- [ ] Variables d'environnement configurées
- [ ] Règles Firebase mises à jour
- [ ] SSL/TLS configuré

### 🧪 Tests Post-Deploy
```bash
# Test de base
curl -I https://your-app-url.web.app

# Test des routes
curl https://your-app-url.web.app/profile
curl https://your-app-url.web.app/chat

# Test des assets
curl -I https://your-app-url.web.app/assets/images/logo.png
```

## 📱 Tests Multi-Plateformes

### 🌐 Web Testing
```bash
# Chrome
google-chrome --incognito https://your-app-url.web.app

# Firefox
firefox -private-window https://your-app-url.web.app

# Safari (macOS)
open -a Safari https://your-app-url.web.app
```

### 📱 Mobile Testing
```bash
# Android Emulator
flutter run -d android

# iOS Simulator (macOS)
flutter run -d ios

# Physical Device
flutter run -d <device-id>
```

## 🔧 Troubleshooting

### ❌ Erreurs Communes

#### Build Web Fail
```bash
# Clear cache
flutter clean
flutter pub get
rm -rf build/

# Rebuild
flutter build web --release --verbose
```

#### Firebase Deploy Fail
```bash
# Vérifier la configuration
firebase projects:list
firebase use --add

# Vérifier les permissions
firebase login --reauth
```

#### Performance Issues
```bash
# Analyser la taille du bundle
flutter build web --analyze-size

# Profiler l'app
flutter run --profile -d chrome
```

## 📊 Métriques de Production

### 🎯 KPIs à Surveiller
- **Page Load Time**: < 3 secondes
- **First Contentful Paint**: < 1.5 secondes
- **Largest Contentful Paint**: < 2.5 secondes
- **Cumulative Layout Shift**: < 0.1
- **First Input Delay**: < 100ms

### 📈 Outils de Monitoring
- **Firebase Performance**: Temps de chargement
- **Firebase Analytics**: Utilisation et engagement
- **Firebase Crashlytics**: Erreurs et crashes
- **Google PageSpeed Insights**: Performance web

---

## 🎉 Déploiement Réussi !

Une fois le déploiement terminé :

1. ✅ **Vérifiez l'URL de production**
2. 📱 **Testez sur différents devices**
3. 📊 **Configurez le monitoring**
4. 🔒 **Vérifiez la sécurité**
5. 📈 **Surveillez les métriques**

**JeuTaime est maintenant live ! 🚀**