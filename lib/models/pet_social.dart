import 'dart:math';

enum UserMode {
  incarnate, // L'utilisateur EST un animal
  adopter,   // L'utilisateur ADOPTE un animal
}

enum PetType {
  cat,
  dog,
  rabbit,
  bird,
  fish,
  hamster,
  dragon,
  unicorn,
}

enum PetMood {
  happy,
  content,
  neutral,
  sad,
  angry,
  sleeping,
  playful,
  hungry,
  lonely,
  excited,
}

class UserPetProfile {
  String userId;
  UserMode mode;
  
  // Si mode = incarnate : l'utilisateur EST cet animal
  // Si mode = adopter : l'utilisateur POSSÈDE cet animal
  Pet? currentPet;
  
  // Historique des interactions avec d'autres utilisateurs
  List<PetInteraction> interactions;
  
  // Points de relations sociales
  int socialPoints;
  
  UserPetProfile({
    required this.userId,
    required this.mode,
    this.currentPet,
    this.interactions = const [],
    this.socialPoints = 0,
  });
}

class PetInteraction {
  String id;
  String fromUserId;  // Qui initie l'interaction
  String toUserId;    // Qui la reçoit
  InteractionType type;
  DateTime timestamp;
  Map<String, dynamic> data;
  bool isAccepted;
  bool isCompleted;
  
  PetInteraction({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.timestamp,
    this.data = const {},
    this.isAccepted = false,
    this.isCompleted = false,
  });
}

enum InteractionType {
  // Adopteur vers Animal incarné
  offerTreat,     // Offrir une friandise
  requestPlay,    // Demander à jouer
  giveCuddle,     // Faire un câlin
  offerToy,       // Offrir un jouet
  
  // Animal incarné vers Adopteur
  askForFood,     // Demander de la nourriture
  wantAttention,  // Vouloir de l'attention
  showAffection,  // Montrer de l'affection
  bringGift,      // Apporter un cadeau
  
  // Entre Animaux incarnés
  playTogether,   // Jouer ensemble
  socialGroom,    // Se toiletter mutuellement
  territorial,    // Comportement territorial
  friendly,       // Interaction amicale
  
  // Entre Adopteurs
  meetPets,       // Présenter leurs animaux
  exchangeTips,   // Échanger des conseils
  playdate,       // Organiser une rencontre
}

class Pet {
  String id;
  String name;
  PetType type;
  String ownerId; // ID de l'utilisateur (incarné ou adopteur)
  UserMode ownerMode; // Mode du propriétaire
  
  // Stats de base
  int happiness;      // 0-100
  int hunger;         // 0-100 (100 = très affamé)
  int energy;         // 0-100
  int social;         // 0-100 (besoin d'interaction sociale)
  int age;            // en jours
  int level;          // niveau de l'animal
  int experience;     // points d'expérience
  
  // Timestamps
  DateTime lastFed;
  DateTime lastPlayed;
  DateTime lastSocialInteraction;
  DateTime adoptionDate;
  DateTime lastUpdate;
  
  // Statistiques sociales
  int totalInteractions;
  int friendsCount;
  List<String> friendIds;
  
  // Préférences comportementales (pour les animaux incarnés)
  Map<InteractionType, double> interactionPreferences;
  
