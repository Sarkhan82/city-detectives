import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:city_detectives/features/investigation/models/investigation_progress.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_cache.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';

import 'app.dart';

/// Point d'entrée City Detectives. Lance l'app (Story 1.1 – app shell).
/// Story 3.3 : initialisation Hive pour la sauvegarde de la progression.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(InvestigationProgressAdapter());
  await Hive.openBox<InvestigationProgress>(kInvestigationProgressBoxName);
  await Hive.openBox<String>(kInvestigationCacheBoxName);
  runApp(const App());
}
