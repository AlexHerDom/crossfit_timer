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
        'work': 'Acción',
        'rest': 'Pausa',
        'get_ready': 'Prepárate',
        'start': 'Inicio',
        'pause': 'Pausa',
        'resume': 'Continuar',
        'stop': 'Detener',
        'reset': 'Reiniciar',
        'preparation': 'Preparación',
        'minute_complete': 'Minuto completado',

        // Home Screen
        'workout_timer': 'CrossFit Timer Pro',
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
        'running_subtitle': 'Intervalos de running',

        // Running specific texts
        'run_distance': 'CORRE {distance}M',
        'running_rest': 'PAUSA',
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
            'Otras apps premium: \$120/año\\nWorkout Timer: \$3.99 UNA VEZ\\n\\n🎉 ¡Ahorras \$116 al año!',
        'developed_by':
            'Desarrollado con ❤️ por Alexander Herrera\\n📍 Especialista en Fitness Apps',
        'close': 'Cerrar',
        'love_it': '¡Me Encanta!',
        'thanks_message': '¡Gracias por usar Workout Timer!',

        // Running Summary
        'average': 'Promedio',
        'best': 'Mejor',
        'worst': 'Peor',
        'round_details': 'Detalle por rondas',
        'performance_chart': 'Gráfica de Rendimiento',
        'completed_rounds_status': 'Rondas Completadas',

        // Stats Screen
        'stats_title': 'Estadísticas',
        'stats_total_workouts': 'Entrenamientos',
        'stats_total_time': 'Tiempo total',
        'stats_current_streak': 'Racha actual',
        'stats_best_streak': 'Mejor racha',
        'stats_weekly': 'Últimos 7 días',
        'stats_by_type': 'Por tipo de timer',
        'stats_empty': 'Sin estadísticas aún',
        'stats_empty_hint': 'Completa entrenamientos para ver tu progreso',
        'stats': 'Estadísticas',
        'stats_all': 'Todo',
        'stats_monthly': 'Últimos 30 días',
        'stats_quarterly': 'Últimos 3 meses',
        'stats_all_time': 'Todo el historial',

        // Badges / Gamification
        'badges_title': 'Logros',
        'badges_unlocked': 'desbloqueados',
        'badge_locked': 'Bloqueado',
        'badge_unlocked_title': '¡Logro Desbloqueado!',
        'badge_streak_3': 'Primera Llama',
        'badge_streak_3_desc': 'Racha de 3 días',
        'badge_streak_7': 'En Llamas',
        'badge_streak_7_desc': 'Racha de 7 días',
        'badge_streak_14': 'Imparable',
        'badge_streak_14_desc': 'Racha de 14 días',
        'badge_streak_30': 'Leyenda',
        'badge_streak_30_desc': 'Racha de 30 días',
        'badge_streak_60': 'Volcánico',
        'badge_streak_60_desc': 'Racha de 60 días',
        'badge_streak_90': 'Inmortal',
        'badge_streak_90_desc': 'Racha de 90 días',
        'badge_wod_1': 'Primer WOD',
        'badge_wod_1_desc': 'Completa tu primer entrenamiento',
        'badge_wod_10': 'Guerrero',
        'badge_wod_10_desc': 'Completa 10 entrenamientos',
        'badge_wod_25': 'Máquina',
        'badge_wod_25_desc': 'Completa 25 entrenamientos',
        'badge_wod_50': 'Rey',
        'badge_wod_50_desc': 'Completa 50 entrenamientos',
        'badge_wod_100': 'Titán',
        'badge_wod_100_desc': 'Completa 100 entrenamientos',
        'badge_wod_200': 'Cometa',
        'badge_wod_200_desc': 'Completa 200 entrenamientos',
        'badge_wod_500': 'Olimpo',
        'badge_wod_500_desc': 'Completa 500 entrenamientos',
        'badge_all_types': 'Todoterreno',
        'badge_all_types_desc': 'Usa los 5 tipos de timer',
        'badge_amrap_10': 'Maestro AMRAP',
        'badge_amrap_10_desc': '10 entrenamientos AMRAP',
        'badge_emom_10': 'Maestro EMOM',
        'badge_emom_10_desc': '10 entrenamientos EMOM',
        'badge_tabata_10': 'Maestro Tabata',
        'badge_tabata_10_desc': '10 entrenamientos Tabata',
        'badge_running_10': 'Corredor',
        'badge_running_10_desc': '10 entrenamientos Running',
        'badge_countdown_10': 'Cronómetro',
        'badge_countdown_10_desc': '10 entrenamientos Countdown',
        'badge_time_1h': 'Hora de Poder',
        'badge_time_1h_desc': '1 hora total entrenando',
        'badge_time_5h': 'Voluntad de Hierro',
        'badge_time_5h_desc': '5 horas total entrenando',
        'badge_time_10h': 'Diamante',
        'badge_time_10h_desc': '10 horas total entrenando',
        'badge_time_25h': 'Estrella',
        'badge_time_25h_desc': '25 horas total entrenando',
        'badge_time_50h': 'Medalla de Oro',
        'badge_time_50h_desc': '50 horas total entrenando',
        'badge_time_100h': 'Ascendido',
        'badge_time_100h_desc': '100 horas total entrenando',
        'level_1': 'Novato',
        'level_2': 'Iniciado',
        'level_3': 'Atleta',
        'level_4': 'Guerrero',
        'level_5': 'Élite',
        'level_6': 'Maestro',
        'level_7': 'Leyenda',
        'level_8': 'Semidiós',
        'level_9': 'Titán',
        'level_10': 'Inmortal',
        'level_label': 'Nivel',
        'level_up_title': '¡Subiste de Nivel!',
        'level_next': 'logros más para el siguiente nivel',
        'level_max': '¡Nivel máximo alcanzado!',
        'all_badges_unlocked': '¡Todos los logros desbloqueados!',
        'achievements_title': 'Logros',
        'achievements_subtitle': 'Colecciona insignias y sube de nivel',
        'share_achievements': 'Mira mi progreso en CrossFit Timer Pro!',
        'prestige': 'Prestigio',
        'prestige_button': 'Activar Prestigio',
        'prestige_title': 'Activar Prestigio',
        'prestige_confirm': 'Tus logros se reiniciarán y ganarás una estrella de prestigio. Tu historial de entrenamientos se mantiene. ¿Continuar?',
        'prestige_activate': 'Activar',
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
        'workout_timer': 'CrossFit Timer Pro',
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
            'Other premium apps: \$120/year\\nWorkout Timer: \$3.99 ONCE\\n\\n🎉 Save \$116 per year!',
        'developed_by':
            'Developed with ❤️ by Alexander Herrera\\n📍 Fitness Apps Specialist',
        'close': 'Close',
        'love_it': 'Love it!',
        'thanks_message': 'Thanks for using Workout Timer!',

        // Running Summary
        'average': 'Average',
        'best': 'Best',
        'worst': 'Worst',
        'round_details': 'Round details',
        'performance_chart': 'Performance Chart',
        'completed_rounds_status': 'Completed Rounds',

        // Stats Screen
        'stats_title': 'Statistics',
        'stats_total_workouts': 'Workouts',
        'stats_total_time': 'Total time',
        'stats_current_streak': 'Current streak',
        'stats_best_streak': 'Best streak',
        'stats_weekly': 'Last 7 days',
        'stats_by_type': 'By timer type',
        'stats_empty': 'No stats yet',
        'stats_empty_hint': 'Complete workouts to see your progress',
        'stats': 'Statistics',
        'stats_all': 'All',
        'stats_monthly': 'Last 30 days',
        'stats_quarterly': 'Last 3 months',
        'stats_all_time': 'All time',

        // Badges / Gamification
        'badges_title': 'Achievements',
        'badges_unlocked': 'unlocked',
        'badge_locked': 'Locked',
        'badge_unlocked_title': 'Achievement Unlocked!',
        'badge_streak_3': 'First Flame',
        'badge_streak_3_desc': '3-day streak',
        'badge_streak_7': 'On Fire',
        'badge_streak_7_desc': '7-day streak',
        'badge_streak_14': 'Unstoppable',
        'badge_streak_14_desc': '14-day streak',
        'badge_streak_30': 'Legend',
        'badge_streak_30_desc': '30-day streak',
        'badge_streak_60': 'Volcanic',
        'badge_streak_60_desc': '60-day streak',
        'badge_streak_90': 'Immortal',
        'badge_streak_90_desc': '90-day streak',
        'badge_wod_1': 'First WOD',
        'badge_wod_1_desc': 'Complete your first workout',
        'badge_wod_10': 'Warrior',
        'badge_wod_10_desc': 'Complete 10 workouts',
        'badge_wod_25': 'Machine',
        'badge_wod_25_desc': 'Complete 25 workouts',
        'badge_wod_50': 'King',
        'badge_wod_50_desc': 'Complete 50 workouts',
        'badge_wod_100': 'Titan',
        'badge_wod_100_desc': 'Complete 100 workouts',
        'badge_wod_200': 'Comet',
        'badge_wod_200_desc': 'Complete 200 workouts',
        'badge_wod_500': 'Olympus',
        'badge_wod_500_desc': 'Complete 500 workouts',
        'badge_all_types': 'All-Rounder',
        'badge_all_types_desc': 'Use all 5 timer types',
        'badge_amrap_10': 'AMRAP Master',
        'badge_amrap_10_desc': '10 AMRAP workouts',
        'badge_emom_10': 'EMOM Master',
        'badge_emom_10_desc': '10 EMOM workouts',
        'badge_tabata_10': 'Tabata Master',
        'badge_tabata_10_desc': '10 Tabata workouts',
        'badge_running_10': 'Runner',
        'badge_running_10_desc': '10 Running workouts',
        'badge_countdown_10': 'Timekeeper',
        'badge_countdown_10_desc': '10 Countdown workouts',
        'badge_time_1h': 'Hour of Power',
        'badge_time_1h_desc': '1 hour total training',
        'badge_time_5h': 'Iron Will',
        'badge_time_5h_desc': '5 hours total training',
        'badge_time_10h': 'Diamond',
        'badge_time_10h_desc': '10 hours total training',
        'badge_time_25h': 'Star',
        'badge_time_25h_desc': '25 hours total training',
        'badge_time_50h': 'Gold Medal',
        'badge_time_50h_desc': '50 hours total training',
        'badge_time_100h': 'Ascended',
        'badge_time_100h_desc': '100 hours total training',
        'level_1': 'Rookie',
        'level_2': 'Beginner',
        'level_3': 'Athlete',
        'level_4': 'Warrior',
        'level_5': 'Elite',
        'level_6': 'Master',
        'level_7': 'Legend',
        'level_8': 'Demigod',
        'level_9': 'Titan',
        'level_10': 'Immortal',
        'level_label': 'Level',
        'level_up_title': 'Level Up!',
        'level_next': 'achievements to next level',
        'level_max': 'Max level reached!',
        'all_badges_unlocked': 'All achievements unlocked!',
        'achievements_title': 'Achievements',
        'achievements_subtitle': 'Collect badges and level up',
        'share_achievements': 'Check out my progress on CrossFit Timer Pro!',
        'prestige': 'Prestige',
        'prestige_button': 'Activate Prestige',
        'prestige_title': 'Activate Prestige',
        'prestige_confirm': 'Your achievements will reset and you\'ll earn a prestige star. Your workout history is kept. Continue?',
        'prestige_activate': 'Activate',
      },
    };

    return translations[_currentLanguage]?[key] ??
        translations['es']?[key] ??
        key;
  }
}
