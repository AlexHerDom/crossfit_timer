import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'es'; // Default español

  String get currentLanguage => _currentLanguage;

  // Mapa de idiomas disponibles
  static const Map<String, String> availableLanguages = {
    'es': 'Español',
    'en': 'English',
  };

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Intentar cargar idioma guardado, si no existe, usar idioma del sistema
    String? savedLanguage = prefs.getString('app_language');

    if (savedLanguage != null) {
      _currentLanguage = savedLanguage;
    } else {
      // Detectar idioma del sistema
      String systemLanguage = Platform.localeName.split('_')[0];

      // Si el idioma del sistema está disponible, usarlo; si no, usar español
      if (availableLanguages.containsKey(systemLanguage)) {
        _currentLanguage = systemLanguage;
      } else {
        _currentLanguage = 'es'; // Default español
      }

      // Guardar la detección automática
      await prefs.setString('app_language', _currentLanguage);
    }

    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (availableLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);

      notifyListeners();
    }
  }

  // Método para obtener el locale para flutter_tts
  String getTTSLocale() {
    switch (_currentLanguage) {
      case 'es':
        return 'es-MX'; // Español mexicano para mejor pronunciación
      case 'en':
        return 'en-US'; // Inglés americano
      default:
        return 'es-MX';
    }
  }

  // Método para obtener textos localizados
  String getText(String key) {
    final Map<String, Map<String, String>> translations = {
      'es': {
        // TTS y Audio
        'workout_start': '¡Comienza!',
        'workout_complete': '¡Entrenamiento completado! ¡Excelente trabajo!',
        'halfway_point': 'Mitad del tiempo',
        'ten_seconds_left': 'Diez segundos restantes',
        'five_seconds_left': 'Cinco segundos',
        'time_up': 'Tiempo',

        // Timer Screen Navigation
        'exit': 'Salir',
        'fullscreen': 'Pantalla completa',
        'exit_fullscreen': 'Salir de pantalla completa',

        // Timer Subtitles (improved)
        'amrap_description': 'Máximas rondas posibles',
        'emom_description': 'Cada minuto en punto',
        'tabata_description': 'Alta intensidad',
        'countdown_description': 'Cuenta regresiva',

        // Timer States
        'prepare_for': 'Prepárate para',
        'round_of': 'Ronda {current} de {total}',

        // Completion Dialog
        'workout_completed': '¡Entrenamiento Completado!',
        'excellent_work': '¡Excelente trabajo!',
        'share': 'Compartir',
        'repeat': 'Repetir',
        'main_menu': 'Menú Principal',

        // Completion Messages
        'amrap_completed': '¡Has completado tu entrenamiento AMRAP!',
        'emom_completed': '¡Has completado {rounds} rondas EMOM!',
        'tabata_completed': '¡Has completado {rounds} rondas de Tabata!',
        'time_completed': '¡Tiempo completado!',

        // Share Messages
        'just_completed': '¡Acabo de completar mi entrenamiento!',
        'keep_training': '¡Sigue entrenando y alcanza tus metas!',
        'workout_completed_subject': '¡Entrenamiento completado!',
        'share_error': '❌ Error al compartir el entrenamiento',

        // Share Summary
        'type': 'Tipo',
        'duration': 'Duración',
        'duration_per_round': 'Duración por ronda',
        'rounds_completed': 'Rondas completadas',
        'total_time': 'Tiempo total',
        'date': 'Fecha',
        'at': 'a las',
        'status': 'Estado',
        'completed': '¡Completado!',
        'work_20s': '⚡ 20s trabajo',
        'rest_10s': '😮‍💨 10s descanso',

        'round': 'Ronda',
        'work': 'Trabajo',
        'rest': 'Descanso',
        'get_ready': 'Prepárate',
        'start': 'Inicio',
        'pause': 'Pausa',
        'resume': 'Continuar',
        'stop': 'Detener',
        'reset': 'Reiniciar',
        'preparation': 'Preparación',
        'minute_complete': 'Minuto completado',

        // Home Screen
        'workout_timer': 'Workout Timer',
        'time_train': 'Es hora de entrenar',
        'amrap_title': 'AMRAP',
        'amrap_subtitle': 'Máximas rondas posibles',
        'emom_title': 'EMOM',
        'emom_subtitle': 'Cada minuto en punto',
        'tabata_title': 'TABATA',
        'tabata_subtitle': '20s trabajo / 10s descanso',
        'countdown_title': 'COUNTDOWN',
        'countdown_subtitle': 'Temporizador simple',
        'running_title': 'RUNNING',
        'running_subtitle': 'Intervalos de carrera',

        // Running specific texts
        'run_distance': 'CORRE {distance}M',
        'running_rest': 'DESCANSO',
        'completed_distance': 'TERMINÉ LA DISTANCIA',
        'skip_rest': 'SALTAR DESCANSO',
        'next_interval': 'Próximo: {distance}m',

        // AppBar
        'history': 'Historial',
        'settings': 'Configuraciones',
        'about': 'Acerca de',

        // Timer Screen
        'round_number': 'Ronda',
        'rounds': 'rondas',

        // Config Screen
        'configure': 'Configurar',
        'customize_workout': 'Personaliza tu entrenamiento',
        'preparation_time': 'Tiempo de preparación',
        'minutes': 'Minutos',
        'seconds': 'Segundos',
        'minutes_per_round': 'Minutos por ronda',
        'extra_seconds': 'Segundos extra',
        'field_required': 'Este campo es requerido',
        'enter_valid_number': 'Ingresa un número válido',
        'min_suffix': 'min',
        'sec_suffix': 'seg',
        'seconds_suffix': 'segundos',
        'rounds_suffix': 'rondas',
        'meters_suffix': 'metros',
        'target_distance': 'Distancia objetivo',
        'rest_between_rounds': 'Descanso entre rondas',
        'number_of_rounds': 'Número de rondas',
        'work_time': 'Tiempo de trabajo',
        'rest_time': 'Tiempo de descanso',
        'save_configuration': 'Guardar Configuración',

        // Settings Screen
        'save_settings': 'Guardar configuraciones',
        'settings_saved': 'Configuraciones guardadas',
        'audio_section': '🔊 Audio',
        'feedback_section': '📳 Feedback',
        'screen_section': '📱 Pantalla',
        'training_section': '⏱️ Entrenamiento',
        'appearance_section': '🎨 Apariencia',
        'sounds_enabled': 'Sonidos habilitados',
        'sounds_enabled_desc': 'Reproducir beeps durante los entrenamientos',
        'beep_volume_title': 'Volumen de beeps',
        'beep_volume_desc': 'Ajusta el volumen de los sonidos',
        'vibration_enabled': 'Vibración habilitada',
        'vibration_enabled_desc': 'Vibrar durante los entrenamientos',
        'keep_screen_active': 'Mantener pantalla activa',
        'keep_screen_active_desc':
            'La pantalla no se apagará durante entrenamientos',
        'preparation_time_title': 'Tiempo de preparación',
        'preparation_time_desc': 'Segundos antes de iniciar el entrenamiento',
        'color_theme': 'Tema de color',
        'language_section': 'Idioma / Language',
        'restore_defaults_button': 'Restaurar valores por defecto',
        'restore_defaults_title': 'Restaurar valores por defecto',
        'restore_defaults_message':
            '¿Estás seguro de que quieres restaurar todas las configuraciones a sus valores por defecto?',
        'cancel': 'Cancelar',
        'restore': 'Restaurar',
        'settings_restored': 'Configuraciones restauradas',
        'app_info': 'Información de la App',
        'version': 'Versión: 1.0.0',
        'developer': 'Desarrollador: CrossFit Timer Team',
        'app_description':
            'Esta aplicación está diseñada para ayudarte con tus entrenamientos de CrossFit y fitness.',

        // About Dialog
        'timer_number_one': 'El Timer #1 para CrossFit',
        'used_by_athletes': 'Usado por +5,000 atletas profesionales',
        'everything_included': 'TODO INCLUIDO:',
        'professional_timers':
            '4 Timers Profesionales (AMRAP, EMOM, TABATA, COUNTDOWN)',
        'intelligent_voice': 'Coach de Voz Inteligente (Español/Inglés)',
        'complete_history': 'Historial y Estadísticas Completas',
        'offline_no_ads': '100% Sin Conexión - Sin Anuncios',
        'premium_themes': 'Temas Premium y Sonidos Profesionales',
        'incredible_value': 'VALOR INCREÍBLE',
        'other_apps_cost':
            'Otras apps premium: \$120/año\\nWorkout Timer PRO: \$3.99 UNA VEZ\\n\\n🎉 ¡Ahorras \$116 al año!',
        'developed_by':
            'Desarrollado con ❤️ por Alexander Herrera\\n📍 Especialista en Fitness Apps',
        'close': 'Cerrar',
        'love_it': '¡Me Encanta!',
        'thanks_message': '¡Gracias por usar Workout Timer PRO!',
        
        // Running Summary
        'average': 'Promedio',
        'best': 'Mejor',
        'worst': 'Peor',
        'round_details': 'Detalle por rondas',
        'performance_chart': 'Gráfica de Rendimiento',
        'completed_rounds_status': 'Rondas Completadas',
      },
      'en': {
        // TTS y Audio
        'workout_start': 'Start!',
        'workout_complete': 'Workout completed! Excellent work!',
        'halfway_point': 'Halfway point',
        'ten_seconds_left': 'Ten seconds remaining',
        'five_seconds_left': 'Five seconds',
        'time_up': 'Time',

        // Timer Screen Navigation
        'exit': 'Exit',
        'fullscreen': 'Fullscreen',
        'exit_fullscreen': 'Exit fullscreen',

        // Timer Subtitles (improved)
        'amrap_description': 'As many rounds as possible',
        'emom_description': 'Every minute on the minute',
        'tabata_description': 'High intensity',
        'countdown_description': 'Countdown timer',

        // Timer States
        'prepare_for': 'Get ready for',
        'round_of': 'Round {current} of {total}',

        // Completion Dialog
        'workout_completed': 'Workout Completed!',
        'excellent_work': 'Excellent work!',
        'share': 'Share',
        'repeat': 'Repeat',
        'main_menu': 'Main Menu',

        // Completion Messages
        'amrap_completed': 'You have completed your AMRAP workout!',
        'emom_completed': 'You have completed {rounds} EMOM rounds!',
        'tabata_completed': 'You have completed {rounds} Tabata rounds!',
        'time_completed': 'Time completed!',

        // Share Messages
        'just_completed': 'Just completed my workout!',
        'keep_training': 'Keep training and reach your goals!',
        'workout_completed_subject': 'Workout completed!',
        'share_error': '❌ Error sharing workout',

        // Share Summary
        'type': 'Type',
        'duration': 'Duration',
        'duration_per_round': 'Duration per round',
        'rounds_completed': 'Rounds completed',
        'total_time': 'Total time',
        'date': 'Date',
        'at': 'at',
        'status': 'Status',
        'completed': 'Completed!',
        'work_20s': '⚡ 20s work',
        'rest_10s': '😮‍💨 10s rest',

        'round': 'Round',
        'work': 'Work',
        'rest': 'Rest',
        'get_ready': 'Get ready',
        'start': 'Start',
        'pause': 'Pause',
        'resume': 'Resume',
        'stop': 'Stop',
        'reset': 'Reset',
        'preparation': 'Preparation',
        'minute_complete': 'Minute complete',

        // Home Screen
        'workout_timer': 'Workout Timer',
        'time_train': 'Time to train',
        'amrap_title': 'AMRAP',
        'amrap_subtitle': 'As Many Rounds As Possible',
        'emom_title': 'EMOM',
        'emom_subtitle': 'Every Minute On the Minute',
        'tabata_title': 'TABATA',
        'tabata_subtitle': '20s work / 10s rest',
        'countdown_title': 'COUNTDOWN',
        'countdown_subtitle': 'Simple timer',
        'running_title': 'RUNNING',
        'running_subtitle': 'Running intervals',

        // Running specific texts
        'run_distance': 'RUN {distance}M',
        'running_rest': 'REST',
        'completed_distance': 'COMPLETED DISTANCE',
        'skip_rest': 'SKIP REST',
        'next_interval': 'Next: {distance}m',

        // AppBar
        'history': 'History',
        'settings': 'Settings',
        'about': 'About',

        // Timer Screen
        'round_number': 'Round',
        'rounds': 'rounds',

        // Config Screen
        'configure': 'Configure',
        'customize_workout': 'Customize your workout',
        'preparation_time': 'Preparation time',
        'minutes': 'Minutes',
        'seconds': 'Seconds',
        'minutes_per_round': 'Minutes per round',
        'extra_seconds': 'Extra seconds',
        'number_of_rounds': 'Number of rounds',
        'work_time': 'Work time',
        'rest_time': 'Rest time',
        'save_configuration': 'Save Configuration',
        'field_required': 'This field is required',
        'enter_valid_number': 'Enter a valid number',
        'min_suffix': 'min',
        'sec_suffix': 'sec',
        'seconds_suffix': 'seconds',
        'rounds_suffix': 'rounds',
        'meters_suffix': 'meters',
        'target_distance': 'Target distance',
        'rest_between_rounds': 'Rest between rounds',

        // Settings Screen
        'save_settings': 'Save settings',
        'settings_saved': 'Settings saved',
        'audio_section': '🔊 Audio',
        'feedback_section': '📳 Feedback',
        'screen_section': '📱 Screen',
        'training_section': '⏱️ Training',
        'appearance_section': '🎨 Appearance',
        'sounds_enabled': 'Sounds enabled',
        'sounds_enabled_desc': 'Play beeps during workouts',
        'beep_volume_title': 'Beep volume',
        'beep_volume_desc': 'Adjust the volume of sounds',
        'vibration_enabled': 'Vibration enabled',
        'vibration_enabled_desc': 'Vibrate during workouts',
        'keep_screen_active': 'Keep screen active',
        'keep_screen_active_desc': 'Screen will not turn off during workouts',
        'preparation_time_title': 'Preparation time',
        'preparation_time_desc': 'Seconds before starting workout',
        'color_theme': 'Color theme',
        'restore_defaults_button': 'Restore default values',
        'restore_defaults_title': 'Restore default values',
        'restore_defaults_message':
            'Are you sure you want to restore all settings to their default values?',
        'cancel': 'Cancel',
        'restore': 'Restore',
        'settings_restored': 'Settings restored',
        'app_info': 'App Information',
        'version': 'Version: 1.0.0',
        'developer': 'Developer: CrossFit Timer Team',
        'app_description':
            'This app is designed to help you with your CrossFit and fitness workouts.',
        'sound': 'Sound',
        'vibration': 'Vibration',
        'keep_screen_on': 'Keep screen on',
        'beep_volume': 'Beep volume',
        'language': 'Language',
        'appearance': 'Appearance',
        'restore_defaults': 'Restore defaults',
        'language_changed': 'Language changed to',
        'language_applies_to':
            'Language applies to workout voice notifications',

        // About Dialog
        'timer_number_one': 'The #1 Timer for CrossFit',
        'used_by_athletes': 'Used by +5,000 professional athletes',
        'everything_included': 'EVERYTHING INCLUDED:',
        'professional_timers':
            '4 Professional Timers (AMRAP, EMOM, TABATA, COUNTDOWN)',
        'intelligent_voice': 'Intelligent Voice Coach (Spanish/English)',
        'complete_history': 'Complete History and Statistics',
        'offline_no_ads': '100% Offline - No Ads',
        'premium_themes': 'Premium Themes and Professional Sounds',
        'incredible_value': 'INCREDIBLE VALUE',
        'other_apps_cost':
            'Other premium apps: \$120/year\\nWorkout Timer PRO: \$3.99 ONCE\\n\\n🎉 Save \$116 per year!',
        'developed_by':
            'Developed with ❤️ by Alexander Herrera\\n📍 Fitness Apps Specialist',
        'close': 'Close',
        'love_it': 'Love it!',
        'thanks_message': 'Thanks for using Workout Timer PRO!',
        
        // Running Summary
        'average': 'Average',
        'best': 'Best',
        'worst': 'Worst',
        'round_details': 'Round details',
        'performance_chart': 'Performance Chart',
        'completed_rounds_status': 'Completed Rounds',
      },
    };

    return translations[_currentLanguage]?[key] ??
        translations['es']?[key] ??
        key;
  }
}
