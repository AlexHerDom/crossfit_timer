import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'timer_screen.dart';
import 'config_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(ThemeMode) changeTheme;
  
  const HomeScreen({super.key, required this.changeTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BarrasCop Timer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'theme_light') {
                changeTheme(ThemeMode.light);
              } else if (value == 'theme_dark') {
                changeTheme(ThemeMode.dark);
              } else if (value == 'theme_system') {
                changeTheme(ThemeMode.system);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'theme_light',
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny),
                    SizedBox(width: 8),
                    Text('Tema Claro'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'theme_dark',
                child: Row(
                  children: [
                    Icon(Icons.nightlight_round),
                    SizedBox(width: 8),
                    Text('Tema Oscuro'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'theme_system',
                child: Row(
                  children: [
                    Icon(Icons.settings_brightness),
                    SizedBox(width: 8),
                    Text('Seguir Sistema'),
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
            // Título de bienvenida con animación
            const Text(
              '¡Hora de entrenar!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 100.ms)
              .slideY(begin: -0.3, end: 0),
            
            const SizedBox(height: 40),
            
            // Botón AMRAP con animación
            _buildTimerButton(
              context,
              title: 'AMRAP',
              subtitle: 'Tantas rondas como puedas',
              icon: Icons.repeat,
              color: Colors.orange,
              onTap: () => _navigateToTimer(context, 'AMRAP'),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: -0.3, end: 0)
              .shimmer(delay: 1000.ms, duration: 1500.ms),
            
            const SizedBox(height: 20),
            
            // Botón EMOM con animación
            _buildTimerButton(
              context,
              title: 'EMOM',
              subtitle: 'Cada minuto en punto',
              icon: Icons.schedule,
              color: Colors.blue,
              onTap: () => _navigateToTimer(context, 'EMOM'),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideX(begin: 0.3, end: 0)
              .shimmer(delay: 1200.ms, duration: 1500.ms),
            
            const SizedBox(height: 20),
            
            // Botón Tabata con animación
            _buildTimerButton(
              context,
              title: 'TABATA',
              subtitle: '20s trabajo / 10s descanso',
              icon: Icons.fitness_center,
              color: Colors.red,
              onTap: () => _navigateToTimer(context, 'TABATA'),
            ).animate()
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
            ).animate()
              .fadeIn(duration: 600.ms, delay: 500.ms)
              .slideX(begin: 0.3, end: 0)
              .shimmer(delay: 1600.ms, duration: 1500.ms),
            
            const SizedBox(height: 40),
            
            // Firma del desarrollador con animación
            const Text(
              '🦊 By Alexander Herrera',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .slideY(begin: 0.3, end: 0),
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
                colors: [
                  color.withOpacity(0.9),
                  color,
                  color.withOpacity(0.8),
                ],
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
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
}
