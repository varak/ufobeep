#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

# Create icon sizes
sizes = [192, 144, 96, 72, 48, 36]
background_color = "#1a202c"
ufo_emoji = "🛸"

for size in sizes:
    # Create image
    img = Image.new('RGBA', (size, size), background_color)
    draw = ImageDraw.Draw(img)
    
    # Try to load a font, fallback to default
    try:
        font_size = int(size * 0.8)  # Make emoji bigger
        font = ImageFont.truetype("/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf", font_size)
    except:
        try:
            font_size = int(size * 0.8)
            font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", font_size)
        except:
            # Just draw a simple UFO shape if no emoji font
            font_size = int(size * 0.4)
            font = ImageFont.load_default()
            # Draw a simple UFO shape instead
            center_x, center_y = size // 2, size // 2
            # UFO body (ellipse)
            draw.ellipse([center_x - size//3, center_y - size//6, center_x + size//3, center_y + size//6], 
                        fill="#00ff88", outline="#00ff88")
            # UFO dome (smaller ellipse on top)
            draw.ellipse([center_x - size//6, center_y - size//4, center_x + size//6, center_y], 
                        fill="#88ffaa", outline="#88ffaa")
            # Light beam (triangle below)
            draw.polygon([(center_x, center_y + size//6), 
                         (center_x - size//4, size - size//8), 
                         (center_x + size//4, size - size//8)], 
                        fill="#00ff88", outline="#00ff88")
            img.save(f'/home/mike/D/ufobeep/app/assets/icons/ufo_icon_{size}.png')
            continue
    
    # Calculate text position (center)
    text = ufo_emoji
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Draw the UFO emoji
    draw.text((x, y), text, font=font, fill="white")  # Use white for better visibility
    
    # Save the image
    img.save(f'/home/mike/D/ufobeep/app/assets/icons/ufo_icon_{size}.png')

# Create the main icon
main_img = Image.new('RGBA', (1024, 1024), background_color)
main_draw = ImageDraw.Draw(main_img)

try:
    main_font = ImageFont.truetype("/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf", 800)  # Even bigger
except:
    try:
        main_font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", 800)
    except:
        # Draw a simple UFO shape if no emoji font
        center_x, center_y = 512, 512
        # UFO body (large ellipse)
        main_draw.ellipse([center_x - 300, center_y - 100, center_x + 300, center_y + 100], 
                    fill="#00ff88", outline="#00ff88")
        # UFO dome (smaller ellipse on top)
        main_draw.ellipse([center_x - 150, center_y - 200, center_x + 150, center_y], 
                    fill="#88ffaa", outline="#88ffaa")
        # Light beam (triangle below)
        main_draw.polygon([(center_x, center_y + 100), 
                     (center_x - 200, 900), 
                     (center_x + 200, 900)], 
                    fill="#00ff88", outline="#00ff88")
        main_img.save('/home/mike/D/ufobeep/app/assets/icons/ufo_icon.png')
        print("UFO icons created successfully!")
        exit()

# Center the emoji
bbox = main_draw.textbbox((0, 0), ufo_emoji, font=main_font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
x = (1024 - text_width) // 2
y = (1024 - text_height) // 2

main_draw.text((x, y), ufo_emoji, font=main_font, fill="white")  # Use white
main_img.save('/home/mike/D/ufobeep/app/assets/icons/ufo_icon.png')

print("UFO icons created successfully!")