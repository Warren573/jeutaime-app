/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Modèle de profil utilisateur pour les cartes swipables
 * Reproduit le système de découverte du site de référence
 */

import 'interaction_system.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String city;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final String job;
  final double distance;
  final bool isOnline;
  final String lastSeen;
  final UserRelation? relation; // Relation avec l'utilisateur actuel

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.bio,
    required this.photos,
    required this.interests,
    required this.job,
    required this.distance,
    this.isOnline = false,
    required this.lastSeen,
    this.relation,
  });

  // Données de test pour les cartes
  static List<UserProfile> getMockProfiles() {
    return [
      UserProfile(
        id: '1',
        name: 'Sophie',
        age: 28,
        city: 'Paris',
        bio: 'Passionnée de littérature et de voyages. J\'aime les longues balades au coucher du soleil et les discussions philosophiques devant un bon café. 📚✈️',
        photos: [
          'assets/profiles/sophie1.jpg',
          'assets/profiles/sophie2.jpg',
          'assets/profiles/sophie3.jpg',
        ],
        interests: ['Lecture', 'Voyages', 'Photographie', 'Cuisine', 'Art'],
        job: 'Architecte',
        distance: 2.3,
        isOnline: true,
        lastSeen: 'En ligne',
        relation: UserRelation(activitiesShared: true, messagesCount: 1),
      ),
      UserProfile(
        id: '2',
        name: 'Marie',
        age: 26,
        city: 'Lyon',
        bio: 'Danseuse professionnelle et amatrice de bonne cuisine. Toujours prête pour de nouvelles aventures ! 💃🍷',
        photos: [
          'assets/profiles/marie1.jpg',
          'assets/profiles/marie2.jpg',
        ],
        interests: ['Danse', 'Musique', 'Gastronomie', 'Théâtre'],
        job: 'Danseuse',
        distance: 5.7,
        isOnline: false,
        lastSeen: 'Il y a 3h',
        relation: UserRelation(
          friendship: true,
          compatibility80: true,
          compatibilityScore: 82.3,
          messagesCount: 6,
        ),
      ),
        relation: UserRelation(activitiesShared: true, friendship: true, messagesCount: 5),
      ),
      UserProfile(
        id: '3',
        name: 'Claire',
        age: 30,
        city: 'Bordeaux',
        bio: 'Médecin le jour, artiste le soir. Je peins mes émotions et cherche quelqu\'un avec qui partager ma passion. 🎨❤️',
        photos: [
          'assets/profiles/claire1.jpg',
          'assets/profiles/claire2.jpg',
          'assets/profiles/claire3.jpg',
        ],
        interests: ['Peinture', 'Médecine', 'Nature', 'Yoga', 'Vin'],
        job: 'Médecin',
        distance: 12.1,
        isOnline: false,
        lastSeen: 'Il y a 1j',
        relation: UserRelation(
          activitiesShared: true, 
          barWeeklyCompleted: true, 
          compatibility80: true, 
          compatibilityScore: 87.5,
          messagesCount: 8,
        ),
      ),
      UserProfile(
        id: '4',
        name: 'Emma',
        age: 25,
        city: 'Marseille',
        bio: 'Aventurière dans l\'âme, j\'adore l\'escalade et les randonnées. Recherche un partenaire d\'aventures ! 🧗‍♀️⛰️',
        photos: [
          'assets/profiles/emma1.jpg',
          'assets/profiles/emma2.jpg',
        ],
        interests: ['Escalade', 'Randonnée', 'Sports', 'Nature', 'Aventure'],
        job: 'Guide de montagne',
        distance: 8.4,
        isOnline: true,
        lastSeen: 'En ligne',
        relation: UserRelation(
          activitiesShared: true,
          heartConnection: true,
          compatibility80: true,
          compatibilityScore: 95.0,
          messagesCount: 15,
        ),
      ),
    ];
  }
}