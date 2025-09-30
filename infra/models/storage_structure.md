# Modèle de structure Firebase Storage — JeuTaime

## users/{uid}/
- profile.jpg : photo de profil
- gallery/{filename} : photos de la galerie utilisateur
- certification/{filename} : documents de certification (photo, vidéo, justificatif)
- memories/{memoryId}.jpg : photos associées aux souvenirs

## bars/{barId}/
- bar.jpg : photo principale du bar
- gallery/{filename} : photos de la galerie du bar

## letters/{threadId}/
- attachments/{filename} : pièces jointes aux lettres (optionnel)

## admin/
- promo_codes/{filename} : fichiers de gestion des codes promo
- reports/{reportId}/{filename} : pièces jointes aux rapports

## temp/
- uploads/{filename} : fichiers temporaires (avant validation ou traitement)

### Règles de gestion
- Les fichiers sont nommés par UID, ID ou timestamp pour éviter les collisions.
- Les accès sont contrôlés par les règles Storage (lecture/écriture selon l'identité et le rôle).
- Les fichiers sensibles (certification, rapports) sont accessibles uniquement par l'utilisateur concerné ou l'admin.
