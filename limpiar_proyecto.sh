#!/bin/bash

# 🧹 Script de limpieza para CrossFit Timer Pro
# Elimina archivos temporales y scripts de iconos antiguos

echo "🧹 Limpiando archivos innecesarios del proyecto CrossFit Timer Pro..."

# 1. Eliminar scripts de Python para crear iconos (ya no se necesitan)
echo "🐍 Eliminando scripts Python de iconos antiguos..."
PYTHON_SCRIPTS=(
    "create_icon.py"
    "create_fitness_icon.py" 
    "create_muscle_up_icon.py"
    "create_workout_timer_icon.py"
    "create_untitled_icon.py"
)

for script in "${PYTHON_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "   🗑️  Eliminando: $script"
        rm "$script"
    fi
done

# 2. Limpiar archivos temporales de Flutter
echo "📱 Limpiando cache de Flutter..."
flutter clean >/dev/null 2>&1

# 3. Eliminar archivos .DS_Store del proyecto
echo "🍎 Eliminando archivos .DS_Store..."
find . -name ".DS_Store" -delete 2>/dev/null

# 4. Verificar y limpiar directorios temporales
echo "📁 Limpiando directorios temporales..."
if [ -d "/tmp/crossfit_icons" ]; then
    echo "   🗑️  Eliminando: /tmp/crossfit_icons"
    rm -rf "/tmp/crossfit_icons"
fi

# 5. Mostrar archivos de iconos actuales que SÍ se usan
echo ""
echo "✅ Limpieza completada!"
echo ""
echo "📊 Archivos de iconos ACTIVOS (estos SÍ se usan):"
echo "🤖 Android mipmap:"
find android/app/src/main/res/mipmap-* -name "*.png" 2>/dev/null | wc -l | xargs echo "   - Archivos Android:"
echo "🍎 iOS AppIcon:"
find ios/Runner/Assets.xcassets/AppIcon.appiconset -name "*.png" 2>/dev/null | wc -l | xargs echo "   - Archivos iOS:"
echo "📱 Assets:"
find assets -name "app_icon*.png" 2>/dev/null | wc -l | xargs echo "   - Archivos Assets:"

echo ""
echo "🎯 Script de integración activo:"
echo "   - integrar_nuevo_icono.sh (mantener)"
echo ""
echo "💡 Proyecto limpio y optimizado!"
