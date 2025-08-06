import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
  ];

  // Timer Types
  String get amrap => _isSpanish ? 'AMRAP' : 'AMRAP';
  String get emom => _isSpanish ? 'EMOM' : 'EMOM';
  String get tabata => _isSpanish ? 'TABATA' : 'TABATA';
  String get countdown => _isSpanish ? 'COUNTDOWN' : 'COUNTDOWN';

  // Timer Subtitles
  String get amrapSubtitle => _isSpanish ? 'Máximas rondas' : 'Max rounds';
  String get emomSubtitle => _isSpanish ? 'Cada minuto' : 'Every minute';
  String get tabataSubtitle =>
      _isSpanish ? 'Alta intensidad' : 'High intensity';
  String get countdownSubtitle => _isSpanish ? 'Cuenta regresiva' : 'Countdown';

  // Home Screen
  String get workoutTimer => _isSpanish ? 'Workout Timer' : 'Workout Timer';
  String get selectWorkout =>
      _isSpanish ? 'Selecciona tu entrenamiento' : 'Select your workout';
  String get history => _isSpanish ? 'Historial' : 'History';
  String get settings => _isSpanish ? 'Configuración' : 'Settings';

  // Timer Screen
  String get prepareFor => _isSpanish ? 'Prepárate para' : 'Get ready for';
  String get work => _isSpanish ? 'TRABAJO' : 'WORK';
  String get rest => _isSpanish ? 'DESCANSO' : 'REST';
  String get roundOf =>
      _isSpanish ? 'Ronda {current} de {total}' : 'Round {current} of {total}';
  String get reset => _isSpanish ? 'Reset' : 'Reset';
  String get pause => _isSpanish ? 'Pausa' : 'Pause';
  String get start => _isSpanish ? 'Iniciar' : 'Start';
  String get exit => _isSpanish ? 'Salir' : 'Exit';
  String get fullscreen => _isSpanish ? 'Pantalla completa' : 'Fullscreen';
  String get exitFullscreen =>
      _isSpanish ? 'Salir de pantalla completa' : 'Exit fullscreen';

  // Completion Dialog
  String get workoutCompleted =>
      _isSpanish ? '¡Entrenamiento Completado!' : 'Workout Completed!';
  String get excellentWork =>
      _isSpanish ? '¡Excelente trabajo!' : 'Excellent work!';
  String get share => _isSpanish ? 'Compartir' : 'Share';
  String get repeat => _isSpanish ? 'Repetir' : 'Repeat';
  String get mainMenu => _isSpanish ? 'Menú Principal' : 'Main Menu';

  // Completion Messages
  String get amrapCompleted => _isSpanish
      ? '¡Has completado tu entrenamiento AMRAP!'
      : 'You have completed your AMRAP workout!';
  String emomCompleted(int rounds) => _isSpanish
      ? '¡Has completado $rounds rondas EMOM!'
      : 'You have completed $rounds EMOM rounds!';
  String tabataCompleted(int rounds) => _isSpanish
      ? '¡Has completado $rounds rondas de Tabata!'
      : 'You have completed $rounds Tabata rounds!';
  String get timeCompleted =>
      _isSpanish ? '¡Tiempo completado!' : 'Time completed!';

  // Share Messages
  String get justCompleted => _isSpanish
      ? '¡Acabo de completar mi entrenamiento!'
      : 'Just completed my workout!';
  String get keepTraining => _isSpanish
      ? '¡Sigue entrenando y alcanza tus metas!'
      : 'Keep training and reach your goals!';
  String get workoutCompletedSubject =>
      _isSpanish ? '¡Entrenamiento completado!' : 'Workout completed!';
  String get shareError => _isSpanish
      ? '❌ Error al compartir el entrenamiento'
      : '❌ Error sharing workout';

  // Share Summary
  String get type => _isSpanish ? 'Tipo' : 'Type';
  String get duration => _isSpanish ? 'Duración' : 'Duration';
  String get durationPerRound =>
      _isSpanish ? 'Duración por ronda' : 'Duration per round';
  String get roundsCompleted =>
      _isSpanish ? 'Rondas completadas' : 'Rounds completed';
  String get totalTime => _isSpanish ? 'Tiempo total' : 'Total time';
  String get date => _isSpanish ? 'Fecha' : 'Date';
  String get at => _isSpanish ? 'a las' : 'at';
  String get status => _isSpanish ? 'Estado' : 'Status';
  String get completed => _isSpanish ? '¡Completado!' : 'Completed!';
  String get work20s => _isSpanish ? 'Trabajo: 20s' : 'Work: 20s';
  String get rest10s => _isSpanish ? 'Descanso: 10s' : 'Rest: 10s';

  // Settings Screen
  String get language => _isSpanish ? 'Idioma' : 'Language';
  String get spanish => _isSpanish ? 'Español' : 'Spanish';
  String get english => _isSpanish ? 'Inglés' : 'English';
  String get theme => _isSpanish ? 'Tema' : 'Theme';
  String get orange => _isSpanish ? 'Naranja' : 'Orange';
  String get blue => _isSpanish ? 'Azul' : 'Blue';
  String get red => _isSpanish ? 'Rojo' : 'Red';
  String get green => _isSpanish ? 'Verde' : 'Green';
  String get purple => _isSpanish ? 'Morado' : 'Purple';

  // Configuration Screen
  String get configuration => _isSpanish ? 'Configuración' : 'Configuration';
  String get minutes => _isSpanish ? 'Minutos' : 'Minutes';
  String get seconds => _isSpanish ? 'Segundos' : 'Seconds';
  String get rounds => _isSpanish ? 'Rondas' : 'Rounds';
  String get workTime => _isSpanish ? 'Tiempo de trabajo' : 'Work time';
  String get restTime => _isSpanish ? 'Tiempo de descanso' : 'Rest time';
  String get save => _isSpanish ? 'Guardar' : 'Save';

  // History Screen
  String get workoutHistory =>
      _isSpanish ? 'Historial de Entrenamientos' : 'Workout History';
  String get noWorkouts =>
      _isSpanish ? 'No hay entrenamientos registrados' : 'No workouts recorded';
  String get startTraining => _isSpanish
      ? '¡Comienza a entrenar para ver tu progreso aquí!'
      : 'Start training to see your progress here!';

  // Timer descriptions for sharing
  String get amrapDescription => _isSpanish
      ? 'AMRAP (As Many Rounds As Possible)'
      : 'AMRAP (As Many Rounds As Possible)';
  String get emomDescription => _isSpanish
      ? 'EMOM (Every Minute On the Minute)'
      : 'EMOM (Every Minute On the Minute)';

  bool get _isSpanish => locale.languageCode == 'es';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
