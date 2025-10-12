import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'feedback_system.dart';

/// Gestionnaire global d'erreurs pour JeuTaime
class ErrorHandler {
  
  /// Gère les erreurs de manière centralisée
  static void handleError({
    required dynamic error,
    StackTrace? stackTrace,
    BuildContext? context,
    String? userMessage,
    bool showToUser = true,
  }) {
    // Log de l'erreur pour le développement
    if (kDebugMode) {
      debugPrint('🚨 ERREUR JeuTaime: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    
    // Affichage à l'utilisateur si contexte disponible
    if (context != null && showToUser) {
      final message = userMessage ?? _getErrorMessage(error);
      FeedbackSystem.showErrorAnimation(
        context: context,
        message: message,
      );
    }
  }
  
  /// Gère les erreurs de connexion réseau
  static void handleNetworkError({
    required BuildContext context,
    String? customMessage,
  }) {
    FeedbackSystem.showSnackbar(
      context: context,
      message: customMessage ?? 'Problème de connexion. Vérifiez votre internet.',
      actionLabel: 'Réessayer',
      onActionPressed: () {
        // Logique de retry si nécessaire
      },
      backgroundColor: Colors.orange.shade700,
    );
  }
  
  /// Gère les erreurs de validation
  static void handleValidationError({
    required BuildContext context,
    required String field,
    String? customMessage,
  }) {
    FeedbackSystem.showToast(
      context: context,
      message: customMessage ?? 'Veuillez vérifier le champ $field',
      icon: '⚠️',
      backgroundColor: Colors.orange.shade700,
    );
  }
  
  /// Gère les erreurs d'authentification
  static void handleAuthError({
    required BuildContext context,
    String? customMessage,
  }) {
    FeedbackSystem.showConfirmDialog(
      context: context,
      title: 'Authentification requise',
      message: customMessage ?? 'Veuillez vous reconnecter pour continuer.',
      confirmText: 'Se reconnecter',
      cancelText: 'Plus tard',
      confirmColor: Colors.blue,
    ).then((shouldReconnect) {
      if (shouldReconnect == true) {
        // Logique de reconnexion
        _handleReconnection(context);
      }
    });
  }
  
  /// Gère les erreurs de paiement/coins insuffisants
  static void handleInsufficientCoinsError({
    required BuildContext context,
    required int required,
    required int current,
  }) {
    FeedbackSystem.showConfirmDialog(
      context: context,
      title: 'Pièces insuffisantes',
      message: 'Il vous faut $required pièces (vous en avez $current).\nVoulez-vous aller à la boutique ?',
      confirmText: 'Aller à la boutique',
      cancelText: 'Plus tard',
      confirmColor: Colors.green,
    ).then((shouldGoToShop) {
      if (shouldGoToShop == true) {
        // Navigation vers la boutique
        _navigateToShop(context);
      }
    });
  }
  
  /// Try-catch wrapper avec gestion automatique
  static Future<T?> safeExecute<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    String? errorMessage,
    bool showLoading = false,
  }) async {
    OverlayEntry? loadingOverlay;
    
    try {
      if (showLoading) {
        loadingOverlay = FeedbackSystem.showLoadingDialog(context: context);
      }
      
      final result = await operation();
      return result;
      
    } catch (error, stackTrace) {
      handleError(
        error: error,
        stackTrace: stackTrace,
        context: context,
        userMessage: errorMessage,
      );
      return null;
      
    } finally {
      loadingOverlay?.remove();
    }
  }
  
  /// Validation des entrées utilisateur
  static String? validateField({
    required String? value,
    required String fieldName,
    int? minLength,
    int? maxLength,
    bool isEmail = false,
    bool isRequired = true,
  }) {
    // Champ requis
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return '$fieldName est requis';
    }
    
    if (value == null || value.trim().isEmpty) {
      return null; // Optionnel et vide = OK
    }
    
    // Longueur minimum
    if (minLength != null && value.length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }
    
    // Longueur maximum
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }
    
    // Validation email
    if (isEmail && !_isValidEmail(value)) {
      return 'Format d\'email invalide';
    }
    
    return null;
  }
  
  /// Messages d'erreur personnalisés
  static String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Problème de connexion internet';
    }
    
    if (errorString.contains('timeout')) {
      return 'La requête a pris trop de temps';
    }
    
    if (errorString.contains('permission')) {
      return 'Permissions insuffisantes';
    }
    
    if (errorString.contains('not found')) {
      return 'Ressource introuvable';
    }
    
    if (errorString.contains('unauthorized')) {
      return 'Accès non autorisé';
    }
    
    return 'Une erreur inattendue s\'est produite';
  }
  
  /// Validation email
  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
  
  /// Navigation vers la boutique
  static void _navigateToShop(BuildContext context) {
    // TODO: Implémenter navigation vers la boutique
    FeedbackSystem.showToast(
      context: context,
      message: 'Navigation vers la boutique...',
      icon: '🛒',
    );
  }
  
  /// Gestion de la reconnexion
  static void _handleReconnection(BuildContext context) {
    // TODO: Implémenter logique de reconnexion
    FeedbackSystem.showToast(
      context: context,
      message: 'Reconnexion en cours...',
      icon: '🔄',
    );
  }
}

/// Extension pour les widgets avec gestion d'erreur
extension SafeWidget on Widget {
  /// Wrapper avec gestion d'erreur
  Widget withErrorHandling(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return this;
        } catch (error, stackTrace) {
          ErrorHandler.handleError(
            error: error,
            stackTrace: stackTrace,
            context: context,
          );
          
          // Widget de fallback en cas d'erreur
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 10),
                Text(
                  'Erreur d\'affichage',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// Constantes pour les codes d'erreur
class ErrorCodes {
  static const String networkError = 'NETWORK_ERROR';
  static const String authError = 'AUTH_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String insufficientCoins = 'INSUFFICIENT_COINS';
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String resourceNotFound = 'RESOURCE_NOT_FOUND';
}