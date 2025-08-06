import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class ConfigScreen extends StatefulWidget {
  final String timerType;

  const ConfigScreen({super.key, required this.timerType});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  // Controladores para los campos de texto
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();
  final _roundsController = TextEditingController();
  final _workSecondsController = TextEditingController();
  final _restSecondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultValues();
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _roundsController.dispose();
    _workSecondsController.dispose();
    _restSecondsController.dispose();
    super.dispose();
  }

  void _loadDefaultValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.timerType) {
      case 'AMRAP':
        _minutesController.text = (prefs.getInt('amrap_minutes') ?? 5)
            .toString();
        _secondsController.text = (prefs.getInt('amrap_seconds') ?? 0)
            .toString();
        break;
      case 'EMOM':
        _minutesController.text = (prefs.getInt('emom_minutes') ?? 1)
            .toString();
        _secondsController.text = (prefs.getInt('emom_seconds') ?? 0)
            .toString();
        _roundsController.text = (prefs.getInt('emom_rounds') ?? 10).toString();
        break;
      case 'TABATA':
        _workSecondsController.text = (prefs.getInt('tabata_work') ?? 20)
            .toString();
        _restSecondsController.text = (prefs.getInt('tabata_rest') ?? 10)
            .toString();
        _roundsController.text = (prefs.getInt('tabata_rounds') ?? 8)
            .toString();
        break;
      case 'COUNTDOWN':
        _minutesController.text = (prefs.getInt('countdown_minutes') ?? 3)
            .toString();
        _secondsController.text = (prefs.getInt('countdown_seconds') ?? 0)
            .toString();
        break;
    }
  }

  void _saveConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.timerType) {
      case 'AMRAP':
        await prefs.setInt('amrap_minutes', int.parse(_minutesController.text));
        await prefs.setInt('amrap_seconds', int.parse(_secondsController.text));
        break;
      case 'EMOM':
        await prefs.setInt('emom_minutes', int.parse(_minutesController.text));
        await prefs.setInt('emom_seconds', int.parse(_secondsController.text));
        await prefs.setInt('emom_rounds', int.parse(_roundsController.text));
        break;
      case 'TABATA':
        await prefs.setInt(
          'tabata_work',
          int.parse(_workSecondsController.text),
        );
        await prefs.setInt(
          'tabata_rest',
          int.parse(_restSecondsController.text),
        );
        await prefs.setInt('tabata_rounds', int.parse(_roundsController.text));
        break;
      case 'COUNTDOWN':
        await prefs.setInt(
          'countdown_minutes',
          int.parse(_minutesController.text),
        );
        await prefs.setInt(
          'countdown_seconds',
          int.parse(_secondsController.text),
        );
        break;
    }

    Navigator.pop(context, true); // Regresar con resultado positivo
  }

  Widget _buildTimeField(
    String label,
    TextEditingController controller, {
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixText: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es requerido';
            }
            final number = int.tryParse(value);
            if (number == null || number < 0) {
              return 'Ingresa un número válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar ${widget.timerType}'),
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personaliza tu entrenamiento ${widget.timerType}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Configuración específica para cada tipo
              if (widget.timerType == 'AMRAP') ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        'Minutos',
                        _minutesController,
                        suffix: 'min',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeField(
                        'Segundos',
                        _secondsController,
                        suffix: 'seg',
                      ),
                    ),
                  ],
                ),
              ],

              if (widget.timerType == 'EMOM') ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        'Minutos por ronda',
                        _minutesController,
                        suffix: 'min',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeField(
                        'Segundos extra',
                        _secondsController,
                        suffix: 'seg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTimeField(
                  'Número de rondas',
                  _roundsController,
                  suffix: 'rondas',
                ),
              ],

              if (widget.timerType == 'TABATA') ...[
                _buildTimeField(
                  'Tiempo de trabajo',
                  _workSecondsController,
                  suffix: 'segundos',
                ),
                const SizedBox(height: 20),
                _buildTimeField(
                  'Tiempo de descanso',
                  _restSecondsController,
                  suffix: 'segundos',
                ),
                const SizedBox(height: 20),
                _buildTimeField(
                  'Número de rondas',
                  _roundsController,
                  suffix: 'rondas',
                ),
              ],

              if (widget.timerType == 'COUNTDOWN') ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        'Minutos',
                        _minutesController,
                        suffix: 'min',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeField(
                        'Segundos',
                        _secondsController,
                        suffix: 'seg',
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // Botón para guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Guardar Configuración',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
