import '../models/user_model.dart';
import '../models/conversation_model.dart';

/// Service anti-ghosting pour améliorer la qualité des interactions
/// Applique des sanctions et bonus basés sur le comportement utilisateur
class AntiGhostingService {
  static const int GHOSTING_THRESHOLD_HOURS = 48;
  static const int GHOSTING_PENALTY = -50;
  static const int VICTIM_BONUS = 25;
  static const int ACTIVE_USER_BONUS = 10;

  /// Vérifie si un utilisateur a ghosté une conversation
  static bool hasGhosted(ConversationModel conversation, String userId) {
    final lastMessage = conversation.lastMessage;
    if (lastMessage?.senderId == userId) return false;
    
    final timeSinceLastResponse = DateTime.now().difference(lastMessage!.timestamp);
    return timeSinceLastResponse.inHours > GHOSTING_THRESHOLD_HOURS;
  }

  /// Applique les sanctions/bonus anti-ghosting
  static Future<void> applyAntiGhostingRules(String conversationId) async {
    // Logique Firebase pour :
    // 1. Identifier le ghosteur
    // 2. Appliquer -50 points au ghosteur
    // 3. Donner +25 points à la victime
    // 4. Réduire la visibilité du ghosteur
    // 5. Augmenter la visibilité de la victime
  }

  /// Calcule le score de fiabilité d'un utilisateur
  static int calculateReliabilityScore(UserModel user) {
    int baseScore = 1000;
    int conversations = user.totalConversations;
    int ghostingCount = user.ghostingCount;
    int activeConversations = user.activeConversations;
    
    // Malus pour ghosting
    baseScore -= (ghostingCount * GHOSTING_PENALTY);
    
    // Bonus pour activité
    baseScore += (activeConversations * ACTIVE_USER_BONUS);
    
    // Bonus pour ancienneté
    final accountAge = DateTime.now().difference(user.createdAt).inDays;
    baseScore += (accountAge / 7).floor() * 5; // +5 pts par semaine
    
    return baseScore.clamp(0, 2000);
  }

  /// Détermine les actions à prendre selon le score de fiabilité
  static List<String> getGhostingActions(int reliabilityScore) {
    if (reliabilityScore < 500) {
      return ['RESTRICTED_VISIBILITY', 'LIMITED_MATCHES', 'WARNING_BADGE'];
    } else if (reliabilityScore < 800) {
      return ['REDUCED_VISIBILITY'];
    } else if (reliabilityScore > 1500) {
      return ['BOOSTED_VISIBILITY', 'PRIORITY_MATCHES', 'TRUSTED_BADGE'];
    }
    return [];
  }

  /// Obtient une description de l'action anti-ghosting
  static String getActionDescription(String action) {
    switch (action) {
      case 'RESTRICTED_VISIBILITY':
        return 'Visibilité fortement réduite';
      case 'LIMITED_MATCHES':
        return 'Nombre de matchs limité';
      case 'WARNING_BADGE':
        return 'Badge d\'avertissement affiché';
      case 'REDUCED_VISIBILITY':
        return 'Visibilité légèrement réduite';
      case 'BOOSTED_VISIBILITY':
        return 'Visibilité augmentée';
      case 'PRIORITY_MATCHES':
        return 'Matchs prioritaires';
      case 'TRUSTED_BADGE':
        return 'Badge utilisateur de confiance';
      default:
        return action;
    }
  }
}
