import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔊 SERVICIO DE AUDIO CON VOLUMEN ALTO PARA CROSSFIT AL AIRE LIBRE
// ═══════════════════════════════════════════════════════════════════════════════

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Volumen configurable por el usuario (por defecto al máximo)
  double _userVolume = 1.0;

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🔧 CONFIGURACIÓN INICIAL
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    try {
      // Cargar volumen guardado del usuario
      await _loadUserVolume();

      // Configurar el player para máximo rendimiento
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setBalance(0.0); // Balance centrado

      print("🔊 AudioService inicializado - Volumen: $_userVolume");
    } catch (e) {
      print("❌ Error inicializando AudioService: $e");
    }
  }

  Future<void> _loadUserVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userVolume = prefs.getDouble('audio_volume') ?? 1.0; // Default: máximo
      print("📱 Volumen cargado desde preferencias: $_userVolume");
    } catch (e) {
      print("❌ Error cargando volumen: $e - usando máximo");
      _userVolume = 1.0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🎚️ CONTROL DE VOLUMEN
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> setVolume(double volume) async {
    try {
      _userVolume = volume.clamp(0.0, 1.0); // Asegurar rango válido

      // Guardar en preferencias
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('audio_volume', _userVolume);

      print("🔊 Volumen actualizado a: $_userVolume");
    } catch (e) {
      print("❌ Error guardando volumen: $e");
    }
  }

  double get volume => _userVolume;

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🔊 MÉTODOS DE REPRODUCCIÓN CON VOLUMEN OPTIMIZADO
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> playBeep() async {
    await _playSound('sounds/beep.wav', 'Beep');
  }

  Future<void> playCompletion() async {
    await _playSound('sounds/completion.wav', 'Completion');
  }

  Future<void> playHalfway() async {
    await _playSound('sounds/halfway.wav', 'Halfway');
  }

  Future<void> playHalfwaySpecial() async {
    await _playSound('sounds/halfway_special.wav', 'Halfway Special');
  }

  Future<void> playCountdown() async {
    await _playSound('sounds/countdown.wav', 'Countdown');
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🎵 MÉTODO PRIVADO UNIFICADO CON MÁXIMO VOLUMEN
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> _playSound(String assetPath, String soundName) async {
    try {
      // 🔊 CONFIGURACIÓN PARA MÁXIMO VOLUMEN
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setVolume(_userVolume); // Usar volumen del usuario
      await _audioPlayer.setBalance(0.0); // Balance centrado

      // 🎵 REPRODUCIR SONIDO
      await _audioPlayer.play(AssetSource(assetPath));

      // 📳 FEEDBACK HÁPTICO FUERTE
      HapticFeedback.heavyImpact();

      print("✅ $soundName reproducido exitosamente - Volumen: $_userVolume");
    } catch (e) {
      print("❌ Error reproduciendo $soundName: $e");

      // 🚨 FALLBACK CON SONIDOS DEL SISTEMA
      await _playFallbackSound();
    }
  }

  Future<void> _playFallbackSound() async {
    try {
      // Usar sonidos más fuertes del sistema
      SystemSound.play(SystemSoundType.alert); // Más fuerte que 'click'
      HapticFeedback.heavyImpact();
      print("🔊 FALLBACK: SystemSound.alert usado");
    } catch (e) {
      print("❌ Error con SystemSound: $e");
      // Al menos vibración
      HapticFeedback.heavyImpact();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🧪 MÉTODO DE PRUEBA PARA VERIFICAR VOLUMEN
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> testVolume() async {
    print("🧪 Probando volumen actual: $_userVolume");
    await playBeep();

    // Esperar un poco y reproducir otro sonido
    await Future.delayed(Duration(milliseconds: 500));
    await playCompletion();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🗑️ LIMPIEZA DE RECURSOS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      print("🗑️ AudioService disposed");
    } catch (e) {
      print("❌ Error disposing AudioService: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 📊 INFORMACIÓN DE DEBUG
  // ═══════════════════════════════════════════════════════════════════════════════

  String getDebugInfo() {
    return '''
🔊 AudioService Debug Info:
- Volumen del usuario: $_userVolume
- Player mode: lowLatency
- Balance: centrado (0.0)
- Fallback: SystemSound.alert
''';
  }
}
