import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/animated_circular_timer.dart';
import '../widgets/confetti_effect.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  final String timerType;

  const TimerScreen({super.key, required this.timerType});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Variables para controlar el timer
  Timer? _timer;
  int _currentSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _showConfetti = false;

  // Variables específicas para cada tipo de entrenamiento
  int _currentRound = 1;
  int _totalRounds = 1;
  bool _isWorkPeriod = true; // Para Tabata (trabajo vs descanso)
  bool _isFullScreen = false; // Para modo pantalla completa

    // Variables para preparación
  int _preparationTime = 10;
  bool _isPreparation = true; // Período de preparación de 10 segundos

  // Player de audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    // Asegurar que se desactive wakelock al salir
    WakelockPlus.disable();
    super.dispose();
  }

  // Funciones para feedback de audio usando archivos de sonido
  Future<void> _playBeep() async {
    try {
      // Configurar el player para Android
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('sounds/beep.wav'));
      HapticFeedback.lightImpact();
      print("✅ Beep reproducido exitosamente");
    } catch (e) {
      print("❌ Error reproduciendo beep: $e");
      // Fallback múltiple
      try {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _playCompletionSound() async {
    try {
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('sounds/completion.wav'));
      HapticFeedback.heavyImpact();
      print("✅ Completion sound reproducido exitosamente");
    } catch (e) {
      print("❌ Error reproduciendo completion: $e");
      // Fallback múltiple
      try {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.heavyImpact();
      }
    }
  }

  Future<void> _playHalfwayBeep() async {
    try {
      // Sonido especial diferente para la mitad del tiempo (más grave y largo)
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('sounds/halfway_special.wav'));
      HapticFeedback.lightImpact();
      print("✅ Halfway beep especial reproducido exitosamente");
    } catch (e) {
      print("❌ Error reproduciendo halfway: $e");
      // Fallback
      try {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _playHalfwayDoubleBeep() async {
    try {
      // Primer beep
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('sounds/halfway.wav'));
      HapticFeedback.lightImpact();
      
      // Esperar un momento y segundo beep
      await Future.delayed(const Duration(milliseconds: 300));
      await _audioPlayer.play(AssetSource('sounds/halfway.wav'));
      HapticFeedback.lightImpact();
      
      print("✅ Halfway double beep reproducido exitosamente");
    } catch (e) {
      print("❌ Error reproduciendo halfway double beep: $e");
      // Fallback
      try {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 300));
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _playPreparationBeep() async {
    try {
      // Sonido especial para la preparación (más suave y motivador)
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('sounds/beep.wav'));
      HapticFeedback.selectionClick(); // Vibración más suave para preparación
      print("✅ Preparation beep reproducido exitosamente");
    } catch (e) {
      print("❌ Error reproduciendo preparation beep: $e");
      // Fallback
      try {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.selectionClick();
      }
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _setupTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.timerType) {
      case 'AMRAP':
        int minutes = prefs.getInt('amrap_minutes') ?? 5;
        int seconds = prefs.getInt('amrap_seconds') ?? 0;
        _totalSeconds = (minutes * 60) + seconds;
        // Inicializar con período de preparación
        _isPreparation = true;
        _currentSeconds = _preparationTime;
        break;
      case 'EMOM':
        int minutes = prefs.getInt('emom_minutes') ?? 1;
        int seconds = prefs.getInt('emom_seconds') ?? 0;
        _totalSeconds = (minutes * 60) + seconds;
        _totalRounds = prefs.getInt('emom_rounds') ?? 10;
        // Inicializar con período de preparación
        _isPreparation = true;
        _currentSeconds = _preparationTime;
        break;
      case 'TABATA':
        _totalSeconds = prefs.getInt('tabata_work') ?? 20; // Tiempo de trabajo
        _totalRounds = prefs.getInt('tabata_rounds') ?? 8;
        _isWorkPeriod = true;
        // Inicializar con período de preparación
        _isPreparation = true;
        _currentSeconds = _preparationTime;
        break;
      case 'COUNTDOWN':
        int minutes = prefs.getInt('countdown_minutes') ?? 3;
        int seconds = prefs.getInt('countdown_seconds') ?? 0;
        _totalSeconds = (minutes * 60) + seconds;
        // Para COUNTDOWN, no usar preparación - iniciar directamente
        _isPreparation = false;
        _currentSeconds = _totalSeconds;
        break;
    }
    setState(() {}); // Actualizar la UI con los nuevos valores
  }

  void _startTimer() {
    if (_isPaused) {
      _isPaused = false;
    }

    setState(() {
      _isRunning = true;
    });

    // Mantener la pantalla activa durante el entrenamiento
    WakelockPlus.enable();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;

          // Durante la preparación
          if (_isPreparation) {
            // Sonidos de countdown en los últimos 3 segundos de preparación
            if (_currentSeconds <= 3 && _currentSeconds > 0) {
              _playPreparationBeep();
            }
            // Cuando termina la preparación
            else if (_currentSeconds == 0) {
              _finishPreparation();
              return; // Salir para evitar manejar el timer complete
            }
          } else {
            // Durante el entrenamiento normal
            
            // Sonido en cada segundo durante los últimos 10 segundos
            if (_currentSeconds <= 10 && _currentSeconds > 0) {
              _playBeep();
            }
            // Sonido especial doble en el segundo 30 (mitad del minuto)
            else if (_currentSeconds == 30) {
              _playHalfwayDoubleBeep();
            }
            // Sonido a la mitad del tiempo total (solo si el tiempo total es mayor a 1 minuto y no es 30)
            else if (_totalSeconds > 60 &&
                _currentSeconds == (_totalSeconds ~/ 2) &&
                _currentSeconds != 30) {
              _playHalfwayBeep();
            }
          }
        } else {
          if (!_isPreparation) {
            _handleTimerComplete();
          }
        }
      });
    });
  }

  void _finishPreparation() async {
    setState(() {
      _isPreparation = false;

      // Configurar el timer principal según el tipo
      switch (widget.timerType) {
        case 'AMRAP':
        case 'COUNTDOWN':
          _currentSeconds = _totalSeconds;
          break;
        case 'EMOM':
          _currentSeconds = _totalSeconds;
          break;
        case 'TABATA':
          _currentSeconds = _totalSeconds; // Tiempo de trabajo
          break;
      }
    });

    // Vibración intensa para marcar el inicio
    HapticFeedback.heavyImpact();

    // Sonido de inicio del entrenamiento (más fuerte y motivador)
    _playCompletionSound();

    // Breve pausa para el efecto dramático
    await Future.delayed(const Duration(milliseconds: 200));

    print("🚀 ¡ENTRENAMIENTO INICIADO! Tipo: ${widget.timerType}");
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });

    // Permitir que la pantalla se bloquee al pausar
    WakelockPlus.disable();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _currentRound = 1;
      _isWorkPeriod = true;
      // Solo activar preparación si NO es COUNTDOWN
      _isPreparation = widget.timerType != 'COUNTDOWN';
      _showConfetti = false;
      _setupTimer();
    });

    // Permitir que la pantalla se bloquee al resetear
    WakelockPlus.disable();
  }

  void _handleTimerComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.timerType) {
      case 'AMRAP':
        _timer?.cancel();
        _playCompletionSound();
        _showCompletionDialog();
        break;
      case 'EMOM':
        _playBeep();
        if (_currentRound < _totalRounds) {
          _currentRound++;
          int minutes = prefs.getInt('emom_minutes') ?? 1;
          int seconds = prefs.getInt('emom_seconds') ?? 0;
          _currentSeconds = (minutes * 60) + seconds;
        } else {
          _timer?.cancel();
          _playCompletionSound();
          _showCompletionDialog();
        }
        break;
      case 'TABATA':
        if (_isWorkPeriod) {
          // Cambiar a período de descanso
          _isWorkPeriod = false;
          _currentSeconds = prefs.getInt('tabata_rest') ?? 10;
          _playBeep();
        } else {
          // Terminar descanso, siguiente ronda o completar
          _isWorkPeriod = true;
          if (_currentRound < _totalRounds) {
            _currentRound++;
            _currentSeconds = prefs.getInt('tabata_work') ?? 20;
            _playBeep();
          } else {
            _timer?.cancel();
            _playCompletionSound();
            _showCompletionDialog();
          }
        }
        break;
      case 'COUNTDOWN':
        _timer?.cancel();
        _playCompletionSound();
        _showCompletionDialog();
        break;
    }
  }

  void _showCompletionDialog() {
    setState(() {
      _isRunning = false;
      _showConfetti = true;
    });

    // Permitir que la pantalla se bloquee al completar
    WakelockPlus.disable();

    // Guardar en el historial
    _saveWorkoutHistory();

    // Ocultar confetti después de un tiempo más corto
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Colors.orange, size: 32),
              const SizedBox(height: 8),
              const Text(
                '¡Completado!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCompletionMessage(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '🔥 ¡Excelente trabajo! 🔥',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetTimer();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Repetir'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Volver a la pantalla principal
                },
                icon: const Icon(Icons.home),
                label: const Text('Menú Principal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveWorkoutHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('workout_history') ?? [];

    // Calcular duración total del entrenamiento
    int totalDuration = 0;
    switch (widget.timerType) {
      case 'AMRAP':
        totalDuration = _totalSeconds;
        break;
      case 'EMOM':
        totalDuration = _totalSeconds * _totalRounds;
        break;
      case 'TABATA':
        totalDuration =
            ((prefs.getInt('tabata_work') ?? 20) +
                (prefs.getInt('tabata_rest') ?? 10)) *
            _totalRounds;
        break;
      case 'COUNTDOWN':
        totalDuration = _totalSeconds;
        break;
    }

    // Crear registro del entrenamiento
    String workoutRecord =
        '${widget.timerType}|$totalDuration|$_totalRounds|${DateTime.now().toIso8601String()}';
    history.add(workoutRecord);

    // Mantener solo los últimos 50 entrenamientos
    if (history.length > 50) {
      history = history.sublist(history.length - 50);
    }

    await prefs.setStringList('workout_history', history);
  }

  String _getCompletionMessage() {
    switch (widget.timerType) {
      case 'AMRAP':
        return '¡Has completado tu entrenamiento AMRAP!';
      case 'EMOM':
        return '¡Has completado $_totalRounds rondas EMOM!';
      case 'TABATA':
        return '¡Has completado $_totalRounds rondas de Tabata!';
      case 'COUNTDOWN':
        return '¡Tiempo completado!';
      default:
        return '¡Buen trabajo!';
    }
  }

  Color _getTimerColor() {
    if (widget.timerType == 'TABATA') {
      return _isWorkPeriod ? Colors.red : Colors.blue;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.timerType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_getTimerColor().withOpacity(0.8), _getTimerColor()],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFullScreen,
            icon: Icon(
              _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
            tooltip: _isFullScreen
                ? 'Salir de pantalla completa'
                : 'Pantalla completa',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicador de preparación - simple y profesional
                if (_isPreparation)
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: const Text(
                          '🔥 Prepárate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.0, 1.0),
                      ),

                // Información del entrenamiento actual con animación
                if (widget.timerType == 'TABATA' && !_isPreparation)
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isWorkPeriod
                                ? [
                                    Colors.red.withOpacity(0.8),
                                    Colors.orange.withOpacity(0.6),
                                  ]
                                : [
                                    Colors.blue.withOpacity(0.8),
                                    Colors.cyan.withOpacity(0.6),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: (_isWorkPeriod ? Colors.red : Colors.blue)
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          _isWorkPeriod
                              ? '💪 ¡TRABAJA DURO!'
                              : '😮‍💨 Recupera',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                      )
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withOpacity(0.6),
                      ),

                if (widget.timerType != 'COUNTDOWN' &&
                    widget.timerType != 'AMRAP' &&
                    !_isPreparation)
                  Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getTimerColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getTimerColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Ronda $_currentRound de $_totalRounds',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _getTimerColor(),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 40),

                // Timer principal animado
                Center(
                      child: AnimatedCircularTimer(
                        currentSeconds: _currentSeconds,
                        totalSeconds: _isPreparation
                            ? _preparationTime
                            : _totalSeconds,
                        timerColor: _isPreparation
                            ? Colors.orange
                            : _getTimerColor(),
                        isRunning: _isRunning,
                        onTap: () {
                          if (_isRunning) {
                            _pauseTimer();
                          } else {
                            _startTimer();
                          }
                        },
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                    ),

                const SizedBox(height: 60),

                // Controles del timer con animaciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Reset
                    _buildControlButton(
                          onPressed: _resetTimer,
                          backgroundColor: Colors.grey[600]!,
                          icon: Icons.refresh,
                          label: 'Reset',
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    // Botón Play/Pause
                    _buildControlButton(
                          onPressed: _isRunning ? _pauseTimer : _startTimer,
                          backgroundColor: _isRunning
                              ? Colors.orange
                              : Colors.green,
                          icon: _isRunning ? Icons.pause : Icons.play_arrow,
                          label: _isRunning ? 'Pausa' : 'Iniciar',
                          isPrimary: true,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 700.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                        ),

                    // Botón Stop
                    _buildControlButton(
                          onPressed: () => Navigator.pop(context),
                          backgroundColor: Colors.red[600]!,
                          icon: Icons.stop,
                          label: 'Salir',
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),

                const SizedBox(height: 30),

                // Firma del desarrollador con animación
                Text(
                      '🦊 By Alexander Herrera',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1000.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),

          // Efecto de confetti - más discreto
          if (_showConfetti)
            ConfettiEffect(
              isPlaying: _showConfetti,
              duration: 3, // 3 segundos de confetti elegante
              onComplete: () {
                setState(() {
                  _showConfetti = false;
                });
              },
            ),
        ],
      ),
    );
  }

  // Widget para botones de control mejorados
  Widget _buildControlButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: backgroundColor,
            heroTag: label,
            elevation: 8,
            child: Icon(icon, size: isPrimary ? 32 : 28, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }
}
