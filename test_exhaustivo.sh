#!/bin/bash

# 🧪 SCRIPT DE TESTING EXHAUSTIVO AUTOMATIZADO
# CrossFit Timer - Verificación completa de funcionalidades

echo "🚀 INICIANDO TESTING EXHAUSTIVO DE CROSSFIT TIMER"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Función para mostrar resultados
show_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC} - $2"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC} - $2"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo ""
echo "📋 FASE 1: ANÁLISIS ESTÁTICO"
echo "=============================="

# 1. Flutter Doctor
echo -e "${BLUE}🔍 Verificando Flutter Doctor...${NC}"
flutter doctor --verbose > flutter_doctor_output.txt 2>&1
if grep -q "No issues found!" flutter_doctor_output.txt; then
    show_result 0 "Flutter Doctor - Configuración OK"
else
    show_result 1 "Flutter Doctor - Problemas encontrados"
fi

# 2. Dependencias
echo -e "${BLUE}🔍 Verificando dependencias...${NC}"
flutter pub get > pub_get_output.txt 2>&1
if [ $? -eq 0 ]; then
    show_result 0 "Dependencias - Instalación exitosa"
else
    show_result 1 "Dependencias - Error en instalación"
fi

# 3. Análisis de código
echo -e "${BLUE}🔍 Análisis de código (flutter analyze)...${NC}"
flutter analyze > analyze_output.txt 2>&1
ERROR_COUNT=$(grep -c "error •" analyze_output.txt || echo "0")
WARNING_COUNT=$(grep -c "warning •" analyze_output.txt || echo "0")

echo "   📊 Errores encontrados: $ERROR_COUNT"
echo "   📊 Warnings encontrados: $WARNING_COUNT"

if [ $ERROR_COUNT -eq 0 ]; then
    show_result 0 "Análisis estático - Sin errores críticos"
else
    show_result 1 "Análisis estático - $ERROR_COUNT errores críticos"
fi

echo ""
echo "📋 FASE 2: TESTING DE COMPILACIÓN"
echo "=================================="

# 4. Build debug
echo -e "${BLUE}🔍 Compilación debug...${NC}"
flutter build apk --debug > build_debug_output.txt 2>&1
if [ $? -eq 0 ]; then
    show_result 0 "Build Debug - Compilación exitosa"
else
    show_result 1 "Build Debug - Error en compilación"
fi

# 5. Build release (solo verifica que compile)
echo -e "${BLUE}🔍 Verificación build release...${NC}"
flutter build apk --release > build_release_output.txt 2>&1
if [ $? -eq 0 ]; then
    show_result 0 "Build Release - Compilación exitosa"
else
    show_result 1 "Build Release - Error en compilación"
fi

echo ""
echo "📋 FASE 3: TESTING DE ASSETS"
echo "=============================="

# 6. Verificar assets de sonido
echo -e "${BLUE}🔍 Verificando assets de sonido...${NC}"
SOUND_FILES=("beep.wav" "completion.wav" "countdown.wav" "halfway.wav" "halfway_special.wav")
MISSING_SOUNDS=0

for sound in "${SOUND_FILES[@]}"; do
    if [ -f "assets/sounds/$sound" ]; then
        echo "   ✅ $sound encontrado"
    else
        echo "   ❌ $sound NO encontrado"
        MISSING_SOUNDS=$((MISSING_SOUNDS + 1))
    fi
done

if [ $MISSING_SOUNDS -eq 0 ]; then
    show_result 0 "Assets de sonido - Todos los archivos presentes"
else
    show_result 1 "Assets de sonido - $MISSING_SOUNDS archivos faltantes"
fi

# 7. Verificar iconos
echo -e "${BLUE}🔍 Verificando iconos...${NC}"
if [ -f "assets/app_icon.png" ] && [ -f "assets/app_icon_512.png" ]; then
    show_result 0 "Iconos de app - Presentes"
else
    show_result 1 "Iconos de app - Faltantes"
fi

echo ""
echo "📋 FASE 4: TESTING DE ARCHIVO CRÍTICOS"
echo "======================================="

# 8. Verificar archivos críticos
echo -e "${BLUE}🔍 Verificando archivos críticos...${NC}"
CRITICAL_FILES=(
    "lib/main.dart"
    "lib/screens/home_screen.dart"
    "lib/screens/timer_screen.dart"
    "lib/screens/config_screen.dart"
    "lib/screens/settings_screen.dart"
    "lib/language_provider.dart"
    "lib/theme_provider.dart"
    "pubspec.yaml"
)

MISSING_FILES=0
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file FALTANTE"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -eq 0 ]; then
    show_result 0 "Archivos críticos - Todos presentes"
else
    show_result 1 "Archivos críticos - $MISSING_FILES faltantes"
fi

echo ""
echo "📋 FASE 5: TESTING DE CONFIGURACIÓN"
echo "===================================="

# 9. Verificar pubspec.yaml
echo -e "${BLUE}🔍 Verificando pubspec.yaml...${NC}"
REQUIRED_DEPS=("flutter" "shared_preferences" "audioplayers" "flutter_tts" "provider")
MISSING_DEPS=0

for dep in "${REQUIRED_DEPS[@]}"; do
    if grep -q "$dep:" pubspec.yaml; then
        echo "   ✅ $dep configurado"
    else
        echo "   ❌ $dep NO configurado"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
done

if [ $MISSING_DEPS -eq 0 ]; then
    show_result 0 "Dependencias pubspec - Todas configuradas"
else
    show_result 1 "Dependencias pubspec - $MISSING_DEPS faltantes"
fi

echo ""
echo "📋 FASE 6: TESTING DE DEVICE (SI ESTÁ CONECTADO)"
echo "================================================"

# 10. Verificar dispositivos conectados
echo -e "${BLUE}🔍 Verificando dispositivos...${NC}"
flutter devices > devices_output.txt 2>&1
DEVICE_COUNT=$(grep -c "•" devices_output.txt || echo "0")

echo "   📱 Dispositivos detectados: $DEVICE_COUNT"

if [ $DEVICE_COUNT -gt 0 ]; then
    show_result 0 "Dispositivos - $DEVICE_COUNT dispositivo(s) conectado(s)"
    
    # Si hay dispositivos, intentar ejecutar la app por 10 segundos
    echo -e "${BLUE}🔍 Prueba de ejecución rápida (10s)...${NC}"
    timeout 10s flutter run --hot 2>&1 | head -20 > run_test_output.txt &
    sleep 10
    pkill -f "flutter run" 2>/dev/null
    
    if grep -q "Connecting to service protocol" run_test_output.txt; then
        show_result 0 "Ejecución en dispositivo - App inicia correctamente"
    else
        show_result 1 "Ejecución en dispositivo - Problemas al iniciar"
    fi
else
    show_result 1 "Dispositivos - Ningún dispositivo conectado"
fi

echo ""
echo "🎯 RESUMEN FINAL DE TESTING"
echo "============================"
echo -e "${GREEN}✅ Tests pasados: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Tests fallidos: $TESTS_FAILED${NC}"
echo -e "${BLUE}📊 Total tests: $TOTAL_TESTS${NC}"

PASS_PERCENTAGE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
echo -e "${YELLOW}📈 Porcentaje de éxito: $PASS_PERCENTAGE%${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡TODOS LOS TESTS PASARON! App lista para testing manual${NC}"
    exit 0
elif [ $PASS_PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  App mayormente funcional, revisar issues menores${NC}"
    exit 0
else
    echo -e "${RED}🚨 ISSUES CRÍTICOS ENCONTRADOS - Revisar antes de continuar${NC}"
    exit 1
fi
