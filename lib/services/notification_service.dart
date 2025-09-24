import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class NotificationService {
  static FirebaseMessaging? _messaging;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static String? _fcmToken;
  
  // Types de notifications
  static const String TYPE_NEW_MESSAGE = 'new_message';
  static const String TYPE_NEW_MATCH = 'new_match';
  static const String TYPE_LIKE_RECEIVED = 'like_received';
  static const String TYPE_PROFILE_VISIT = 'profile_visit';
  static const String TYPE_GIFT_RECEIVED = 'gift_received';
  static const String TYPE_GAME_REWARD = 'game_reward';
  static const String TYPE_DAILY_REMINDER = 'daily_reminder';
  static const String TYPE_SUBSCRIPTION_EXPIRY = 'subscription_expiry';

  // Paramètres de notification
  static Map<String, NotificationSettings> _settings = {
    TYPE_NEW_MESSAGE: NotificationSettings(enabled: true, priority: NotificationPriority.high),
    TYPE_NEW_MATCH: NotificationSettings(enabled: true, priority: NotificationPriority.high),
    TYPE_LIKE_RECEIVED: NotificationSettings(enabled: true, priority: NotificationPriority.normal),
    TYPE_PROFILE_VISIT: NotificationSettings(enabled: false, priority: NotificationPriority.low),
    TYPE_GIFT_RECEIVED: NotificationSettings(enabled: true, priority: NotificationPriority.normal),
    TYPE_GAME_REWARD: NotificationSettings(enabled: true, priority: NotificationPriority.low),
    TYPE_DAILY_REMINDER: NotificationSettings(enabled: true, priority: NotificationPriority.low),
    TYPE_SUBSCRIPTION_EXPIRY: NotificationSettings(enabled: true, priority: NotificationPriority.normal),
  };

  static Future<void> initialize() async {
    try {
      // Initialiser Firebase Messaging
      _messaging = FirebaseMessaging.instance;
      
      // Demander les permissions
      await _requestPermissions();
      
      // Initialiser les notifications locales
      await _initializeLocalNotifications();
      
      // Obtenir le token FCM
      await _getFCMToken();
      
      // Configurer les handlers
      _setupNotificationHandlers();
      
      print('NotificationService initialisé avec succès');
    } catch (e) {
      print('Erreur d\'initialisation NotificationService: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    if (_messaging == null) return;

    final settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Permission accordée: ${settings.authorizationStatus}
  }

  static Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static Future<void> _getFCMToken() async {
    if (_messaging == null) return;

    try {
      _fcmToken = await _messaging!.getToken();
      print('Token FCM: $_fcmToken');
      
      // Envoyer le token au serveur
      await _sendTokenToServer(_fcmToken!);
      
      // Écouter les changements de token
      _messaging!.onTokenRefresh.listen(_sendTokenToServer);
    } catch (e) {
      print('Erreur obtention token FCM: $e');
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      // TODO: Implémenter l'envoi du token au backend
      print('Envoi token au serveur: $token');
      
      // Sauvegarder localement
      _fcmToken = token;
    } catch (e) {
      print('Erreur envoi token: $e');
    }
  }

  static void _setupNotificationHandlers() {
    if (_messaging == null) return;

    // Messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Messages en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Clic sur notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Message en premier plan: ${message.notification?.title}');
    
    // Vérifier si les notifications sont activées pour ce type
    String notificationType = message.data['type'] ?? 'unknown';
    if (!_isNotificationEnabled(notificationType)) {
      return;
    }

    // Afficher notification locale
    await _showLocalNotification(message);
    
    // Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'notification_received_foreground',
      parameters: {
        'type': notificationType,
        'title': message.notification?.title ?? 'Sans titre',
      },
    );
  }

  static Future<void> _handleNotificationClick(RemoteMessage message) async {
    print('Clic sur notification: ${message.data}');
    
    // Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'notification_clicked',
      parameters: {
        'type': message.data['type'] ?? 'unknown',
        'action': message.data['action'] ?? 'open',
      },
    );

    // Navigation basée sur le type
    await _navigateFromNotification(message.data);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    if (_localNotifications == null) return;

    final String type = message.data['type'] ?? 'default';
    final NotificationSettings settings = _settings[type] ?? 
        NotificationSettings(enabled: true, priority: NotificationPriority.normal);

    if (!settings.enabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'jeutaime_main_channel',
      'Notifications JeTaime',
      channelDescription: 'Notifications principales de JeTaime',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications!.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? _getDefaultTitle(type),
      message.notification?.body ?? _getDefaultBody(type),
      platformDetails,
      payload: message.data.toString(),
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification locale cliquée: ${response.payload}');
    
    // Parser le payload et naviguer
    if (response.payload != null) {
      // TODO: Parser le payload et naviguer vers l'écran approprié
    }
  }

  static Future<void> _navigateFromNotification(Map<String, dynamic> data) async {
    final String type = data['type'] ?? '';
    final String? userId = data['user_id'];
    final String? conversationId = data['conversation_id'];
    
    switch (type) {
      case TYPE_NEW_MESSAGE:
        if (conversationId != null) {
          // TODO: Naviguer vers la conversation
          print('Navigation vers conversation: $conversationId');
        }
        break;
        
      case TYPE_NEW_MATCH:
        if (userId != null) {
          // TODO: Naviguer vers le profil du match
          print('Navigation vers match: $userId');
        }
        break;
        
      case TYPE_LIKE_RECEIVED:
      case TYPE_PROFILE_VISIT:
        // TODO: Naviguer vers la liste des likes/visites
        print('Navigation vers activité');
        break;
        
      case TYPE_GIFT_RECEIVED:
        if (conversationId != null) {
          // TODO: Naviguer vers la conversation avec le cadeau
          print('Navigation vers cadeau: $conversationId');
        }
        break;
        
      case TYPE_GAME_REWARD:
        // TODO: Naviguer vers l'écran des jeux
        print('Navigation vers jeux');
        break;
        
      case TYPE_DAILY_REMINDER:
        // TODO: Naviguer vers l'écran principal
        print('Navigation vers accueil');
        break;
        
      case TYPE_SUBSCRIPTION_EXPIRY:
        // TODO: Naviguer vers l'écran d'abonnement
        print('Navigation vers abonnement');
        break;
    }
  }

  // Messages d'arrière-plan (fonction top-level requise)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Message en arrière-plan: ${message.notification?.title}');
    
    // Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'notification_received_background',
      parameters: {
        'type': message.data['type'] ?? 'unknown',
        'title': message.notification?.title ?? 'Sans titre',
      },
    );
  }

  // Méthodes utilitaires
  static bool _isNotificationEnabled(String type) {
    return _settings[type]?.enabled ?? true;
  }

  static String _getDefaultTitle(String type) {
    switch (type) {
      case TYPE_NEW_MESSAGE: return '💬 Nouveau message';
      case TYPE_NEW_MATCH: return '💕 Nouveau match !';
      case TYPE_LIKE_RECEIVED: return '❤️ Quelqu\'un vous aime';
      case TYPE_PROFILE_VISIT: return '👀 Visite de profil';
      case TYPE_GIFT_RECEIVED: return '🎁 Cadeau reçu';
      case TYPE_GAME_REWARD: return '🎮 Récompense débloquée';
      case TYPE_DAILY_REMINDER: return '🌟 Revenez nous voir !';
      case TYPE_SUBSCRIPTION_EXPIRY: return '⭐ Abonnement expire bientôt';
      default: return 'JeTaime';
    }
  }

  static String _getDefaultBody(String type) {
    switch (type) {
      case TYPE_NEW_MESSAGE: return 'Vous avez reçu un nouveau message';
      case TYPE_NEW_MATCH: return 'Vous avez un nouveau match à découvrir';
      case TYPE_LIKE_RECEIVED: return 'Découvrez qui vous a liké';
      case TYPE_PROFILE_VISIT: return 'Quelqu\'un a visité votre profil';
      case TYPE_GIFT_RECEIVED: return 'Vous avez reçu un cadeau spécial';
      case TYPE_GAME_REWARD: return 'Vous avez gagné une récompense';
      case TYPE_DAILY_REMINDER: return 'De nouvelles personnes vous attendent';
      case TYPE_SUBSCRIPTION_EXPIRY: return 'Renouvelez pour continuer à profiter';
      default: return 'Vous avez une nouvelle notification';
    }
  }

  // API publique
  static Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // TODO: Appel API backend pour envoyer la notification
      print('Envoi notification: $type vers $userId');
      
      // Analytics
      FirebaseAnalytics.instance.logEvent(
        name: 'notification_sent',
        parameters: {
          'type': type,
          'target_user': userId,
        },
      );
    } catch (e) {
      print('Erreur envoi notification: $e');
    }
  }

  static Future<void> updateNotificationSettings(String type, bool enabled) async {
    _settings[type] = _settings[type]?.copyWith(enabled: enabled) ?? 
        NotificationSettings(enabled: enabled, priority: NotificationPriority.normal);
    
    // TODO: Sauvegarder en local et sync avec le serveur
    print('Paramètre notification $type: $enabled');
  }

  static Map<String, bool> getNotificationSettings() {
    return _settings.map((key, value) => MapEntry(key, value.enabled));
  }

  static Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (_localNotifications == null) return;

    // TODO: Implémenter la planification avec timezone
    // Nécessite l'import de 'package:timezone/timezone.dart' as tz;
    // 
    // await _localNotifications!.zonedSchedule(
    //   DateTime.now().millisecondsSinceEpoch.remainder(100000),
    //   title,
    //   body,
    //   tz.TZDateTime.from(scheduledTime, tz.local),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'jeutaime_scheduled_channel',
    //       'Rappels JeTaime',
    //       channelDescription: 'Notifications programmées de JeTaime',
    //       importance: Importance.defaultImportance,
    //       priority: Priority.defaultPriority,
    //     ),
    //     iOS: DarwinNotificationDetails(),
    //   ),
    //   payload: payload,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );
  }

  static Future<void> cancelAllNotifications() async {
    if (_localNotifications == null) return;
    await _localNotifications!.cancelAll();
  }

  static String? get fcmToken => _fcmToken;
}

// Handler pour les messages d'arrière-plan (fonction globale requise)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService._firebaseMessagingBackgroundHandler(message);
}

class NotificationSettings {
  final bool enabled;
  final NotificationPriority priority;

  const NotificationSettings({
    required this.enabled,
    required this.priority,
  });

  NotificationSettings copyWith({
    bool? enabled,
    NotificationPriority? priority,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
    );
  }
}

enum NotificationPriority {
  low,
  normal,
  high,
}