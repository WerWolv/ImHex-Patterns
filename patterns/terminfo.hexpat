/* info */
#pragma author Nightowl286
#pragma description Compiled term info entry

#pragma endian little

#pragma magic [1e 02] @ 0x00
#pragma MIME application/x-terminfo2

#pragma magic [1a 01] @ 0x00
#pragma MIME application/x-terminfo

/*
	Format has been primarily taken from:
	https://www.man7.org/linux/man-pages/man5/term.5.html

	Technically you can't count on the binary formats being compatible
	on different unix versions, however *(as I've been told)* those versions
	are pretty much dead nowadays so this format is common enough to work
	in like the majority of the cases.
*/

/* imports */
import std.array;
import std.mem;
import std.string;
import std.ctype;


/* utility */
fn is_char(char ch) {
    char value = std::mem::read_unsigned($, 1);
    return value == ch;
};

fn is_not_char(char ch) {
    char value = std::mem::read_unsigned($, 1);
    return value != ch;
};


/* types */
enum number_format : s16 {
    legacy = 0o432,
    extended = 0o1036
}
[[format("number_format_to_string")]];

struct boolean_capability { s8 value; }
[[
    sealed,
    format("boolean_capability_format"),
    comment("Indicates the presence of a boolean capability.\n\n(An empty value indicates that the capability is missing).")
]];

struct numerical_capability {
    if (parent.header.format == number_format::extended)
        s32 value;
    else
        s16 value;
}
[[
    sealed,
    format("numerical_capability_format"),
    comment("Indicates the presence of a numerical capability.\n\n(An empty value indicates that the capability is missing).")
]];

struct string_table_value_offset { s16 value; }
[[
    sealed,
    format("string_table_value_offset_format"),
    comment("Indicates the offset of a string capability value in the string table.\n\n(An empty value indicates that the capability is missing).")
]];

struct string_table_name_offset { s16 value; }
[[
    sealed,
    format("string_table_name_offset_format"),
    comment("Indicates the offset of a name string in the string table.\n\n(This value is relative to the name portion of the string table).")
]];

struct terminal_name {
    char name[while(is_not_char('|') && is_not_char(0x00))];
    padding[1];

    if (is_char('|')) $ += 1;
    if (is_char(0)) break;
}
[[
    sealed,
    comment("Represents a terminal name/alias.")
]];

struct table_string {
    char value[while(is_not_char(0x00))];
    if (is_char(0))
    $ += 1;

}
[[
    sealed,
    format("string_table_value_format"),
    comment("A null-terminated string in the string table.")
]];

struct string_table {
    std::ByteSizedArray<table_string, parent.header.string_table_size> array [[inline]];
};

struct legacy_header {
    number_format format
    [[comment("The number format of the terminfo entry.")]];

    s16 name_size
    [[
        name("name size"),
        comment("The size of the terminal names in bytes.")
    ]];

    s16 boolean_count
    [[
        name("boolean capability count"),
        comment("The amount of known boolean capabilities in the file.")
    ]];

    s16 numerical_count
    [[
        name("numerical capability count"),
        comment("The amount of known numerical capabilities in the file.")
    ]];

    s16 string_count
    [[
        name("string capability count"),
        comment("The amount of known string capabilities in the file.")
    ]];

    s16 string_table_size
    [[
        name("string table size"),
        comment("The size of the string table (in bytes).")
    ]];
};

struct extended_header {
    s16 boolean_count
    [[
        name("boolean capability count"),
        comment("The amount of extended boolean capabilities in the file.")
    ]];

    s16 numerical_count
    [[
        name("numerical capability count"),
        comment("The amount of extended numerical capabilities in the file.")
    ]];

    s16 string_count
    [[
        name("string capability count"),
        comment("The amount of extended string capabilities in the file.")
    ]];

    s16 table_item_count
    [[
        name("table item count"),
        comment("The amount of items in the string table.")
    ]];

    s16 string_table_size
    [[
        name("string table size"),
        comment("The size of the extended string table (in bytes).")
    ]];
};

struct extended_data {
    extended_header header
    [[comment("The metadata about the extended section of the file.")]];

    boolean_capability booleans[header.boolean_count]
    [[
        name("boolean capabilities"),
        comment("The extended boolean capabilities.")
    ]];

