// Story 8.1 – FR85, FR86, FR87. FCM/APNs : token, enregistrement backend, écoute des messages.
// Configuration Firebase (google-services.json, GoogleService-Info.plist) hors repo – voir README ou .env.example.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';

/// Callback pour obtenir le JWT courant (après login / au refresh FCM).
typedef GetAuthToken = Future<String?> Function();

const String _registerPushTokenMutation = r'''
  mutation RegisterPushToken($token: String!, $platform: String!) {
    registerPushToken(token: $token, platform: $platform)
  }
''';

/// Callback appelé quand l'utilisateur ouvre une notification (Task 4.2 – navigation).
typedef OnNotificationOpened = void Function(RemoteMessage message);

/// Callback optionnel pour tests : appelé quand [registerWithBackend] est invoqué (Task 5.2).
typedef OnRegisterWithBackendCalled = void Function(String authToken, String? fcmToken);

/// Service push (Story 8.1). Initialisation FCM, permission, token, enregistrement backend, écoute messages.
/// Si Firebase n'est pas configuré (ex. tests), [initialize] est no-op et [getToken] retourne null.
///
/// Pour les tests (Task 5.2) : [getTokenOverride] et [ensureInitializedForTest] permettent
/// de simuler un token FCM et un init réussi sans Firebase.
class PushService {
  PushService({
    GraphQLClient Function(String? authToken)? createClient,
    GetAuthToken? getAuthToken,
    OnNotificationOpened? onNotificationOpened,
    Future<String?> Function()? getTokenOverride,
    bool ensureInitializedForTest = false,
    OnRegisterWithBackendCalled? onRegisterWithBackendCalled,
  })  : _createClient = createClient ?? ((String? t) => createGraphQLClient(authToken: t)),
        _getAuthToken = getAuthToken,
        _onNotificationOpened = onNotificationOpened,
        _getTokenOverride = getTokenOverride,
        _ensureInitializedForTest = ensureInitializedForTest,
        _onRegisterWithBackendCalled = onRegisterWithBackendCalled;

  final GraphQLClient Function(String? authToken) _createClient;
  final GetAuthToken? _getAuthToken;
  OnNotificationOpened? _onNotificationOpened;
  final Future<String?> Function()? _getTokenOverride;
  final bool _ensureInitializedForTest;
  final OnRegisterWithBackendCalled? _onRegisterWithBackendCalled;

  /// Enregistre le callback pour la navigation au tap (Task 4.2). À appeler depuis un widget ayant accès au router.
  void setOnNotificationOpened(OnNotificationOpened? cb) {
    _onNotificationOpened = cb;
  }

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialise Firebase. No-op si options absentes (ex. tests sans google-services.json).
  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PushService: Firebase non configuré ($e) – push désactivé.');
      }
      return false;
    }
  }

  /// Configure l'instance après init Firebase. À appeler une fois (ex. au démarrage de l'app).
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (_ensureInitializedForTest) {
      _initialized = true;
      return;
    }
    _initialized = await PushService.initialize();
    if (!_initialized) return;
    _setupTokenRefresh();
    _setupMessageHandlers();
  }

  void _setupTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      try {
        final authToken = _getAuthToken != null ? await _getAuthToken() : null;
        if (authToken != null && authToken.isNotEmpty) {
          await registerWithBackend(authToken, newToken);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('PushService onTokenRefresh: $e');
      }
    });
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('PushService: message reçu (foreground) ${message.notification?.title}');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('PushService: notification ouverte ${message.data}');
      }
      _onNotificationOpened?.call(message);
    });
  }

  /// Demande la permission notification si nécessaire (iOS). Android pas nécessaire pour les notifications.
  Future<bool> requestPermission() async {
    if (!_initialized) return false;
    if (_ensureInitializedForTest) return true;
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Récupère le token FCM (APNs sur iOS via FCM). Retourne null si non configuré ou refus.
  Future<String?> getToken() async {
    if (!_initialized) return null;
    if (_getTokenOverride != null) return _getTokenOverride();
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      if (kDebugMode) debugPrint('PushService getToken: $e');
      return null;
    }
  }

  /// Plateforme courante pour registerPushToken (évite dart:io pour compatibilité web).
  static String get platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }

  /// Enregistre le token push côté backend (mutation registerPushToken). À appeler après login et au refresh.
  Future<bool> registerWithBackend(String authToken, [String? fcmToken]) async {
    final token = fcmToken ?? await getToken();
    _onRegisterWithBackendCalled?.call(authToken, token);
    if (token == null || token.isEmpty) return false;
    final client = _createClient(authToken);
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(_registerPushTokenMutation),
          variables: {'token': token, 'platform': platform},
        ),
      );
      if (result.hasException) {
        if (kDebugMode) {
          debugPrint('PushService registerWithBackend: ${result.exception}');
        }
        return false;
      }
      final ok = result.data?['registerPushToken'] as bool?;
      return ok ?? false;
    } catch (e) {
      if (kDebugMode) debugPrint('PushService registerWithBackend: $e');
      return false;
    }
  }
}
