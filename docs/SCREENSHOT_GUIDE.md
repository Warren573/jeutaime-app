# 📷 Guide : Prendre des captures d'écran avec Flutter

## 🎯 Méthodes pour capturer des écrans

### 1. 📱 Captures d'écran sur simulateur/émulateur

#### iOS Simulator (macOS)
```bash
# Prendre une capture d'écran
xcrun simctl io booted screenshot screenshot.png

# Avec date automatique
xcrun simctl io booted screenshot "ios_$(date +%Y%m%d_%H%M%S).png"
```

#### Android Emulator
```bash
# Via ADB
adb exec-out screencap -p > screenshot.png

# Avec date automatique
adb exec-out screencap -p > "android_$(date +%Y%m%d_%H%M%S).png"
```

### 2. 🖥️ Captures d'écran web (Chrome DevTools)

#### Méthode 1 : DevTools
1. `F12` → ouvrir les DevTools
2. `Ctrl+Shift+M` → mode responsive
3. Choisir la taille (iPhone 12, etc.)
4. `Ctrl+Shift+P` → "Capture screenshot"

#### Méthode 2 : Extension navigateur
```bash
# Installer une extension comme "Full Page Screen Capture"
# Ou utiliser les outils intégrés du navigateur
```

### 3. 🛠️ Captures programmatiques avec Flutter

#### Méthode avec RepaintBoundary
```dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ScreenshotHelper {
  static final GlobalKey _repaintBoundaryKey = GlobalKey();
  
  static Widget wrapWithScreenshot(Widget child) {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: child,
    );
  }
  
  static Future<Uint8List?> captureScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Erreur capture d\'écran: $e');
      return null;
    }
  }
}
```

#### Usage dans votre app
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Écran'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _takeScreenshot,
          ),
        ],
      ),
      body: ScreenshotHelper.wrapWithScreenshot(
        // Votre contenu ici
        MyScreenContent(),
      ),
    );
  }
  
  void _takeScreenshot() async {
    Uint8List? imageBytes = await ScreenshotHelper.captureScreenshot();
    if (imageBytes != null) {
      // Sauvegarder l'image
      _saveImage(imageBytes);
    }
  }
}
```

### 4. 🧪 Captures avec les tests d'intégration

#### Créer un test de capture
```dart
// test/screenshot_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jeutaime_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Screenshots', () {
    testWidgets('Capture écran d\'accueil', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await binding.takeScreenshot('home_screen');
    });
    
    testWidgets('Capture écran lettres', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Naviguer vers l'écran lettres
      await tester.tap(find.text('Lettres'));
      await tester.pumpAndSettle();
      
      await binding.takeScreenshot('letters_screen');
    });
  });
}
```

#### Lancer les tests de capture
```bash
# iOS
flutter test integration_test/screenshot_test.dart --screenshot

# Android
flutter test integration_test/screenshot_test.dart --screenshot
```

## 📋 Checklist pour de bonnes captures d'écran

### ✅ Avant la capture
- [ ] Interface en mode sombre/clair selon le design
- [ ] Données de démonstration réalistes (pas de "Lorem ipsum")
- [ ] Notifications/badges cohérents
- [ ] Barre de statut propre (batterie ~80%, signal fort)

### ✅ Paramètres de capture
- [ ] Résolution native du device
- [ ] Format PNG (meilleure qualité)
- [ ] Ratio d'aspect correct (16:9, 19:9, etc.)

### ✅ Après la capture
- [ ] Nommage cohérent : `{feature}_{screen}_{platform}_{version}.png`
- [ ] Organisation dans le bon dossier
- [ ] Optimisation de la taille si nécessaire
- [ ] Mise à jour de la documentation

## 🚀 Automatisation des captures

### Script bash pour captures multiples
```bash
#!/bin/bash
# scripts/take_screenshots.sh

SCREENSHOT_DIR="assets/screenshots"
DATE=$(date +%Y%m%d_%H%M%S)

echo "📷 Prise de captures d'écran automatique..."

# iOS
if [ -n "$(xcrun simctl list devices | grep Booted)" ]; then
    echo "📱 Capture iOS..."
    xcrun simctl io booted screenshot "$SCREENSHOT_DIR/mobile/ios_home_$DATE.png"
fi

# Android
if [ -n "$(adb devices | grep emulator)" ]; then
    echo "🤖 Capture Android..."
    adb exec-out screencap -p > "$SCREENSHOT_DIR/mobile/android_home_$DATE.png"
fi

echo "✅ Captures terminées dans $SCREENSHOT_DIR"
```

### Intégration dans le workflow de développement
```yaml
# .github/workflows/screenshots.yml
name: Generate Screenshots
on:
  push:
    branches: [main]

jobs:
  screenshots:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - name: Run screenshot tests
        run: |
          flutter test integration_test/screenshot_test.dart --screenshot
      - name: Upload screenshots
        uses: actions/upload-artifact@v2
        with:
          name: screenshots
          path: test_driver/screenshots/
```

## 📱 Résolutions recommandées par plateforme

### iOS
- iPhone SE: 375×667
- iPhone 12/13: 390×844
- iPhone 12/13 Pro Max: 428×926
- iPad: 768×1024

### Android
- Phone (MD): 360×640
- Phone (LG): 411×731
- Tablet: 768×1024

### Web
- Desktop: 1920×1080
- Tablet: 768×1024
- Mobile: 375×667