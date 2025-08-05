import 'package:flutter/material.dart';
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
            // Título de bienvenida
            const Text(
              '¡Hora de entrenar!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Botón AMRAP
            _buildTimerButton(
              context,
              title: 'AMRAP',
              subtitle: 'Tantas rondas como puedas',
              icon: Icons.repeat,
              color: Colors.orange,
              onTap: () => _navigateToTimer(context, 'AMRAP'),
            ),
            
            const SizedBox(height: 20),
            
            // Botón EMOM
            _buildTimerButton(
              context,
              title: 'EMOM',
              subtitle: 'Cada minuto en punto',
              icon: Icons.schedule,
              color: Colors.blue,
              onTap: () => _navigateToTimer(context, 'EMOM'),
            ),
            
            const SizedBox(height: 20),
            
            // Botón Tabata
            _buildTimerButton(
              context,
              title: 'TABATA',
              subtitle: '20s trabajo / 10s descanso',
              icon: Icons.fitness_center,
              color: Colors.red,
              onTap: () => _navigateToTimer(context, 'TABATA'),
            ),
            
            const SizedBox(height: 20),
            
            // Botón Countdown
            _buildTimerButton(
              context,
              title: 'COUNTDOWN',
              subtitle: 'Temporizador simple',
              icon: Icons.timer,
              color: Colors.green,
              onTap: () => _navigateToTimer(context, 'COUNTDOWN'),
            ),
            
            const SizedBox(height: 40),
            
            // Firma del desarrollador
            const Text(
              '🦊 By Alexander Herrera',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para crear botones consistentes
  Widget _buildTimerButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
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
          elevation: 5,
        ),
        child: Row(
          children: [
            Icon(icon, size: 40),
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
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            // Botón de configuración
            IconButton(
              onPressed: () => _openConfigScreen(context, title),
              icon: const Icon(Icons.settings),
              color: Colors.white70,
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
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
