import 'package:flutter/material.dart';

import '../models/station.dart';
import '../theme/app_theme.dart';

/// İstasyon adına göre üretilen gradient "albüm kapağı".
/// (ICY metadata kapak görseli taşımaz; gerçek kapaklar için bir API
/// (iTunes Search / MusicBrainz) eklenebilir.)
class StationArt extends StatelessWidget {
  final Station? station;
  final double size;
  final bool glow;

  const StationArt({super.key, this.station, this.size = 56, this.glow = false});

  @override
  Widget build(BuildContext context) {
    final h = (station?.id.hashCode ?? 0).abs() % 360;
    final c1 = HSVColor.fromAHSV(1, h.toDouble(), .75, .95).toColor();
    final c2 = HSVColor.fromAHSV(1, ((h + 80) % 360).toDouble(), .8, .6).toColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .18),
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: glow
            ? [BoxShadow(color: AppColors.pink.withOpacity(.45), blurRadius: 40, spreadRadius: 2)]
            : null,
      ),
      child: Icon(Icons.radio, color: Colors.white.withOpacity(.9), size: size * .45),
    );
  }
}
