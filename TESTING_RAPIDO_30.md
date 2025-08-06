# 🚀 TESTING MANUAL RÁPIDO - 30 TESTS CRÍTICOS

## ⏱️ **TIEMPO ESTIMADO: 15-20 MINUTOS**

### 🎯 **OBJETIVO:** Verificar funcionalidad core antes de tiendas

---

## 📱 **TESTS CRÍTICOS OBLIGATORIOS**

### **1. HOME SCREEN (5 tests)**
- [ ] **T1** - App abre correctamente
- [ ] **T2** - 4 timers visibles (AMRAP, EMOM, TABATA, COUNTDOWN)  
- [ ] **T3** - ⭐ **CRÍTICO:** Subtítulo Tabata muestra configuración actual
- [ ] **T4** - Botones Historial/Settings funcionan
- [ ] **T5** - Cambio de idioma funciona

### **2. TABATA TIMER (10 tests) ⭐ MÁS IMPORTANTE**
- [ ] **T6** - Configurar trabajo 15s, descanso 5s → Guardar
- [ ] **T7** - ⭐ **SÚPER CRÍTICO:** Volver a home → subtítulo = "15s trabajo / 5s descanso"
- [ ] **T8** - Iniciar timer → Preparación 3s
- [ ] **T9** - Timer alterna 15s trabajo / 5s descanso
- [ ] **T10** - Contador rondas funciona (1/8, 2/8... 8/8)
- [ ] **T11** - Sonidos diferentes trabajo/descanso
- [ ] **T12** - Pausa/Resume funciona
- [ ] **T13** - Completar 8 rondas → Diálogo final
- [ ] **T14** - Cambiar idioma → ⭐ **CRÍTICO:** Subtítulo cambia idioma
- [ ] **T15** - Volver a español → Subtítulo en español

### **3. OTROS TIMERS (9 tests)**

**AMRAP:**
- [ ] **T16** - Configurar 3 min → Timer cuenta correctamente
- [ ] **T17** - Pausa/Resume funciona
- [ ] **T18** - Completa y muestra diálogo

**EMOM:**
- [ ] **T19** - Configurar 3 rondas 1 min → Funciona
- [ ] **T20** - Contador de rondas correcto  
- [ ] **T21** - Completa todas las rondas

**COUNTDOWN:**
- [ ] **T22** - Configurar 2:30 → Cuenta regresiva correcta
- [ ] **T23** - Formato MM:SS correcto
- [ ] **T24** - Llega a 00:00 y completa

### **4. CONFIGURACIONES (6 tests)**
- [ ] **T25** - Sonidos on/off funciona
- [ ] **T26** - Vibración on/off funciona
- [ ] **T27** - TTS español/inglés funciona
- [ ] **T28** - Mantener pantalla activa funciona
- [ ] **T29** - Cambio de tema funciona
- [ ] **T30** - Restaurar defaults funciona

---

## 🎯 **CRITERIO DE APROBACIÓN:**

- **✅ 28-30 tests (93-100%):** App LISTA para tiendas ✅
- **✅ 25-27 tests (83-90%):** App lista con mejoras menores
- **⚠️ 21-24 tests (70-80%):** Revisar issues
- **❌ <21 tests (<70%):** Necesita correcciones

---

## ⭐ **TESTS SUPER CRÍTICOS QUE DEBEN PASAR:**
- **T3, T7, T14:** Subtítulo dinámico Tabata
- **T9:** Funcionalidad core timers
- **T27:** Cambio de idioma

**Si estos 5 tests pasan → 95% confianza en release**

---

## 📝 **RESULTADO:**
**Tests pasados:** ___/30  
**Porcentaje:** ___%  
**¿Lista para tiendas?** ___
