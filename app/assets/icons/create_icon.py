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
        font_size = int(size * 0.6)
        font = ImageFont.truetype("/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf", font_size)
    except:
        try:
            font_size = int(size * 0.6)
            font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", font_size)
        except:
            font_size = int(size * 0.4)
            font = ImageFont.load_default()
    
    # Calculate text position (center)
    text = ufo_emoji
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Draw the UFO emoji
    draw.text((x, y), text, font=font, fill="#00ff88")
    
    # Save the image
    img.save(f'/home/mike/D/ufobeep/app/assets/icons/ufo_icon_{size}.png')

# Create the main icon
main_img = Image.new('RGBA', (1024, 1024), background_color)
main_draw = ImageDraw.Draw(main_img)

try:
    main_font = ImageFont.truetype("/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf", 600)
except:
    try:
        main_font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", 600)
    except:
        main_font = ImageFont.load_default()

# Center the emoji
bbox = main_draw.textbbox((0, 0), ufo_emoji, font=main_font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
x = (1024 - text_width) // 2
y = (1024 - text_height) // 2

main_draw.text((x, y), ufo_emoji, font=main_font, fill="#00ff88")
main_img.save('/home/mike/D/ufobeep/app/assets/icons/ufo_icon.png')

print("UFO icons created successfully!")