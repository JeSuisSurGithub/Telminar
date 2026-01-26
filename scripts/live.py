import serial
import sys
import tty
import termios

ser = serial.Serial('/dev/serial0', 38400)

fd = sys.stdin.fileno()
old_settings = termios.tcgetattr(fd)

try:
    tty.setcbreak(fd)
    print("Type characters. Ctrl-C to exit.")

    cursor_x = 0
    cursor_y = 0
    line_width = 100

    while True:
        ch = sys.stdin.read(1)

        if ch == '\x03':  # Ctrl-C
            break
        elif ch == '\r':  # Carriage Return
            cursor_x = 0
            ser.write(b'\r')
        elif ch == '\n':  # Line Feed
            cursor_y += 1
            ser.write(b'\r\n')
        else:
            ser.write(ch.encode('utf-8'))
            cursor_x += 1
            if cursor_x >= line_width:
                cursor_x = 0
                cursor_y += 1

finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    ser.close()
