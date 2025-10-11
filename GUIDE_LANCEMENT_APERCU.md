# 🚀 JeuTaime - Comment Lancer l'Aperçu

## 📱 **MÉTHODES DISPONIBLES**

### **1. 🌐 Version Web Compilée (build/web/)**
```bash
# Démarrer un serveur local
cd /workspaces/jeutaime-app/build/web
python3 -m http.server 8080

# Puis ouvrir dans le navigateur
# → http://localhost:8080
```

### **2. 📄 Version HTML Standalone**
```bash
# Serveur depuis la racine 
cd /workspaces/jeutaime-app
python3 -m http.server 8080

# Fichiers disponibles :
# → http://localhost:8080/index.html (App complète)
# → http://localhost:8080/demo_simple.html (Version démo)
# → http://localhost:8080/jeutaime_mobile_local.html (Mobile)
# → http://localhost:8080/apercu_app_interactif.html (Aperçu technique)
```

### **3. 🚀 GitHub Codespaces/Gitpod**
Si vous êtes dans un environnement cloud :
```bash
# Le serveur sera automatiquement exposé
python3 -m http.server 8080
# → L'URL sera générée automatiquement
```

### **4. 🔗 Version Déployée en Ligne**
Si l'app est déjà déployée :
- **Vercel** : https://jeutaime-app.vercel.app
- **Firebase** : https://jeutaime-warren.web.app  
- **GitHub Pages** : https://warren573.github.io/jeutaime-app

---

## ⚡ **LANCEMENT RAPIDE**

### **Commande Simple :**
```bash
cd /workspaces/jeutaime-app && python3 -m http.server 8080
```

### **Alternative Node.js :**
```bash
cd /workspaces/jeutaime-app && npx serve . -p 8080
```

### **Alternative PHP :**
```bash
cd /workspaces/jeutaime-app && php -S localhost:8080
```

---

## 📱 **VERSIONS DISPONIBLES**

### **🎮 App Flutter Complète (build/web/)**
- **Fichier** : `build/web/index.html`
- **Features** : Tous les jeux, bars, adoption
- **Performance** : Optimisée, 60fps
- **Responsive** : Mobile/Tablet/Desktop

### **🌐 Version HTML Standalone (index.html)**
- **Fichier** : `index.html` (663 lignes)
- **Features** : Interface complète simulée
- **Style** : Thème bois chaleureux
- **Navigation** : 5 onglets fonctionnels

### **📱 Version Mobile (jeutaime_mobile_local.html)**
- **Optimisée** : Spécial smartphones
- **Contrôles** : Tactiles optimisés
- **UI** : Interface mobile-first

### **📊 Aperçu Technique (apercu_app_interactif.html)**
- **Contenu** : Documentation complète
- **Animations** : Statistiques animées
- **Details** : Architecture, features, roadmap

---

## 🔧 **DÉPANNAGE**

### **Problème : "Port déjà utilisé"**
```bash
# Changer le port
python3 -m http.server 3000
# ou
python3 -m http.server 8000
```

### **Problème : "Python non trouvé"**
```bash
# Utiliser Node.js
npx serve . -p 8080

# Ou installer Python
sudo apt update && sudo apt install python3
```

### **Problème : "CORS Error"**
- ❌ Ne PAS ouvrir avec `file://`
- ✅ Utiliser un serveur web local

### **Problème : "Commande non trouvée"**
```bash
# Vérifier les outils disponibles
which python3
which node
which php

# Installer si nécessaire
sudo apt install python3 nodejs php
```

---

## 🎯 **GUIDE ÉTAPE PAR ÉTAPE**

### **Étape 1 : Naviguer vers le projet**
```bash
cd /workspaces/jeutaime-app
```

### **Étape 2 : Choisir la version**
```bash
# Version Flutter compilée (recommandée)
cd build/web && python3 -m http.server 8080

# OU Version HTML standalone  
python3 -m http.server 8080
```

### **Étape 3 : Ouvrir dans le navigateur**
- **URL** : http://localhost:8080
- **Mobile** : Activer le mode responsive (F12)
- **Test** : Naviguer entre les onglets

### **Étape 4 : Tester les fonctionnalités**
- ✅ Navigation 5 onglets
- ✅ Jeux interactifs (8 jeux)
- ✅ Bars thématiques (5 bars)
- ✅ Système adoption
- ✅ Design responsive

---

## 🌟 **FONCTIONNALITÉS À TESTER**

### **🎮 Dans l'Onglet Accueil :**
- Profil utilisateur (niveau, coins)
- Bouton d'accès au profil
- Statistiques XP

### **🍸 Dans l'Onglet Social > Jeux :**
- Réactivité, Puzzle, Précision
- Tic-Tac-Toe, Casse-Briques
- Memory, Snake, Quiz (NOUVEAUX)

### **🏛️ Dans l'Onglet Social > Bars :**
- Bar Romantique, Humoristique  
- Bar Pirates, Hebdomadaire, Secret

### **💝 Dans l'Onglet Social > Adoption :**
- Mode Incarnation vs Adoption
- Soin des animaux (4 stats)
- Économie des coins

---

## 🚀 **PRÊT À TESTER !**

**Commande recommandée :**
```bash
cd /workspaces/jeutaime-app && python3 -m http.server 8080
```

Puis ouvrir **http://localhost:8080** dans votre navigateur ! 🎉