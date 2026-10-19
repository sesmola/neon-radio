import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/station_tile.dart';
import '../services/radio_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<RadioProvider>().favorites;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Favori İstasyonlar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Expanded(
              child: favs.isEmpty
                  ? const Center(
                      child: Text('Henüz favori yok.\nKalp simgesine dokunarak ekleyin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54)))
                  : ListView(children: [for (final s in favs) StationTile(station: s)]),
            ),
          ],
        ),
      ),
    );
  }
}
