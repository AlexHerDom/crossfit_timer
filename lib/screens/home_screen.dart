import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timer_screen.dart';
import 'config_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../theme_provider.dart';
import '../language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabataWorkSeconds = 20;
  int _tabataRestSeconds = 10;

  @override
  void initState() {
    super.initState();
    _loadTabataConfig();
  }

  void _loadTabataConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tabataWorkSeconds = prefs.getInt('tabata_work') ?? 20;
      _tabataRestSeconds = prefs.getInt('tabata_rest') ?? 10;
    });
  }

  String _getTabataSubtitle(LanguageProvider languageProvider) {
    final subtitle =
        '${_tabataWorkSeconds}s ${languageProvider.getText('work').toLowerCase()} / ${_tabataRestSeconds}s ${languageProvider.getText('rest').toLowerCase()}';
    // Debug: imprimir el subtítulo para verificar
    print(
      '🧪 DEBUG: Tabata subtitle = $subtitle (work: $_tabataWorkSeconds, rest: $_tabataRestSeconds)',
    );
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history),
            tooltip: languageProvider.getText('history'),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
            tooltip: languageProvider.getText('settings'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'about') {
                _showAboutDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 8),
                    Text(languageProvider.getText('about')),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkMode
                    ? const [Color(0xFF1E2030), Color(0xFF2A2A38), Color(0xFF1E2030)]
                    : const [Color(0xFFE0F7FA), Color(0xFFFCE4EC), Color(0xFFE8EAF6)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Título de bienvenida
                    Column(
                          children: [
                            Text(
                              languageProvider.getText('workout_timer'),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              languageProvider.getText('time_train'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: themeProvider.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 50.ms)
                        .slideY(begin: -0.2, end: 0),

                    const SizedBox(height: 40),

                    // Botón AMRAP
                    _buildTimerButton(
                      context,
                      title: languageProvider.getText('amrap_title'),
                      subtitle: languageProvider.getText('amrap_subtitle'),
                      icon: Icons.all_inclusive,
                      color: Colors.orange,
                      onTap: () => _navigateToTimer(context, 'AMRAP'),
                      isDarkMode: themeProvider.isDarkMode,
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    // Botón EMOM
                    _buildTimerButton(
                      context,
                      title: languageProvider.getText('emom_title'),
                      subtitle: languageProvider.getText('emom_subtitle'),
                      icon: Icons.access_time,
                      color: Colors.blue,
                      onTap: () => _navigateToTimer(context, 'EMOM'),
                      isDarkMode: themeProvider.isDarkMode,
                    ).animate().fadeIn(duration: 400.ms, delay: 175.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    // Botón Tabata
                    _buildTimerButton(
                      context,
                      title: languageProvider.getText('tabata_title'),
                      subtitle: _getTabataSubtitle(languageProvider),
                      icon: Icons.flash_on,
                      color: Colors.red,
                      onTap: () => _navigateToTimer(context, 'TABATA'),
                      isDarkMode: themeProvider.isDarkMode,
                    ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    // Botón Countdown
                    _buildTimerButton(
                      context,
                      title: languageProvider.getText('countdown_title'),
                      subtitle: languageProvider.getText('countdown_subtitle'),
                      icon: Icons.timer,
                      color: Colors.green,
                      onTap: () => _navigateToTimer(context, 'COUNTDOWN'),
                      isDarkMode: themeProvider.isDarkMode,
                    ).animate().fadeIn(duration: 400.ms, delay: 325.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    // Botón Running
                    _buildTimerButton(
                      context,
                      title: languageProvider.getText('running_title'),
                      subtitle: languageProvider.getText('running_subtitle'),
                      icon: Icons.directions_run,
                      color: Colors.purple,
                      onTap: () => _navigateToTimer(context, 'RUNNING'),
                      isDarkMode: themeProvider.isDarkMode,
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para crear botones consistentes con efectos mejorados
  Widget _buildTimerButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.black.withValues(alpha: 0.7);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: color.withValues(alpha: 0.1),
              highlightColor: color.withValues(alpha: 0.05),
              child: Row(
                children: [
                  // Icono izquierdo
                  SizedBox(
                    width: 72,
                    child: Icon(icon, size: 34, color: textColor),
                  ),
                  // Texto
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón configuración
                  IconButton(
                    onPressed: () => _openConfigScreen(context, title),
                    icon: const Icon(Icons.settings_outlined, size: 22),
                    color: subtitleColor,
                    splashRadius: 22,
                    tooltip: 'Configurar',
                  ),
                  // Flecha
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: textColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Función para navegar a la pantalla del timer
  void _navigateToTimer(BuildContext context, String timerType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(timerType: timerType),
      ),
    );
  }

  // Función para abrir la configuración
  void _openConfigScreen(BuildContext context, String timerType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigScreen(timerType: timerType),
      ),
    );

    // Recargar la configuración de Tabata cuando regresa de la configuración
    if (timerType == 'TABATA') {
      _loadTabataConfig();
    }
  }

  void _showAboutDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Workout Timer PRO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'v1.0.0 - Complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.deepOrange.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🏆 ${languageProvider.getText('timer_number_one')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.getText('used_by_athletes'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ ${languageProvider.getText('everything_included')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              languageProvider.getText('professional_timers'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              languageProvider.getText('intelligent_voice'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              languageProvider.getText('complete_history'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              languageProvider.getText('offline_no_ads'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              languageProvider.getText('premium_themes'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '💰 ${languageProvider.getText('incredible_value')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider
                            .getText('other_apps_cost')
                            .replaceAll('\\n', '\n'),
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  languageProvider
                      .getText('developed_by')
                      .replaceAll('\\n', '\n'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      languageProvider.getText('close'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Aquí puedes agregar la lógica para mostrar más información o ir a la tienda
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            languageProvider.getText('thanks_message'),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(languageProvider.getText('love_it')),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
