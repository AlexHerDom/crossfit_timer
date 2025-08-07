#!/bin/bash

# 🧹 Script de LIMPIEZA PROFUNDA para CrossFit Timer Pro
# Elimina TODOS los archivos innecesarios dejando solo lo esencial

echo "🧹 ===== LIMPIEZA PROFUNDA INICIADA ====="

# 1. ELIMINAR ARCHIVOS .MD INNECESARIOS (todos excepto README.md)
echo "📝 Eliminando archivos .md innecesarios..."

rm -f ALTERNATIVAS_ICONO.md
rm -f FLATICON_SOLUCION.md 
rm -f GUIA_PUBLICACION_COMPLETA.md
rm -f GUIA_SCREENSHOTS.md
rm -f ICONO_INTEGRADO_EXITOSAMENTE.md
rm -f MATERIALES_TIENDAS.md
rm -f PLAN_LANZAMIENTO_EVOLUTIVO.md
rm -f PROMPTS_ICONO_AI.md
rm -f PUBLICACION_FINAL.md
rm -f QUICK_TEST.md
rm -f README_STORE.md
rm -f REPORTE_TESTING_FINAL.md
rm -f TESTING_EXHAUSTIVO.md
rm -f TESTING_FINAL_COMPLETADO.md
rm -f TESTING_MANUAL_COMPLETO.md
rm -f TESTING_PLAN.md
rm -f TESTING_RAPIDO_30.md
rm -f TEST_RESULTS.md
rm -f TUTORIAL_LEONARDO_AI.md
rm -f marketing_strategy.md
rm -f privacy_policy.md
rm -f store_listing.md

# 2. ELIMINAR SCRIPTS PYTHON DE ICONOS
echo "🐍 Eliminando scripts Python de iconos..."
rm -f create_fitness_icon.py
rm -f create_icon.py 
rm -f create_muscle_up_icon.py
rm -f create_untitled_icon.py
rm -f create_workout_timer_icon.py

# 3. ELIMINAR ARCHIVOS DE BUILDS Y LOGS
echo "📦 Eliminando archivos de build y logs..."
rm -f BUILD_INFO.txt
rm -f build_debug_output.txt
rm -f build_release_output.txt
rm -f devices_output.txt
rm -f flutter_doctor_output.txt
rm -f pub_get_output.txt
rm -f run_test_output.txt

# 4. ELIMINAR SCRIPTS INNECESARIOS
echo "📜 Eliminando scripts innecesarios..."
rm -f cleanup_warnings.sh
rm -f create_feature_graphic.sh
rm -f generar_icono_escritorio.sh
rm -f lanzamiento.sh
rm -f test_exhaustivo.sh

# 5. ELIMINAR ARCHIVOS HTML Y JS INNECESARIOS
echo "🌐 Eliminando archivos web innecesarios..."
rm -f generador_icono.html
rm -f test_manual.js

# 6. ELIMINAR DIRECTORIO ICON_ENV (entorno Python)
if [ -d "icon_env" ]; then
    echo "📁 Eliminando entorno Python icon_env..."
    rm -rf "icon_env"
fi

# 7. ELIMINAR SCREENSHOTS (si no se necesitan)
if [ -d "screenshots" ]; then
    echo "📸 Eliminando directorio screenshots..."
    rm -rf "screenshots"
fi

# 8. LIMPIAR FLUTTER
echo "📱 Limpiando cache de Flutter..."
flutter clean

# 9. ELIMINAR .DS_Store
echo "🍎 Eliminando archivos .DS_Store..."
find . -name ".DS_Store" -delete

echo ""
echo "✅ ===== LIMPIEZA PROFUNDA COMPLETADA ====="
echo ""
echo "📊 ARCHIVOS QUE SE MANTIENEN (solo lo esencial):"
echo "🔧 Configuración:"
echo "   - pubspec.yaml"
echo "   - analysis_options.yaml"
echo "   - .gitignore"
echo "   - README.md"
echo ""
echo "📱 Código fuente:"
echo "   - lib/ (código Dart/Flutter)"
echo "   - android/ (configuración Android)"
echo "   - ios/ (configuración iOS)"
echo "   - assets/ (recursos de la app)"
echo ""
echo "🔑 Claves y configuración:"
echo "   - crossfit-timer-key.jks (clave de firma)"
echo "   - integrar_nuevo_icono.sh (script de iconos activo)"
echo ""
echo "💡 Proyecto ULTRA LIMPIO - Solo archivos esenciales!"
