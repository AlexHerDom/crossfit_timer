# 🧪 TESTING MANUAL EXHAUSTIVO - CROSSFIT TIMER
## Guía paso a paso para verificar todas las funcionalidades

---

## 📱 **INSTRUCCIONES GENERALES**
1. **Dispositivo:** Usar dispositivo físico (preferible) o emulador
2. **Método:** Ejecutar cada test marcando ✅ o ❌
3. **Tiempo estimado:** 45-60 minutos para testing completo
4. **Criterio:** Si 85%+ tests pasan → App lista para tiendas

---

## 🚀 **FASE 1: TESTING BÁSICO DE NAVEGACIÓN**

### 1.1 Inicio de la App
- [ ] **T001** - App abre correctamente
- [ ] **T002** - Logo/icono visible 
- [ ] **T003** - Títulos en idioma correcto
- [ ] **T004** - 4 opciones de timer visibles (AMRAP, EMOM, TABATA, COUNTDOWN)

### 1.2 AppBar y Navegación
- [ ] **T005** - Botón "Historial" funciona
- [ ] **T006** - Botón "Configuraciones" funciona  
- [ ] **T007** - Botón "Acerca de" funciona
- [ ] **T008** - Navegación hacia atrás funciona

---

## ⏱️ **FASE 2: TESTING INDIVIDUAL DE TIMERS**

### 2.1 AMRAP Timer
- [ ] **T009** - Botón AMRAP abre configuración
- [ ] **T010** - Configurar 5 minutos → Guardar
- [ ] **T011** - Timer muestra preparación (3 segundos default)
- [ ] **T012** - Timer inicia cuenta correctamente  
- [ ] **T013** - Botón PAUSA funciona
- [ ] **T014** - Botón RESUME funciona
- [ ] **T015** - Botón STOP funciona
- [ ] **T016** - Timer completa y muestra diálogo final
- [ ] **T017** - Sonidos reproducen correctamente

### 2.2 EMOM Timer  
- [ ] **T018** - Botón EMOM abre configuración
- [ ] **T019** - Configurar 3 rondas de 1 minuto → Guardar
- [ ] **T020** - Timer muestra preparación
- [ ] **T021** - Timer alterna minutos correctamente
- [ ] **T022** - Contador de rondas funciona (1/3, 2/3, 3/3)
- [ ] **T023** - Pausa/Resume funciona
- [ ] **T024** - Timer completa todas las rondas
- [ ] **T025** - TTS anuncia "Minute complete"

### 2.3 TABATA Timer ⭐ (TESTING CRÍTICO)
- [ ] **T026** - Botón TABATA abre configuración  
- [ ] **T027** - **CRÍTICO:** Subtítulo dinámico en home (ej: "20s trabajo / 10s descanso")
- [ ] **T028** - Cambiar trabajo a 15s, descanso a 5s → Guardar
- [ ] **T029** - **CRÍTICO:** Volver a home → verificar subtítulo cambió ("15s trabajo / 5s descanso")  
- [ ] **T030** - Iniciar timer → 8 rondas automáticas
- [ ] **T031** - Alternancia trabajo/descanso correcta
- [ ] **T032** - Contador de rondas funciona (1/8, 2/8... 8/8)
- [ ] **T033** - Sonidos diferentes para trabajo/descanso
- [ ] **T034** - Pausa/Resume funciona
- [ ] **T035** - Timer completa 8 rondas

### 2.4 COUNTDOWN Timer
- [ ] **T036** - Botón COUNTDOWN abre configuración
- [ ] **T037** - Configurar 2 min 30 seg → Guardar  
- [ ] **T038** - Timer cuenta regresiva correctamente
- [ ] **T039** - Muestra formato MM:SS correctamente
- [ ] **T040** - Pausa/Resume funciona
- [ ] **T041** - Timer llega a 00:00 y completa

---

## 🔧 **FASE 3: TESTING DE CONFIGURACIONES**

### 3.1 Configuraciones de Audio
- [ ] **T042** - Desactivar sonidos → No hay beeps en timer
- [ ] **T043** - Activar sonidos → Beeps funcionan
- [ ] **T044** - Cambiar volumen → Se refleja en beeps
- [ ] **T045** - TTS en español funciona
- [ ] **T046** - TTS en inglés funciona

### 3.2 Configuraciones de Pantalla
- [ ] **T047** - Activar "Mantener pantalla activa" → Pantalla no se apaga
- [ ] **T048** - Desactivar → Pantalla se apaga normalmente
- [ ] **T049** - Vibración activada → Vibra durante timer
- [ ] **T050** - Vibración desactivada → No vibra

### 3.3 Configuraciones de Idioma ⭐ (TESTING CRÍTICO)
- [ ] **T051** - Cambiar a inglés → Toda la UI cambia
- [ ] **T052** - **CRÍTICO:** Subtítulos dinámicos cambian idioma
- [ ] **T053** - TTS cambia a inglés
- [ ] **T054** - Cambiar de vuelta a español → Todo vuelve a español
- [ ] **T055** - **CRÍTICO:** Subtítulo Tabata se actualiza en español

