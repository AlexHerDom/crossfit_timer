import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../language_provider.dart';
import '../localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _keepScreenOn = true;
  double _beepVolume = 1.0;
  int _preparationTime = 10;
  String _selectedTheme = 'Orange';
  String _selectedLanguage = 'es'; // Default to Spanish

  final List<String> _themes = ['Orange', 'Blue', 'Red', 'Green', 'Purple'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _keepScreenOn = prefs.getBool('keep_screen_on') ?? true;
      _beepVolume = prefs.getDouble('beep_volume') ?? 1.0;
      _preparationTime = prefs.getInt('preparation_time') ?? 10;
      _selectedTheme = prefs.getString('selected_theme') ?? 'Orange';
      // El idioma ahora se maneja a través del LanguageProvider
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('keep_screen_on', _keepScreenOn);
    await prefs.setDouble('beep_volume', _beepVolume);
    await prefs.setInt('preparation_time', _preparationTime);
    await prefs.setString('selected_theme', _selectedTheme);
    await prefs.setString('language_code', _selectedLanguage);
  }

  Color _getThemeColor() {
    switch (_selectedTheme) {
      case 'Blue':
        return Colors.blue;
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      case 'Purple':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuraciones',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.primaryColor.withOpacity(0.8),
                themeProvider.primaryColor,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Configuraciones guardadas'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Guardar configuraciones',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de Audio
          _buildSectionHeader('🔊 Audio'),
          _buildSwitchTile(
            'Sonidos habilitados',
            'Reproducir beeps durante los entrenamientos',
            _soundEnabled,
            (value) => setState(() => _soundEnabled = value),
            Icons.volume_up,
          ),
          if (_soundEnabled)
            _buildSliderTile(
              'Volumen de beeps',
              'Ajusta el volumen de los sonidos',
              _beepVolume,
              0.0,
              1.0,
              (value) => setState(() => _beepVolume = value),
              Icons.volume_up,
            ),

          const SizedBox(height: 20),

          // Sección de Feedback
          _buildSectionHeader('📳 Feedback'),
          _buildSwitchTile(
            'Vibración habilitada',
            'Vibrar durante los entrenamientos',
            _vibrationEnabled,
            (value) => setState(() => _vibrationEnabled = value),
            Icons.vibration,
          ),

          const SizedBox(height: 20),

          // Sección de Pantalla
          _buildSectionHeader('📱 Pantalla'),
          _buildSwitchTile(
            'Mantener pantalla activa',
            'La pantalla no se apagará durante entrenamientos',
            _keepScreenOn,
            (value) => setState(() => _keepScreenOn = value),
            Icons.screen_lock_portrait,
          ),

          const SizedBox(height: 20),

          // Sección de Entrenamiento
          _buildSectionHeader('⏱️ Entrenamiento'),
          _buildSliderTile(
            'Tiempo de preparación',
            'Segundos antes de iniciar el entrenamiento',
            _preparationTime.toDouble(),
            5.0,
            30.0,
            (value) => setState(() => _preparationTime = value.round()),
            Icons.timer,
            suffix: ' seg',
          ),

          const SizedBox(height: 20),

          // Sección de Tema
          _buildSectionHeader('🎨 Apariencia'),
          _buildThemeSelector(themeProvider),

          const SizedBox(height: 20),

          // Sección de Idioma
          _buildLanguageSelector(),

          const SizedBox(height: 30),

          // Botón para restaurar valores por defecto
          Center(
            child: ElevatedButton.icon(
              onPressed: _resetToDefaults,
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar valores por defecto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Información de la app
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _getThemeColor(),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: _getThemeColor()),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _getThemeColor(),
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    IconData icon, {
    String suffix = '',
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _getThemeColor()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${value.round()}$suffix',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getThemeColor(),
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
              activeColor: _getThemeColor(),
              inactiveColor: _getThemeColor().withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: _getThemeColor()),
                const SizedBox(width: 12),
                const Text(
                  'Tema de color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: _themes.map((theme) {
                Color themeColor = _getThemeColorByName(theme);
                bool isSelected = theme == _selectedTheme;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTheme = theme;
                    });
                    themeProvider.setTheme(theme);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: themeColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getThemeColorByName(String themeName) {
    switch (themeName) {
      case 'Blue':
        return Colors.blue;
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      case 'Purple':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  Widget _buildLanguageSelector() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.language, color: _getThemeColor()),
                  const SizedBox(width: 12),
                  const Text(
                    'Idioma / Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: languageProvider.currentLanguage == 'es'
                              ? _getThemeColor()
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: languageProvider.currentLanguage == 'es'
                            ? _getThemeColor().withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: InkWell(
                        onTap: () {
                          languageProvider.changeLanguage('es');
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text('🇪🇸', style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 4),
                              Text(
                                'Español',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      languageProvider.currentLanguage == 'es'
                                      ? _getThemeColor()
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: languageProvider.currentLanguage == 'en'
                              ? _getThemeColor()
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: languageProvider.currentLanguage == 'en'
                            ? _getThemeColor().withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: InkWell(
                        onTap: () {
                          languageProvider.changeLanguage('en');
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text('🇺🇸', style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 4),
                              Text(
                                'English',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      languageProvider.currentLanguage == 'en'
                                      ? _getThemeColor()
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restaurar valores por defecto'),
          content: const Text(
            '¿Estás seguro de que quieres restaurar todas las configuraciones a sus valores por defecto?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _soundEnabled = true;
                  _vibrationEnabled = true;
                  _keepScreenOn = true;
                  _beepVolume = 1.0;
                  _preparationTime = 10;
                  _selectedTheme = 'Orange';
                  _selectedLanguage = 'es';
                });

                await _saveSettings();

                final themeProvider = Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                );
                themeProvider.setTheme('Orange');

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Configuraciones restauradas'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getThemeColor(),
                foregroundColor: Colors.white,
              ),
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: _getThemeColor()),
                const SizedBox(width: 12),
                const Text(
                  'Información de la App',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Versión: 1.0.0'),
            const Text('Desarrollador: CrossFit Timer Team'),
            const SizedBox(height: 8),
            const Text(
              'Esta aplicación está diseñada para ayudarte con tus entrenamientos de CrossFit y fitness.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
