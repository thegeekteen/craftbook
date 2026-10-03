import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/widgets/app_restarter.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';

Future<void> _bootstrap() async {
  await configureDependencies();
  // Before the first frame, so a saved dark choice doesn't flash light.
  await getIt<ThemeCubit>().load();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _bootstrap();

  runApp(AppRestarter(
    // After a restore: the old database is already closed.
    reload: () async {
      await getIt.reset();
      await _bootstrap();
    },
    builder: (messengerKey) => CraftbookApp(scaffoldMessengerKey: messengerKey),
  ));
}
