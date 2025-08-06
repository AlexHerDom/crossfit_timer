import 'package:shared_preferences/shared_preferences.dart';

/// Gestor de analytics básico para entender uso de la app
/// Preparado para migración futura a Firebase Analytics
class AnalyticsManager {
  static const String _usageStatsKey = 'usage_stats';
  static const String _sessionCountKey = 'session_count';
  static const String _firstLaunchKey = 'first_launch_date';

  /// Inicializar analytics
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Marcar primera vez si es necesario
    if (!prefs.containsKey(_firstLaunchKey)) {
      await prefs.setString(_firstLaunchKey, DateTime.now().toIso8601String());
    }

    // Incrementar contador de sesiones
    final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
    await prefs.setInt(_sessionCountKey, sessionCount + 1);

    print('📊 Analytics: Sesión #${sessionCount + 1}');
  }

  /// Trackear uso de timer
  static Future<void> trackTimerUsed(String timerType, {int? duration}) async {
    final event = {
      'type': 'timer_used',
      'timer_type': timerType.toUpperCase(),
      'duration_seconds': duration,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _saveEvent(event);
    print(
      '📊 Timer usado: $timerType${duration != null ? ' (${duration}s)' : ''}',
    );
  }

  /// Trackear uso de función
  static Future<void> trackFeatureUsed(
    String feature, {
    Map<String, dynamic>? params,
  }) async {
    final event = {
      'type': 'feature_used',
      'feature': feature,
      'params': params,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _saveEvent(event);
    print('📊 Función usada: $feature');
  }

  /// Trackear configuración cambiada
  static Future<void> trackConfigurationChanged(
    String setting,
    dynamic value,
  ) async {
    final event = {
      'type': 'configuration_changed',
      'setting': setting,
      'value': value.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _saveEvent(event);
    print('📊 Configuración: $setting = $value');
  }

  /// Trackear finalización de entrenamiento
  static Future<void> trackWorkoutCompleted(
    String timerType,
    int totalDuration,
  ) async {
    final event = {
      'type': 'workout_completed',
      'timer_type': timerType.toUpperCase(),
      'total_duration_seconds': totalDuration,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _saveEvent(event);
    print('📊 Entrenamiento completado: $timerType (${totalDuration}s)');
  }

  /// Trackear error o crash
  static Future<void> trackError(String error, {String? context}) async {
    final event = {
      'type': 'error',
      'error_message': error,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _saveEvent(event);
    print('❌ Error tracked: $error');
  }

  /// Guardar evento en local storage
  static Future<void> _saveEvent(Map<String, dynamic> event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingEvents = prefs.getStringList(_usageStatsKey) ?? [];

      // Mantener solo los últimos 100 eventos para no saturar storage
      if (existingEvents.length >= 100) {
        existingEvents.removeAt(0);
      }

      existingEvents.add(event.toString());
      await prefs.setStringList(_usageStatsKey, existingEvents);
    } catch (e) {
      print('❌ Error guardando analytics: $e');
    }
  }

  /// Obtener estadísticas de uso (para debugging)
  static Future<Map<String, dynamic>> getUsageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getString(_firstLaunchKey);
    final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
    final events = prefs.getStringList(_usageStatsKey) ?? [];

    return {
      'first_launch': firstLaunch,
      'total_sessions': sessionCount,
      'total_events': events.length,
      'days_since_install': firstLaunch != null
          ? DateTime.now().difference(DateTime.parse(firstLaunch)).inDays
          : 0,
    };
  }

  /// Limpiar datos de analytics (para testing)
  static Future<void> clearAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usageStatsKey);
    await prefs.remove(_sessionCountKey);
    await prefs.remove(_firstLaunchKey);
    print('🧹 Analytics limpiados');
  }

  /// Exportar datos para análisis (futuro)
  static Future<String> exportAnalyticsData() async {
    final stats = await getUsageStats();
    final prefs = await SharedPreferences.getInstance();
    final events = prefs.getStringList(_usageStatsKey) ?? [];

    final export = {
      'summary': stats,
      'events': events,
      'exported_at': DateTime.now().toIso8601String(),
    };

    return export.toString();
  }
}