---

## 🎨 **FASE 4: TESTING DE TEMAS Y UI**

### 4.1 Temas de Color
- [ ] **T056** - Cambiar tema azul → UI cambia
- [ ] **T057** - Cambiar tema verde → UI cambia  
- [ ] **T058** - Cambiar tema rojo → UI cambia
- [ ] **T059** - Tema se mantiene en navigation
- [ ] **T060** - Tema se mantiene al reiniciar app

### 4.2 Responsividad
- [ ] **T061** - Rotar dispositivo → UI se adapta
- [ ] **T062** - Pantalla completa en timer funciona
- [ ] **T063** - Salir de pantalla completa funciona
- [ ] **T064** - Diferentes tamaños de texto legibles

---

## 📊 **FASE 5: TESTING DE HISTORIAL**

### 5.1 Guardado de Entrenamientos
- [ ] **T065** - Completar AMRAP → Se guarda en historial
- [ ] **T066** - Completar EMOM → Se guarda en historial
- [ ] **T067** - Completar TABATA → Se guarda en historial
- [ ] **T068** - Completar COUNTDOWN → Se guarda en historial

### 5.2 Visualización de Historial  
- [ ] **T069** - Historial muestra entrenamientos recientes
- [ ] **T070** - Detalles de entrenamiento son correctos
- [ ] **T071** - Fecha y hora correctas
- [ ] **T072** - Filtros por tipo funcionan

---

## 📤 **FASE 6: TESTING DE FUNCIONES AVANZADAS**

### 6.1 Compartir Entrenamientos
- [ ] **T073** - Botón compartir en diálogo final funciona
- [ ] **T074** - Mensaje de compartir contiene datos correctos
- [ ] **T075** - Compartir desde historial funciona

### 6.2 Restaurar Configuraciones
- [ ] **T076** - "Restaurar valores por defecto" funciona
- [ ] **T077** - Confirmación de restauración aparece
- [ ] **T078** - Valores se restauran correctamente

---

## 🚨 **FASE 7: TESTING DE CASOS EXTREMOS**

### 7.1 Interrupciones
- [ ] **T079** - Llamada telefónica durante timer → Timer pausa
- [ ] **T080** - Volver a app → Timer resume correctamente
- [ ] **T081** - Minimizar app → Timer continúa en background
- [ ] **T082** - Notificación → No interfiere con timer

### 7.2 Valores Extremos
- [ ] **T083** - Timer de 1 segundo funciona
- [ ] **T084** - Timer de 60 minutos funciona  
- [ ] **T085** - 50 rondas EMOM funciona
- [ ] **T086** - Valores mínimos/máximos aceptados

---

## ❌ **FASE 8: TESTING DE ERRORES**

### 8.1 Manejo de Errores
- [ ] **T087** - Campos vacíos en configuración → Error claro
- [ ] **T088** - Valores inválidos → Error claro
- [ ] **T089** - Sin conexión → App funciona offline
- [ ] **T090** - Batería baja → App funciona

### 8.2 Recuperación de Errores
- [ ] **T091** - Error durante timer → App no se cierra
- [ ] **T092** - Memoria baja → App responde
- [ ] **T093** - Reinicio durante timer → Estado se recupera

---

## 🏁 **FASE 9: TESTING FINAL**

### 9.1 Testing de Performance
- [ ] **T094** - App inicia en menos de 3 segundos
- [ ] **T095** - Navegación es fluida (sin lag)
- [ ] **T096** - Timers son precisos (usar cronómetro externo)
- [ ] **T097** - Uso de batería es reasonable

### 9.2 Testing de Calidad Final
- [ ] **T098** - No hay crashes durante uso normal
- [ ] **T099** - Todos los textos son correctos (sin typos)
- [ ] **T100** - ⭐ **CRÍTICO:** Subtítulo dinámico Tabata siempre actualizado

---

## 📈 **RESULTADO FINAL**

### Resumen de Testing:
- **Tests Pasados:** ___/100
- **Tests Fallidos:** ___/100  
- **Porcentaje de Éxito:** ___%

### Criterios de Aprobación:
- ✅ **85-100%:** App lista para tiendas
- ⚠️ **70-84%:** Necesita mejoras menores
- ❌ **<70%:** Requiere correcciones importantes

### Issues Críticos que DEBEN funcionar:
1. **T027 & T029:** Subtítulo dinámico de Tabata
2. **T052 & T055:** Cambios de idioma en subtítulos  
3. **T100:** Consistencia del subtítulo dinámico

---

**📝 Notas adicionales:**
- Documentar cualquier bug encontrado
- Tomar screenshots de errores
- Probar en diferentes dispositivos si es posible
- Verificar que la funcionalidad principal (timers) funcione perfectamente