  // Récompenses et objets collectés
  List<String> toysOwned;
  List<String> achievementsUnlocked;
  
  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.ownerMode,
    this.happiness = 80,
    this.hunger = 20,
    this.energy = 100,
    this.social = 50,
    this.age = 0,
    this.level = 1,
    this.experience = 0,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastSocialInteraction,
    DateTime? adoptionDate,
    DateTime? lastUpdate,
    this.totalInteractions = 0,
    this.friendsCount = 0,
    this.friendIds = const [],
    this.interactionPreferences = const {},
    this.toysOwned = const [],
    this.achievementsUnlocked = const [],
  }) : 
    lastFed = lastFed ?? DateTime.now(),
    lastPlayed = lastPlayed ?? DateTime.now(),
    lastSocialInteraction = lastSocialInteraction ?? DateTime.now(),
    adoptionDate = adoptionDate ?? DateTime.now(),
    lastUpdate = lastUpdate ?? DateTime.now();

  // Emoji selon le type d'animal
  String get emoji {
    switch (type) {
      case PetType.cat:
        return '🐱';
      case PetType.dog:
        return '🐶';
      case PetType.rabbit:
        return '🐰';
      case PetType.bird:
        return '🐦';
      case PetType.fish:
        return '🐠';
      case PetType.hamster:
        return '🐹';
      case PetType.dragon:
        return '🐉';
      case PetType.unicorn:
        return '🦄';
    }
  }

  // Description selon le mode du propriétaire
  String get roleDescription {
    switch (ownerMode) {
      case UserMode.incarnate:
        return 'Animal incarné';
      case UserMode.adopter:
        return 'Animal de compagnie';
    }
  }

  // Humeur actuelle basée sur les stats
  PetMood get mood {
    if (energy < 20) return PetMood.sleeping;
    if (hunger > 80) return PetMood.hungry;
    if (social < 30) return PetMood.lonely;
    if (happiness > 80 && social > 70) return PetMood.excited;
    if (happiness > 80) return PetMood.happy;
    if (happiness > 60) return PetMood.playful;
    if (happiness > 40) return PetMood.content;
    if (happiness > 20) return PetMood.neutral;
    if (happiness > 10) return PetMood.sad;
    return PetMood.angry;
  }

  // Actions disponibles selon le mode
  List<InteractionType> get availableActions {
    switch (ownerMode) {
      case UserMode.incarnate:
        return [
          InteractionType.askForFood,
          InteractionType.wantAttention,
          InteractionType.showAffection,
          InteractionType.bringGift,
          InteractionType.playTogether,
          InteractionType.socialGroom,
          InteractionType.friendly,
        ];
      case UserMode.adopter:
        return [
          InteractionType.offerTreat,
          InteractionType.requestPlay,
          InteractionType.giveCuddle,
          InteractionType.offerToy,
          InteractionType.meetPets,
          InteractionType.exchangeTips,
          InteractionType.playdate,
        ];
    }
  }

  // Réagir à une interaction reçue
  Map<String, dynamic> reactToInteraction(PetInteraction interaction) {
    // L'animal réagit différemment selon qu'il est incarné ou adopté
    if (ownerMode == UserMode.incarnate) {
      return _reactAsIncarnatedAnimal(interaction);
    } else {
      return _reactAsAdoptedPet(interaction);
    }
  }

  Map<String, dynamic> _reactAsIncarnatedAnimal(PetInteraction interaction) {
    // L'utilisateur qui incarne l'animal décide comment réagir
    switch (interaction.type) {
      case InteractionType.offerTreat:
        if (hunger > 30) {
          hunger = (hunger - 30).clamp(0, 100).toInt();
          happiness = (happiness + 20).clamp(0, 100).toInt();
          return {
            'accepted': true,
            'message': '$name a accepté la friandise avec joie ! 😋',
            'animation': 'eating',
          };
        } else {
          return {
            'accepted': false,
            'message': '$name n\'a pas faim pour le moment.',
            'animation': 'refuse',
          };
        }
        
      case InteractionType.requestPlay:
        if (energy > 20 && social < 80) {
          energy = (energy - 15).clamp(0, 100).toInt();
          happiness = (happiness + 25).clamp(0, 100).toInt();
          social = (social + 20).clamp(0, 100).toInt();
          return {
            'accepted': true,
            'message': '$name est ravi de jouer ! 🎾',
            'animation': 'playing',
          };
        } else if (energy <= 20) {
          return {
            'accepted': false,
            'message': '$name est trop fatigué pour jouer.',
            'animation': 'tired',
          };
        } else {
          return {
            'accepted': false,
            'message': '$name préfère se reposer maintenant.',
            'animation': 'content',
          };
        }
        
      case InteractionType.giveCuddle:
        happiness = (happiness + 15).clamp(0, 100).toInt();
        social = (social + 15).clamp(0, 100).toInt();
        return {
          'accepted': true,
          'message': '$name ronronne de bonheur ! 💕',
          'animation': 'cuddling',
        };
        
      default:
        return {
          'accepted': false,
          'message': '$name ne comprend pas cette interaction.',
          'animation': 'confused',
        };
    }
  }

  Map<String, dynamic> _reactAsAdoptedPet(PetInteraction interaction) {
    // L'animal de compagnie réagit automatiquement selon ses stats
    final random = Random();
    
    switch (interaction.type) {
      case InteractionType.playTogether:
        if (energy > 30 && happiness > 40) {
          final success = random.nextBool();
          if (success) {
            energy = (energy - 20).clamp(0, 100).toInt();
            happiness = (happiness + 30).clamp(0, 100).toInt();
            social = (social + 25).clamp(0, 100).toInt();
            return {
              'accepted': true,
              'message': '$name s\'amuse beaucoup ! Les deux animaux jouent ensemble ! 🎉',
              'animation': 'group_play',
            };
          }
        }
        return {
          'accepted': false,
          'message': '$name n\'est pas d\'humeur à jouer avec d\'autres animaux.',
          'animation': 'shy',
        };
        
      case InteractionType.friendly:
        if (social < 70) {
          social = (social + 20).clamp(0, 100).toInt();
          happiness = (happiness + 10).clamp(0, 100).toInt();
          return {
            'accepted': true,
            'message': '$name apprécie cette interaction amicale ! 😊',
            'animation': 'friendly',
          };
        }
        return {
          'accepted': true,
          'message': '$name répond poliment à l\'interaction.',
          'animation': 'polite',
        };
        
      default:
        return {
          'accepted': false,
          'message': '$name ne peut pas réagir à cette action.',
          'animation': 'neutral',
        };
    }
  }

  // Initier une interaction avec un autre utilisateur
  Map<String, dynamic> initiateInteraction(InteractionType type, Pet targetPet) {
    // Vérifier la compatibilité de l'interaction
    if (!_isInteractionCompatible(type, targetPet.ownerMode)) {
      return {
        'success': false,
        'message': 'Ce type d\'interaction n\'est pas possible avec ce type d\'utilisateur.',
      };
    }

    // Créer l'interaction
    final interaction = PetInteraction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: ownerId,
      toUserId: targetPet.ownerId,
      type: type,
      timestamp: DateTime.now(),
      data: {
        'fromPetId': id,
        'toPetId': targetPet.id,
        'fromPetName': name,
        'toPetName': targetPet.name,
      },
    );

    return {
      'success': true,
      'interaction': interaction,
      'message': _getInteractionInitiationMessage(type, targetPet),
    };
  }

  bool _isInteractionCompatible(InteractionType type, UserMode targetMode) {
    switch (ownerMode) {
      case UserMode.incarnate:
        switch (type) {
          case InteractionType.askForFood:
          case InteractionType.wantAttention:
          case InteractionType.showAffection:
          case InteractionType.bringGift:
            return targetMode == UserMode.adopter;
          case InteractionType.playTogether:
          case InteractionType.socialGroom:
          case InteractionType.friendly:
          case InteractionType.territorial:
            return targetMode == UserMode.incarnate || targetMode == UserMode.adopter;
          default:
            return false;
        }
      case UserMode.adopter:
        switch (type) {
          case InteractionType.offerTreat:
          case InteractionType.requestPlay:
          case InteractionType.giveCuddle:
          case InteractionType.offerToy:
            return targetMode == UserMode.incarnate;
          case InteractionType.meetPets:
          case InteractionType.exchangeTips:
          case InteractionType.playdate:
            return targetMode == UserMode.adopter;
          default:
            return false;
        }
    }
  }

  String _getInteractionInitiationMessage(InteractionType type, Pet targetPet) {
    switch (type) {
      case InteractionType.offerTreat:
        return 'Vous offrez une friandise à ${targetPet.name} !';
      case InteractionType.requestPlay:
        return 'Vous demandez à ${targetPet.name} s\'il veut jouer !';
      case InteractionType.askForFood:
        return '$name demande de la nourriture à ${targetPet.name} !';
      case InteractionType.playTogether:
        return '$name propose de jouer avec ${targetPet.name} !';
      case InteractionType.showAffection:
        return '$name montre son affection à ${targetPet.name} !';
      default:
        return 'Interaction initiée avec ${targetPet.name} !';
    }
  }

  // Mettre à jour l'état de l'animal
  void updateState() {
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(lastUpdate).inMinutes;
    
    if (timeSinceLastUpdate < 1) return;
    
    // Évolution différente selon le mode
    if (ownerMode == UserMode.incarnate) {
      // L'animal incarné évolue plus lentement et dépend plus des interactions sociales
      _updateIncarnatedAnimalState(timeSinceLastUpdate);
    } else {
      // L'animal de compagnie évolue de manière plus prévisible
      _updateAdoptedPetState(timeSinceLastUpdate);
    }
    
    lastUpdate = now;
  }

  void _updateIncarnatedAnimalState(int minutes) {
    // Faim évolue plus lentement (l'utilisateur peut chercher de la nourriture)
    hunger = (hunger + (minutes * 0.2)).clamp(0, 100).toInt();
    
    // Énergie diminue selon l'activité
    energy = (energy - (minutes * 0.3)).clamp(0, 100).toInt();
    
    // Le social est crucial pour les animaux incarnés
    final timeSinceSocial = DateTime.now().difference(lastSocialInteraction).inHours;
    if (timeSinceSocial > 2) {
      social = (social - (minutes * 0.5)).clamp(0, 100).toInt();
      happiness = (happiness - (minutes * 0.3)).clamp(0, 100).toInt();
    }
  }

  void _updateAdoptedPetState(int minutes) {
    // Évolution classique d'un animal de compagnie
    hunger = (hunger + (minutes * 0.4)).clamp(0, 100).toInt();
    energy = (energy - (minutes * 0.4)).clamp(0, 100).toInt();
    
    // Diminue le bonheur si négligé
    if (hunger > 70 || energy < 30) {
      happiness = (happiness - (minutes * 0.2)).clamp(0, 100).toInt();
    }
    
    // Le besoin social évolue moins vite
    social = (social - (minutes * 0.1)).clamp(0, 100).toInt();
  }

  // Générer un animal selon le mode choisi
  static Pet generateAnimal(String userId, UserMode mode, PetType type, String name) {
    return Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      ownerId: userId,
      ownerMode: mode,
      happiness: mode == UserMode.incarnate ? 70 : 80,
      hunger: mode == UserMode.incarnate ? 30 : 20,
      energy: 100,
      social: mode == UserMode.incarnate ? 60 : 50,
    );
  }

  // Sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'ownerId': ownerId,
      'ownerMode': ownerMode.toString(),
      'happiness': happiness,
      'hunger': hunger,
      'energy': energy,
      'social': social,
      'age': age,
      'level': level,
      'experience': experience,
      'lastFed': lastFed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'lastSocialInteraction': lastSocialInteraction.toIso8601String(),
      'adoptionDate': adoptionDate.toIso8601String(),
      'lastUpdate': lastUpdate.toIso8601String(),
      'totalInteractions': totalInteractions,
      'friendsCount': friendsCount,
      'friendIds': friendIds,
      'toysOwned': toysOwned,
      'achievementsUnlocked': achievementsUnlocked,
    };
  }
}