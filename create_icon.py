#!/usr/bin/env python3
"""
Script para crear un icono personalizado para BarrasCop
"""

import os
from PIL import Image, ImageDraw, ImageFont

def create_app_icon():
    # Crear imagen de 1024x1024 (tamaño recomendado para iconos)
    size = 1024
    img = Image.new('RGB', (size, size), '#FF8C00')  # Fondo naranja
    draw = ImageDraw.Draw(img)
    
    # Dibujar fondo con degradado circular
    center = size // 2
    for r in range(center, 0, -5):
        alpha = int(255 * (r / center))
        color = (255, 140 + int(115 * (r / center)), 0, alpha)
        draw.ellipse([center - r, center - r, center + r, center + r], 
                    fill=(color[0], color[1], color[2]))
    
    # Dibujar barras de gimnasio (como una barra olímpica)
    bar_color = '#2C2C2C'  # Gris oscuro
    
    # Barra principal horizontal
    bar_width = size * 0.7
    bar_height = size * 0.08
    bar_x = (size - bar_width) // 2
    bar_y = (size - bar_height) // 2
    
    draw.rectangle([bar_x, bar_y, bar_x + bar_width, bar_y + bar_height], 
                  fill=bar_color)
    
    # Discos en los extremos
    disc_radius = size * 0.12
    disc_thickness = size * 0.03
    
    # Disco izquierdo
    left_disc_x = bar_x - disc_radius
    left_disc_y = center - disc_radius
    draw.ellipse([left_disc_x, left_disc_y, 
                 left_disc_x + 2*disc_radius, left_disc_y + 2*disc_radius], 
                fill=bar_color)
    
    # Disco derecho
    right_disc_x = bar_x + bar_width - disc_radius
    right_disc_y = center - disc_radius
    draw.ellipse([right_disc_x, right_disc_y, 
                 right_disc_x + 2*disc_radius, right_disc_y + 2*disc_radius], 
                fill=bar_color)
    
    # Añadir brillo a los discos
    highlight_color = '#4A4A4A'
    for disc_x in [left_disc_x, right_disc_x]:
        highlight_size = disc_radius * 0.6
        highlight_x = disc_x + disc_radius * 0.3
        highlight_y = left_disc_y + disc_radius * 0.3
        draw.ellipse([highlight_x, highlight_y, 
                     highlight_x + highlight_size, highlight_y + highlight_size], 
                    fill=highlight_color)
    
    # Añadir texto "BC" en el centro
    try:
        # Intentar usar una fuente del sistema
        font_size = int(size * 0.15)
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Arial Bold.ttf", font_size)
        except:
            try:
                font = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf", font_size)
            except:
                font = ImageFont.load_default()
        
        text = "BC"
        
        # Obtener el tamaño del texto
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Centrar el texto
        text_x = (size - text_width) // 2
        text_y = (size - text_height) // 2 + size * 0.15  # Mover ligeramente hacia abajo
        
        # Dibujar sombra del texto
        shadow_offset = 3
        draw.text((text_x + shadow_offset, text_y + shadow_offset), text, 
                 fill='#000000', font=font)
        
        # Dibujar texto principal
        draw.text((text_x, text_y), text, fill='#FFFFFF', font=font)
        
    except Exception as e:
        print(f"Error con la fuente: {e}")
        # Fallback: dibujar círculos como letras
        circle_radius = size * 0.04
        circle_y = center + size * 0.15
        
        # B
        b_x = center - size * 0.08
        draw.ellipse([b_x - circle_radius, circle_y - circle_radius,
                     b_x + circle_radius, circle_y + circle_radius], 
                    fill='#FFFFFF')
        
        # C
        c_x = center + size * 0.08
        draw.ellipse([c_x - circle_radius, circle_y - circle_radius,
                     c_x + circle_radius, circle_y + circle_radius], 
                    fill='#FFFFFF')
    
    # Crear directorio assets si no existe
    assets_dir = 'assets'
    if not os.path.exists(assets_dir):
        os.makedirs(assets_dir)
    
    # Guardar la imagen
    img.save(f'{assets_dir}/app_icon.png', 'PNG')
    print(f"✅ Icono creado exitosamente en {assets_dir}/app_icon.png")
    
    # Crear también una versión más pequeña para previsualización
    small_img = img.resize((512, 512), Image.Resampling.LANCZOS)
    small_img.save(f'{assets_dir}/app_icon_512.png', 'PNG')
    print(f"✅ Versión pequeña creada en {assets_dir}/app_icon_512.png")

if __name__ == "__main__":
    create_app_icon()
