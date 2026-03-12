import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WorkoutHistory> _workoutHistory = [];
  final String _selectedFilter = 'Todos';
  // final List<String> _filters = [
  //   'Todos',
  //   'AMRAP',
  //   'EMOM',
  //   'TABATA',
  //   'COUNTDOWN',
  // ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyStrings = prefs.getStringList('workout_history') ?? [];

    setState(() {
      _workoutHistory = historyStrings.map((historyString) {
        List<String> parts = historyString.split('|');
        return WorkoutHistory(
          type: parts[0],
          duration: int.parse(parts[1]),
          rounds: int.parse(parts[2]),
          date: DateTime.parse(parts[3]),
        );
      }).toList();

      // Ordenar por fecha más reciente
      _workoutHistory.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // List<WorkoutHistory> get _filteredWorkouts {
  //   if (_selectedFilter == 'Todos') {
  //     return _workoutHistory;
  //   }
  //   return _workoutHistory.where((w) => w.type == _selectedFilter).toList();
  // }

  void _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('workout_history');
    setState(() {
      _workoutHistory.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Historial borrado')));
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'AMRAP':
        return Colors.orange;
      case 'EMOM':
        return Colors.blue;
      case 'TABATA':
        return Colors.red;
      case 'COUNTDOWN':
        return Colors.green;
      case 'RUNNING':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'AMRAP':
        return Icons.repeat;
      case 'EMOM':
        return Icons.timer;
      case 'TABATA':
        return Icons.flash_on;
      case 'COUNTDOWN':
        return Icons.hourglass_bottom;
      case 'RUNNING':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildHistoryItem(WorkoutHistory workout) {
    final color = _getTypeColor(workout.type);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.2),
              ],
            ),
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                _getTypeIcon(workout.type),
                color: Colors.black87,
              ),
            ),
            title: Text(
              workout.type,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duración: ${_formatDuration(workout.duration)}',
                  style: TextStyle(color: Colors.black.withOpacity(0.7)),
                ),
                if (workout.rounds > 1)
                  Text(
                    'Rondas: ${workout.rounds}',
                    style: TextStyle(color: Colors.black.withOpacity(0.7)),
                  ),
                Text(
                  _formatDate(workout.date),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.fitness_center,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Historial de Entrenamientos',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_workoutHistory.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Borrar historial',
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0F7FA), // Light Cyan
                  Color(0xFFFCE4EC), // Light Pink
                  Color(0xFFE8EAF6), // Light Indigo/Lavender
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _workoutHistory.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 80, color: Colors.black38),
                              SizedBox(height: 20),
                              Text(
                                'No hay entrenamientos registrados',
                                style: TextStyle(fontSize: 18, color: Colors.black54),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Completa tu primer entrenamiento para verlo aquí',
                                style: TextStyle(fontSize: 14, color: Colors.black45),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _workoutHistory.length,
                                              itemBuilder: (context, index) {
                                                final workout = _workoutHistory[index];
                                                return _buildHistoryItem(workout);
                                              },                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutHistory {
  final String type;
  final int duration; // en segundos
  final int rounds;
  final DateTime date;

  WorkoutHistory({
    required this.type,
    required this.duration,
    required this.rounds,
    required this.date,
  });
}
