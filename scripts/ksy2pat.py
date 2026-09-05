import yaml
import sys
import re
import string

output = ""

top_level_struct_name = ""
top_level_struct = ""

TYPES = {
    "u1": "u8", "u2": "u16", "u4": "u32", "u8": "u64",
    "s1": "s8", "s2": "s16", "s4": "s32", "s8": "s64",
    "f4": "float", "f8": "double",
}

def fixTypeName(name):
    name = name.replace("_", " ")
    name = string.capwords(name)
    name = name.replace(" ", "")

    return name

def format_comment(comment):
    if comment != "":
        return " // " + comment.replace('\n', ' ')
    return ""

def declare_variable(name, entry_type, array_size, bitfield_field_size):
    if array_size != "":
        return f"{entry_type} {name}[{array_size}];"
    if bitfield_field_size != "":
        return f"{name} : {bitfield_field_size};"
    return f"{entry_type} {name};"

def struct_decl_header(type, is_bitfield):
    if is_bitfield:
        return f"bitfield {fixTypeName(type)} {{\n"
    return f"struct {fixTypeName(type)} {{\n"

def convert_type(entry):
    entry_type = entry["type"]
    if entry_type == "str":
        if entry["encoding"] == "UTF-16LE":
            return "le char16"
        elif entry["encoding"] == "UTF-16BE":
            return "be char16"
        return "char"

    if entry_type in TYPES:
        return TYPES[entry_type]

    return fixTypeName(entry_type)

def fetch_type_info(type_name, types_info):
    return types_info.setdefault(type_name, {"type": type_name})

def collect_seq_type_info(seq, parent_type, types_info):
    if not seq:
        return

    type_info = fetch_type_info(parent_type, types_info)

def collect_type_info(data, top_level_struct_name):
    types_info = {}

    collect_seq_type_info(data.get("seq"), top_level_struct_name, types_info)
    for parent_type, entry in data.get("types", {}).items():
        collect_seq_type_info(entry.get("seq"), parent_type, types_info)

    return types_info

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

def handle_types(types, types_info):
    result = ""
    for type in types:
        entry = types[type]

        type_info = types_info.get(type, {})
        is_bitfield = False
        lines = ""

        if "seq" in entry:
            is_bitfield, lines = handle_seq(entry["seq"], type_info, types_info)
        if "instances" in entry:
            lines += handle_instances(entry["instances"])

        result += struct_decl_header(type, is_bitfield)

        result += lines + "\n"

        result += "};\n\n"

    return result

def handle_instances(instances):
    result = ""
    for name in instances:
        instance = instances[name]
        result += f"    auto {name} = {instance['value']} [[export]];"
        result += format_comment(instance.get("doc", ""))
        result += "\n"

    return result.rstrip()


def handle_seq(seq, type_info, types_info):
    result = ""

    is_bitfield = False
    lines = []

    for entry in seq:
        name = entry["id"]
        entry_type = ""
        array_size = ""
        bitfield_field_size = ""
        docs = ""

        if "doc" in entry:
            docs = entry["doc"]

        if "type" in entry:
            entry_type = convert_type(entry)

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
        
        new_line += "    " + declare_variable(name, entry_type, array_size, bitfield_field_size)

        new_line += format_comment(docs)

        lines.append(new_line)

    for line in lines:
        result += line + "\n"

    return (is_bitfield, result)

def generate_imhex_pattern(data):
    global top_level_struct

    add_line("import type.magic;\n")

    if "meta" in data:
       handle_meta(data["meta"])

    types_info = collect_type_info(data, top_level_struct_name)
    add_line("")

    if "types" in data:
        add_line(handle_types(data["types"], types_info))
    
    if "seq" in data:
        add_line(handle_types({ top_level_struct_name: { "seq": data["seq"] } }, types_info))

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
