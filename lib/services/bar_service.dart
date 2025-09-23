import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bar.dart';
import '../models/group.dart';
import '../models/user.dart' as app_user;
import 'dart:math';

class BarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir tous les bars disponibles
  static Stream<List<Bar>> getBars() {
    return _firestore
        .collection('bars')
        .where('isActive', isEqualTo: true)
        .orderBy('category')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bar.fromFirestore(doc))
            .toList());
  }

  // Obtenir un bar spécifique
  static Future<Bar?> getBar(String barId) async {
    try {
      final doc = await _firestore.collection('bars').doc(barId).get();
      if (doc.exists) {
        return Bar.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting bar: $e');
      return null;
    }
  }

  // Obtenir les bars par catégorie
  static Stream<List<Bar>> getBarsByCategory(String category) {
    return _firestore
        .collection('bars')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('activeUsers', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bar.fromFirestore(doc))
            .toList());
  }

  // Entrer dans un bar
  static Future<String?> enterBar(String userId, String barId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final user = app_user.User.fromFirestore(userDoc);
      
      // Vérifier si l'utilisateur peut entrer dans le bar
      final bar = await getBar(barId);
      if (bar == null) return null;

      // Vérifications des conditions d'entrée
      if (bar.isPremiumOnly && !user.isPremium) {
        throw Exception('Ce bar est réservé aux membres Premium');
      }

      if (bar.minimumAge != null && user.age < bar.minimumAge!) {
        throw Exception('Âge minimum requis: ${bar.minimumAge} ans');
      }

      if (bar.requiredInterests.isNotEmpty) {
        final hasRequiredInterest = bar.requiredInterests
            .any((interest) => user.interests.contains(interest));
        if (!hasRequiredInterest) {
          throw Exception('Intérêts requis: ${bar.requiredInterests.join(', ')}');
        }
      }

      // Trouver ou créer un groupe
      String? groupId = await _findOrCreateGroup(userId, barId, bar);
      
      if (groupId != null) {
        // Mettre à jour la localisation de l'utilisateur
        await _firestore.collection('users').doc(userId).update({
          'currentBarId': barId,
          'currentGroupId': groupId,
          'lastBarVisit': Timestamp.now(),
        });

        // Incrémenter le nombre d'utilisateurs actifs du bar
        await _firestore.collection('bars').doc(barId).update({
          'activeUsers': FieldValue.increment(1),
          'lastActivity': Timestamp.now(),
        });
      }

      return groupId;
    } catch (e) {
      print('Error entering bar: $e');
      rethrow;
    }
  }

  // Quitter un bar
  static Future<void> leaveBar(String userId, String barId, String groupId) async {
    try {
      // Retirer l'utilisateur du groupe
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
        'leftMembers': FieldValue.arrayUnion([userId]),
        'lastActivity': Timestamp.now(),
      });

      // Mettre à jour l'utilisateur
      await _firestore.collection('users').doc(userId).update({
        'currentBarId': null,
        'currentGroupId': null,
      });

      // Décrémenter le nombre d'utilisateurs actifs du bar
      await _firestore.collection('bars').doc(barId).update({
        'activeUsers': FieldValue.increment(-1),
      });

      // Vérifier si le groupe est maintenant vide
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (groupDoc.exists) {
        final group = Group.fromFirestore(groupDoc);
        if (group.members.isEmpty) {
          // Marquer le groupe comme inactif
          await _firestore.collection('groups').doc(groupId).update({
            'isActive': false,
            'endedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      print('Error leaving bar: $e');
      rethrow;
    }
  }

  // Obtenir les groupes actifs d'un bar
  static Stream<List<Group>> getActiveGroups(String barId) {
    return _firestore
        .collection('groups')
        .where('barId', isEqualTo: barId)
        .where('isActive', isEqualTo: true)
        .where('isPrivate', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromFirestore(doc))
            .toList());
  }

  // Obtenir l'activité en cours d'un bar
  static Future<BarActivity?> getCurrentActivity(String barId) async {
    try {
      final bar = await getBar(barId);
      if (bar == null || bar.activities.isEmpty) return null;

      final now = DateTime.now();
      
      // Pour simplifier, on retourne la première activité disponible
      // Dans une version plus avancée, on pourrait avoir un système de planning
      
      final currentActivity = bar.activities.first;
      return currentActivity;
    } catch (e) {
      print('Error getting current activity: $e');
      return null;
    }
  }

  // Participer à une activité
  static Future<void> participateInActivity(
    String userId,
    String barId,
    String groupId,
    String activityType,
  ) async {
    try {
      final participationData = {
        'userId': userId,
        'barId': barId,
        'groupId': groupId,
        'activityType': activityType,
        'createdAt': Timestamp.now(),
        'isCompleted': false,
      };

      await _firestore.collection('activities').add(participationData);

      // Mettre à jour les statistiques du groupe
      await _firestore.collection('groups').doc(groupId).update({
        'activityCount': FieldValue.increment(1),
        'lastActivity': Timestamp.now(),
      });
    } catch (e) {
      print('Error participating in activity: $e');
      rethrow;
    }
  }

  // Créer un bar hebdomadaire (admin)
  static Future<String> createWeeklyBar({
    required String name,
    required String description,
    required String theme,
    required List<Map<String, dynamic>> activities,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final weeklyBar = Bar(
      barId: '',
      name: name,
      type: BarType.weekly,
      isActive: true,
      maxParticipants: 200,
      activeUsers: 0,
      expiresAt: endDate,
    );

    final docRef = await _firestore.collection('bars').add(weeklyBar.toFirestore());
    
    // Notifier tous les utilisateurs
    await _notifyUsersAboutNewBar(docRef.id, name);
    
    return docRef.id;
  }

  // Trouver ou créer un groupe approprié
  static Future<String?> _findOrCreateGroup(String userId, String barId, Bar bar) async {
    try {
      // Chercher un groupe existant avec de la place
      final existingGroupsQuery = await _firestore
          .collection('groups')
          .where('barId', isEqualTo: barId)
          .where('isActive', isEqualTo: true)
          .where('isPrivate', isEqualTo: false)
          .get();

      for (final doc in existingGroupsQuery.docs) {
        final group = Group.fromFirestore(doc);
        if (group.members.length < group.maxSize) {
          // Rejoindre ce groupe
          await _firestore.collection('groups').doc(group.id).update({
            'members': FieldValue.arrayUnion([userId]),
            'lastActivity': Timestamp.now(),
          });
          return group.id;
        }
      }

      // Créer un nouveau groupe
      final groupData = Group(
        groupId: '',
        type: GroupType.bar, 
        barId: barId,
        createdAt: DateTime.now(),
        name: _generateGroupName(bar.type.value),
        description: 'Nouveau groupe dans ${bar.name}',
        members: [userId],
        maxSize: bar.maxParticipants,
        isActive: true,
        isPrivate: false,
        theme: bar.type.value,
      );

      final newGroupRef = await _firestore.collection('groups').add(groupData.toFirestore());
      return newGroupRef.id;
    } catch (e) {
      print('Error finding or creating group: $e');
      return null;
    }
  }

  // Générer un nom de groupe aléatoire
  static String _generateGroupName(String theme) {
    final themeNames = {
      'romantic': ['Les Romantiques', 'Cœurs Tendres', 'Amour Éternel', 'Passion Rose'],
      'humorous': ['Les Rigolos', 'Sourires Complices', 'Éclats de Rire', 'Humour & Cie'],
      'pirates': ['L\'Équipage', 'Corsaires Libres', 'Aventuriers des Mers', 'Boucaniers'],
      'intellectual': ['Les Penseurs', 'Esprits Brillants', 'Philosophes Modernes', 'Culture Club'],
      'adventure': ['Aventuriers', 'Explorateurs', 'Adrénaline', 'Grand Air'],
    };

    final names = themeNames[theme] ?? ['Groupe Sympa', 'Nouvelle Aventure', 'Rencontres'];
    final random = Random();
    return names[random.nextInt(names.length)];
  }

  // Notifier les utilisateurs d'un nouveau bar
  static Future<void> _notifyUsersAboutNewBar(String barId, String barName) async {
    // Cette fonction pourrait être optimisée avec Cloud Functions
    // Pour le moment, on crée juste une notification générale
    
    await _firestore.collection('notifications').add({
      'type': 'new_bar',
      'barId': barId,
      'title': 'Nouveau bar disponible!',
      'message': 'Découvrez $barName et rencontrez de nouvelles personnes.',
      'createdAt': Timestamp.now(),
      'isGlobal': true,
    });
  }

  // Obtenir les utilisateurs dans un bar spécifique
  static Future<List<app_user.User>> getUsersInBar(String barType) async {
    try {
      // Pour la démo, on simule des utilisateurs selon le type de bar
      final querySnapshot = await _firestore
          .collection('users')
          .where('interests', arrayContains: barType)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => app_user.User.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting users in bar: $e');
      return [];
    }
  }

  // Vérifier l'accès au bar mystère
  static Future<bool> canAccessMysteryBar(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final user = app_user.User.fromFirestore(userDoc);
      
      // Conditions d'accès au bar mystère :
      // - Premium actif
      // - Au moins 1000 pièces
      // - Badge spécial "Explorer"
      return user.isPremium && 
             user.coins >= 1000 && 
             user.hasBadge('explorer');
    } catch (e) {
      print('Error checking mystery bar access: $e');
      return false;
    }
  }
}
