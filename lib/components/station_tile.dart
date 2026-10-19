import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/station.dart';
import '../services/radio_provider.dart';
import '../theme/app_theme.dart';
import 'station_art.dart';

class StationTile extends StatelessWidget {
  final Station station;
  const StationTile({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RadioProvider>();
    final isCurrent = r.current?.id == station.id;
    return ListTile(
      onTap: () => r.selectStation(station),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: StationArt(station: station),
      title: Text(station.name,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCurrent ? AppColors.cyan : null)),
      subtitle: Text(station.genre, style: const TextStyle(color: Colors.white54)),
      trailing: IconButton(
        icon: Icon(
          r.isFavorite(station) ? Icons.favorite : Icons.favorite_border,
          color: r.isFavorite(station) ? AppColors.pink : Colors.white54,
        ),
        onPressed: () => r.toggleFavorite(station),
      ),
    );
  }
}
