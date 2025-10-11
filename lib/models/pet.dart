import 'dart:math';

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
}

class Pet {
  String id;
  String name;
  PetType type;
  int happiness;      // 0-100
  int hunger;         // 0-100 (100 = très affamé)
  int energy;         // 0-100
  int age;            // en jours
  int level;          // niveau de l'animal
  int experience;     // points d'expérience
  DateTime lastFed;
  DateTime lastPlayed;
  DateTime adoptionDate;
  DateTime lastUpdate;
  
  // Statistiques
  int totalFoodEaten;
  int totalGamesPlayed;
  int totalHappinessGiven;
  
  // Apparence personnalisable
  String color;
  List<String> accessories;
  
  Pet({
    required this.id,
    required this.name,
    required this.type,
    this.happiness = 80,
    this.hunger = 20,
    this.energy = 100,
    this.age = 0,
    this.level = 1,
    this.experience = 0,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? adoptionDate,
    DateTime? lastUpdate,
    this.totalFoodEaten = 0,
    this.totalGamesPlayed = 0,
    this.totalHappinessGiven = 0,
    this.color = '#FF6B9D',
    this.accessories = const [],
  }) : 
    lastFed = lastFed ?? DateTime.now(),
    lastPlayed = lastPlayed ?? DateTime.now(),
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

  // Nom du type d'animal
  String get typeName {
    switch (type) {
      case PetType.cat:
        return 'Chat';
      case PetType.dog:
        return 'Chien';
      case PetType.rabbit:
        return 'Lapin';
      case PetType.bird:
        return 'Oiseau';
      case PetType.fish:
        return 'Poisson';
      case PetType.hamster:
        return 'Hamster';
      case PetType.dragon:
        return 'Dragon';
      case PetType.unicorn:
        return 'Licorne';
    }
  }

  // Humeur actuelle basée sur les stats
  PetMood get mood {
    if (energy < 20) return PetMood.sleeping;
    if (hunger > 80) return PetMood.hungry;
    if (happiness > 80) return PetMood.happy;
    if (happiness > 60) return PetMood.playful;
    if (happiness > 40) return PetMood.content;
    if (happiness > 20) return PetMood.neutral;
    if (happiness > 10) return PetMood.sad;
    return PetMood.angry;
  }

  // Emoji de l'humeur
  String get moodEmoji {
    switch (mood) {
      case PetMood.happy:
        return '😄';
      case PetMood.playful:
        return '😆';
      case PetMood.content:
        return '😊';
      case PetMood.neutral:
        return '😐';
      case PetMood.sad:
        return '😢';
      case PetMood.angry:
        return '😠';
      case PetMood.sleeping:
        return '😴';
      case PetMood.hungry:
        return '🤤';
    }
  }

  // Description de l'humeur
  String get moodDescription {
    switch (mood) {
      case PetMood.happy:
        return '$name est très heureux !';
      case PetMood.playful:
        return '$name veut jouer !';
      case PetMood.content:
        return '$name est content et paisible.';
      case PetMood.neutral:
        return '$name va bien.';
      case PetMood.sad:
        return '$name a l\'air triste...';
      case PetMood.angry:
        return '$name est en colère ! Il faut s\'en occuper !';
      case PetMood.sleeping:
        return '$name est fatigué et dort.';
      case PetMood.hungry:
        return '$name a très faim !';
    }
  }

  // Barres de progression (0-100)
  double get happinessPercent => happiness / 100.0;
  double get hungerPercent => (100 - hunger) / 100.0; // Inverser pour que 100% = repu
  double get energyPercent => energy / 100.0;

  // Points d'expérience requis pour le niveau suivant
  int get experienceForNextLevel => level * 100;
  
  // Progression vers le niveau suivant (0-1)
  double get levelProgress => experience / experienceForNextLevel;

  // Coût d'adoption selon le type
  int get adoptionCost {
    switch (type) {
      case PetType.cat:
      case PetType.dog:
        return 500;
      case PetType.rabbit:
      case PetType.hamster:
        return 300;
      case PetType.bird:
      case PetType.fish:
        return 200;
      case PetType.dragon:
        return 2000;
      case PetType.unicorn:
        return 3000;
    }
  }

  // Mettre à jour l'état de l'animal (appelé périodiquement)
  void updateState() {
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(lastUpdate).inMinutes;
    
    if (timeSinceLastUpdate < 1) return; // Pas de mise à jour si moins d'1 minute
    
    // Diminuer l'énergie avec le temps
    if (energy > 0) {
      energy = (energy - (timeSinceLastUpdate * 0.5)).clamp(0, 100).toInt();
    }
    
    // Augmenter la faim avec le temps
    if (hunger < 100) {
      hunger = (hunger + (timeSinceLastUpdate * 0.3)).clamp(0, 100).toInt();
    }
    
    // Diminuer le bonheur si l'animal a faim ou est fatigué
    if (hunger > 60 || energy < 20) {
      happiness = (happiness - (timeSinceLastUpdate * 0.2)).clamp(0, 100).toInt();
    }
    
    // Vieillir l'animal (1 jour = 24h réelles = 1 niveau d'âge)
    final daysSinceAdoption = now.difference(adoptionDate).inDays;
    age = daysSinceAdoption;
    
    lastUpdate = now;
  }

