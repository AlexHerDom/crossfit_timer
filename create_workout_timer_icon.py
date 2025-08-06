#!/usr/bin/env python3
"""
Script para crear un icono profesional para Workout Timer
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_workout_timer_icon():
    # Crear imagen de 1024x1024 (tamaño recomendado para iconos)
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))  # Fondo transparente
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    
    # Crear fondo con degradado circular moderno
    for r in range(center, 0, -2):
        progress = 1 - (r / center)
        # Degradado de naranja a rojo
        red = int(255 * (0.8 + 0.2 * progress))
        green = int(140 * (1 - 0.3 * progress))
        blue = int(20 * progress)
        alpha = int(255 * (0.95 + 0.05 * progress))
        
        color = (red, green, blue, alpha)
        draw.ellipse([center - r, center - r, center + r, center + r], 
                    fill=color)
    
    # Dibujar anillo exterior del cronómetro
    ring_thickness = size * 0.08
    outer_radius = center * 0.9
    inner_radius = outer_radius - ring_thickness
    
    # Anillo exterior blanco con sombra
    draw.ellipse([center - outer_radius - 4, center - outer_radius - 4, 
                 center + outer_radius + 4, center + outer_radius + 4], 
                fill=(0, 0, 0, 100))  # Sombra
    
    draw.ellipse([center - outer_radius, center - outer_radius, 
                 center + outer_radius, center + outer_radius], 
                fill=(255, 255, 255, 255))
    
    draw.ellipse([center - inner_radius, center - inner_radius, 
                 center + inner_radius, center + inner_radius], 
                fill=(0, 0, 0, 0))  # Hacer hueco transparente
    
    # Dibujar marcas de tiempo (12, 3, 6, 9)
    mark_length = ring_thickness * 0.6
    mark_width = size * 0.015
    
    for i in range(4):
        angle = i * 90 * math.pi / 180
        start_radius = inner_radius + ring_thickness * 0.2
        end_radius = start_radius + mark_length
        
        start_x = center + start_radius * math.cos(angle - math.pi/2)
        start_y = center + start_radius * math.sin(angle - math.pi/2)
        end_x = center + end_radius * math.cos(angle - math.pi/2)
        end_y = center + end_radius * math.sin(angle - math.pi/2)
        
        # Crear rectángulo para la marca
        mark_points = []
        perpendicular_angle = angle
        
        for sign in [-1, 1]:
            offset_x = sign * mark_width/2 * math.cos(perpendicular_angle)
            offset_y = sign * mark_width/2 * math.sin(perpendicular_angle)
            mark_points.extend([
                (start_x + offset_x, start_y + offset_y),
                (end_x + offset_x, end_y + offset_y)
            ])
        
        draw.polygon(mark_points, fill=(60, 60, 60, 255))
    
    # Dibujar manecillas del cronómetro
    # Manecilla horaria (más corta, más gruesa)
    hour_length = inner_radius * 0.5
    hour_width = size * 0.02
    hour_angle = 45 * math.pi / 180  # 45 grados
    
    hour_end_x = center + hour_length * math.cos(hour_angle - math.pi/2)
    hour_end_y = center + hour_length * math.sin(hour_angle - math.pi/2)
    
    draw.line([center, center, hour_end_x, hour_end_y], 
              fill=(60, 60, 60, 255), width=int(hour_width))
    
    # Manecilla minutera (más larga, más delgada)
    minute_length = inner_radius * 0.7
    minute_width = size * 0.015
    minute_angle = 90 * math.pi / 180  # 90 grados
    
    minute_end_x = center + minute_length * math.cos(minute_angle - math.pi/2)
    minute_end_y = center + minute_length * math.sin(minute_angle - math.pi/2)
    
    draw.line([center, center, minute_end_x, minute_end_y], 
              fill=(60, 60, 60, 255), width=int(minute_width))
    
    # Centro del cronómetro
    center_radius = size * 0.03
    draw.ellipse([center - center_radius, center - center_radius,
                 center + center_radius, center + center_radius], 
                fill=(60, 60, 60, 255))
    
    # Agregar icono de play pequeño en la parte inferior
    play_size = size * 0.15
    play_y = center + inner_radius * 0.4
    
    # Triángulo de play
    play_points = [
        (center - play_size/3, play_y - play_size/2),
        (center - play_size/3, play_y + play_size/2),
        (center + play_size/2, play_y)
    ]
    
    draw.polygon(play_points, fill=(255, 255, 255, 200))
    
    return img

def create_all_icon_sizes(base_img):
    """Crear todos los tamaños necesarios para Android e iOS"""
    sizes = {
        # Android mipmap sizes
        'android/app/src/main/res/mipmap-mdpi/launcher_icon.png': 48,
        'android/app/src/main/res/mipmap-hdpi/launcher_icon.png': 72,
        'android/app/src/main/res/mipmap-xhdpi/launcher_icon.png': 96,
        'android/app/src/main/res/mipmap-xxhdpi/launcher_icon.png': 144,
        'android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png': 192,
        
        # Archivo base para otros usos
        'assets/app_icon.png': 512,
        'assets/app_icon_1024.png': 1024,
    }
    
    for path, size in sizes.items():
        # Crear directorio si no existe
        dir_path = os.path.dirname(path)
        if dir_path:
            os.makedirs(dir_path, exist_ok=True)
        
        # Redimensionar y guardar
        resized = base_img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(path, 'PNG', optimize=True)
        print(f"✅ Creado: {path} ({size}x{size})")

def main():
    print("🎨 Creando icono profesional para Workout Timer...")
    
    # Crear icono base
    icon = create_workout_timer_icon()
    
    # Crear todos los tamaños
    create_all_icon_sizes(icon)
    
    print("🎉 ¡Icono de Workout Timer creado exitosamente!")
    print("📱 El icono incluye:")
    print("   - Cronómetro moderno con degradado naranja-rojo")
    print("   - Manecillas en posición dinámica")
    print("   - Símbolo de play para indicar funcionalidad")
    print("   - Todos los tamaños para Android")

if __name__ == "__main__":
    main()
