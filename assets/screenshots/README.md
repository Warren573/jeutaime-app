# 📸 Captures d'écran JeuTaime

## 📁 Organisation des dossiers

### `/mobile/` - Captures mobiles (iOS/Android)
- Format recommandé : PNG, résolution native du device
- Noms de fichiers : `{screen_name}_{platform}_{date}.png`

### `/web/` - Captures version web
- Format recommandé : PNG, 1920x1080 ou responsive
- Noms de fichiers : `{screen_name}_web_{date}.png`

### `/features/` - Captures par fonctionnalité

#### `/features/auth/` - Authentification
- Écran de connexion
- Écran d'inscription
- Processus d'onboarding

#### `/features/letters/` - Système de lettres
- Liste des conversations
- Écriture d'une lettre
- Lecture d'une lettre
- Boîte à souvenirs

#### `/features/bars/` - Bars virtuels
- Liste des bars disponibles
- Interface d'un bar
- Mini-jeux et défis
- Création de bar privé

#### `/features/economy/` - Système d'économie
- Profil utilisateur avec points
- Boutique d'offrandes
- Historique des transactions
- Écran de récompenses

#### `/features/profile/` - Profil utilisateur
- Vue du profil
- Édition du profil
- Paramètres
- Badges et réalisations

## 📏 Standards de capture

### Résolutions recommandées
- **Mobile** : Native device (ex: 390x844 pour iPhone 12)
- **Web** : 1920x1080 (desktop) ou 768x1024 (tablet)

### Naming convention
```
{feature}_{screen}_{platform}_{version}.png

Exemples :
- letters_list_mobile_v1.png
- bars_main_web_v2.png
- economy_shop_mobile_v1.png
```

### Qualité
- Format : PNG pour la transparence
- Compression : Lossless
- DPI : 72 pour web, 144+ pour mobile haute définition