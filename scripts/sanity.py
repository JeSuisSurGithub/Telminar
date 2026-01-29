import serial
import time

ser = serial.Serial('/dev/serial0', baudrate=38400, timeout=1)

time.sleep(0.1)

ser.write(b'0123456789' * 600)

# ser.write(bytes([0]))

ser.close()
