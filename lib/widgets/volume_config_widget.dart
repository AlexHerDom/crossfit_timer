import 'package:flutter/material.dart';
import '../services/audio_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🎚️ WIDGET DE CONFIGURACIÓN DE VOLUMEN PARA CROSSFIT
// ═══════════════════════════════════════════════════════════════════════════════

class VolumeConfigWidget extends StatefulWidget {
  final String title;
  final String subtitle;

  const VolumeConfigWidget({
    super.key,
    this.title = 'Volumen de Audio',
    this.subtitle = 'Ajusta el volumen para entrenamientos al aire libre',
  });

  @override
  State<VolumeConfigWidget> createState() => _VolumeConfigWidgetState();
}

class _VolumeConfigWidgetState extends State<VolumeConfigWidget> {
  final AudioService _audioService = AudioService();
  double _currentVolume = 1.0;
  bool _isTestingVolume = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentVolume();
  }

  void _loadCurrentVolume() {
    setState(() {
      _currentVolume = _audioService.volume;
    });
  }

  Future<void> _updateVolume(double newVolume) async {
    setState(() {
      _currentVolume = newVolume;
    });

    await _audioService.setVolume(newVolume);
    print("🔊 Volumen actualizado a: $newVolume");
  }

  Future<void> _testVolume() async {
    if (_isTestingVolume) return;

    setState(() {
      _isTestingVolume = true;
    });

    try {
      await _audioService.testVolume();
    } catch (e) {
      print("❌ Error probando volumen: $e");
    }

    // Esperar un poco antes de permitir otra prueba
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isTestingVolume = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎚️ TÍTULO Y DESCRIPCIÓN
            Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // 🎚️ SLIDER DE VOLUMEN
            Row(
              children: [
                Icon(Icons.volume_down, color: Colors.grey[600]),
                Expanded(
                  child: Slider(
                    value: _currentVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_currentVolume * 100).round()}%',
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: _updateVolume,
                  ),
                ),
                Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
              ],
            ),

            // 📊 INFORMACIÓN DEL VOLUMEN ACTUAL
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Volumen: ${(_currentVolume * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🧪 BOTÓN DE PRUEBA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTestingVolume ? null : _testVolume,
                icon: _isTestingVolume
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.play_circle_filled),
                label: Text(
                  _isTestingVolume ? 'Reproduciendo...' : 'Probar Volumen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // 💡 CONSEJOS PARA USO AL AIRE LIBRE
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consejos para entrenar al aire libre:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Usa 80-100% para entrenamientos exteriores\n'
                          '• Conecta altavoces Bluetooth para más volumen\n'
                          '• El teléfono vibra como respaldo adicional',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
