import serial
import time

ser = serial.Serial('/dev/serial0', baudrate=38400, timeout=1)

time.sleep(0.1)

ser.write(b' ' * 6000)

ser.write(b"Hi!\r\n")
for i in range(256):
    if i != 0 and (i % 8) == 0:
        ser.write(b"\r\n")
    ser.write(bytes([i]))

ser.close()
