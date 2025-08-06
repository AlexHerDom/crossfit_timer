# 🧪 PLAN DE TESTING EXHAUSTIVO - CrossFit Timer App

## 1. 🔧 **Bug del Subtítulo Dinámico de Tabata**

### ✅ **Pasos para probar:**
1. Abrir la app
2. Verificar que el subtítulo de Tabata muestre "20s trabajo / 10s descanso" por defecto
3. Ir a Configurar Tabata
4. Cambiar Work Time a 30s y Rest Time a 15s
5. Guardar configuración
6. Regresar al menú principal
7. **Verificar que el subtítulo ahora muestre "30s trabajo / 15s descanso"**

### ✅ **Casos extremos:**
- Configurar con 5s trabajo / 5s descanso
- Configurar con 60s trabajo / 30s descanso
- Cambiar idioma y verificar que el texto cambie ("work/rest" vs "trabajo/descanso")

---

## 2. 🧪 **Testing Exhaustivo de Todas las Funciones**

### **A. TIMERS - Funcionalidad Core**

#### **AMRAP (As Many Rounds As Possible)**
- [ ] Configurar 5 minutos
- [ ] Configurar 10 minutos  
- [ ] Configurar 20 minutos
- [ ] Iniciar timer y verificar cuenta regresiva
- [ ] Verificar sonidos en cada minuto
- [ ] Verificar TTS "Mitad del tiempo" a los 2.5min (en 5min)
- [ ] Verificar TTS "Diez segundos restantes"
- [ ] Verificar TTS "Cinco segundos" 
- [ ] Verificar TTS "Tiempo"
- [ ] Probar Pausa/Resume
- [ ] Probar Stop/Reset
- [ ] Probar en español e inglés

#### **EMOM (Every Minute On the Minute)**
- [ ] Configurar 5 rondas de 1 minuto
- [ ] Configurar 10 rondas de 1 minuto
- [ ] Iniciar y verificar beep cada minuto
- [ ] Verificar contador de rondas
- [ ] Verificar TTS en cada ronda
- [ ] Probar Pausa/Resume
- [ ] Probar Stop/Reset
- [ ] Probar en español e inglés

#### **TABATA**
- [ ] Configurar 20s trabajo / 10s descanso (default)
- [ ] Configurar 30s trabajo / 15s descanso (custom)
- [ ] Configurar 8 rondas
- [ ] Verificar alternancia trabajo/descanso
- [ ] Verificar sonidos en transiciones
- [ ] Verificar TTS en cada cambio
- [ ] Verificar contador de rondas
- [ ] Probar Pausa/Resume
- [ ] Probar Stop/Reset
- [ ] **Verificar que el subtítulo en home sea dinámico**
- [ ] Probar en español e inglés

#### **COUNTDOWN**
- [ ] Configurar 5 minutos
- [ ] Configurar 10 minutos
- [ ] Configurar 30 segundos
- [ ] Verificar cuenta regresiva
- [ ] Verificar TTS "Mitad del tiempo"
- [ ] Verificar TTS "Diez segundos restantes"
- [ ] Verificar TTS "Cinco segundos"
- [ ] Verificar TTS "Tiempo"
- [ ] Probar Pausa/Resume
- [ ] Probar Stop/Reset
- [ ] Probar en español e inglés

### **B. CONFIGURACIONES**

#### **Audio**
- [ ] Activar/Desactivar sonidos
- [ ] Ajustar volumen de beeps (0.0 a 1.0)
- [ ] Verificar que los cambios se apliquen inmediatamente

#### **Feedback**  
- [ ] Activar/Desactivar vibración
- [ ] Verificar vibración durante timers

#### **Pantalla**
- [ ] Activar/Desactivar "Mantener pantalla activa"
- [ ] Verificar que la pantalla no se apague durante workouts

#### **Entrenamiento**
- [ ] Cambiar tiempo de preparación (5-30 segundos)
- [ ] Verificar que se aplique en todos los timers

