# CrossFit Timer Pro — Contexto General
_Última actualización: 2026-03-18_

---

## Resumen de la app

**CrossFit Timer Pro** es una app de temporizador de intervalos para entrenamientos de CrossFit, desarrollada en **Flutter** (Android + iOS). Publicada en Google Play por **Alexander Herrera Dominguez** (`com.alexherdom.crossfit_timer_pro`).

### Modos de entrenamiento disponibles
| Modo | Descripción |
|------|-------------|
| **AMRAP** | As Many Rounds As Possible — cuenta el tiempo libre |
| **EMOM** | Every Minute On the Minute — avisa cada minuto |
| **TABATA** | Intervalos trabajo/descanso configurables (default 20s/10s) |
| **COUNTDOWN** | Cuenta regresiva simple |
| **RUNNING** | Timer para series de carrera con distancia y descanso |

### Funcionalidades principales
- Temporizador circular animado con efecto glassmorphism
- Voz TTS que anuncia el estado del entrenamiento
- Sonidos de beep configurables con control de volumen
- Historial de sesiones con gráficas (`fl_chart`)
- Modo pantalla completa durante el entrenamiento
- Vibración como feedback adicional
- Modo oscuro / claro
- Idiomas: Español e Inglés
- Confetti al terminar el entrenamiento
- Notificaciones en pantalla de bloqueo
- Mantiene pantalla encendida durante el entreno

### Stack técnico
- **Flutter** + Dart
- **Provider** para manejo de estado (ThemeProvider, LanguageProvider, AdService)
- **SharedPreferences** para persistencia local
- **audioplayers** para sonidos
- **flutter_tts** para voz
- **fl_chart** para gráficas de historial
- **flutter_local_notifications** para notificaciones
- **wakelock_plus** para mantener pantalla encendida

### Estructura de pantallas
```
HomeScreen         → lista de modos de entrenamiento
ConfigScreen       → configuración por modo (rondas, tiempo, etc.)
TimerScreen        → pantalla principal del entrenamiento
HistoryScreen      → historial de sesiones
SettingsScreen     → ajustes generales + "Quitar anuncios"
```

### Versiones
| Versión | Build | Notas |
|---------|-------|-------|
| 1.0.0 | 1 | Lanzamiento inicial |
| 1.0.1 | 4 | Mejoras de UI, modo oscuro |
| 1.0.2 | 5 | App gratuita + AdMob + IAP (actual en revisión) |

---

## Modelo de negocio implementado
- App **gratis** en Play Store
- **Banner ads** (AdMob) no intrusivos
- **"Quitar anuncios — $2"** como compra única (IAP) en Settings

---

## Lo que ya está hecho

### Código
- `lib/services/ad_service.dart` — servicio central que maneja:
  - Banner home (`_bannerAd`)
  - Banner timer (`_timerBannerAd`) — instancias separadas para evitar conflicto
  - IAP con `in_app_purchase` (producto `remove_ads`)
  - Estado persistido en `SharedPreferences` (`ads_removed`)
- `lib/screens/home_screen.dart` — banner fijo en la parte inferior
- `lib/screens/timer_screen.dart` — banner flotante (`Positioned`) que aparece con `AnimatedSlide` solo cuando el timer está en pausa (no desplaza el layout)
- `lib/screens/settings_screen.dart` — sección "Soporte" con botón "Quitar anuncios — $2" y botón "Restaurar"
- `lib/main.dart` — inicializa `MobileAds` y registra `AdService` como provider
- `android/app/src/main/AndroidManifest.xml` — permiso `INTERNET`, `AD_ID` y App ID de AdMob
- `ios/Runner/Info.plist` — `GADApplicationIdentifier` (test ID por ahora)
- `pubspec.yaml` — paquetes `google_mobile_ads: ^5.1.0` y `in_app_purchase: ^3.2.0`

### AdMob (admob.google.com)
- Cuenta registrada ✅
- App registrada: **CrossFit Timer Pro** (Android)
- **App ID real:** `ca-app-pub-6636064525240027~7398969943`
- **Ad Unit IDs reales:**
  - `banner_home`: `ca-app-pub-6636064525240027/7917844691`
  - `banner_timer`: `ca-app-pub-6636064525240027/3242567661`
- En debug mode siempre se muestran anuncios de prueba de Google (normal)
- Cuenta pendiente de aprobación por Google (~24h)

### Play Console
- App cambiada de **pago → gratuita** ✅
- Versión **1.0.2 (build 5)** subida como borrador ✅
- Enviada a revisión ✅
- Declaración "ID de publicidad" completada: **Sí, Publicidad o marketing** ✅

---

## Pendiente / Por hacer

### Alta prioridad
1. **Crear producto IAP `remove_ads` en Play Console**
   - Ir a: Monetizar con Play → Productos → Productos únicos
   - ID del producto: `remove_ads` (exactamente ese, es el que está en el código)
   - Nombre: "Quitar anuncios"
   - Precio: $2.00 USD
   - Tipo: Compra única (no consumible)
   - _Nota: No se puede crear hasta que Google procese la nueva versión con el permiso BILLING_

2. **Esperar aprobación de Google Play** (~1-3 días)
   - Una vez aprobada, volver a Productos únicos y crear el `remove_ads`

3. **Completar perfil de pagos en AdMob**
   - Hay un banner rojo en AdMob que dice "Configuración de pagos incompleta"
   - Sin esto Google no pagará los ingresos de anuncios

### Media prioridad
4. **Verificar app en AdMob**
   - Estado actual: "Debe revisarse / Serv. anuncios limit."
   - Requiere subir un archivo `app-ads.txt` a un sitio web del desarrollador
   - Sin esto los anuncios están limitados (pero funcionan)

5. **IDs de AdMob para iOS**
   - Actualmente el `Info.plist` tiene el ID de prueba de Google
   - Si se publica en App Store, necesita ID real de AdMob para iOS

6. **Compilar versión 1.0.3** con el permiso `AD_ID` ya añadido al AndroidManifest
   - El permiso ya está en el código (commit `7807304`)
   - Falta compilar AAB y subir como nueva versión

### Baja prioridad
7. Actualizar el texto "offline_no_ads" en el diálogo "About" de home_screen.dart
   - Actualmente dice "sin internet, sin anuncios" lo cual ya no es correcto

---

## IDs importantes (guardar)
| Cosa | ID |
|------|----|
| AdMob App ID Android | `ca-app-pub-6636064525240027~7398969943` |
| Ad Unit banner_home | `ca-app-pub-6636064525240027/7917844691` |
| Ad Unit banner_timer | `ca-app-pub-6636064525240027/3242567661` |
| IAP Product ID | `remove_ads` |
| Play Console Package | `com.alexherdom.crossfit_timer_pro` |

---

## Rama de git
- Rama actual: `feature/running-timer`
- Último commit: `7807304` — feat: add AdMob banner ads and remove ads IAP
