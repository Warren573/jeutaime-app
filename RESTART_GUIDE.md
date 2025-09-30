# Guide de Redémarrage Rapide - JeuTaime Mobile

## Si rien ne marche, suivre ces étapes :

### 1. Vérifier le serveur
```bash
# Tester si le serveur fonctionne
curl http://localhost:8084

# Si erreur, relancer le serveur
cd /workspaces/jeutaime-app
python3 -m http.server 8084 --directory build/web
```

### 2. URLs de test disponibles
- **Flutter complet** : https://solid-trout-jjgqg4649rg72qvrw-8084.app.github.dev/
- **HTML mobile** : https://solid-trout-jjgqg4649rg72qvrw-8084.app.github.dev/jeutaime_mobile_local.html
- **HTML simple** : https://solid-trout-jjgqg4649rg72qvrw-8084.app.github.dev/mobile_test.html

### 3. Si problème d'accès mobile
```bash
# Télécharger le fichier HTML local
cp /workspaces/jeutaime-app/jeutaime_mobile_local.html ~/jeutaime_mobile.html
```

Ensuite transférer le fichier sur mobile et ouvrir dans un navigateur.

### 4. Tests à effectuer sur mobile :
- [ ] Interface responsive
- [ ] Interactions tactiles
- [ ] Scroll horizontal
- [ ] Navigation bottom
- [ ] Système de score
- [ ] Notifications

### 5. Commandes de diagnostic
```bash
# Voir les processus Python
ps aux | grep python

# Voir les ports ouverts
netstat -tlnp | grep 8084

# Tester la connectivité
curl -I http://localhost:8084
```

## Statut actuel : ✅ FONCTIONNEL
- Serveur : ✅ Actif sur port 8084
- URLs : ✅ Accessibles 
- Fichiers : ✅ Complets et optimisés