import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await configureDependencies();
  
  // Register database instance
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  
  runApp(CraftbookApp());
}
