import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/radio_provider.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final h = context.watch<RadioProvider>().history;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Son Çalınanlar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Expanded(
              child: h.isEmpty
                  ? const Center(
                      child: Text('Çalan parça bilgisi geldikçe burada listelenir.',
                          style: TextStyle(color: Colors.white54)))
                  : ListView.separated(
                      itemCount: h.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                      itemBuilder: (_, i) {
                        final t = h[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.music_note, color: AppColors.cyan),
                          title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${t.artist} • ${t.station}',
                              style: const TextStyle(color: Colors.white54)),
                          trailing: Text(_hm(t.playedAt),
                              style: const TextStyle(color: Colors.white38)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
