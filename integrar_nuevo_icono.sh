#!/bin/bash

# 🎯 Script para integrar el nuevo icono en CrossFit Timer Pro
# Autor: Copilot Assistant
# Fecha: $(date)

echo "🏋️‍♂️ Integrando nuevo icono en CrossFit Timer Pro..."

# Verificar que el icono existe
if [ ! -f ~/Desktop/"Untitled image.png" ]; then
    echo "❌ Error: No se encontró el archivo 'Untitled image.png' en el escritorio"
    exit 1
fi

echo "✅ Icono encontrado: $(file ~/Desktop/'Untitled image.png')"

# Crear directorio temporal
TEMP_DIR="/tmp/crossfit_icons"
mkdir -p "$TEMP_DIR"

# Copiar icono original al directorio temporal
cp ~/Desktop/"Untitled image.png" "$TEMP_DIR/original_1024.png"

echo "📏 Generando todas las resoluciones necesarias..."

# Generar resoluciones para Android (mipmap)
echo "🤖 Generando iconos Android..."
sips -z 48 48 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/android_48.png" >/dev/null 2>&1
sips -z 72 72 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/android_72.png" >/dev/null 2>&1
sips -z 96 96 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/android_96.png" >/dev/null 2>&1
sips -z 144 144 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/android_144.png" >/dev/null 2>&1
sips -z 192 192 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/android_192.png" >/dev/null 2>&1

# Generar resoluciones para iOS
echo "🍎 Generando iconos iOS..."
sips -z 120 120 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/ios_120.png" >/dev/null 2>&1
sips -z 180 180 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/ios_180.png" >/dev/null 2>&1
sips -z 1024 1024 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/ios_1024.png" >/dev/null 2>&1

# Generar resoluciones para assets
echo "📱 Generando iconos para assets..."
sips -z 36 36 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/asset_36.png" >/dev/null 2>&1
sips -z 48 48 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/asset_48.png" >/dev/null 2>&1
sips -z 72 72 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/asset_72.png" >/dev/null 2>&1
sips -z 96 96 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/asset_96.png" >/dev/null 2>&1
sips -z 144 144 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/asset_144.png" >/dev/null 2>&1
sips -z 192 192 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/asset_192.png" >/dev/null 2>&1
sips -z 512 512 "$TEMP_DIR/original_1024.png" --out "$TEMP_DIR/asset_512.png" >/dev/null 2>&1

echo "🔄 Reemplazando iconos Android..."

# Reemplazar iconos Android (mipmap)
cp "$TEMP_DIR/android_48.png" "android/app/src/main/res/mipmap-mdpi/launcher_icon.png"
cp "$TEMP_DIR/android_48.png" "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"

cp "$TEMP_DIR/android_72.png" "android/app/src/main/res/mipmap-hdpi/launcher_icon.png"
cp "$TEMP_DIR/android_72.png" "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"

cp "$TEMP_DIR/android_96.png" "android/app/src/main/res/mipmap-xhdpi/launcher_icon.png"
cp "$TEMP_DIR/android_96.png" "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"

cp "$TEMP_DIR/android_144.png" "android/app/src/main/res/mipmap-xxhdpi/launcher_icon.png"
cp "$TEMP_DIR/android_144.png" "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"

cp "$TEMP_DIR/android_192.png" "android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png"
cp "$TEMP_DIR/android_192.png" "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"

echo "🍎 Reemplazando iconos iOS..."

# Reemplazar iconos iOS
cp "$TEMP_DIR/ios_120.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png"
cp "$TEMP_DIR/ios_180.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png"
cp "$TEMP_DIR/ios_1024.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"

echo "📦 Reemplazando iconos en assets..."

# Reemplazar iconos en assets
cp "$TEMP_DIR/original_1024.png" "assets/app_icon.png"
cp "$TEMP_DIR/asset_36.png" "assets/app_icon_36.png"
cp "$TEMP_DIR/asset_48.png" "assets/app_icon_48.png"
cp "$TEMP_DIR/asset_72.png" "assets/app_icon_72.png"
cp "$TEMP_DIR/asset_96.png" "assets/app_icon_96.png"
cp "$TEMP_DIR/asset_144.png" "assets/app_icon_144.png"
cp "$TEMP_DIR/asset_192.png" "assets/app_icon_192.png"
cp "$TEMP_DIR/asset_512.png" "assets/app_icon_512.png"
cp "$TEMP_DIR/ios_1024.png" "assets/app_icon_1024.png"

echo "🧹 Limpiando archivos temporales..."
rm -rf "$TEMP_DIR"

echo ""
echo "✅ ¡Nuevo icono integrado exitosamente!"
echo "📊 Resumen de archivos actualizados:"
echo "   🤖 Android: 10 archivos (5 resoluciones x 2 nombres)"
echo "   🍎 iOS: 3 archivos (AppIcon.appiconset)"
echo "   📱 Assets: 9 archivos (todas las resoluciones)"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. flutter clean"
echo "   2. flutter build apk --release"
echo "   3. Copiar nueva APK al escritorio"
echo ""
echo "💡 El nuevo icono debería verse mucho mejor y más grande!"
