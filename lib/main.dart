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

  RadioAudioHandler handler;
  String? initError;
  try {
    // Arka plan çalma + bildirim/kilit ekranı kontrolü
    handler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.neonradio.audio',
        androidNotificationChannelName: 'Neon Radyo',
        androidNotificationOngoing: true,
      ),
    ).timeout(const Duration(seconds: 8));
  } catch (e) {
    // Servis başlamazsa uygulama yine de açılır (sadece ön planda çalar)
    initError = e.toString();
    handler = RadioAudioHandler();
  }

  final auth = AuthService();
  try {
    await auth.load().timeout(const Duration(seconds: 3));
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => RadioProvider(handler)),
        ChangeNotifierProvider(create: (_) => BroadcastService()),
      ],
      child: NeonRadioApp(initError: initError),
    ),
  );
}

class NeonRadioApp extends StatelessWidget {
  final String? initError;
  const NeonRadioApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Radyo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) => Stack(
        children: [
          child ?? const SizedBox.shrink(),
          if (initError != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Material(
                color: Colors.red.shade900,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Ses servisi hatası: $initError',
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ),
            ),
        ],
      ),
      home: Consumer<AuthService>(
        builder: (_, auth, __) =>
            auth.isLoggedIn ? const MainShell() : const LoginScreen(),
      ),
    );
  }
}
