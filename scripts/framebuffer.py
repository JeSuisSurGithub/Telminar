OUT_MEM_FILE = "framebuffer.mi"
FRAMEBUFFER_SIZE = 6000
CHAR_WIDTH = 8
INIT_MESSAGE = "Good morning! Here's your debugging terminal!"

with open(OUT_MEM_FILE, "w") as f:
    f.write("#File_format=Hex\n")
    f.write(f"#Address_depth={FRAMEBUFFER_SIZE}\n")
    f.write(f"#Data_width={CHAR_WIDTH}\n")

    for c in INIT_MESSAGE:
        f.write(f"{ord(c):02X}\n")

    for _ in range(FRAMEBUFFER_SIZE - len(INIT_MESSAGE)):
        f.write(f"00\n")

print(f"Done! Generated {OUT_MEM_FILE}")