#### **Apariencia**
- [ ] Cambiar tema: Orange, Blue, Red, Green, Purple
- [ ] Verificar que el color se aplique en toda la app

#### **Idioma**
- [ ] Cambiar de Español a Inglés
- [ ] Verificar que TODOS los textos cambien
- [ ] Verificar TTS en nuevo idioma
- [ ] Cambiar de Inglés a Español
- [ ] Verificar persistencia al cerrar/abrir app

### **C. NAVEGACIÓN Y UX**

#### **Menú Principal**
- [ ] Verificar animaciones de las cards
- [ ] Probar navegación a cada timer
- [ ] Probar navegación a configuraciones
- [ ] Probar navegación a historial
- [ ] Verificar menú "About"

#### **Pantalla de Timer**
- [ ] Verificar modo pantalla completa
- [ ] Verificar botón salir
- [ ] Verificar que regrese al menú principal

#### **Configuración de cada Timer**
- [ ] Validar campos requeridos
- [ ] Probar números inválidos
- [ ] Verificar guardado de configuración
- [ ] Verificar que la configuración persista

### **D. CASOS EXTREMOS Y ERRORES**

#### **Performance**
- [ ] Timer de 60 minutos (máximo)
- [ ] Timer de 1 segundo (mínimo)
- [ ] Cambio rápido entre timers
- [ ] Rotación de pantalla durante timer
- [ ] Llamada telefónica durante timer
- [ ] App en background/foreground

#### **Configuraciones Extremas**
- [ ] Volumen al 0%
- [ ] Volumen al 100%
- [ ] Tiempo de preparación 5 segundos
- [ ] Tiempo de preparación 30 segundos
- [ ] Tabata 5s trabajo / 5s descanso
- [ ] EMOM 30 rondas

#### **Estados de Error**
- [ ] Sin sonido disponible
- [ ] Sin vibración disponible  
- [ ] Sin TTS disponible
- [ ] Poco espacio de almacenamiento
- [ ] App sin permisos

### **E. PERSISTENCIA DE DATOS**

#### **SharedPreferences**
- [ ] Cerrar app y verificar configuraciones guardadas
- [ ] Reinstalar app y verificar valores por defecto
- [ ] Restaurar valores por defecto
- [ ] Configuraciones personalizadas persisten

---

## 3. 📝 **CHECKLIST DE TESTING**

### **Configuración de Test**
- [ ] Dispositivo físico Android
- [ ] Dispositivo físico iOS (si disponible)
- [ ] Emulador Android diferentes versiones
- [ ] Diferentes tamaños de pantalla

### **Funcionalidad Crítica**
- [ ] Todos los timers funcionan correctamente
- [ ] TTS funciona en ambos idiomas
- [ ] Sonidos y vibración funcionan
- [ ] Configuraciones se guardan y cargan
- [ ] Cambio de idioma completo
- [ ] **Subtítulo dinámico de Tabata funciona**

### **UX/UI**
- [ ] Navegación fluida
- [ ] Animaciones suaves
- [ ] Textos legibles
- [ ] Colores consistentes
- [ ] Responsive design

### **Edge Cases**
- [ ] No crashes en casos extremos
- [ ] Manejo correcto de errores
- [ ] Performance aceptable
- [ ] Batería no se agota rápido

---

## 4. 🐛 **BUGS ENCONTRADOS**

### **Críticos (Deben arreglarse antes de release)**
- [ ] 

### **Menores (Pueden arreglarse después)**
- [ ] 

### **Mejoras (Nice to have)**
- [ ] 

---

## 5. ✅ **TESTING COMPLETADO**

Fecha: ___________
Testeado por: ___________
Dispositivo: ___________
Versión: 1.0.0

**Estado:** [ ] ✅ APROBADO PARA RELEASE  [ ] ❌ NECESITA CORRECCIONES
