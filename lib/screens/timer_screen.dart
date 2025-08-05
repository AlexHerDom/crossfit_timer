import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  
  // Variables específicas para cada tipo de entrenamiento
  int _currentRound = 1;
  int _totalRounds = 1;
  bool _isWorkPeriod = true; // Para Tabata (trabajo vs descanso)
  bool _isFullScreen = false; // Para modo pantalla completa
  
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

  Future<void> _playCountdownBeep() async {
    try {
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('sounds/countdown.wav'));
      HapticFeedback.mediumImpact();
      print("✅ Countdown beep reproducido exitosamente");
    } catch (e) {
      print("❌ Error reproduciendo countdown: $e");
      // Fallback
      try {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.mediumImpact();
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.mediumImpact();
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
        _currentSeconds = _totalSeconds;
        break;
      case 'EMOM':
        int minutes = prefs.getInt('emom_minutes') ?? 1;
        int seconds = prefs.getInt('emom_seconds') ?? 0;
        _totalSeconds = (minutes * 60) + seconds;
        _currentSeconds = _totalSeconds;
        _totalRounds = prefs.getInt('emom_rounds') ?? 10;
        break;
      case 'TABATA':
        _totalSeconds = prefs.getInt('tabata_work') ?? 20; // Tiempo de trabajo
        _currentSeconds = _totalSeconds;
        _totalRounds = prefs.getInt('tabata_rounds') ?? 8;
        _isWorkPeriod = true;
        break;
      case 'COUNTDOWN':
        int minutes = prefs.getInt('countdown_minutes') ?? 3;
        int seconds = prefs.getInt('countdown_seconds') ?? 0;
        _totalSeconds = (minutes * 60) + seconds;
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
          
          // Sonido cuando faltan 10 segundos
          if (_currentSeconds == 10) {
            _playCountdownBeep();
          }
          // Sonido a la mitad del tiempo total (solo si el tiempo total es mayor a 1 minuto)
          else if (_totalSeconds > 60 && _currentSeconds == (_totalSeconds ~/ 2)) {
            _playHalfwayBeep();
          }
        } else {
          _handleTimerComplete();
        }
      });
    });
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
    });
    
    // Permitir que la pantalla se bloquee al completar
    WakelockPlus.disable();
    
    // Guardar en el historial
    _saveWorkoutHistory();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Entrenamiento Completado! 🏆'),
          content: Text(_getCompletionMessage()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              child: const Text('Repetir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Volver a la pantalla principal
              },
              child: const Text('Menú Principal'),
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
        totalDuration = ((prefs.getInt('tabata_work') ?? 20) + (prefs.getInt('tabata_rest') ?? 10)) * _totalRounds;
        break;
      case 'COUNTDOWN':
        totalDuration = _totalSeconds;
        break;
    }
    
    // Crear registro del entrenamiento
    String workoutRecord = '${widget.timerType}|$totalDuration|$_totalRounds|${DateTime.now().toIso8601String()}';
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

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
        title: Text(widget.timerType),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleFullScreen,
            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            tooltip: _isFullScreen ? 'Salir de pantalla completa' : 'Pantalla completa',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Información del entrenamiento actual
            if (widget.timerType == 'TABATA')
              Text(
                _isWorkPeriod ? '¡TRABAJA! 💪' : 'Descansa 😮‍💨',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isWorkPeriod ? Colors.red : Colors.blue,
                ),
              ),
            
            if (widget.timerType != 'COUNTDOWN' && widget.timerType != 'AMRAP')
              Text(
                'Ronda $_currentRound de $_totalRounds',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            
            const SizedBox(height: 40),
            
            // Timer principal
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getTimerColor().withOpacity(0.1),
                border: Border.all(
                  color: _getTimerColor(),
                  width: 8,
                ),
              ),
              child: Center(
                child: Text(
                  _formatTime(_currentSeconds),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getTimerColor(),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Controles del timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón Reset
                FloatingActionButton(
                  onPressed: _resetTimer,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.refresh),
                ),
                
                // Botón Play/Pause
                FloatingActionButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: _isRunning ? Colors.orange : Colors.green,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                
                // Botón Stop (volver al inicio)
                FloatingActionButton(
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.stop),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Firma del desarrollador
            Text(
              '🦊 By Alexander Herrera',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
