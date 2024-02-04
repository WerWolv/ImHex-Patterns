import yaml
import sys
import re
import string

output = ""

top_level_struct_name = ""
top_level_struct = ""

def fixTypeName(name):
    name = name.replace("_", " ")
    name = string.capwords(name)
    name = name.replace(" ", "")

    return name

def add_line(line, indent = 0):
    global output
    output += (" " * indent) + line + "\n"

def handle_meta_xref(xref):
    if "mime" in xref:
        add_line(f"#pragma MIME {xref['mime']}")

def handle_meta_endian(meta_endian):
    if meta_endian == "be":
        add_line("#pragma endian big")
    elif meta_endian == "le":
        add_line("#pragma endian little")
    else:
        print(f"Unknown endian: {meta_endian}")
        exit(1)

def handle_meta(meta):
    if "xref" in meta:
        handle_meta_xref(meta["xref"])
    if "endian" in meta:
        handle_meta_endian(meta["endian"])
    if "id" in meta:
        global top_level_struct_name
        top_level_struct_name = str(meta["id"]).capitalize()

def handle_types(types):
    result = ""
    for type in types:
        entry = types[type]

        is_bitfield = False
        lines = ""

        if "seq" in entry:
            is_bitfield, lines = handle_seq(entry["seq"])
        if "instances" in entry:
            lines += handle_instances(entry["instances"])

        if is_bitfield:
            result += f"bitfield {fixTypeName(type)} {{\n"
        else:
            result += f"struct {fixTypeName(type)} {{\n"

        result += lines + "\n"

        result += "};\n\n"

    return result

def handle_instances(instances):
    result = ""
    for name in instances:
        instance = instances[name]
        result += f"    auto {name} = {instance['value']} [[export]];"

        if "doc" in instance:
            result += " // " + instance["doc"].replace('\n', ' ')
        
        result += "\n"

    return result.rstrip()


def handle_seq(seq):
    result = ""

    is_bitfield = False
    lines = []

    for entry in seq:
        name = entry["id"]
        entry_type = ""
        array_size = ""
        bitfield_field_size = ""
        content_check = ""
        docs = ""

        if "doc" in entry:
            docs = entry["doc"]

        if "type" in entry:
            entry_type = entry["type"]

        if entry_type == "str":
            if entry["encoding"] == "UTF-16LE":
                entry_type = "le char16"
            elif entry["encoding"] == "UTF-16BE":
                entry_type = "be char16"
            else:
                entry_type = "char"
        elif entry_type == "u1":
            entry_type = "u8"
        elif entry_type == "u2":
            entry_type = "u16"
        elif entry_type == "u4":
            entry_type = "u32"
        elif entry_type == "u8":
            entry_type = "u64"
        elif entry_type == "s1":
            entry_type = "s8"
        elif entry_type == "s2":
            entry_type = "s16"
        elif entry_type == "s4":
            entry_type = "s32"
        elif entry_type == "s8":
            entry_type = "s64"
        elif entry_type == "f4":
            entry_type = "float"
        elif entry_type == "f8":
            entry_type = "double"
        else:
            entry_type = fixTypeName(entry_type)
        
        if "contents" in entry:
            if isinstance(entry["contents"], str):
                entry_type = f"type::Magic<\"{entry['contents']}\">"
            else:
                array_size = len(entry["contents"])
                encoded_string = ""
                for char in entry["contents"]:
                    encoded_string += f"\\x{char:02X}"

                entry_type = f"type::Magic<\"{encoded_string}\">"
        elif "size" in entry:
            array_size = entry["size"]
            if isinstance(array_size, str):
                array_size = array_size.replace("_root", "parent")
            entry_type = "u8"

        if re.compile("^b[0-9]+$").match(entry_type):
            is_bitfield = True
            bitfield_field_size = int(entry_type[1:])

        new_line = ""

        if "if" in entry:
            new_line += f"    if ({entry['if']})\n    "
        
        if array_size != "":
            new_line += f"    {entry_type} {name}[{array_size}];"
        elif bitfield_field_size != "":
            new_line += f"    {name} : {bitfield_field_size};"
        else:
            new_line += f"    {entry_type} {name};"

        if docs != "":
            new_line += " // " + docs.replace('\n', ' ')

        lines.append(new_line)

    for line in lines:
        result += line + "\n"

    return (is_bitfield, result)

def generate_imhex_pattern(data):
    global top_level_struct

    add_line("import type.magic;\n")

    if "meta" in data:
       handle_meta(data["meta"])

    add_line("")

    if "types" in data:
        add_line(handle_types(data["types"]))
    
    if "seq" in data:
        add_line(handle_types({ top_level_struct_name: { "seq": data["seq"] } }))

    add_line(f"{fixTypeName(top_level_struct_name)} {fixTypeName(top_level_struct_name).lower()} @ 0x00;\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ksy2pat.py <ksy file>")
        exit(1)

    file_content = ""
    with open(sys.argv[1]) as f:
        file_content = f.read()

    data = yaml.load(file_content, Loader=yaml.CLoader)
    generate_imhex_pattern(data)

    with open(f"{sys.argv[1]}.hexpat", "w") as f:
        f.write(output)