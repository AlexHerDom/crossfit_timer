import 'package:shared_preferences/shared_preferences.dart';

/// Gestor de licencias para futuro modelo freemium
/// Por ahora todos los usuarios son premium ($1.99)
class LicenseManager {
  static const String _premiumKey = 'is_premium_user';
  static const String _purchaseDateKey = 'purchase_date';

  // Por ahora todos son premium (pagaron $1.99)
  static bool _isPremium = true;

  /// Inicializar el estado de premium
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? true; // Por defecto premium

    // Si es la primera vez, marcar como premium
    if (!prefs.containsKey(_premiumKey)) {
      await setPremiumStatus(true);
    }
  }

  /// Verificar si el usuario es premium
  static bool get isPremium => _isPremium;

  /// Establecer estado premium
  static Future<void> setPremiumStatus(bool premium) async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = premium;
    await prefs.setBool(_premiumKey, premium);

    if (premium) {
      await prefs.setString(_purchaseDateKey, DateTime.now().toIso8601String());
    }
  }

  /// Verificar si puede usar un timer específico
  static bool canUseTimer(String timerType) {
    // Por ahora todos pueden usar todo (pagaron $1.99)
    if (!_isPremium && timerType.toUpperCase() != 'COUNTDOWN') {
      return false; // Para futuro freemium
    }
    return true;
  }

  /// Verificar si puede acceder al historial
  static bool canAccessHistory() {
    return _isPremium; // Por ahora siempre true
  }

  /// Verificar si puede usar TTS avanzado
  static bool canUseTTS() {
    return _isPremium; // Por ahora siempre true
  }

  /// Verificar si puede usar todos los temas
  static bool canUseAllThemes() {
    return _isPremium; // Por ahora siempre true
  }

  /// Obtener fecha de compra
  static Future<DateTime?> getPurchaseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_purchaseDateKey);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  /// Para futuro: mostrar pantalla de upgrade
  static void showUpgradeDialog() {
    // Implementar cuando migremos a freemium
    print('🔒 Función premium requerida - Upgrade necesario');
  }

  /// Verificar si es usuario "grandfathered" (pagó $1.99 original)
  static Future<bool> isGrandfatheredUser() async {
    final purchaseDate = await getPurchaseDate();
    if (purchaseDate == null) return true; // Asumimos que es usuario original

    // Todos los usuarios antes de la migración a freemium son grandfathered
    final freemiumLaunchDate = DateTime(2025, 12, 1); // Fecha tentativa
    return purchaseDate.isBefore(freemiumLaunchDate);
  }
}
