import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class ConfettiEffect extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;
  final int duration; // Duración en segundos

  const ConfettiEffect({
    super.key,
    required this.isPlaying,
    this.onComplete,
    this.duration = 4, // 4 segundos por defecto
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect> {
  late ConfettiController _confettiController;
  late ConfettiController _confettiController2;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
    _confettiController2 = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
  }

  @override
  void didUpdateWidget(ConfettiEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      // Iniciar con un pequeño delay para efecto más elegante
      _confettiController.play();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _confettiController2.play();
      });

      // Llamar onComplete después de la animación
      Future.delayed(Duration(seconds: widget.duration), () {
        if (mounted) widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _confettiController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti principal desde el centro hacia arriba - más elegante
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -math.pi / 2, // Hacia arriba
            maxBlastForce: 20,
            minBlastForce: 10,
            emissionFrequency: 0.3,
            numberOfParticles: 15,
            gravity: 0.3,
            colors: const [
              Colors.orange,
              Colors.amber,
              Colors.red,
              Colors.yellow,
            ],
          ),
        ),

        // Confetti lateral suave
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController2,
            blastDirection: math.pi / 2, // Hacia abajo
            maxBlastForce: 15,
            minBlastForce: 8,
            emissionFrequency: 0.4,
            numberOfParticles: 10,
            gravity: 0.2,
            colors: const [Colors.orange, Colors.amber, Colors.yellow],
          ),
        ),
      ],
    );
  }
}
