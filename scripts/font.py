from PIL import Image, ImageDraw, ImageFont

FONT_FILE = "PxPlus_IBM_BIOS.ttf"
OUT_MEM_FILE = "font.mi"
PREVIEW_PNG = "font_grid.png"
CHAR_SIZE = 8
OVERSAMPLE = 8
NUM_CHARS = 256
THRESHOLD = 128

font_size = CHAR_SIZE * OVERSAMPLE
font = ImageFont.truetype(FONT_FILE, font_size)

GRID_COLS = 16
GRID_ROWS = 16
preview_img = Image.new("L", (CHAR_SIZE*GRID_COLS, CHAR_SIZE*GRID_ROWS), 0)

with open(OUT_MEM_FILE, "w") as f:
    f.write("#File_format=Hex\n")
    f.write(f"#Address_depth={NUM_CHARS*CHAR_SIZE}\n")
    f.write(f"#Data_width={CHAR_SIZE}\n")

    for ch in range(NUM_CHARS):
        img_big = Image.new("L", (CHAR_SIZE*OVERSAMPLE, CHAR_SIZE*OVERSAMPLE), 0)
        draw = ImageDraw.Draw(img_big)
        draw.text((0, 0), chr(ch), 255, font=font)

        img_small = img_big.resize((CHAR_SIZE, CHAR_SIZE), Image.NEAREST)

        gx = (ch % GRID_COLS) * CHAR_SIZE
        gy = (ch // GRID_COLS) * CHAR_SIZE
        preview_img.paste(img_small, (gx, gy))

        for y in range(CHAR_SIZE):
            row_bits = 0
            for x in range(CHAR_SIZE):
                pixel = img_small.getpixel((x, y))
                if pixel > THRESHOLD:
                    row_bits |= 1 << (7 - x)
            f.write(f"{row_bits:02X}\n")

preview_img.save(PREVIEW_PNG)
print(f"Done! Generated {OUT_MEM_FILE} and preview {PREVIEW_PNG}")