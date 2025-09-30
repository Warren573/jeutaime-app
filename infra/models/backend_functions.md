# Liste des fonctions backend à implémenter — JeuTaime

## Callables (Appels directs depuis le client)
- createUserProfile(uid, data)
- updateUserProfile(uid, data)
- certifyUser(uid, documents)
- sendLetter(threadId, content, attachments)
- createLetterThread(participants)
- markLetterRead(threadId, messageId)
- joinBarGroup(barId, uid)
- leaveBarGroup(barId, uid)
- createMemory(uid, barId, content, photo)
- purchaseCoins(uid, amount)
- purchasePremium(uid)
- redeemPromoCode(uid, code)
- referFriend(referrerUid, referredEmail)
- reportContent(uid, type, targetId, reason)
- updateSettings(uid, settings)

## Triggers (Réactions automatiques aux changements Firestore)
- onUserCertified: attribuer badge, envoyer notification
- onLetterSent: notifier destinataire, mettre à jour thread
- onReportCreated: notifier admin, marquer contenu
- onPurchaseCompleted: créditer coins/premium
- onMemoryCreated: notifier amis/groupe

## Cron (Tâches planifiées)
- dailyBonus: distribuer bonus quotidien
- weeklyBarComposition: générer groupes/bar
- cleanupExpiredGroups: supprimer groupes expirés
- cleanupTempFiles: supprimer fichiers temporaires

## Webhooks
- stripeWebhook: gérer paiements Stripe (success, failure, refund)
- emailWebhook: gérer retours d’emails (bounce, spam)

## Utils
- validatePromoCode(code)
- calculateUserScore(uid)
- getBarRecommendations(uid)
- getUserActivityStats(uid)

---
Chaque fonction doit respecter les règles de sécurité, valider les entrées, et journaliser les actions importantes pour l’admin/modération.