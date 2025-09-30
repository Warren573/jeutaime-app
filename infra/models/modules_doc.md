# Documentation des modules secondaires JeuTaime

## Promo
- **redeemPromoCode(code)** : Permet à un utilisateur d’utiliser un code promo pour obtenir des coins. Le code doit être valide et non utilisé.
- Usage : Appel côté client avec le code promo. Si succès, l’utilisateur reçoit le bonus.

## Parrainage
- **referFriend(referredEmail)** : Génère un code de parrainage et enregistre l’invitation. Peut envoyer un email d’invitation.
- **validateReferralCode(code)** : Valide le code de parrainage, attribue le bonus au parrain et au filleul.
- Usage : Appel côté client lors de l’invitation ou de l’inscription avec code.

## Analytics
- **logUserAction(action, details)** : Enregistre une action utilisateur (ex : login, achat, envoi lettre) dans Firestore pour suivi et analyse.
- **getUserStats()** : Retourne des statistiques simples (lettres envoyées, groupes rejoints) pour l’utilisateur courant.
- Usage : Appel côté client pour journaliser ou afficher des stats.

## Tests
- Des fichiers de test existent pour chaque module (test/promo_test.ts, test/referrals_test.ts, test/analytics_test.ts).
- Ils vérifient les cas d’erreur et le bon fonctionnement des fonctions.

---
Chaque module est accessible via les fonctions cloud Firebase, sécurisé par l’authentification. Pour toute question sur l’utilisation ou l’intégration, demande une explication ou un exemple !