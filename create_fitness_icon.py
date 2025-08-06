#!/usr/bin/env python3
"""
Script para crear un ícono de app más profesional y relacionado con fitness
Genera un ícono con pesas/mancuernas estilizadas y un diseño moderno
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_fitness_icon():
    """Crea un ícono profesional de fitness con pesas estilizadas"""
    
    # Configuración
    sizes = [1024, 512, 192, 144, 96, 72, 48, 36]
    base_size = 1024
    
    # Colores modernes y profesionales
    bg_color = (255, 87, 34)  # Naranja vibrante (Material Orange)
    accent_color = (255, 193, 7)  # Amarillo dorado
    weight_color = (33, 33, 33)  # Gris muy oscuro
    bar_color = (117, 117, 117)  # Gris medio
    shadow_color = (0, 0, 0, 50)  # Sombra suave
    
    def draw_dumbbell(draw, center_x, center_y, scale=1.0):
        """Dibuja una mancuerna estilizada y moderna"""
        
        # Dimensiones escaladas
        bar_width = int(120 * scale)
        bar_height = int(12 * scale)
        weight_size = int(45 * scale)
        weight_depth = int(25 * scale)
        
        # Posiciones
        bar_left = center_x - bar_width // 2
        bar_right = center_x + bar_width // 2
        bar_top = center_y - bar_height // 2
        bar_bottom = center_y + bar_height // 2
        
        # Sombras para profundidad
        shadow_offset = int(4 * scale)
        
        # Sombra de pesas izquierdas
        for i in range(3):
            weight_x = bar_left - weight_depth * i
            draw.ellipse([
                weight_x - weight_size - shadow_offset,
                center_y - weight_size - shadow_offset,
                weight_x + weight_size - shadow_offset,
                center_y + weight_size - shadow_offset
            ], fill=shadow_color)
        
        # Sombra de pesas derechas  
        for i in range(3):
            weight_x = bar_right + weight_depth * i
            draw.ellipse([
                weight_x - weight_size - shadow_offset,
                center_y - weight_size - shadow_offset,
                weight_x + weight_size - shadow_offset,
                center_y + weight_size - shadow_offset
            ], fill=shadow_color)
        
        # Sombra de la barra
        draw.rectangle([
            bar_left - shadow_offset,
            bar_top - shadow_offset,
            bar_right - shadow_offset,
            bar_bottom - shadow_offset
        ], fill=shadow_color)
        
        # Pesas izquierdas (3 discos)
        for i in range(3):
            weight_x = bar_left - weight_depth * i
            color = weight_color if i == 1 else accent_color
            draw.ellipse([
                weight_x - weight_size,
                center_y - weight_size,
                weight_x + weight_size,
                center_y + weight_size
            ], fill=color)
            
            # Detalle interior
            inner_size = weight_size - int(8 * scale)
            draw.ellipse([
                weight_x - inner_size,
                center_y - inner_size,
                weight_x + inner_size,
                center_y + inner_size
            ], fill=bg_color)
        
        # Pesas derechas (3 discos)
        for i in range(3):
            weight_x = bar_right + weight_depth * i
            color = weight_color if i == 1 else accent_color
            draw.ellipse([
                weight_x - weight_size,
                center_y - weight_size,
                weight_x + weight_size,
                center_y + weight_size
            ], fill=color)
            
            # Detalle interior
            inner_size = weight_size - int(8 * scale)
            draw.ellipse([
                weight_x - inner_size,
                center_y - inner_size,
                weight_x + inner_size,
                center_y + inner_size
            ], fill=bg_color)
        
        # Barra central con degradado
        draw.rectangle([bar_left, bar_top, bar_right, bar_bottom], fill=bar_color)
        
        # Detalles de agarre en la barra
        grip_spacing = int(15 * scale)
        grip_width = int(2 * scale)
        for i in range(-2, 3):
            grip_x = center_x + i * grip_spacing
            draw.rectangle([
                grip_x - grip_width//2,
                bar_top,
                grip_x + grip_width//2,
                bar_bottom
            ], fill=weight_color)
    
    # Crear íconos en todos los tamaños
    for size in sizes:
        # Crear imagen con fondo transparente
        img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Fondo circular con gradiente simulado
        margin = size // 10
        circle_size = size - 2 * margin
        
        # Sombra del círculo
        shadow_offset = size // 40
        draw.ellipse([
            margin + shadow_offset,
            margin + shadow_offset,
            margin + circle_size + shadow_offset,
            margin + circle_size + shadow_offset
        ], fill=(0, 0, 0, 30))
        
        # Círculo de fondo principal
        draw.ellipse([
            margin,
            margin,
            margin + circle_size,
            margin + circle_size
        ], fill=bg_color)
        
        # Anillo interior para efecto de profundidad
        ring_width = size // 25
        draw.ellipse([
            margin + ring_width,
            margin + ring_width,
            margin + circle_size - ring_width,
            margin + circle_size - ring_width
        ], fill=accent_color)
        
        # Círculo interior
        inner_margin = margin + ring_width * 2
        inner_size = circle_size - ring_width * 4
        draw.ellipse([
            inner_margin,
            inner_margin,
            inner_margin + inner_size,
            inner_margin + inner_size
        ], fill=bg_color)
        
        # Dibujar mancuerna escalada
        scale = size / base_size
        draw_dumbbell(draw, size // 2, size // 2, scale)
        
        # Guardar ícono
        filename = f'app_icon_{size}.png' if size != 1024 else 'app_icon.png'
        img.save(f'assets/{filename}', 'PNG')
        print(f"✅ Creado: {filename} ({size}x{size})")
    
    print(f"\n🎉 ¡Íconos de fitness creados exitosamente!")
    print(f"📱 Generados {len(sizes)} tamaños diferentes")
    print(f"💪 Diseño: Mancuernas profesionales con gradientes")
    print(f"🎨 Colores: Naranja vibrante con acentos dorados")

if __name__ == "__main__":
    try:
        create_fitness_icon()
    except ImportError:
        print("❌ Error: Necesitas instalar Pillow")
        print("💡 Ejecuta: pip install Pillow")
    except Exception as e:
        print(f"❌ Error: {e}")
