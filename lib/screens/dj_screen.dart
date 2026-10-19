import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/glass_card.dart';
import '../components/wave_animation.dart';
import '../services/broadcast_service.dart';
import '../theme/app_theme.dart';

class DjScreen extends StatefulWidget {
  const DjScreen({super.key});

  @override
  State<DjScreen> createState() => _DjScreenState();
}

class _DjScreenState extends State<DjScreen> with SingleTickerProviderStateMixin {
  final _url = TextEditingController(text: 'http://SUNUCU_IP:8889/live/whip');
  final _token = TextEditingController();
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      _url.text = p.getString('whip_url') ?? _url.text;
      _token.text = p.getString('whip_token') ?? '';
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _toggle(BroadcastService b) async {
    if (b.isLive || b.isBusy) {
      await b.stop();
      return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setString('whip_url', _url.text.trim());
    await p.setString('whip_token', _token.text.trim());
    await b.start(_url.text, token: _token.text);
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final b = context.watch<BroadcastService>();
    final active = b.isLive || b.isBusy;

    final (label, color) = switch (b.state) {
      BroadcastState.live => ('CANLI', Colors.redAccent),
      BroadcastState.connecting => ('BAĞLANIYOR…', Colors.orangeAccent),
      BroadcastState.reconnecting => ('YENİDEN BAĞLANIYOR…', Colors.orangeAccent),
      BroadcastState.error => ('HATA', AppColors.pink),
      BroadcastState.idle => ('YAYIN KAPALI', Colors.white38),
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('DJ / Yayıncı Paneli',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                // Canlı sinyal göstergesi
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: color.withOpacity(.15),
                      border: Border.all(color: color.withOpacity(.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            boxShadow: b.isLive
                                ? [BoxShadow(color: color, blurRadius: 4 + 12 * _pulse.value)]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(label,
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                WaveAnimation(active: b.isLive && !b.muted, height: 56),
                const SizedBox(height: 10),
                Text(_fmt(b.elapsed),
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.w300, letterSpacing: 2)),
                if (b.message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(b.message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.pink, fontSize: 12)),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _toggle(b),
                          icon: Icon(active ? Icons.stop_circle : Icons.podcasts),
                          label: Text(active ? 'YAYINI DURDUR' : 'YAYINI BAŞLAT',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: active ? Colors.redAccent : AppColors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      iconSize: 28,
                      onPressed: active ? b.toggleMute : null,
                      icon: Icon(b.muted ? Icons.mic_off : Icons.mic),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Sunucu Ayarları',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(
            controller: _url,
            enabled: !active,
            decoration: const InputDecoration(
                labelText: 'WHIP URL', prefixIcon: Icon(Icons.link)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _token,
            enabled: !active,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Yayın Anahtarı / Token (opsiyonel)',
                prefixIcon: Icon(Icons.key)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Bağlantı koparsa otomatik yeniden bağlan'),
            value: b.autoReconnect,
            onChanged: b.setAutoReconnect,
          ),
        ],
      ),
    );
  }
}
