import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfettiOverlay extends StatefulWidget {
  final ConfettiController controller;

  const ConfettiOverlay({super.key, required this.controller});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: widget.controller,
        blastDirectionality: BlastDirectionality.explosive,
        particleDrag: 0.05,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.2,
        shouldLoop: false,
        colors: const [
          AppTheme.primaryPink,
          AppTheme.roseGold,
          AppTheme.coralPink,
          AppTheme.lightPink,
          Colors.white,
        ],
      ),
    );
  }
}
