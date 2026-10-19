import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/radio_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'station_art.dart';
import 'wave_animation.dart';

class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RadioProvider>();
    final s = r.current;

    return GlassCard(
      child: Column(
        children: [
          StationArt(station: s, size: 170, glow: r.playing),
          const SizedBox(height: 20),
          WaveAnimation(active: r.playing && !r.loading),
          const SizedBox(height: 14),
          Text(r.nowTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(r.nowArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, fontSize: 15)),
          if (r.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(r.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.pink, fontSize: 12)),
            ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 28,
                onPressed: s == null ? null : () => r.toggleFavorite(s),
                icon: Icon(
                  s != null && r.isFavorite(s) ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.pink,
                ),
              ),
              _PlayButton(playing: r.playing, loading: r.loading, onTap: r.togglePlay),
              IconButton(
                iconSize: 28,
                onPressed: () => _sleepSheet(context),
                icon: Icon(
                  Icons.bedtime_outlined,
                  color: r.sleepLeft != null ? AppColors.cyan : Colors.white70,
                ),
              ),
            ],
          ),
          if (r.sleepLeft != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Uyku zamanlayıcısı: ${_fmt(r.sleepLeft!)}',
                  style: const TextStyle(color: AppColors.cyan, fontSize: 12)),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.volume_mute, size: 20, color: Colors.white54),
              Expanded(
                child: Slider(value: r.volume, onChanged: r.setVolume),
              ),
              const Icon(Icons.volume_up, size: 20, color: Colors.white54),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  void _sleepSheet(BuildContext context) {
    final r = context.read<RadioProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Uyku Zamanlayıcısı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            for (final m in [15, 30, 45, 60, 90])
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text('$m dakika sonra kapat'),
                onTap: () {
                  r.setSleepTimer(Duration(minutes: m));
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.timer_off_outlined, color: AppColors.pink),
              title: const Text('Zamanlayıcıyı iptal et'),
              onTap: () {
                r.setSleepTimer(null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool playing, loading;
  final VoidCallback onTap;
  const _PlayButton({required this.playing, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradient,
          boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(.6), blurRadius: 24)],
        ),
        child: loading && playing
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
            : Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 44, color: Colors.white),
      ),
    );
  }
}
