import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class ConfettiEffect extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;
  final int duration; // Duración en segundos
  final bool isIntense; // Para efectos más intensos en celebración

  const ConfettiEffect({
    super.key,
    required this.isPlaying,
    this.onComplete,
    this.duration = 4, // 4 segundos por defecto
    this.isIntense = false, // Normal por defecto
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect> {
  late ConfettiController _confettiController;
  late ConfettiController _confettiController2;
  late ConfettiController _confettiController3; // Tercer controlador para efectos intensos
  late ConfettiController _confettiController4; // Cuarto controlador para efectos intensos

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
    _confettiController2 = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
    _confettiController3 = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
    _confettiController4 = ConfettiController(
      duration: Duration(seconds: widget.duration),
    );
  }

  @override
  void didUpdateWidget(ConfettiEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      // Efectos normales siempre presentes
      _confettiController.play();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _confettiController2.play();
      });

      // Efectos intensos solo para celebraciones especiales
      if (widget.isIntense) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _confettiController3.play();
        });

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) _confettiController4.play();
        });
      }

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
    _confettiController3.dispose();
    _confettiController4.dispose();
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
            maxBlastForce: widget.isIntense ? 35 : 20,
            minBlastForce: widget.isIntense ? 20 : 10,
            emissionFrequency: widget.isIntense ? 0.2 : 0.3,
            numberOfParticles: widget.isIntense ? 25 : 15,
            gravity: 0.3,
            colors: const [
              Colors.orange,
              Colors.amber,
              Colors.red,
              Colors.yellow,
              Colors.deepOrange,
            ],
          ),
        ),

        // Confetti lateral suave
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController2,
            blastDirection: math.pi / 2, // Hacia abajo
            maxBlastForce: widget.isIntense ? 25 : 15,
            minBlastForce: widget.isIntense ? 15 : 8,
            emissionFrequency: widget.isIntense ? 0.3 : 0.4,
            numberOfParticles: widget.isIntense ? 18 : 10,
            gravity: 0.2,
            colors: const [
              Colors.orange, 
              Colors.amber, 
              Colors.yellow,
              Colors.red,
            ],
          ),
        ),

        // Confetti lateral izquierdo (solo para efectos intensos)
        if (widget.isIntense)
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _confettiController3,
              blastDirection: math.pi / 4, // Hacia arriba-derecha
              maxBlastForce: 30,
              minBlastForce: 15,
              emissionFrequency: 0.25,
              numberOfParticles: 20,
              gravity: 0.25,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.yellow,
                Colors.redAccent,
                Colors.deepOrange,
              ],
            ),
          ),

        // Confetti lateral derecho (solo para efectos intensos)
        if (widget.isIntense)
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _confettiController4,
              blastDirection: 3 * math.pi / 4, // Hacia arriba-izquierda
              maxBlastForce: 30,
              minBlastForce: 15,
              emissionFrequency: 0.25,
              numberOfParticles: 20,
              gravity: 0.25,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.yellow,
                Colors.redAccent,
                Colors.deepOrange,
              ],
            ),
          ),
      ],
    );
  }
}
