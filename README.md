# 🏋️‍♀️ CrossFit Timer App

Una aplicación de temporizador diseñada específicamente para entrenamientos de CrossFit, desarrollada en Flutter como proyecto de aprendizaje.

## ✨ Características

### Tipos de Entrenamiento Soportados

- **AMRAP** (As Many Rounds As Possible): Realiza tantas rondas como puedas en un tiempo determinado
- **EMOM** (Every Minute On the Minute): Ejecuta un ejercicio específico al inicio de cada minuto
- **TABATA**: Protocolo de 20 segundos de trabajo y 10 segundos de descanso
- **COUNTDOWN**: Temporizador simple de cuenta regresiva

### Funcionalidades

- ⏯️ Controles de Play/Pause/Reset
- 🎨 Interfaz intuitiva con códigos de colores
- 🔄 Seguimiento de rondas automático
- 🏆 Notificaciones de finalización
- 📱 Diseño responsivo
- ⚙️ **Configuración personalizada de tiempos**
- 📳 **Vibración y alertas sonoras**
- 📊 **Historial de entrenamientos**
- 🖥️ **Modo pantalla completa**
- 🌓 **Temas personalizables (claro/oscuro)**

## 🚀 Cómo ejecutar

```bash
# Clonar el repositorio
git clone [tu-repo]

# Navegar al directorio
cd crossfit_timer

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## 🧠 Conceptos de Flutter aprendidos

- **StatefulWidget vs StatelessWidget**
- **State Management básico**
- **Navigation entre pantallas**
- **Timer y manejo de tiempo**
- **Layouts con Column, Row, Container**
- **Material Design y theming**
- **Widgets reutilizables**

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada y manejo de temas
└── screens/
    ├── home_screen.dart         # Pantalla principal con opciones
    ├── timer_screen.dart        # Pantalla del temporizador activo
    ├── config_screen.dart       # Configuración personalizada de tiempos
    └── history_screen.dart      # Historial de entrenamientos
```

## 🎯 Próximas mejoras

- [x] Configuración personalizada de tiempos
- [x] Sonidos y vibración 
- [x] Historial de entrenamientos
- [x] Modo de pantalla completa
- [x] Temas personalizables
- [ ] Archivos de audio personalizados
- [ ] Estadísticas detalladas
- [ ] Exportar historial
- [ ] Widgets de escritorio
- [ ] Notificaciones push

---

*Proyecto desarrollado como introducción a Flutter y desarrollo móvil.*
