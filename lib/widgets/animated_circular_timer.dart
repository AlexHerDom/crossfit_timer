import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedCircularTimer extends StatefulWidget {
  final int currentSeconds;
  final int totalSeconds;
  final Color timerColor;
  final bool isRunning;
  final VoidCallback? onTap;

  const AnimatedCircularTimer({
    super.key,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.timerColor,
    required this.isRunning,
    this.onTap,
  });

  @override
  State<AnimatedCircularTimer> createState() => _AnimatedCircularTimerState();
}

class _AnimatedCircularTimerState extends State<AnimatedCircularTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de pulsación más sutil
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.02, // Pulsación más sutil
        ).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );

    // Animación de rotación para efectos especiales
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void didUpdateWidget(AnimatedCircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Activar pulsación sutil solo cuando faltan 3 segundos
    if (widget.currentSeconds <= 3 && widget.currentSeconds > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    // No usar rotación automática para mantener profesionalismo
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Obtener color según el tiempo restante
  Color _getTimerColor() {
    if (widget.currentSeconds <= 10 && widget.currentSeconds > 0) {
      return Colors.green; // Verde en los últimos 10 segundos
    }
    return widget.timerColor; // Color normal
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.totalSeconds > 0
        ? (widget.totalSeconds - widget.currentSeconds) / widget.totalSeconds
        : 0.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getTimerColor().withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fondo del círculo
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: _getTimerColor().withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                  ),

                  // Progreso circular simple y profesional
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: _getTimerColor().withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTimerColor(),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                  // Texto del tiempo - simple y limpio
                  Text(
                    _formatTime(widget.currentSeconds),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: _getTimerColor(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
