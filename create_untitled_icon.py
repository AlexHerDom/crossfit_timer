#!/usr/bin/env python3
"""
Script para crear el icono Untitled Image - CrossFit Timer
Cronómetro naranja con pesas
"""

from PIL import Image, ImageDraw
import math

def create_crossfit_timer_icon():
    # Crear imagen 1024x1024 con fondo transparente
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Color naranja principal
    orange = (255, 146, 43)  # #ff922b
    orange_dark = (230, 120, 30)  # versión más oscura
    white = (255, 255, 255)
    
    # Centro de la imagen
    center_x, center_y = size // 2, size // 2
    
    # 1. Dibujar el cronómetro principal (círculo grande)
    main_radius = 350
    # Borde exterior del cronómetro
    draw.ellipse([center_x - main_radius, center_y - main_radius, 
                  center_x + main_radius, center_y + main_radius], 
                 fill=orange, outline=orange_dark, width=8)
    
    # Interior blanco del cronómetro
    inner_radius = 280
    draw.ellipse([center_x - inner_radius, center_y - inner_radius,
                  center_x + inner_radius, center_y + inner_radius],
                 fill=white, outline=white)
    
    # 2. Dibujar el botón superior del cronómetro
    button_width = 80
    button_height = 120
    button_top = center_y - main_radius - button_height + 20
    draw.rounded_rectangle([center_x - button_width//2, button_top,
                           center_x + button_width//2, button_top + button_height],
                          radius=15, fill=orange, outline=orange_dark, width=4)
    
    # 3. Dibujar las manecillas del reloj (check mark / V)
    # Manecilla corta (hacia abajo-derecha)
    start_x, start_y = center_x - 60, center_y + 20
    end_x, end_y = center_x, center_y + 80
    draw.line([start_x, start_y, end_x, end_y], fill=orange, width=25)
    
    # Manecilla larga (hacia arriba-derecha) 
    start_x, start_y = center_x, center_y + 80
    end_x, end_y = center_x + 120, center_y - 40
    draw.line([start_x, start_y, end_x, end_y], fill=orange, width=25)
    
    # 4. Dibujar las pesas (mancuernas) a los lados
    # Pesa izquierda
    weight_y = center_y + 200
    weight_left_x = center_x - 280
    
    # Barra de la pesa izquierda
    bar_width = 120
    bar_height = 25
    draw.rounded_rectangle([weight_left_x - bar_width//2, weight_y - bar_height//2,
                           weight_left_x + bar_width//2, weight_y + bar_height//2],
                          radius=8, fill=orange, outline=orange_dark, width=3)
    
    # Discos de la pesa izquierda
    disc_radius = 45
    # Disco izquierdo
    draw.rounded_rectangle([weight_left_x - bar_width//2 - disc_radius, weight_y - disc_radius,
                           weight_left_x - bar_width//2 + 15, weight_y + disc_radius],
                          radius=8, fill=orange, outline=orange_dark, width=3)
    # Disco derecho
    draw.rounded_rectangle([weight_left_x + bar_width//2 - 15, weight_y - disc_radius,
                           weight_left_x + bar_width//2 + disc_radius, weight_y + disc_radius],
                          radius=8, fill=orange, outline=orange_dark, width=3)
    
    # Pesa derecha (simétrica)
    weight_right_x = center_x + 280
    
    # Barra de la pesa derecha
    draw.rounded_rectangle([weight_right_x - bar_width//2, weight_y - bar_height//2,
                           weight_right_x + bar_width//2, weight_y + bar_height//2],
                          radius=8, fill=orange, outline=orange_dark, width=3)
    
    # Discos de la pesa derecha
    # Disco izquierdo
    draw.rounded_rectangle([weight_right_x - bar_width//2 - disc_radius, weight_y - disc_radius,
                           weight_right_x - bar_width//2 + 15, weight_y + disc_radius],
                          radius=8, fill=orange, outline=orange_dark, width=3)
    # Disco derecho
    draw.rounded_rectangle([weight_right_x + bar_width//2 - 15, weight_y - disc_radius,
                           weight_right_x + bar_width//2 + disc_radius, weight_y + disc_radius],
                          radius=8, fill=orange, outline=orange_dark, width=3)
    
    # 5. Agregar algunos detalles del cronómetro
    # Pequeños marcadores en el borde
    for i in range(12):
        angle = i * 30 * math.pi / 180  # cada 30 grados
        x1 = center_x + (inner_radius - 20) * math.cos(angle)
        y1 = center_y + (inner_radius - 20) * math.sin(angle)
        x2 = center_x + (inner_radius - 40) * math.cos(angle)
        y2 = center_y + (inner_radius - 40) * math.sin(angle)
        draw.line([x1, y1, x2, y2], fill=orange, width=8)
    
    return img

if __name__ == "__main__":
    print("🎨 Creando icono Untitled Image - CrossFit Timer...")
    
    # Crear el icono
    icon = create_crossfit_timer_icon()
    
    # Guardar en el escritorio
    output_path = "/Users/10048099SAPP/Desktop/untitled_image_crossfit.png"
    icon.save(output_path, "PNG")
    
    print(f"✅ Icono creado exitosamente: {output_path}")
    print(f"📏 Tamaño: 1024x1024 pixels")
    print("🏋️‍♂️ Listo para usar con el script de integración!")
