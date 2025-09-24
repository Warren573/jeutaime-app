# JeuTaime - Référence de Design

Cette application doit reproduire EXACTEMENT le design et les fonctionnalités de : https://jeutaime-warren.web.app/

## Écrans à reproduire :
- ✅ Accueil : grille des bars + header avec solde pièces
- ✅ Profils : stack de cartes + actions like/pass  
- ✅ Bars : 5 bars thématiques (Romantique, Humoristique, Pirates, Hebdomadaire, Caché)
- ✅ Lettres : correspondances authentiques
- ✅ Boutique : packs pièces + premium 19,90€/mois
- ✅ Journal : badges + historique activités

## Style exact à suivre :
- Couleurs : dégradés bois/chaleureux (#8B7355, #A0956B, #D2B48C)
- Police : Georgia, Times New Roman
- Cards : border-radius 15-20px, ombres douces
- Navigation : bottom fixed avec 7 onglets

## Navigation bottom avec ces onglets EXACTEMENT:
🏠 Accueil | 👤 Profils | 🍸 Bars | 💌 Lettres | 🛍️ Boutique | 📖 Journal | ⚙️ Paramètres

## Bars thématiques (5 bars comme sur le site) :
1. 🌹 Bar Romantique - ambiance tamisée
2. 😄 Bar Humoristique - défi du jour  
3. 🏴‍☠️ Bar Pirates - chasse au trésor
4. 📅 Bar Hebdomadaire - groupe de 4 (2H/2F)
5. 👑 Bar Caché - accès par énigmes

## Header obligatoire :
- Titre "JeuTaime" en Georgia
- Solde pièces (ex: "245 pièces") avec icône 💰
- Style bois chaleureux avec dégradé

## Couleurs officielles :
```dart
primary: Color(0xFF8B7355),     // Brun bois principal
secondary: Color(0xFFA0956B),   // Brun moyen
accent: Color(0xFFD2B48C),      // Beige chaleureux
background: Color(0xFFF5F5DC),  // Beige clair
```

## IMPORTANT :
Cette app doit reproduire EXACTEMENT https://jeutaime-warren.web.app/
Style: dégradés chaleureux bois/romantique, navigation bottom avec 7 onglets
Structure: même écrans, même UI, même fonctionnalités que la demo existante