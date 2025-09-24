/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Système complet d'avatars émojis pour JeuTaime Flutter
 * Adapté du JavaScript fourni - Style bois chaleureux
 */

import 'dart:math';
import 'package:flutter/material.dart';
import '../config/ui_reference.dart';

class EmojiAvatar {
  final String emoji;
  final Color primaryColor;
  final Color secondaryColor;
  final Gradient background;
  final String pattern;
  final double size;
  final String id;

  EmojiAvatar({
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.background,
    required this.pattern,
    this.size = 60.0,
    required this.id,
  });
}

class EmojiAvatarGenerator {
  static final Random _random = Random();
  
  // Base d'émojis organisée par catégorie
  static const Map<String, Map<String, List<String>>> emojis = {
    'people': {
      'feminine': ['👩', '🌸', '✨', '🦋', '🌹', '💫', '🌺', '🎭', '👸', '🧚', '💃', '🌙', '🦢', '🍃'],
      'masculine': ['👨', '🔥', '⚡', '🦅', '🏔️', '🎯', '⚔️', '🦁', '👑', '🏴‍☠️', '🚀', '⚓', '🗡️', '🎸'],
      'neutral': ['😊', '🌟', '🎨', '🎵', '📚', '🌙', '☀️', '🎪', '🎲', '🌈', '🎭', '🎪', '🔮', '✨']
    },
    'expressions': {
      'romantic': ['😍', '🥰', '😘', '💕', '💖', '💝', '🌹', '💐', '💌', '💒', '🕯️', '✨'],
      'humorous': ['😂', '🤣', '😄', '😁', '🤪', '😆', '🎭', '🎪', '🤹', '🎨', '🎯', '🎲'],
      'mysterious': ['😏', '🤫', '😎', '🔮', '🎭', '👁️', '🌚', '🗝️', '🔍', '🌙', '⭐', '💫'],
      'pirate': ['🏴‍☠️', '⚔️', '🦜', '🗡️', '⚓', '💰', '🏴', '🦈', '🗺️', '🧭', '🏝️', '⛵']
    },
    'activities': {
      'art': ['🎨', '✏️', '🖌️', '🎭', '📸', '🎵', '🎪', '🌟', '🖼️', '🎬', '📝', '🎼'],
      'nature': ['🌸', '🌺', '🦋', '🌿', '🌙', '⭐', '🌈', '🌊', '🌞', '🍃', '🌲', '🌻'],
      'adventure': ['🗺️', '🧭', '🏔️', '🌋', '🚀', '⚡', '🔥', '💎', '🏕️', '🗻', '🌊', '⛰️'],
      'romance': ['💝', '💌', '🌹', '💐', '🕯️', '✨', '💫', '🌙', '💕', '💖', '🦢', '🌺']
    }
  };
  
  // Couleurs thématiques selon les bars JeuTaime
  static const Map<String, List<Color>> colors = {
    'romantic': [
      Color(0xFFFF69B4), Color(0xFFFFB6C1), Color(0xFFFF1493), 
      Color(0xFFDC143C), Color(0xFFFFC0CB), Color(0xFFDDA0DD)
    ],
    'humorous': [
      Color(0xFFFF9800), Color(0xFFFFA500), Color(0xFFFFD700), 
      Color(0xFFFF6347), Color(0xFFFF4500), Color(0xFFFFA726)
    ],
    'pirates': [
      Color(0xFF8B4513), Color(0xFFD2691E), Color(0xFFCD853F), 
      Color(0xFFDEB887), Color(0xFFF4A460), Color(0xFF8B7355)
    ],
    'weekly': [
      Color(0xFF4FACFE), Color(0xFF00F2FE), Color(0xFF667eea), 
      Color(0xFF764ba2), Color(0xFF5DADE2), Color(0xFF3498DB)
    ],
    'hidden': [
      Color(0xFF9C27B0), Color(0xFFE91E63), Color(0xFF673AB7), 
      Color(0xFF3F51B5), Color(0xFFFF9800), Color(0xFF8E24AA)
    ]
  };

