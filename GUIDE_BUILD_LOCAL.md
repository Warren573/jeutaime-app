# 📱 Guide de Compilation APK Local - JeuTaime App

## 🎯 Objectif
Ce guide vous permet de compiler l'APK Android de JeuTaime en local, contournant les limitations de mémoire de Codespaces.

## 📋 Prérequis

### 🔧 Outils Nécessaires
- **Android Studio** (dernière version stable)
- **Flutter SDK** (version 3.3.0 ou plus récente)
- **Java JDK** (version 11 ou plus récente)
- **Git** pour cloner le projet
- **8GB de RAM minimum** recommandés

### 📱 Configuration Android
- **SDK Android 33** (API level 33) minimum
- **Build Tools 33.0.0** ou plus récent
- **Android Emulator** ou téléphone physique pour les tests

## 🚀 Installation Étape par Étape

### 1. 📥 Installation Flutter

```bash
# Sur Windows
# Télécharger Flutter depuis https://flutter.dev/docs/get-started/install/windows
# Extraire dans C:\flutter

# Sur macOS
brew install flutter

# Sur Linux
sudo snap install flutter --classic

# Vérifier l'installation
flutter doctor
```

### 2. 🛠 Configuration Android Studio

```bash
# Ouvrir Android Studio
# Aller dans Tools > SDK Manager
# Installer :
# - Android SDK Platform 33
# - Android Build Tools 33.0.0
# - Android Emulator
# - Google Play System Images

# Configurer les variables d'environnement
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### 3. 📦 Cloner le Projet

```bash
# Cloner le repository
git clone https://github.com/Warren573/jeutaime-app.git
cd jeutaime-app

# Passer sur la bonne branche
git checkout feature/complete-jeutaime-systems

# Installer les dépendances
flutter pub get
```

### 4. ⚙️ Configuration Gradle Optimisée

Modifier `android/gradle.properties` :

```properties
# Optimisation mémoire pour compilation locale
org.gradle.jvmargs=-Xmx4G -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.daemon=true
org.gradle.caching=true

# Configuration Android
android.useAndroidX=true
android.enableJetifier=true
android.enableR8=true
android.compileSdkVersion=33
android.targetSdkVersion=33
android.minSdkVersion=21

# Optimisation build
android.enableDexingArtifactTransform=false
android.enableBuildCache=true
```

### 5. 🔧 Configuration Android App

Vérifier `android/app/build.gradle` :

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "com.jeutaime.app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 🔨 Compilation

### 1. 🧪 Mode Debug (Développement)

```bash
# Compiler APK debug
flutter build apk --debug --target lib/main_offline.dart

# Installer sur appareil connecté
flutter install --debug --target lib/main_offline.dart
```

### 2. 🚀 Mode Release (Production)

```bash
# Nettoyer le cache
flutter clean
flutter pub get

# Compiler APK release
flutter build apk --release --target lib/main_offline.dart

# L'APK sera dans : build/app/outputs/flutter-apk/app-release.apk
```

### 3. 📦 Bundle Android (Play Store)

```bash
# Pour distribution Play Store
flutter build appbundle --release --target lib/main_offline.dart

# Le bundle sera dans : build/app/outputs/bundle/release/app-release.aab
```

## 🐛 Résolution des Problèmes

### ❌ Erreur de Mémoire
```bash
# Si erreur "OutOfMemoryError"
export GRADLE_OPTS="-XX:MaxHeapSize=4g -Xmx4g"

# Ou modifier android/gradle.properties
org.gradle.jvmargs=-Xmx6G -XX:MaxPermSize=1G
```

### ❌ Erreur de Signature
```bash
# Générer une clé de signature debug
keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000
```

### ❌ Problème de Dépendances
```bash
# Nettoyer et réinstaller
flutter clean
flutter pub cache repair
flutter pub get
```

### ❌ Erreur de Build Tools
```bash
# Vérifier les outils installés
flutter doctor -v

# Mettre à jour Flutter
flutter upgrade
flutter doctor --android-licenses
```

## 📊 Optimisations de Performance

### 🚀 Build Release Optimisé

```bash
# Build avec optimisations maximales
flutter build apk --release \
  --target lib/main_offline.dart \
  --obfuscate \
  --split-debug-info=debug-info/ \
  --tree-shake-icons \
  --target-platform android-arm64
```

### 💾 Réduction de Taille

```bash
# Build séparé par architecture (plus petit)
flutter build apk --release \
  --target lib/main_offline.dart \
  --split-per-abi

# Génère :
# - app-arm64-v8a-release.apk (pour téléphones récents)
# - app-armeabi-v7a-release.apk (pour téléphones anciens)
# - app-x86_64-release.apk (pour émulateurs)
```

## 🧪 Tests et Validation

### 📱 Test sur Émulateur

```bash
# Lancer émulateur
flutter emulators --launch <emulator_id>

# Installer et tester
flutter run --release --target lib/main_offline.dart
```

### 📲 Test sur Appareil Physique

```bash
# Activer le mode développeur sur Android
# Connecter en USB avec débogage activé

# Vérifier la détection
flutter devices

# Installer
flutter install --release --target lib/main_offline.dart
```

## 📁 Structure des Fichiers Générés

```
build/app/outputs/
├── flutter-apk/
│   ├── app-release.apk          # APK principal
│   ├── app-arm64-v8a-release.apk # APK ARM64
│   └── app-armeabi-v7a-release.apk # APK ARM32
├── bundle/release/
│   └── app-release.aab          # Bundle Play Store
└── mapping/release/
    └── mapping.txt              # Fichier de mapping (obfuscation)
```

## 🎯 Commandes Utiles

```bash
# Analyser la taille de l'APK
flutter build apk --analyze-size --target lib/main_offline.dart

# Profiler la performance
flutter run --profile --target lib/main_offline.dart

# Debug en mode release
flutter run --release --enable-software-rendering --target lib/main_offline.dart

# Vérifier la signature
jarsigner -verify -verbose -certs app-release.apk
```

## 🚀 Automatisation (Optionnel)

### Script de Build Automatique

Créer `build-android.sh` :

```bash
#!/bin/bash
echo "🚀 Compilation JeuTaime Android"

# Nettoyer
echo "🧹 Nettoyage..."
flutter clean
flutter pub get

# Build
echo "📦 Compilation APK..."
flutter build apk --release \
  --target lib/main_offline.dart \
  --obfuscate \
  --split-debug-info=debug-info/ \
  --tree-shake-icons

echo "✅ APK généré dans : build/app/outputs/flutter-apk/"
echo "📱 Prêt pour installation !"
```

## 📞 Support

### 🔗 Liens Utiles
- **Documentation Flutter** : https://flutter.dev/docs
- **Android Studio** : https://developer.android.com/studio
- **Flutter Doctor** : `flutter doctor -v`

### 🐛 Signaler un Bug
Si vous rencontrez des problèmes lors de la compilation, veuillez :
1. Exécuter `flutter doctor -v`
2. Partager les logs d'erreur complets
3. Indiquer votre système d'exploitation
4. Préciser les étapes qui ont échoué

---

**📱 JeuTaime App - Mode Offline Fonctionnel ✅**
*Compilé et testé avec Flutter 3.35.4*