  // Nourrir l'animal
  Map<String, dynamic> feed(String foodType) {
    final now = DateTime.now();
    
    // Différents types de nourriture
    int hungerReduction = 0;
    int happinessGain = 0;
    int experienceGain = 0;
    
    switch (foodType) {
      case 'basic_food':
        hungerReduction = 30;
        happinessGain = 10;
        experienceGain = 5;
        break;
      case 'premium_food':
        hungerReduction = 50;
        happinessGain = 20;
        experienceGain = 10;
        break;
      case 'treat':
        hungerReduction = 15;
        happinessGain = 25;
        experienceGain = 8;
        break;
    }
    
    // Appliquer les effets
    hunger = (hunger - hungerReduction).clamp(0, 100).toInt();
    happiness = (happiness + happinessGain).clamp(0, 100).toInt();
    experience += experienceGain;
    
    // Vérifier montée de niveau
    bool leveledUp = false;
    while (experience >= experienceForNextLevel) {
      experience -= experienceForNextLevel;
      level++;
      leveledUp = true;
    }
    
    // Statistiques
    totalFoodEaten++;
    totalHappinessGiven += happinessGain;
    lastFed = now;
    
    return {
      'success': true,
      'message': '$name a mangé avec plaisir !',
      'leveledUp': leveledUp,
      'newLevel': leveledUp ? level : null,
    };
  }

  // Jouer avec l'animal
  Map<String, dynamic> play(String gameType) {
    final now = DateTime.now();
    
    if (energy < 20) {
      return {
        'success': false,
        'message': '$name est trop fatigué pour jouer. Laissez-le se reposer.',
      };
    }
    
    // Différents types de jeux
    int energyCost = 0;
    int happinessGain = 0;
    int experienceGain = 0;
    
    switch (gameType) {
      case 'fetch':
        energyCost = 15;
        happinessGain = 20;
        experienceGain = 10;
        break;
      case 'cuddle':
        energyCost = 5;
        happinessGain = 15;
        experienceGain = 5;
        break;
      case 'training':
        energyCost = 25;
        happinessGain = 30;
        experienceGain = 20;
        break;
    }
    
    // Appliquer les effets
    energy = (energy - energyCost).clamp(0, 100).toInt();
    happiness = (happiness + happinessGain).clamp(0, 100).toInt();
    experience += experienceGain;
    
    // Vérifier montée de niveau
    bool leveledUp = false;
    while (experience >= experienceForNextLevel) {
      experience -= experienceForNextLevel;
      level++;
      leveledUp = true;
    }
    
    // Statistiques
    totalGamesPlayed++;
    totalHappinessGiven += happinessGain;
    lastPlayed = now;
    
    return {
      'success': true,
      'message': '$name s\'est amusé avec vous !',
      'leveledUp': leveledUp,
      'newLevel': leveledUp ? level : null,
    };
  }

  // Faire dormir l'animal (récupération d'énergie)
  Map<String, dynamic> rest() {
    if (energy >= 90) {
      return {
        'success': false,
        'message': '$name n\'a pas besoin de dormir maintenant.',
      };
    }
    
    energy = (energy + 40).clamp(0, 100).toInt();
    happiness = (happiness + 5).clamp(0, 100).toInt();
    
    return {
      'success': true,
      'message': '$name se repose et récupère de l\'énergie.',
    };
  }

  // Sérialisation pour sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'happiness': happiness,
      'hunger': hunger,
      'energy': energy,
      'age': age,
      'level': level,
      'experience': experience,
      'lastFed': lastFed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'adoptionDate': adoptionDate.toIso8601String(),
      'lastUpdate': lastUpdate.toIso8601String(),
      'totalFoodEaten': totalFoodEaten,
      'totalGamesPlayed': totalGamesPlayed,
      'totalHappinessGiven': totalHappinessGiven,
      'color': color,
      'accessories': accessories,
    };
  }

  // Désérialisation depuis sauvegarde
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: PetType.values.firstWhere((e) => e.toString() == json['type']),
      happiness: json['happiness'],
      hunger: json['hunger'],
      energy: json['energy'],
      age: json['age'],
      level: json['level'],
      experience: json['experience'],
      lastFed: DateTime.parse(json['lastFed']),
      lastPlayed: DateTime.parse(json['lastPlayed']),
      adoptionDate: DateTime.parse(json['adoptionDate']),
      lastUpdate: DateTime.parse(json['lastUpdate']),
      totalFoodEaten: json['totalFoodEaten'],
      totalGamesPlayed: json['totalGamesPlayed'],
      totalHappinessGiven: json['totalHappinessGiven'],
      color: json['color'],
      accessories: List<String>.from(json['accessories']),
    );
  }

  // Générer un animal aléatoire pour adoption
  static Pet generateRandomPet() {
    final random = Random();
    final types = PetType.values;
    final type = types[random.nextInt(types.length)];
    
    // Noms aléatoires selon le type
    final names = {
      PetType.cat: ['Mimi', 'Félix', 'Luna', 'Simba', 'Nala', 'Whiskers'],
      PetType.dog: ['Rex', 'Bella', 'Max', 'Lucy', 'Charlie', 'Daisy'],
      PetType.rabbit: ['Bunny', 'Coco', 'Snowball', 'Pepper', 'Carrot'],
      PetType.bird: ['Tweety', 'Rio', 'Sky', 'Melody', 'Rainbow'],
      PetType.fish: ['Bulle', 'Nemo', 'Ariel', 'Splash', 'Coral'],
      PetType.hamster: ['Peanut', 'Gizmo', 'Nibbles', 'Fuzzy', 'Pocket'],
      PetType.dragon: ['Flamme', 'Ember', 'Draco', 'Mystique', 'Phoenix'],
      PetType.unicorn: ['Stardust', 'Rainbow', 'Céleste', 'Aurora', 'Prisme'],
    };
    
    final possibleNames = names[type]!;
    final name = possibleNames[random.nextInt(possibleNames.length)];
    
    return Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      happiness: 60 + random.nextInt(30), // 60-90
      hunger: 10 + random.nextInt(30),    // 10-40
      energy: 70 + random.nextInt(30),    // 70-100
    );
  }
}