import io
import sys
import xml.etree.ElementTree as ET
import math

def sortchildrenby(parent, attr):
    parent[:] = sorted(parent, key=lambda child: int(child.find(attr).text, 16))

# Print usage information
if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <file.svd>")
    exit()

# Parse SVD file
svd = ET.parse(sys.argv[1]).getroot()

# Read processor information
processor_name = svd.find("name").text
register_width = svd.find("width").text
register_type = f"u{register_width}"

code = ""

# Add header
code += f"// MMIO Register definition for {processor_name}\n\n"
# Add type definition for register type of correct size
code += f"using reg_t = {register_type};\n\n\n"

for peripheral in svd.find("peripherals"):
    derived = peripheral.attrib.get("derivedFrom")
    peripheral_name = peripheral.find("name").text
    peripheral_address = int(peripheral.find("baseAddress").text, 16)

    # Generate struct header
    code += f"struct {peripheral_name}_t"

    # If register definition has been derived from somewhere else, derive the struct from the other struct
    if derived != None:
        code += f" : {derived}_t"

    code += " {\n"

    prev_offset = 0

    registers = peripheral.find("registers")
    if registers != None: 
        sortchildrenby(registers, "addressOffset")

        for register in registers:
            register_name = register.find("name").text
            register_offset = int(register.find("addressOffset").text, 16)

            # Check if padding has to be inserted
            if prev_offset == 0:
                pass
            elif register_offset - prev_offset > 4:
                code += f"    padding[{register_offset - prev_offset - 4}];\n"
            elif (register_offset - prev_offset != 0) and (register_offset - prev_offset != 4):
                print(f"Overlapping register {register_name}!")
                exit()

            # Add register variable declaration
            code += f"    reg_t {register_name}; // 0x{register_offset:03X}\n"

            prev_offset = register_offset

    code += "};\n"

    # Place instance of register type in memory
    code += f"{peripheral_name}_t {peripheral_name} @ 0x{peripheral_address:08X};\n\n"

# Write generated code to a file
with open(sys.argv[1] + ".pat", "w") as file:
    file.write(code)