# JeuTaime App 💝

[![Deploy to GitHub Pages](https://github.com/Warren573/jeutaime_app/actions/workflows/deploy.yml/badge.svg)](https://github.com/Warren573/jeutaime_app/actions/workflows/deploy.yml)

Application de rencontre ludique et authentique - JeuTaime

## 🚀 Live Demo

**Test the app live:** [https://warren573.github.io/jeutaime_app/](https://warren573.github.io/jeutaime_app/)

The app is automatically deployed to GitHub Pages on every push to the main branch.

## 📱 Features

- ✅ **PWA (Progressive Web App)** - Installable on mobile and desktop
- ✅ **Mode Offline/Online** - Works without internet connection
- ✅ **Modern Interface** - Smooth animations and beautiful design
- ✅ **Bar System** - 5 themed bars for different moods
- ✅ **Authentication** - Complete offline authentication system
- ✅ **Dark/Light Mode** - Automatic theme switching

## 🛠️ Development

### Local Setup

```bash
# Install dependencies
flutter pub get

# Run in development mode
flutter run -d chrome --target lib/main_offline.dart

# Build for production
flutter build web --target lib/main_offline.dart --base-href / --release
```

### Deployment Options

#### GitHub Pages (Automatic)
Push to main branch and GitHub Actions will automatically build and deploy.

#### Netlify
```bash
./deploy.sh
# Then drag & drop build/web to netlify.com
```

#### Vercel
```bash
npm i -g vercel
vercel --prod
```

## 📖 Documentation

- [Guide de présentation](GUIDE_PRESENTATION.md)
- [Guide de build local](GUIDE_BUILD_LOCAL.md)
- [Prochaines étapes](PROCHAINES_ETAPES.md)
- [Guide de test](TESTING_GUIDE.md)