  /// Génération d'avatar personnalisé
  static EmojiAvatar generateAvatar({
    String gender = 'neutral',
    String barType = 'romantic',
    String personality = 'romantic',
    List<String> interests = const [],
  }) {
    List<String> emojiPool = [];
    
    // Ajouter selon le genre
    if (emojis['people']?[gender] != null) {
      emojiPool.addAll(emojis['people']![gender]!);
    } else {
      emojiPool.addAll(emojis['people']!['neutral']!);
    }
    
    // Ajouter emojis selon personnalité
    if (emojis['expressions']?[personality] != null) {
      emojiPool.addAll(emojis['expressions']![personality]!);
    }
    
    // Ajouter selon le bar actuel
    if (emojis['expressions']?[barType] != null) {
      emojiPool.addAll(emojis['expressions']![barType]!);
    }
    
    // Ajouter selon les intérêts
    for (String interest in interests) {
      if (emojis['activities']?[interest] != null) {
        emojiPool.addAll(emojis['activities']![interest]!);
      }
    }
    
    // Sélection finale
    final emoji = emojiPool[_random.nextInt(emojiPool.length)];
    final colorPalette = colors[barType] ?? colors['romantic']!;
    final primaryColor = colorPalette[_random.nextInt(colorPalette.length)];
    final secondaryColor = colorPalette[_random.nextInt(colorPalette.length)];
    
    return EmojiAvatar(
      emoji: emoji,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, secondaryColor],
      ),
      pattern: _generatePattern(),
      size: 60.0,
      id: _generateId(),
    );
  }

  /// Génération pour un bar spécifique
  static EmojiAvatar generateForBar(String barType) {
    const Map<String, List<String>> barEmojis = {
      'romantic': ['🌹', '💝', '✨', '🌸', '💕', '🦋', '💌', '🕯️'],
      'humor': ['😂', '🎪', '🤣', '🎭', '🎯', '🎨', '🤹', '🎲'],
      'pirates': ['🏴‍☠️', '⚔️', '🦜', '⚓', '💰', '🗡️', '🗺️', '🧭'],
      'weekly': ['📅', '🎯', '⭐', '💫', '🌟', '✨', '🏆', '🎊'],
      'hidden': ['👑', '🔮', '🗝️', '💎', '👁️', '🌚', '⚡', '🌙']
    };
    
    final emojis = barEmojis[barType] ?? barEmojis['romantic']!;
    final emoji = emojis[_random.nextInt(emojis.length)];
    final colorPalette = colors[barType] ?? colors['romantic']!;
    final primaryColor = colorPalette[0];
    final secondaryColor = colorPalette[1];
    
    return EmojiAvatar(
      emoji: emoji,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, secondaryColor],
      ),
      pattern: _generatePattern(),
      size: 60.0,
      id: _generateId(),
    );
  }

  /// Génération aléatoire complète
  static EmojiAvatar generateRandom() {
    const genders = ['feminine', 'masculine', 'neutral'];
    const barTypes = ['romantic', 'humorous', 'pirates', 'weekly', 'hidden'];
    const personalities = ['romantic', 'humorous', 'mysterious', 'pirate'];
    const interestsList = ['art', 'nature', 'adventure', 'romance'];
    
    return generateAvatar(
      gender: genders[_random.nextInt(genders.length)],
      barType: barTypes[_random.nextInt(barTypes.length)],
      personality: personalities[_random.nextInt(personalities.length)],
      interests: [interestsList[_random.nextInt(interestsList.length)]],
    );
  }

  static String _generatePattern() {
    const patterns = ['dots', 'lines', 'circles', 'waves', 'none'];
    return patterns[_random.nextInt(patterns.length)];
  }

  static String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return 'avatar_' + List.generate(7, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}