import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WorkoutHistory> _workoutHistory = [];

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

  void _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('workout_history');
    setState(() {
      _workoutHistory.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial borrado')),
    );
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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Entrenamientos'),
        centerTitle: true,
        actions: [
          if (_workoutHistory.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Borrar historial',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _workoutHistory.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No hay entrenamientos registrados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Completa tu primer entrenamiento para verlo aquí',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTypeColor(workout.type),
                            child: Text(
                              workout.type[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            workout.type,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Duración: ${_formatDuration(workout.duration)}'),
                              if (workout.rounds > 1)
                                Text('Rondas: ${workout.rounds}'),
                              Text(
                                _formatDate(workout.date),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.fitness_center,
                            color: _getTypeColor(workout.type),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Firma del desarrollador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '🦊 By Alexander Herrera',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
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
