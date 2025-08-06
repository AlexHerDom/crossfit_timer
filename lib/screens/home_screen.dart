import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'timer_screen.dart';
import 'config_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout Timer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
            tooltip: 'Configuraciones',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'about') {
                _showAboutDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Acerca de'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título de bienvenida con animación más atractivo
            Column(
                  children: [
                    Text(
                      'Workout Timer',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.primaryColor,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: themeProvider.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_gymnastics,
                            size: 18,
                            color: themeProvider.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Entrena como un profesional',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.primaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 100.ms)
                .slideY(begin: -0.3, end: 0),

            const SizedBox(height: 40),

            // Botón AMRAP con animación
            _buildTimerButton(
                  context,
                  title: 'AMRAP',
                  subtitle: 'Tantas rondas como puedas',
                  icon: Icons.all_inclusive,
                  color: Colors.orange,
                  onTap: () => _navigateToTimer(context, 'AMRAP'),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.3, end: 0)
                .shimmer(delay: 1000.ms, duration: 1500.ms),

            const SizedBox(height: 20),

            // Botón EMOM con animación
            _buildTimerButton(
                  context,
                  title: 'EMOM',
                  subtitle: 'Cada minuto en punto',
                  icon: Icons.access_time,
                  color: Colors.blue,
                  onTap: () => _navigateToTimer(context, 'EMOM'),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideX(begin: 0.3, end: 0)
                .shimmer(delay: 1200.ms, duration: 1500.ms),

            const SizedBox(height: 20),

            // Botón Tabata con animación
            _buildTimerButton(
                  context,
                  title: 'TABATA',
                  subtitle: '20s trabajo / 10s descanso',
                  icon: Icons.flash_on,
                  color: Colors.red,
                  onTap: () => _navigateToTimer(context, 'TABATA'),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideX(begin: -0.3, end: 0)
                .shimmer(delay: 1400.ms, duration: 1500.ms),

            const SizedBox(height: 20),

            // Botón Countdown con animación
            _buildTimerButton(
                  context,
                  title: 'COUNTDOWN',
                  subtitle: 'Temporizador simple',
                  icon: Icons.timer,
                  color: Colors.green,
                  onTap: () => _navigateToTimer(context, 'COUNTDOWN'),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideX(begin: 0.3, end: 0)
                .shimmer(delay: 1600.ms, duration: 1500.ms),

            const SizedBox(height: 40),
          ],
        ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1), // Sombra más sutil
            blurRadius: 8, // Menos difuso
            spreadRadius: 1, // Menos extensión
            offset: const Offset(0, 4), // Sombra más pequeña
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3, // Menos elevación
            shadowColor: color.withOpacity(0.2), // Sombra más sutil
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.9), color, color.withOpacity(0.8)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón de configuración mejorado
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => _openConfigScreen(context, title),
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
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
  void _openConfigScreen(BuildContext context, String timerType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigScreen(timerType: timerType),
      ),
    );
  }

  void _showAboutDialog() {
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Icon(Icons.timer, size: 40, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              const Text(
                'Workout Timer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'v1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Temporizador profesional para entrenamientos de fitness',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      '✨ Características:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• AMRAP - As Many Rounds As Possible\n'
                      '• EMOM - Every Minute On the Minute\n'
                      '• TABATA - Intervalos de alta intensidad\n'
                      '• COUNTDOWN - Temporizador simple',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🦊 Desarrollado por Alexander Herrera',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }
}
