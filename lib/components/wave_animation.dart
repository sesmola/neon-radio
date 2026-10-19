import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Ses dalgası (equalizer) animasyonu. [active] false ise düz çizgiye iner.
class WaveAnimation extends StatefulWidget {
  final bool active;
  final int bars;
  final double height;
  final Color? color;

  const WaveAnimation({
    super.key,
    required this.active,
    this.bars = 28,
    this.height = 48,
    this.color,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant WaveAnimation old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) _c.repeat();
    if (!widget.active && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.bars, (i) {
            final v = widget.active
                ? 0.2 + 0.8 * math.sin(_c.value * 2 * math.pi + i * 0.55).abs()
                : 0.08;
            return Container(
              width: 4,
              height: widget.height * v,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: widget.color != null
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.pink, AppColors.cyan],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                color: widget.color,
              ),
            );
          }),
        ),
      ),
    );
  }
}
