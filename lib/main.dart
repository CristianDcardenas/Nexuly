import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/storage/local_cache.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Firebase ---
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- Almacenamiento local (Hive) ---
  // Reto 1: persistencia offline. Se inicializa antes de runApp porque
  // algunos providers leen el cache en su build() inicial.
  await initializeLocalStorage();

  await NotificationService.instance.initialize();

  // NOTA: App Check sigue desactivado — reactivar cerca del deploy.

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('🔴 FlutterError: ${details.exceptionAsString()}');
    }
  };

  runApp(const ProviderScope(child: NexulyApp()));
}

class NexulyApp extends ConsumerWidget {
  const NexulyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Nexuly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
