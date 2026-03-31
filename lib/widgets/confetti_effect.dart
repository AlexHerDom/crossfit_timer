import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class ConfettiEffect extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;
  final int duration;
  final bool isIntense;

  const ConfettiEffect({
    super.key,
    required this.isPlaying,
    this.onComplete,
    this.duration = 3,
    this.isIntense = false,
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect> {
  late ConfettiController _controller;
  late ConfettiController _controller2;

  // Colores de los botones del menú principal
  static const _colors = [
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
    _controller2 = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
  }

  @override
  void didUpdateWidget(ConfettiEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.play();

      if (widget.isIntense) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _controller2.play();
        });
      }

      Future.delayed(Duration(seconds: widget.duration), () {
        if (mounted) widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti suave desde arriba-centro
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirection: math.pi / 2, // Hacia abajo
            maxBlastForce: 8,
            minBlastForce: 3,
            emissionFrequency: widget.isIntense ? 0.06 : 0.04,
            numberOfParticles: widget.isIntense ? 6 : 4,
            gravity: 0.15,
            colors: _colors,
          ),
        ),

        // Segundo emisor solo para level-up
        if (widget.isIntense)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller2,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 10,
              minBlastForce: 4,
              emissionFrequency: 0.04,
              numberOfParticles: 5,
              gravity: 0.12,
              colors: _colors,
            ),
          ),
      ],
    );
  }
}
