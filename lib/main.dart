import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/audio_handler.dart';
import 'services/auth_service.dart';
import 'services/broadcast_service.dart';
import 'services/radio_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Arka plan çalma + bildirim/kilit ekranı kontrolü
  final handler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.neonradio.audio',
      androidNotificationChannelName: 'Neon Radyo',
      androidNotificationOngoing: true,
    ),
  );

  final auth = AuthService();
  await auth.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => RadioProvider(handler)),
        ChangeNotifierProvider(create: (_) => BroadcastService()),
      ],
      child: const NeonRadioApp(),
    ),
  );
}

class NeonRadioApp extends StatelessWidget {
  const NeonRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Radyo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Consumer<AuthService>(
        builder: (_, auth, __) =>
            auth.isLoggedIn ? const MainShell() : const LoginScreen(),
      ),
    );
  }
}
