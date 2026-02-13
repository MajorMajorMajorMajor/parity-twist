from PIL import Image, ImageDraw, ImageFont
import os

size = 192
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Background circle
margin = 8
draw.ellipse([margin, margin, size-margin, size-margin], fill='#1a1a2e')
draw.ellipse([margin+4, margin+4, size-margin-4, size-margin-4], fill='#16213e')

# Draw a 3x3 grid
grid_x, grid_y = 40, 45
cell = 32
line_color = '#e94560'
line_w = 3

for i in range(4):
    y = grid_y + i * cell
    draw.line([(grid_x, y), (grid_x + 3*cell, y)], fill=line_color, width=line_w)
for j in range(4):
    x = grid_x + j * cell
    draw.line([(x, grid_y), (x, grid_y + 3*cell)], fill=line_color, width=line_w)

# Master key cell below middle column
mk_x = grid_x + cell
mk_y = grid_y + 3*cell + 6
draw.rectangle([mk_x, mk_y, mk_x+cell, mk_y+cell], outline='#0f3460', width=line_w)

# "PT" text
try:
    font = ImageFont.truetype("/system/fonts/Roboto-Bold.ttf", 28)
    small_font = ImageFont.truetype("/system/fonts/Roboto-Medium.ttf", 14)
except:
    font = ImageFont.load_default()
    small_font = font

# Numbers in grid
nums = [('2', 0, 0), ('5', 1, 0), ('6', 2, 0),
        ('10', 0, 1), ('4', 1, 1), ('8', 2, 1),
        ('9', 0, 2), ('7', 1, 2), ('1', 2, 2)]
colors = ['#4ecca3', '#e94560', '#0f3460']

for num, col, row in nums:
    cx = grid_x + col * cell + cell // 2
    cy = grid_y + row * cell + cell // 2
    try:
        nf = ImageFont.truetype("/system/fonts/Roboto-Medium.ttf", 16 if len(num) < 2 else 12)
    except:
        nf = small_font
    bbox = draw.textbbox((0,0), num, font=nf)
    tw, th = bbox[2]-bbox[0], bbox[3]-bbox[1]
    draw.text((cx - tw//2, cy - th//2 - 2), num, fill=colors[col], font=nf)

# Master key number
draw.text((mk_x + 10, mk_y + 4), '3', fill='#e94560', font=small_font)

# Save
out = os.path.join(os.path.dirname(__file__), 'res', 'drawable', 'ic_launcher.png')
img.save(out)
print(f"Icon saved to {out}")
