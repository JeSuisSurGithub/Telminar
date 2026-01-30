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

    while True:
        ch = sys.stdin.read(1)
        if ch == '\x03':  # Ctrl-C
            break
        elif ch == '\n':
            ser.write(b'\r\n')
        elif ch == '\x1B':
            ser.write(b'\x00')
        elif ch == '\x7F':
            ser.write(b'\x08')
        else:
            ser.write(ch.encode('utf-8'))

finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    ser.close()
