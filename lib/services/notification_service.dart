import 'dart:async';
import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// Callback de acciones de notificación - DEBE ser top-level (fuera de clase)
@pragma('vm:entry-point')
void onNotificationAction(NotificationResponse response) {
  NotificationService._actionController.add(response.actionId ?? '');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<String> _actionController =
      StreamController<String>.broadcast();

  static Stream<String> get actionStream => _actionController.stream;

  static const int _notificationId = 1;
  static const String _channelId = 'crossfit_timer_channel';
  static const Color _brandColor = Color(0xFFFF9800); // Naranja CrossFit

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationAction,
      onDidReceiveBackgroundNotificationResponse: onNotificationAction,
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      'CrossFit Timer',
      description: 'Timer activo durante el entrenamiento',
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> showTimerNotification({
    required String timerType,
    required int currentRound,
    required int totalRounds,
    required int remainingSeconds,
    int totalSeconds = 0,
    required bool isPaused,
    required bool isWorkPeriod,
  }) async {
    final isRunningType = timerType == 'RUNNING';
    // RUNNING cuenta hacia arriba, el resto cuenta hacia abajo
    final useChronometer = !isPaused && !isRunningType;

    // "when" le dice a Android dónde termina el countdown (ms desde epoch)
    final int? whenMs = useChronometer
        ? DateTime.now().millisecondsSinceEpoch + remainingSeconds * 1000
        : null;

    final title = _buildTitle(timerType, currentRound, totalRounds, isWorkPeriod);
    final body = _buildBody(timerType, remainingSeconds, isPaused, isRunningType);

    final styleInfo = BigTextStyleInformation(
      _buildExpandedContent(
        timerType: timerType,
        currentRound: currentRound,
        totalRounds: totalRounds,
        remainingSeconds: remainingSeconds,
        isPaused: isPaused,
        isWorkPeriod: isWorkPeriod,
      ),
      contentTitle: title,
      summaryText: isPaused ? 'Pausado' : 'En progreso',
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      'CrossFit Timer',
      channelDescription: 'Timer activo',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      // Cronómetro nativo: se actualiza solo sin que Flutter tenga que hacer push
      showWhen: useChronometer,
      usesChronometer: useChronometer,
      chronometerCountDown: true,
      when: whenMs,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.stopwatch,
      color: _brandColor,
      // Barra de progreso mostrando tiempo restante
      showProgress: totalSeconds > 0 && !isRunningType,
      maxProgress: totalSeconds > 0 ? totalSeconds : 100,
      progress: totalSeconds > 0 ? remainingSeconds : 0,
      indeterminate: false,
      styleInformation: styleInfo,
      subText: _buildSubText(timerType, currentRound, totalRounds, isWorkPeriod),
      actions: [
        AndroidNotificationAction(
          isPaused ? 'resume_action' : 'pause_action',
          isPaused ? 'Reanudar' : 'Pausar',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        const AndroidNotificationAction(
          'stop_action',
          'Detener',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    await _plugin.show(
      _notificationId,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> updateTimerNotification({
    required String timerType,
    required int currentRound,
    required int totalRounds,
    required int remainingSeconds,
    int totalSeconds = 0,
    required bool isPaused,
    required bool isWorkPeriod,
  }) async {
    await showTimerNotification(
      timerType: timerType,
      currentRound: currentRound,
      totalRounds: totalRounds,
      remainingSeconds: remainingSeconds,
      totalSeconds: totalSeconds,
      isPaused: isPaused,
      isWorkPeriod: isWorkPeriod,
    );
  }

  static Future<void> cancelTimerNotification() async {
    await _plugin.cancel(_notificationId);
  }

  static String _buildTitle(
    String timerType,
    int currentRound,
    int totalRounds,
    bool isWorkPeriod,
  ) {
    switch (timerType) {
      case 'EMOM':
        return 'EMOM — Ronda $currentRound/$totalRounds';
      case 'TABATA':
        final period = isWorkPeriod ? 'Trabajo' : 'Descanso';
        return 'TABATA — $period ($currentRound/$totalRounds)';
      case 'AMRAP':
        return 'AMRAP';
      case 'COUNTDOWN':
        return 'Countdown';
      case 'RUNNING':
        return 'Running — Rep $currentRound/$totalRounds';
      default:
        return timerType;
    }
  }

  static String _buildSubText(
    String timerType,
    int currentRound,
    int totalRounds,
    bool isWorkPeriod,
  ) {
    switch (timerType) {
      case 'TABATA':
        return isWorkPeriod ? 'Período de trabajo' : 'Período de descanso';
      case 'EMOM':
        return 'Cada minuto en el minuto';
      case 'AMRAP':
        return 'Lo más que puedas';
      case 'COUNTDOWN':
        return 'CrossFit Timer Pro';
      case 'RUNNING':
        return 'Rep $currentRound de $totalRounds';
      default:
        return 'CrossFit Timer Pro';
    }
  }

  static String _buildBody(
    String timerType,
    int remainingSeconds,
    bool isPaused,
    bool isRunningType,
  ) {
    if (isPaused) {
      return '⏸ Pausado — ${_formatTime(remainingSeconds)}';
    }
    if (isRunningType) {
      return '🏃 ${_formatTime(remainingSeconds)} transcurridos';
    }
    return '⏱ ${_formatTime(remainingSeconds)} restantes';
  }

  static String _buildExpandedContent({
    required String timerType,
    required int currentRound,
    required int totalRounds,
    required int remainingSeconds,
    required bool isPaused,
    required bool isWorkPeriod,
  }) {
    final pauseStr = isPaused ? '\n⏸ PAUSADO' : '';
    final timeStr = _formatTime(remainingSeconds);

    switch (timerType) {
      case 'EMOM':
        return 'Ronda $currentRound de $totalRounds\nTiempo restante: $timeStr$pauseStr';
      case 'TABATA':
        final period = isWorkPeriod ? 'Trabajo' : 'Descanso';
        return '$period — Ronda $currentRound/$totalRounds\nTiempo: $timeStr$pauseStr';
      case 'AMRAP':
        return 'Tiempo restante: $timeStr$pauseStr';
      case 'COUNTDOWN':
        return 'Tiempo restante: $timeStr$pauseStr';
      case 'RUNNING':
        return 'Rep $currentRound de $totalRounds\nTranscurrido: $timeStr$pauseStr';
      default:
        return '$timeStr$pauseStr';
    }
  }

  static String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
