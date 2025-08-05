#!/usr/bin/env python3
"""
Script para crear un icono de muscle up exactamente como la imagen de referencia
Fondo blanco, figura negra, estilo minimalista
"""

import os
import math
from PIL import Image, ImageDraw

def create_muscle_up_icon():
    # Crear imagen de 1024x1024 (tamaño recomendado para iconos)
    size = 1024
    img = Image.new('RGBA', (size, size), '#FFFFFF')  # Fondo blanco sólido
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    
    # Colores exactos como la imagen de referencia
    figure_color = '#000000'  # Negro sólido para la figura
    bar_color = '#000000'     # Negro para la barra también
    
    # Dibujar la barra horizontal (más gruesa y centrada)
    bar_width = size * 0.7
    bar_height = size * 0.015
    bar_x = (size - bar_width) // 2
    bar_y = center - size * 0.02  # Centrada verticalmente
    
    draw.rectangle([bar_x, bar_y, bar_x + bar_width, bar_y + bar_height], 
                  fill=bar_color)
    
    # Dibujar figura humana en posición de muscle up (exactamente como la referencia)
    
    # 1. CABEZA (círculo perfecto)
    head_radius = size * 0.055
    head_x = center
    head_y = bar_y - head_radius * 2.8
    
    draw.ellipse([head_x - head_radius, head_y - head_radius,
                 head_x + head_radius, head_y + head_radius], 
                fill=figure_color)
    
    # 2. TORSO (forma triangular/trapezoidal como en la imagen)
    torso_top_width = size * 0.14
    torso_bottom_width = size * 0.09
    torso_height = size * 0.16
    torso_y = head_y + head_radius * 1.2
    
    # Crear forma del torso (más ancho arriba, como una V invertida)
    torso_points = [
        (center - torso_top_width // 2, torso_y),  # Esquina superior izquierda
        (center + torso_top_width // 2, torso_y),  # Esquina superior derecha
        (center + torso_bottom_width // 2, torso_y + torso_height),  # Esquina inferior derecha
        (center - torso_bottom_width // 2, torso_y + torso_height)   # Esquina inferior izquierda
    ]
    draw.polygon(torso_points, fill=figure_color)
    
    # 3. BRAZOS (rectos hacia abajo hasta la barra, como en la imagen)
    arm_width = size * 0.025
    
    # Brazo izquierdo (desde hombro hasta barra)
    left_shoulder_x = center - torso_top_width // 2 + size * 0.02
    left_shoulder_y = torso_y + size * 0.02
    left_arm_end_x = bar_x + size * 0.12
    
    left_arm_points = [
        (left_shoulder_x - arm_width // 2, left_shoulder_y),
        (left_shoulder_x + arm_width // 2, left_shoulder_y),
        (left_arm_end_x + arm_width // 2, bar_y),
        (left_arm_end_x - arm_width // 2, bar_y)
    ]
    draw.polygon(left_arm_points, fill=figure_color)
    
    # Brazo derecho (simétrico)
    right_shoulder_x = center + torso_top_width // 2 - size * 0.02
    right_shoulder_y = torso_y + size * 0.02
    right_arm_end_x = bar_x + bar_width - size * 0.12
    
    right_arm_points = [
        (right_shoulder_x - arm_width // 2, right_shoulder_y),
        (right_shoulder_x + arm_width // 2, right_shoulder_y),
        (right_arm_end_x + arm_width // 2, bar_y),
        (right_arm_end_x - arm_width // 2, bar_y)
    ]
    draw.polygon(right_arm_points, fill=figure_color)
    
    # 4. MANOS agarrando la barra (círculos pequeños)
    hand_radius = size * 0.015
    
    # Mano izquierda
    draw.ellipse([left_arm_end_x - hand_radius, bar_y - hand_radius,
                 left_arm_end_x + hand_radius, bar_y + bar_height + hand_radius], 
                fill=figure_color)
    
    # Mano derecha
    draw.ellipse([right_arm_end_x - hand_radius, bar_y - hand_radius,
                 right_arm_end_x + hand_radius, bar_y + bar_height + hand_radius], 
                fill=figure_color)
    
    # 5. PIERNAS (exactamente como en la imagen - flexionadas y cruzadas)
    leg_width = size * 0.035
    
    # Punto de inicio de las piernas (cadera)
    hip_y = torso_y + torso_height
    
    # Pierna izquierda
    left_hip_x = center - torso_bottom_width // 4
    
    # Muslo izquierdo (hacia abajo y ligeramente hacia afuera)
    left_thigh_length = size * 0.11
    left_knee_x = left_hip_x + size * 0.03
    left_knee_y = hip_y + left_thigh_length
    
    left_thigh_points = [
        (left_hip_x - leg_width // 2, hip_y),
        (left_hip_x + leg_width // 2, hip_y),
        (left_knee_x + leg_width // 2, left_knee_y),
        (left_knee_x - leg_width // 2, left_knee_y)
    ]
    draw.polygon(left_thigh_points, fill=figure_color)
    
    # Pantorrilla izquierda (doblada hacia atrás y cruzada)
    left_calf_length = size * 0.095
    left_foot_x = left_knee_x + size * 0.08  # Cruzada hacia la derecha
    left_foot_y = left_knee_y + left_calf_length
    
    left_calf_points = [
        (left_knee_x - leg_width // 2, left_knee_y),
        (left_knee_x + leg_width // 2, left_knee_y),
        (left_foot_x + leg_width // 2, left_foot_y),
        (left_foot_x - leg_width // 2, left_foot_y)
    ]
    draw.polygon(left_calf_points, fill=figure_color)
    
    # Pierna derecha
    right_hip_x = center + torso_bottom_width // 4
    
    # Muslo derecho (hacia abajo y ligeramente hacia afuera)
    right_knee_x = right_hip_x - size * 0.03
    right_knee_y = hip_y + left_thigh_length
    
    right_thigh_points = [
        (right_hip_x - leg_width // 2, hip_y),
        (right_hip_x + leg_width // 2, hip_y),
        (right_knee_x + leg_width // 2, right_knee_y),
        (right_knee_x - leg_width // 2, right_knee_y)
    ]
    draw.polygon(right_thigh_points, fill=figure_color)
    
    # Pantorrilla derecha (doblada hacia atrás y cruzada)
    right_foot_x = right_knee_x - size * 0.08  # Cruzada hacia la izquierda
    right_foot_y = right_knee_y + left_calf_length
    
    right_calf_points = [
        (right_knee_x - leg_width // 2, right_knee_y),
        (right_knee_x + leg_width // 2, right_knee_y),
        (right_foot_x + leg_width // 2, right_foot_y),
        (right_foot_x - leg_width // 2, right_foot_y)
    ]
    draw.polygon(right_calf_points, fill=figure_color)
    
    # 6. PIES (óvalos pequeños)
    foot_width = size * 0.035
    foot_height = size * 0.02
    
    # Pie izquierdo
    draw.ellipse([left_foot_x - foot_width // 2, left_foot_y - foot_height // 2,
                 left_foot_x + foot_width // 2, left_foot_y + foot_height // 2], 
                fill=figure_color)
    
    # Pie derecho
    draw.ellipse([right_foot_x - foot_width // 2, right_foot_y - foot_height // 2,
                 right_foot_x + foot_width // 2, right_foot_y + foot_height // 2], 
                fill=figure_color)
    
    # Crear directorio assets si no existe
    assets_dir = 'assets'
    if not os.path.exists(assets_dir):
        os.makedirs(assets_dir)
    
    # Guardar la imagen
    img.save(f'{assets_dir}/app_icon.png', 'PNG')
    print(f"✅ Icono de muscle up con fondo blanco creado en {assets_dir}/app_icon.png")
    
    # Crear también una versión más pequeña para previsualización
    small_img = img.resize((512, 512), Image.Resampling.LANCZOS)
    small_img.save(f'{assets_dir}/app_icon_512.png', 'PNG')
    print(f"✅ Versión pequeña creada en {assets_dir}/app_icon_512.png")

if __name__ == "__main__":
    create_muscle_up_icon()
