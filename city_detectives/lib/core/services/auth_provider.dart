import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/services/auth_service.dart';

/// Provider du service d'authentification (Story 1.2).
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
