import csv
import sys

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <file.csv>")
    exit()

fileName = sys.argv[1]

index = 0x00
with open(f"{fileName}.tbl", "w", encoding="utf-8") as outFile:
    with open(fileName) as file:
        reader = csv.reader(file)
        for row in reader:
            for cell in row:
                if cell != "":
                    try:
                        number = int(cell, 16)
                        if number <= 0x1F:
                            lut = [ "NUL", "SOH", "STX", "ETX", "EOT", "ENQ", "ACK", "BEL", "BS", "TAB", "LF", "VT", "FF", "CR", "SO", "SI", "DLE", "DC1", "DC2", "DC3", "DC4", "NAK", "SYN", "ETB", "CAN", "EM", "SUB", "ESC", "FS", "GS", "RS", "US"]
                            print(f"{index:02X}={lut[number]}", file=outFile)
                        elif number == 0x7F:
                            print(f"{index:02X}=DEL", file=outFile)
                        else:
                            if chr(number) == chr(0xFFFD):
                                raise Exception

                            print(f"{index:02X}={chr(number)}", file=outFile)
                    except Exception:
                        print(f"{index:02X}", file=outFile)
                    index += 1