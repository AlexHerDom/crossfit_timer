import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/animated_circular_timer.dart';
import '../widgets/confetti_effect.dart';
import '../theme_provider.dart';
import '../language_provider.dart';
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

  // Variables específicas para RUNNING
  bool _isRunningDistance = true; // true = corriendo, false = descansando
  int _targetDistance = 400; // metros objetivo
  int _restSeconds = 120; // segundos de descanso
  bool _showRunningSummary =
      false; // Para mostrar resumen final en lugar del timer

  // Variables para tracking de rendimiento
  List<int> _roundTimes = []; // Tiempos de cada ronda en segundos
  int _roundStartTime = 0; // Tiempo cuando empezó la ronda actual

  // Variables para preparación
  int _preparationTime = 10;
  bool _isPreparation = true; // Período de preparación de 10 segundos
  int _lastBeepSecond = -1; // Para controlar beeps únicos por segundo
  bool _hasPlayedHalfwayBeep = false; // Para sonidos especiales
  bool _hasPlayedTenSecondsBeep = false; // Para anuncio de 10 segundos
  bool _hasPlayedFiveSecondsBeep = false; // Para anuncio de 5 segundos
  bool _hasPlayedTimeUpBeep = false; // Para anuncio de "Tiempo"

  // Player de audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Text-to-Speech
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    // Forzar orientación vertical (portrait)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _setupTts(); // Configurar Text-to-Speech
    _setupTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reconfigurar TTS cuando cambie el idioma
    _setupTts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
    // Asegurar que se desactive wakelock al salir
    WakelockPlus.disable();
    // Restaurar orientaciones normales al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // Funciones para feedback de audio usando archivos de sonido
  Future<void> _playBeep() async {
    try {
      // Configurar el player para Android
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setVolume(1.0); // Volumen máximo
      await _audioPlayer.play(AssetSource('sounds/beep.wav'));
      HapticFeedback.heavyImpact(); // Vibración más fuerte
      print("✅ Beep reproducido exitosamente - VOLUMEN MÁXIMO");
    } catch (e) {
      print("❌ Error reproduciendo beep: $e");
      // Fallback múltiple MÁS FUERTE
      try {
        SystemSound.play(SystemSoundType.alert); // Sonido más fuerte
        HapticFeedback.heavyImpact();
        print("🔊 FALLBACK: SystemSound.alert usado");
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.heavyImpact();
      }
    }
  }

  Future<void> _playCompletionSound() async {
    try {
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setVolume(1.0); // 🔊 VOLUMEN MÁXIMO PARA EXTERIORES
      await _audioPlayer.play(AssetSource('sounds/completion.wav'));
      HapticFeedback.heavyImpact();
      print("✅ Completion sound reproducido exitosamente - VOLUMEN MÁXIMO");
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
      await _audioPlayer.setVolume(1.0); // 🔊 VOLUMEN MÁXIMO PARA EXTERIORES
      await _audioPlayer.play(AssetSource('sounds/halfway_special.wav'));
      HapticFeedback.lightImpact();
      print(
        "✅ Halfway beep especial reproducido exitosamente - VOLUMEN MÁXIMO",
      );
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
      await _audioPlayer.setVolume(1.0); // 🔊 VOLUMEN MÁXIMO PARA EXTERIORES
      await _audioPlayer.play(AssetSource('sounds/halfway.wav'));
      HapticFeedback.lightImpact();

      // Esperar un momento y segundo beep
      await Future.delayed(const Duration(milliseconds: 300));
      await _audioPlayer.setVolume(
        1.0,
      ); // 🔊 VOLUMEN MÁXIMO PARA EL SEGUNDO BEEP
      await _audioPlayer.play(AssetSource('sounds/halfway.wav'));
      HapticFeedback.lightImpact();

      print("✅ Halfway double beep reproducido exitosamente - VOLUMEN MÁXIMO");
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
      await _audioPlayer.setVolume(1.0); // 🔊 VOLUMEN MÁXIMO PARA EXTERIORES
      await _audioPlayer.play(AssetSource('sounds/beep.wav'));
      HapticFeedback.selectionClick(); // Vibración más suave para preparación
      print("✅ Preparation beep reproducido exitosamente - VOLUMEN MÁXIMO");
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

  Future<void> _playMinuteCompleteSound() async {
    try {
      // Sonido especial para indicar que terminó un minuto
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setVolume(1.0); // 🔊 VOLUMEN MÁXIMO PARA EXTERIORES
      await _audioPlayer.play(
        AssetSource('sounds/halfway.wav'),
      ); // Usamos el sonido de halfway que es más distintivo
      HapticFeedback.mediumImpact(); // Vibración más fuerte para marcar el final del minuto
      print(
        "✅ Minute complete sound reproducido exitosamente - VOLUMEN MÁXIMO",
      );
    } catch (e) {
      print("❌ Error reproduciendo minute complete sound: $e");
      // Fallback con doble beep para distinguir
      try {
        SystemSound.play(SystemSoundType.click);
        await Future.delayed(const Duration(milliseconds: 200));
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.mediumImpact();
      } catch (e2) {
        print("❌ Error con SystemSound: $e2");
        HapticFeedback.mediumImpact();
      }
    }
  }

  // Configurar Text-to-Speech
  Future<void> _setupTts() async {
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Configurar idioma y velocidad según el LanguageProvider
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      await _flutterTts.setLanguage(languageProvider.getTTSLocale());

      if (languageProvider.currentLanguage == 'es') {
        await _flutterTts.setSpeechRate(
          0.5,
        ); // Más lento para español, suena más natural
      } else {
        await _flutterTts.setSpeechRate(0.6); // Velocidad normal para inglés
      }

      print(
        "✅ TTS configurado exitosamente para idioma: ${languageProvider.currentLanguage}",
      );
    } catch (e) {
      print("❌ Error configurando TTS: $e");
    }
  }

  // Función para hablar la mitad del tiempo
  Future<void> _speakHalfway() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      String message = languageProvider.getText('halfway_point');

      await _flutterTts.speak(message);
      print("🎤 TTS: $message");
    } catch (e) {
      print("❌ Error con TTS halfway: $e");
    }
  }

  // Función para hablar cuando se completa el entrenamiento
  Future<void> _speakWorkoutComplete() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      String message = languageProvider.getText('workout_complete');

      await _flutterTts.speak(message);
      print("🎤 TTS: $message");
    } catch (e) {
      print("❌ Error con TTS completion: $e");
    }
  }

  // Función para hablar cuando quedan 10 segundos
  Future<void> _speakTenSecondsLeft() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      String message = languageProvider.getText('ten_seconds_left');

      await _flutterTts.speak(message);
      print("🎤 TTS: $message");
    } catch (e) {
      print("❌ Error con TTS ten seconds: $e");
    }
  }

  // Función para hablar cuando quedan 5 segundos
  Future<void> _speakFiveSecondsLeft() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      String message = languageProvider.getText('five_seconds_left');

      await _flutterTts.speak(message);
      print("🎤 TTS: $message");
    } catch (e) {
      print("❌ Error con TTS five seconds: $e");
    }
  }

  // Función para hablar cuando se acaba el tiempo
  Future<void> _speakTimeUp() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      String message = languageProvider.getText('time_up');

      await _flutterTts.speak(message);
      print("🎤 TTS: $message");
    } catch (e) {
      print("❌ Error con TTS time up: $e");
    }
  }

  // Función para hablar cuando comienza el entrenamiento
  Future<void> _speakWorkoutStart() async {
    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      String message = languageProvider.getText('workout_start');

      await _flutterTts.speak(message);
      print("🎤 TTS: $message");
    } catch (e) {
      print("❌ Error con TTS workout start: $e");
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

    // Cargar tiempo de preparación configurable
    _preparationTime = prefs.getInt('preparation_time') ?? 10;

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
      case 'RUNNING':
        // Configuración para Running
        _targetDistance = prefs.getInt('running_distance') ?? 400;
        _restSeconds = prefs.getInt('running_rest') ?? 60;
        _totalRounds = prefs.getInt('running_rounds') ?? 5;
        _isRunningDistance = true;
        _isPreparation = false;
        _currentSeconds = 0; // Cronómetro empieza en 0
        _roundTimes = []; // Resetear tiempos de rondas
        _roundStartTime = 0; // Resetear tiempo de inicio de ronda
        break;
    }
    setState(() {}); // Actualizar la UI con los nuevos valores
  }

  // Método para recargar configuraciones (útil cuando se cambian desde configuración)
  void reloadConfiguration() {
    _setupTimer();
    _setupTts();
  }

  void _startTimer() {
    if (_isPaused) {
      _isPaused = false;
    }

    setState(() {
      _isRunning = true;
      _lastBeepSecond = -1; // Resetear control de beeps
      _hasPlayedHalfwayBeep = false; // Resetear sonidos especiales
      _hasPlayedTenSecondsBeep = false; // Resetear anuncio de 10 segundos
      _hasPlayedFiveSecondsBeep = false; // Resetear anuncio de 5 segundos
      _hasPlayedTimeUpBeep = false; // Resetear anuncio de "Tiempo"

      // Para RUNNING, registrar el tiempo de inicio de la ronda
      if (widget.timerType == 'RUNNING' && _isRunningDistance) {
        _roundStartTime = _currentSeconds;
      }
    });

    // Mantener la pantalla activa durante el entrenamiento
    WakelockPlus.enable();

    // Si no hay preparación (como COUNTDOWN), anunciar el inicio inmediatamente
    if (!_isPreparation) {
      _speakWorkoutStart();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Lógica especial para RUNNING: cronómetro ascendente cuando está corriendo
        if (widget.timerType == 'RUNNING' && _isRunningDistance) {
          _currentSeconds++; // Cronómetro ascendente
        } else if (_currentSeconds > 0) {
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

            // Anuncio de voz cuando faltan 10 segundos (solo una vez)
            if (_currentSeconds == 10 && !_hasPlayedTenSecondsBeep) {
              _hasPlayedTenSecondsBeep = true;
              _speakTenSecondsLeft(); // Anuncio de voz para 10 segundos restantes
            }

            // Anuncio de voz cuando faltan 5 segundos (solo una vez)
            if (_currentSeconds == 5 && !_hasPlayedFiveSecondsBeep) {
              _hasPlayedFiveSecondsBeep = true;
              _speakFiveSecondsLeft(); // Anuncio de voz para 5 segundos restantes
            }

            // Sonido en cada segundo durante los últimos 10 segundos (solo una vez por segundo)
            if (_currentSeconds <= 10 &&
                _currentSeconds > 0 &&
                _currentSeconds != _lastBeepSecond) {
              _lastBeepSecond = _currentSeconds;
              _playBeep();
              print("🔊 Beep countdown: ${_currentSeconds} segundos restantes");
            }

            // Sonido especial doble en el segundo 30 (mitad del minuto) - independiente
            if (_currentSeconds == 30 && !_hasPlayedHalfwayBeep) {
              _hasPlayedHalfwayBeep = true;
              _playHalfwayDoubleBeep();
              _speakHalfway(); // Anuncio de voz para mitad del minuto
            }

            // Sonido a la mitad del tiempo total (solo si el tiempo total es mayor a 1 minuto y no es 30)
            if (_totalSeconds > 60 &&
                _currentSeconds == (_totalSeconds ~/ 2) &&
                _currentSeconds != 30 &&
                !_hasPlayedHalfwayBeep) {
              _hasPlayedHalfwayBeep = true;
              _playHalfwayBeep();
              _speakHalfway(); // Anuncio de voz para mitad del tiempo total
            }
          }
        } else {
          if (!_isPreparation) {
            // Anuncio de "Tiempo" cuando llega a 0 (solo una vez)
            if (!_hasPlayedTimeUpBeep) {
              _hasPlayedTimeUpBeep = true;
              _speakTimeUp(); // Anuncio de voz para "Tiempo"
            }
            _handleTimerComplete();
          }
        }
      });
    });
  }

  void _finishPreparation() async {
    setState(() {
      _isPreparation = false;
      _lastBeepSecond = -1; // Resetear control de beeps para el entrenamiento
      _hasPlayedHalfwayBeep = false; // Resetear sonidos especiales
      _hasPlayedTenSecondsBeep = false; // Resetear anuncio de 10 segundos
      _hasPlayedFiveSecondsBeep = false; // Resetear anuncio de 5 segundos
      _hasPlayedTimeUpBeep = false; // Resetear anuncio de "Tiempo"

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

    // Anuncio de voz: "¡Comienza!" / "Start!"
    _speakWorkoutStart();

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
      _lastBeepSecond = -1; // Resetear control de beeps
      _hasPlayedHalfwayBeep = false; // Resetear sonidos especiales
      _hasPlayedTenSecondsBeep = false; // Resetear anuncio de 10 segundos
      _hasPlayedFiveSecondsBeep = false; // Resetear anuncio de 5 segundos
      _hasPlayedTimeUpBeep = false; // Resetear anuncio de "Tiempo"
      _setupTimer();
    });

    // Permitir que la pantalla se bloquee al resetear
    WakelockPlus.disable();
  }

  // Método específico para cuando el usuario completa la distancia en RUNNING
  void _completeRunningDistance() {
    setState(() {
      // Registrar el tiempo de esta ronda
      int roundTime = _currentSeconds - _roundStartTime;
      _roundTimes.add(roundTime);
    });

    // Sonido y vibración para marcar la finalización
    HapticFeedback.mediumImpact();

    // Verificar si es la última ronda
    if (_currentRound >= _totalRounds) {
      // Es la última ronda, terminar directamente
      _timer?.cancel();
      _playCompletionSound();
      _speakWorkoutComplete(); // Anuncio de voz cuando se completa
      _showRunningCompletionDialog(); // Mostrar resumen especial para RUNNING
      print("🏁 ¡Entrenamiento completado! Mostrando resumen final");
    } else {
      // No es la última ronda, pasar al descanso
      setState(() {
        _isRunningDistance = false; // Cambiar a modo descanso
        _currentSeconds = _restSeconds; // Configurar tiempo de descanso
      });
      _playCompletionSound();
      print(
        "🏃‍♂️ Distancia completada en ${_roundTimes.last} segundos! Iniciando descanso de $_restSeconds segundos",
      );
    }
  }

  void _handleTimerComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.timerType) {
      case 'AMRAP':
        _timer?.cancel();
        _playCompletionSound();
        _speakWorkoutComplete(); // Anuncio de voz cuando se completa
        _showCompletionDialog();
        break;
      case 'EMOM':
        _playMinuteCompleteSound(); // Sonido especial cuando termina cada minuto en EMOM
        if (_currentRound < _totalRounds) {
          _currentRound++;
          int minutes = prefs.getInt('emom_minutes') ?? 1;
          int seconds = prefs.getInt('emom_seconds') ?? 0;
          _currentSeconds = (minutes * 60) + seconds;
        } else {
          _timer?.cancel();
          _playCompletionSound();
          _speakWorkoutComplete(); // Anuncio de voz cuando se completa
          _showCompletionDialog();
        }
        break;
      case 'TABATA':
        if (_isWorkPeriod) {
          // Cambiar a período de descanso
          _isWorkPeriod = false;
          _currentSeconds = prefs.getInt('tabata_rest') ?? 10;
          _playMinuteCompleteSound(); // Sonido especial al terminar trabajo
        } else {
          // Terminar descanso, siguiente ronda o completar
          _isWorkPeriod = true;
          if (_currentRound < _totalRounds) {
            _currentRound++;
            _currentSeconds = prefs.getInt('tabata_work') ?? 20;
            _playMinuteCompleteSound(); // Sonido especial al terminar descanso
          } else {
            _timer?.cancel();
            _playCompletionSound();
            _speakWorkoutComplete(); // Anuncio de voz cuando se completa
            _showCompletionDialog();
          }
        }
        break;
      case 'RUNNING':
        // Solo se llama cuando termina el tiempo de descanso
        if (!_isRunningDistance) {
          // Volver al modo "corriendo" para la siguiente ronda
          if (_currentRound < _totalRounds) {
            setState(() {
              _isRunningDistance = true; // Volver a modo corriendo
              _currentRound++; // Siguiente ronda
              _currentSeconds = 0; // Resetear cronómetro
              _roundStartTime = 0; // Resetear tiempo de inicio para nueva ronda
            });
            _playMinuteCompleteSound(); // Sonido especial al terminar descanso
            print("✅ Descanso terminado! Ronda $_currentRound - ¡A correr!");
          } else {
            // Completar el entrenamiento
            _timer?.cancel();
            _playCompletionSound();
            _speakWorkoutComplete(); // Anuncio de voz cuando se completa
            _showRunningCompletionDialog(); // Mostrar resumen especial para RUNNING
          }
        }
        break;
      case 'COUNTDOWN':
        _timer?.cancel();
        _playCompletionSound();
        _speakWorkoutComplete(); // Anuncio de voz cuando se completa
        _showCompletionDialog();
        break;
    }
  }

  void _showRunningCompletionDialog() {
    setState(() {
      _isRunning = false;
      _showConfetti = true;
      _showRunningSummary = true; // Mostrar resumen en lugar del timer
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
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                languageProvider.getText('workout_completed'),
                style: const TextStyle(
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
                languageProvider.getText('excellent_work'),
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
            // Botón Compartir
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _shareWorkout();
                },
                icon: const Icon(Icons.share),
                label: Text(languageProvider.getText('share')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Botón Repetir
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetTimer();
                },
                icon: const Icon(Icons.refresh),
                label: Text(languageProvider.getText('repeat')),
                style: TextButton.styleFrom(foregroundColor: Colors.amber), // Usar ámbar como en las cards
              ),
            ),
            const SizedBox(height: 8),
            // Botón Menú Principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Volver a la pantalla principal
                },
                icon: const Icon(Icons.home),
                label: Text(languageProvider.getText('main_menu')),
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
      case 'RUNNING':
        // Para RUNNING, sumar todos los tiempos de las rondas más el tiempo de descanso
        totalDuration = _roundTimes.fold(0, (sum, time) => sum + time);
        // Agregar tiempo de descanso (total de descansos es rounds - 1)
        if (_roundTimes.length > 1) {
          totalDuration += (_roundTimes.length - 1) * _restSeconds;
        }
        break;
    }

    // Crear registro del entrenamiento
    int actualRounds = widget.timerType == 'RUNNING'
        ? _roundTimes.length
        : _totalRounds;
    String workoutRecord =
        '${widget.timerType}|$totalDuration|$actualRounds|${DateTime.now().toIso8601String()}';
    history.add(workoutRecord);

    // Mantener solo los últimos 50 entrenamientos
    if (history.length > 50) {
      history = history.sublist(history.length - 50);
    }

    await prefs.setStringList('workout_history', history);
  }

  String _getCompletionMessage() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    switch (widget.timerType) {
      case 'AMRAP':
        return languageProvider.getText('amrap_completed');
      case 'EMOM':
        return languageProvider
            .getText('emom_completed')
            .replaceAll('{rounds}', '$_totalRounds');
      case 'TABATA':
        return languageProvider
            .getText('tabata_completed')
            .replaceAll('{rounds}', '$_totalRounds');
      case 'COUNTDOWN':
        return languageProvider.getText('time_completed');
      default:
        return languageProvider.getText('excellent_work');
    }
  }

  Color _getTimerColor() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Paleta unificada: usar solo el color primario y grises
    switch (widget.timerType) {
      case 'TABATA':
        // Para Tabata, usar tonos del color primario en lugar de rojo/azul
        return _isWorkPeriod
            ? themeProvider.primaryColor
            : themeProvider.primaryColor.withOpacity(0.6);
      case 'RUNNING':
        // Para Running, usar el color primario
        return themeProvider.primaryColor;
      default:
        return themeProvider.primaryColor;
    }
  }

  // 🎨 Nuevo método para colores de fondo según el estado del timer
  Color _getBackgroundColor() {
    // Si el timer ha terminado (tiempo 0 y no está corriendo)
    if (_currentSeconds == 0 && !_isRunning) {
      return Colors.orange.withOpacity(0.8); // � Naranja intenso como las cards del menú
    }

    // Si no está corriendo o está pausado, usar fondo neutro
    if (!_isRunning || _isPaused) {
      return Theme.of(context).scaffoldBackgroundColor;
    }

    // Durante la preparación - ámbar para coincidir con las cards del menú
    if (_isPreparation) {
      return Colors.blue.withOpacity(0.7); // � Ámbar como las cards del menú
    }

    // Estados específicos por tipo de timer con colores intuitivos
    switch (widget.timerType) {
      case 'TABATA':
        return _isWorkPeriod
            ? Colors.green.withOpacity(0.7) // 🟢 Verde de la card COUNTDOWN para trabajar
            : Colors.blue.withOpacity(
                0.7,
              ); // � Azul de la card EMOM para descanso

      case 'RUNNING':
        return _isRunningDistance
            ? Colors.green.withOpacity(0.7) // 🟢 Verde de la card COUNTDOWN para correr
            : Colors.blue.withOpacity(
                0.7,
              ); // � Azul de la card EMOM para descanso

      case 'AMRAP':
      case 'EMOM':
      case 'COUNTDOWN':
      default:
        return Colors.green.withOpacity(0.7); // 🟢 Verde como las cards del menú
    }
  }

  // 🏷️ Widget para mostrar el estado actual con color distintivo
  Widget _buildStatusIndicator() {
    final languageProvider = Provider.of<LanguageProvider>(context);

    String statusText;
    Color statusColor;
    IconData statusIcon;

    // Determinar texto, color e icono según el estado con colores del menú
    if (_currentSeconds == 0 && !_isRunning) {
      statusText = languageProvider.getText('completed');
      statusColor = Colors.orange; // � Naranja intenso como las cards del menú
      statusIcon = Icons.check_circle;
    } else if (!_isRunning || _isPaused) {
      statusText = _isPaused
          ? languageProvider.getText('paused')
          : languageProvider.getText('ready');
      statusColor = Colors.grey;
      statusIcon = _isPaused ? Icons.pause_circle : Icons.play_circle;
    } else if (_isPreparation) {
      statusText = languageProvider.getText('prepare');
      statusColor = Colors.blue; // � Ámbar como las cards del menú
      statusIcon = Icons.fitness_center;
    } else {
      switch (widget.timerType) {
        case 'TABATA':
          statusText = _isWorkPeriod ? 'ENTRENAMIENTO' : 'RECUPERACIÓN';
          statusColor = _isWorkPeriod
              ? Colors
                    .green // 🟢 Verde de la card COUNTDOWN para trabajar
              : Colors.blue; // � Azul de la card EMOM para descanso
          statusIcon = _isWorkPeriod ? Icons.flash_on : Icons.pause;
          break;
        case 'RUNNING':
          statusText = _isRunningDistance ? 'EJERCICIO' : 'RECUPERACIÓN';
          statusColor = _isRunningDistance
              ? Colors
                    .green // 🟢 Verde de la card COUNTDOWN para correr
              : Colors.blue; // � Azul de la card EMOM para descanso
          statusIcon = _isRunningDistance ? Icons.directions_run : Icons.pause;
          break;
        default:
          statusText = 'EJERCICIO';
          statusColor = Colors.green; // 🟢 Verde para ejercicio
          statusIcon = Icons.fitness_center;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98), // Fondo más opaco para mejor legibilidad
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 2), // Borde más visible
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Sombra más fuerte
            blurRadius: 12,
            spreadRadius: 3,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15), // Fondo más visible
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700, // Texto más bold
              color: Colors.grey[800], // Color más oscuro para mejor contraste
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }

  IconData _getTimerIcon() {
    switch (widget.timerType) {
      case 'AMRAP':
        return Icons
            .all_inclusive; // Símbolo infinito para "As Many Rounds As Possible"
      case 'EMOM':
        return Icons.access_time; // Reloj para "Every Minute On the Minute"
      case 'TABATA':
        return Icons.flash_on; // Rayo para alta intensidad
      case 'COUNTDOWN':
        return Icons.timer; // Timer clásico
      default:
        return Icons.fitness_center; // Pesas por defecto
    }
  }

  String _getTimerSubtitle() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    switch (widget.timerType) {
      case 'AMRAP':
        return languageProvider.getText('amrap_description');
      case 'EMOM':
        return languageProvider.getText('emom_description');
      case 'TABATA':
        return languageProvider.getText('tabata_description');
      case 'COUNTDOWN':
        return languageProvider.getText('countdown_description');
      case 'RUNNING':
        // Mostrar información sin progreso de rondas en el título
        if (_isRunningDistance) {
          return languageProvider
              .getText('run_distance')
              .replaceAll('{distance}', _targetDistance.toString());
        } else {
          return languageProvider.getText('running_rest');
        }
      default:
        return languageProvider.getText('workout_timer');
    }
  }

  void _shareRunningWorkout() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    // Calcular estadísticas
    double averageTime = _roundTimes.isNotEmpty
        ? _roundTimes.reduce((a, b) => a + b) / _roundTimes.length
        : 0;
    int bestTime = _roundTimes.isNotEmpty
        ? _roundTimes.reduce((a, b) => a < b ? a : b)
        : 0;

    DateTime now = DateTime.now();
    String date = '${now.day}/${now.month}/${now.year}';

    String roundDetails = '';
    for (int i = 0; i < _roundTimes.length; i++) {
      roundDetails +=
          '${languageProvider.getText('round')} ${i + 1}: ${_roundTimes[i]}s\n';
    }

    String shareText =
        '''
🏃‍♂️ ${languageProvider.getText('just_completed')}

🎯 ${_targetDistance}m x ${_roundTimes.length} ${languageProvider.getText('rounds').toLowerCase()}
📊 ${languageProvider.getText('average')}: ${averageTime.toStringAsFixed(1)}s
🥇 ${languageProvider.getText('best')}: ${bestTime}s
📅 $date

${languageProvider.getText('round_details')}:
$roundDetails
${languageProvider.getText('keep_training')}

#Running #CrossFit #Fitness #Training #Motivation
''';

    try {
      await Share.share(
        shareText,
        subject: languageProvider.getText('workout_completed_subject'),
      );
    } catch (e) {
      // Si falla, mostrar un mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.getText('share_error')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _shareWorkout() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String workoutDetails = _getWorkoutSummary();
    String shareText =
        '''
${languageProvider.getText('just_completed')}

$workoutDetails

${languageProvider.getText('keep_training')}

#WorkoutTimer #Fitness #Training #Motivation
''';

    try {
      await Share.share(
        shareText,
        subject: languageProvider.getText('workout_completed_subject'),
      );
    } catch (e) {
      // Si falla, mostrar un mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.getText('share_error')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getWorkoutSummary() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    DateTime now = DateTime.now();
    String date = '${now.day}/${now.month}/${now.year}';
    String time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    switch (widget.timerType) {
      case 'AMRAP':
        return '''
📊 ${languageProvider.getText('type')}: ${languageProvider.getText('amrap_description')}
⏱️ ${languageProvider.getText('duration')}: ${_formatTime(_totalSeconds)}
📅 ${languageProvider.getText('date')}: $date ${languageProvider.getText('at')} $time
✅ ${languageProvider.getText('status')}: ${languageProvider.getText('completed')}''';
      case 'EMOM':
        return '''
📊 ${languageProvider.getText('type')}: ${languageProvider.getText('emom_description')}
⏱️ ${languageProvider.getText('duration_per_round')}: ${_formatTime(_totalSeconds)}
🔄 ${languageProvider.getText('rounds_completed')}: $_totalRounds
📅 ${languageProvider.getText('date')}: $date ${languageProvider.getText('at')} $time
✅ ${languageProvider.getText('status')}: ${languageProvider.getText('completed')}''';
      case 'TABATA':
        return '''
📊 ${languageProvider.getText('type')}: TABATA
${languageProvider.getText('work_20s')} | ${languageProvider.getText('rest_10s')}  
🔄 ${languageProvider.getText('rounds_completed')}: $_totalRounds
📅 ${languageProvider.getText('date')}: $date ${languageProvider.getText('at')} $time
✅ ${languageProvider.getText('status')}: ${languageProvider.getText('completed')}''';
      case 'COUNTDOWN':
        return '''
📊 ${languageProvider.getText('type')}: COUNTDOWN
⏱️ ${languageProvider.getText('total_time')}: ${_formatTime(_totalSeconds)}
📅 ${languageProvider.getText('date')}: $date ${languageProvider.getText('at')} $time
✅ ${languageProvider.getText('status')}: ${languageProvider.getText('completed')}''';
      default:
        return '''
📊 ${languageProvider.getText('workout_timer')}
📅 ${languageProvider.getText('date')}: $date ${languageProvider.getText('at')} $time
✅ ${languageProvider.getText('status')}: ${languageProvider.getText('completed')}''';
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6), // Fondo más opaco para mejor legibilidad
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getTimerIcon(), size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.timerType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getTimerSubtitle(),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (widget.timerType == 'TABATA'
                        ? _getTimerColor()
                        : themeProvider.primaryColor)
                    .withOpacity(0.8),
                (widget.timerType == 'TABATA'
                    ? _getTimerColor()
                    : themeProvider.primaryColor),
              ],
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
                ? languageProvider.getText('exit_fullscreen')
                : languageProvider.getText('fullscreen'),
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
                // 🚨 Indicador de estado prominente - COMENTADO por solicitud del usuario
                // _buildStatusIndicator(),

                // Indicador de preparación - responsivo y flexible
                if (_isPreparation)
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1), // Color neutro
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sports_gymnastics,
                              color: Colors.grey[600], // Color neutro
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${languageProvider.getText('prepare_for')} ${_getTimerSubtitle().toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700], // Color neutro
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
                                    Colors.green.withOpacity(0.8), // Verde para trabajo como las cards
                                    Colors.orange.withOpacity(0.6),
                                  ]
                                : [
                                    Colors.amber.withOpacity(0.8), // Ámbar para descanso como las cards
                                    Colors.orange.withOpacity(0.6),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: (_isWorkPeriod ? Colors.green : Colors.amber) // Colores del menú
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Texto principal con localización
                            Text(
                              _isWorkPeriod
                                  ? languageProvider.getText('work')
                                  : languageProvider.getText('rest'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
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

                // Información específica para RUNNING - Diseño simplificado
                if (widget.timerType == 'RUNNING' && !_isPreparation)
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _getTimerColor().withOpacity(
                            0.1,
                          ), // Color del tema suave
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: _getTimerColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isRunningDistance
                                  ? Icons.directions_run
                                  : Icons.self_improvement,
                              color: _getTimerColor(), // Color del tema
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            // Texto principal con información específica de Running
                            Text(
                              _isRunningDistance
                                  ? languageProvider
                                        .getText('run_distance')
                                        .replaceAll(
                                          '{distance}',
                                          _targetDistance.toString(),
                                        )
                                  : languageProvider.getText('running_rest'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getTimerColor(), // Color del tema
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
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

                // Mostrar progreso de rondas completadas durante el descanso de RUNNING
                if (widget.timerType == 'RUNNING' &&
                    !_isRunningDistance &&
                    _roundTimes.isNotEmpty &&
                    !_isPreparation)
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getTimerColor().withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _getTimerColor().withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${languageProvider.getText('rounds_completed').toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getTimerColor().withOpacity(0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < _roundTimes.length; i++) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTimerColor().withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${i + 1}: ${_roundTimes[i]}s',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getTimerColor(),
                                  ),
                                ),
                              ),
                              if (i < _roundTimes.length - 1)
                                const SizedBox(width: 6),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),

                if (widget.timerType != 'COUNTDOWN' &&
                    widget.timerType != 'AMRAP' &&
                    widget.timerType != 'RUNNING' &&
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
                          languageProvider
                              .getText('round_of')
                              .replaceAll('{current}', '$_currentRound')
                              .replaceAll('{total}', '$_totalRounds'),
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

                // Timer principal animado O Resumen final de RUNNING
                Center(
                      child:
                          _showRunningSummary && widget.timerType == 'RUNNING'
                          ? _buildRunningSummaryWidget(languageProvider)
                          : AnimatedCircularTimer(
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

                // Botón específico para RUNNING - Versión limpia sin info de ronda
                if (widget.timerType == 'RUNNING' &&
                    _isRunningDistance &&
                    _isRunning &&
                    !_showRunningSummary)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeRunningDistance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _getTimerColor(), // Usar color del tema
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black26,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'COMPLETÉ ${_targetDistance}M',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  languageProvider.currentLanguage == 'es'
                                      ? 'Iniciar descanso'
                                      : 'Start rest period',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Controles del timer con animaciones
                if (!_showRunningSummary)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón Reset
                      _buildControlButton(
                            onPressed: _resetTimer,
                            backgroundColor: Colors.grey[600]!,
                            icon: Icons.refresh,
                            label: languageProvider.getText('reset'),
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
                            label: _isRunning
                                ? languageProvider.getText('pause')
                                : languageProvider.getText('start'),
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
                            backgroundColor: Colors.orange[600]!, // Usar naranja de AMRAP como las cards
                            icon: Icons.stop,
                            label: languageProvider.getText('exit'),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 800.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
              ],
            ),
          ),

          // Efecto de confetti - más intenso para celebraciones de finalización
          if (_showConfetti)
            ConfettiEffect(
              isPlaying: _showConfetti,
              duration: 5, // 5 segundos de confetti intenso para celebraciones
              isIntense:
                  true, // Activar efectos intensos para finalización de entrenamientos
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

  // Widget para mostrar el resumen final de Running
  Widget _buildRunningSummaryWidget(LanguageProvider languageProvider) {
    // Calcular estadísticas
    double averageTime = _roundTimes.isNotEmpty
        ? _roundTimes.reduce((a, b) => a + b) / _roundTimes.length
        : 0;
    int bestTime = _roundTimes.isNotEmpty
        ? _roundTimes.reduce((a, b) => a < b ? a : b)
        : 0;
    int worstTime = _roundTimes.isNotEmpty
        ? _roundTimes.reduce((a, b) => a > b ? a : b)
        : 0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 600),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título con icono
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.directions_run,
                  color: Colors.purple,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  languageProvider.getText('workout_completed'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_targetDistance}m × ${_roundTimes.length} ${languageProvider.getText('rounds').toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Estadísticas principales
          Row(
            children: [
              _buildStatCard(
                _formatTimeDouble(averageTime),
                languageProvider.getText('average').toUpperCase(),
                Colors.purple,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                _formatTime(bestTime),
                languageProvider.getText('best').toUpperCase(),
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                _formatTime(worstTime),
                languageProvider.getText('worst').toUpperCase(),
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Gráfica de rendimiento
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 ${languageProvider.getText('performance_chart')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (worstTime + (worstTime * 0.1)).toDouble(),
                      minY: 0,
                      groupsSpace: 8,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) =>
                              Colors.purple.withOpacity(0.8),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              'Vuelta ${group.x + 1}\n${rod.toY.round()}s',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt() + 1}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 20,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: (worstTime / 3).ceilToDouble().clamp(
                              1.0,
                              double.infinity,
                            ),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.round()}s',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 9,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: (worstTime / 3)
                            .ceilToDouble()
                            .clamp(1.0, double.infinity),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                        drawVerticalLine: false,
                      ),
                      barGroups: [
                        for (int i = 0; i < _roundTimes.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: _roundTimes[i].toDouble(),
                                color: _roundTimes[i] == bestTime
                                    ? Colors.green
                                    : _roundTimes[i] == worstTime
                                    ? Colors.orange
                                    : Colors.purple,
                                width: (_roundTimes.length <= 5) ? 20 : 15,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    (_roundTimes[i] == bestTime
                                            ? Colors.green
                                            : _roundTimes[i] == worstTime
                                            ? Colors.orange
                                            : Colors.purple)
                                        .withOpacity(0.3),
                                    _roundTimes[i] == bestTime
                                        ? Colors.green
                                        : _roundTimes[i] == worstTime
                                        ? Colors.orange
                                        : Colors.purple,
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareRunningWorkout,
                  icon: const Icon(Icons.share),
                  label: Text(languageProvider.getText('share')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRunningSummary = false;
                    });
                    _resetTimer();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(languageProvider.getText('repeat')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget helper para las estadísticas
  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeDouble(double seconds) {
    int intSeconds = seconds.round();
    return _formatTime(intSeconds);
  }
}