    if ($ % 2 != 0) $ += 1; // align to even boundary before numerical capabilities are read;

    numerical_capability numerical[header.numerical_count]
    [[
        name("numerical capabilities"),
        comment("The extended numerical capabilities.")
    ]];

    string_table_value_offset string_offsets[header.string_count]
    [[
        name("string table value offsets"),
        comment("The string table offsets for the extended string capability values.")
    ]];

    string_table_name_offset name_offsets[header.table_item_count - header.string_count]
    [[
        name("string table name offsets"),
        comment("The string table offsets for all of the extended capability names.\n\n(These values are relative to the name portion of the string table).")
    ]];

    string_table string_table
    [[
        name("string table"),
        comment("Contains all of the string values used in the extended section of the file.")
    ]];
};

struct file {
    legacy_header header
    [[comment("The metadata about the file.")]];

    terminal_name terminal_names[1000]
    [[
        format_entries("terminal_name_format"),
        name("terminal names"),
        comment("The names and aliases that the terminfo file is describing.")
    ]];

    boolean_capability booleans[header.boolean_count]
    [[
        name("boolean capabilities"),
        comment("The known boolean capabilities.")
    ]];

    if ($ % 2 != 0) $ += 1; // align to even boundary before numerical capabilities are read;

    numerical_capability numerical[header.numerical_count]
    [[
        name("numerical capabilities"),
        comment("The known numerical capabilities.")
    ]];

    string_table_value_offset string_offsets[header.string_count]
    [[
        name("string table value offsets"),
        comment("The string table offsets for the known string capability values.")
    ]];

    string_table string_table
    [[
        name("string table"),
        comment("Contains all of the string values used in the (legacy storage format section of) file.")
    ]];

    if (std::mem::eof() == false) {
        extended_data extended
        [[comment("Contains the information from extended storage format section.")]];
    }

} [[inline]];


/* formatting */
fn terminal_name_format(terminal_name name) {
    return '"' + name.name + '"';
};

fn boolean_capability_format(boolean_capability value) {
    match (value.value) {
        (-2): return "cancelled";
        (-1 | 0): return "";
        (1): return "present";
        (_): return value.value;
    }
    return value;
};

fn numerical_capability_format(numerical_capability value) {
    match (value.value) {
        (-2): return "cancelled";
        (-1): return "";
        (_): return value.value;
    }
    return value;
};

fn string_table_value_offset_format(string_table_value_offset value) {
    match (value.value) {
        (-2): return "cancelled";
        (-1): return "";
        (_): return value.value;
    }
    return value;
};

fn string_table_name_offset_format(string_table_name_offset value) {
    return value.value;
};

fn string_table_value_format(ref table_string value) {
    str view = "\"";

    for (s16 i = 0, i < sizeof(value.value), i += 1) {
        char ch = value.value[i];
        if (ch == '\\') view += "\\\\";
        else if (ch == '"') view += "\\\"";
        else if (std::ctype::isgraph(ch)) view += ch;
        else view += to_hex_ch(ch);
    }

    view += "\"";
    return view;
};

fn to_hex_ch(char ch) {
    if (ch == '\x1b') return "\\e";
    if (ch == ' ') return " ";
    if (ch == '\r') return "\\r";
    if (ch == '\n') return "\\n";
    if (ch == '\a') return "\\a";
    if (ch == '\b') return "\\b";
    if (ch == '\t') return "\\t";
    if (ch == 11) return "\\v";
    if (ch == '\f') return "\\f";

    s8 second = ch % 16;
    s8 first = ch / 16;

    return "\\x" + to_hex_digit(first) + to_hex_digit(second);
};

fn to_hex_digit(u8 num) {
    if (num == 10) return 'A';
    if (num == 11) return 'B';
    if (num == 12) return 'C';
    if (num == 13) return 'D';
    if (num == 14) return 'E';
    if (num == 15) return 'F';

    return std::string::to_string(num);
};

fn number_format_to_string(number_format format) {
    if (format == number_format::extended) return "extended";
    if (format == number_format::legacy) return "legacy";

    return "unknown (" + std::string::to_string(s16(format)) + ")";
};


/* actual data */
file file @ 0x00;