import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:city_detectives/features/investigation/models/completed_investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_progress.dart';
import 'package:city_detectives/features/investigation/repositories/completed_investigation_repository.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_cache.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';

import 'app.dart';

/// Point d'entrée City Detectives. Lance l'app (Story 1.1 – app shell).
/// Story 3.3 : initialisation Hive pour la sauvegarde de la progression.
/// Story 5.1 : box enquêtes complétées pour statut et historique.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(InvestigationProgressAdapter());
  Hive.registerAdapter(CompletedInvestigationAdapter());
  await Hive.openBox<InvestigationProgress>(kInvestigationProgressBoxName);
  await Hive.openBox<CompletedInvestigation>(kCompletedInvestigationBoxName);
  await Hive.openBox<String>(kInvestigationCacheBoxName);
  runApp(const App());
}
