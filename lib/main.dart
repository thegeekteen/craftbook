import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  // Before the first frame, so a saved dark choice doesn't flash light.
  await getIt<ThemeCubit>().load();

  runApp(CraftbookApp());
}
