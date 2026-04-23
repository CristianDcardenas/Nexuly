import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Captura de errores no manejados de Flutter.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('🔴 FlutterError: ${details.exceptionAsString()}');
    }
    // TODO: enviar a Crashlytics cuando lo añadamos.
  };

  runApp(const ProviderScope(child: NexulyApp()));
}

class NexulyApp extends ConsumerWidget {
  const NexulyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Nexuly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066FF)),
      ),
      home: const _BootstrapScreen(),
    );
  }
}

/// Pantalla temporal del paso 1.
/// En la Fase 4 (auth) será reemplazada por un router con go_router.
class _BootstrapScreen extends ConsumerWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexuly'),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 72, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Backend inicializado',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Firebase conectado. Modelos y repositorios listos.\n'
                'Siguiente paso: autenticación.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
