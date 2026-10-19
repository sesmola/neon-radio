import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/now_playing_card.dart';
import '../components/station_tile.dart';
import '../services/auth_service.dart';
import '../services/radio_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final radio = context.watch<RadioProvider>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (r) => AppColors.gradient.createShader(r),
                  child: Text(
                    'Hoş Geldiniz, ${auth.displayName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Çıkış yap',
                icon: const Icon(Icons.logout, color: Colors.white54),
                onPressed: () async {
                  await context.read<RadioProvider>().stopPlayback();
                  await context.read<AuthService>().logout();
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          const NowPlayingCard(),
          const SizedBox(height: 24),
          const Text('Canlı İstasyonlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final s in radio.stations) StationTile(station: s),
        ],
      ),
    );
  }
}
