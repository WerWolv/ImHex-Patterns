
/*
    References:
        Pickle Source Code:
            https://github.com/python/cpython/blob/main/Lib/pickle.py
        Pickle Protocol Version Breakdown:
            https://docs.python.org/3.13/library/pickle.html#data-stream-format
        Pickle OpCode Breakdown:
            https://github.com/python/cpython/blob/main/Lib/pickletools.py
*/

#pragma author ODeux
#pragma description Python Binary Object Serialization Protocol

#pragma endian little

import std.mem;
import std.string;

#pragma array_limit 524288

fn todo(auto message){
    std::error(std::format("@0x{:08X} TODO: " + message, $));
};

fn utf8_fmt(auto s){
    return std::format("{}", s);
};
#define UTF8_FMT format("utf8_fmt"), transform("utf8_fmt")

fn utf8_rl_fmt(auto s){
    str new_s = std::string::substr(s, 0, std::string::length(s) - 1);
    return std::format("{}", new_s);
};
#define UTF8_RL_FMT format("utf8_rl_fmt"), transform("utf8_rl_fmt")

fn int_rl_fmt(auto s){
    if(s == "01\n") return true; /* == TRUE(b'I01\n')[1:] */
    if(s == "00\n") return false; /* == FALSE(b'I00\n')[1:] */
    str new_s = std::string::substr(s, 0, std::string::length(s) - 1);
    return std::string::parse_int(new_s, 0);
};
#define INT_RL_FMT format("int_rl_fmt"), transform("int_rl_fmt")

fn float_rl_fmt(auto s){
    str new_s = std::string::substr(s, 0, std::string::length(s) - 1);
    return std::string::parse_float(new_s);
};
#define FLOAT_RL_FMT format("float_rl_fmt"), transform("float_rl_fmt")

fn long_rl_fmt(auto s){
    str new_s = std::string::substr(s, 0, std::string::length(s) - 1);
    if(new_s != "" && std::string::at(new_s, std::string::length(new_s) - 1) == "L")
        new_s = std::string::substr(new_s, 0, std::string::length(new_s) - 1);
    return std::string::parse_int(new_s, 0);
};
#define LONG_RL_FMT format("long_rl_fmt"), transform("long_rl_fmt")

fn ascii_rl_fmt(auto s){
    return std::string::substr(s, 0, std::string::length(s) - 1);
};
#define ASCII_RL_FMT format("ascii_rl_fmt"), transform("ascii_rl_fmt")

fn integer_rl_fmt(auto s){
    str new_s = std::string::substr(s, 0, std::string::length(s) - 1);
    return std::string::parse_int(new_s, 0);
};
#define INTEGER_RL_FMT format("integer_rl_fmt"), transform("integer_rl_fmt")

fn string_rl_fmt(auto s){
    str new_s = std::string::substr(s, 0, std::string::length(s) - 1);
    auto length = std::string::length(new_s);
    if(length >= 2 && new_s[0] == new_s[length - 1] && (new_s[0] == '\'' || new_s[0] == '"'))
        new_s = std::string::substr(new_s, 1, length - 1);
    else std::error("the STRING opcode argument must be quoted");
    return new_s;
};
#define STRING_RL_FMT format("string_rl_fmt"), transform("string_rl_fmt")

enum OpcodesEnum: u8{
    MARK             = '(',  /* push special markobject on stack */
    STOP             = '.',  /* every pickle ends with STOP */
    POP              = '0',  /* discard topmost stack item */
    POP_MARK         = '1',  /* discard stack top through topmost markobject */
    DUP              = '2',  /* duplicate top stack item */
    FLOAT            = 'F',  /* push float object; decimal string argument */
    INT              = 'I',  /* push integer or bool; decimal string argument */
    BININT           = 'J',  /* push four-byte signed int */
    BININT1          = 'K',  /* push 1-byte unsigned int */
    LONG             = 'L',  /* push long; decimal string argument */
    BININT2          = 'M',  /* push 2-byte unsigned int */
    NONE             = 'N',  /* push None */
    PERSID           = 'P',  /* push persistent object; id is taken from string arg */
    BINPERSID        = 'Q',  /*  "       "         "  ;  "  "   "     "  stack */
    REDUCE           = 'R',  /* apply callable to argtuple, both on stack */
    STRING           = 'S',  /* push string; NL-terminated string argument */
    BINSTRING        = 'T',  /* push string; counted binary string argument */
    SHORT_BINSTRING  = 'U',  /*  "     "   ;    "      "       "      " < 256 bytes */
    UNICODE          = 'V',  /* push Unicode string; raw-unicode-escaped'd argument */
    BINUNICODE       = 'X',  /*   "     "       "  ; counted UTF-8 string argument */
    APPEND           = 'a',  /* append stack top to list below it */
    BUILD            = 'b',  /* call __setstate__ or __dict__.update() */
    GLOBAL           = 'c',  /* push self.find_class(modname, name); 2 string args */
    DICT             = 'd',  /* build a dict from stack items */
    EMPTY_DICT       = '}',  /* push empty dict */
    APPENDS          = 'e',  /* extend list on stack by topmost stack slice */
    GET              = 'g',  /* push item from memo on stack; index is string arg */
    BINGET           = 'h',  /*   "    "    "    "   "   "  ;   "    " 1-byte arg */
    INST             = 'i',  /* build & push class instance */
    LONG_BINGET      = 'j',  /* push item from memo on stack; index is 4-byte arg */
    LIST             = 'l',  /* build list from topmost stack items */
    EMPTY_LIST       = ']',  /* push empty list */
    OBJ              = 'o',  /* build & push class instance */
    PUT              = 'p',  /* store stack top in memo; index is string arg */
    BINPUT           = 'q',  /*   "     "    "   "   " ;   "    " 1-byte arg */
    LONG_BINPUT      = 'r',  /*   "     "    "   "   " ;   "    " 4-byte arg */
    SETITEM          = 's',  /* add key+value pair to dict */
    TUPLE            = 't',  /* build tuple from topmost stack items */
    EMPTY_TUPLE      = ')',  /* push empty tuple */
    SETITEMS         = 'u',  /* modify dict by adding topmost key+value pairs */
    BINFLOAT         = 'G',  /* push float; arg is 8-byte float encoding */
    /* ---- Protocol 2 ---- */
    PROTO            = 0x80, /* identify pickle protocol */
    NEWOBJ           = 0x81, /* build object by applying cls.__new__ to argtuple */
    EXT1             = 0x82, /* push object from extension registry; 1-byte index */
    EXT2             = 0x83, /* ditto, but 2-byte index */
    EXT4             = 0x84, /* ditto, but 4-byte index */
    TUPLE1           = 0x85, /* build 1-tuple from stack top */
    TUPLE2           = 0x86, /* build 2-tuple from two topmost stack items */
    TUPLE3           = 0x87, /* build 3-tuple from three topmost stack items */
    NEWTRUE          = 0x88, /* push True */
    NEWFALSE         = 0x89, /* push False */
    LONG1            = 0x8A, /* push long from < 256 bytes */
    LONG4            = 0x8B, /* push really big long */
    /* ---- Protocol 3 (Python 3.x) ---- */
    BINBYTES         = 'B',  /* push bytes; counted binary string argument */
    SHORT_BINBYTES   = 'C',  /*  "     "   ;    "      "       "      " < 256 bytes */
    /* ---- Protocol 4 ---- */
    SHORT_BINUNICODE = 0x8C, /* push short string; UTF-8 length < 256 bytes */
    BINUNICODE8      = 0x8D, /* push very long string */
    BINBYTES8        = 0x8E, /* push very long bytes string */
    EMPTY_SET        = 0x8F, /* push empty set on the stack */
    ADDITEMS         = 0x90, /* modify set by adding topmost stack items */
    FROZENSET        = 0x91, /* build frozenset from topmost stack items */
    NEWOBJ_EX        = 0x92, /* like NEWOBJ but work with keyword only arguments */
    STACK_GLOBAL     = 0x93, /* same as GLOBAL but using names on the stacks */
    MEMOIZE          = 0x94, /* store top of the stack in memo */
    FRAME            = 0x95, /* indicate the beginning of a new frame */
    /* ---- Protocol 5 ---- */
    BYTEARRAY8       = 0x96, /* push bytearray */
    NEXT_BUFFER      = 0x97, /* push next out-of-band buffer */
    READONLY_BUFFER  = 0x98  /* make top of stack readonly */
};

fn readline(){
    auto i = 0;
    while(std::mem::read_unsigned($ + i, 1) != '\n') i += 1;
    return i + 1;
};

struct Opcodes{
    OpcodesEnum opcode;
    match(opcode){
        (OpcodesEnum::MARK): {}
        (OpcodesEnum::STOP): break;
        (OpcodesEnum::POP): {}
        (OpcodesEnum::POP_MARK): {}
        (OpcodesEnum::DUP): {}
        (OpcodesEnum::FLOAT): {
            char Float[readline()] [[FLOAT_RL_FMT]]; /* float(readline()[:1]) */
        }
        (OpcodesEnum::INT): {
            /* == TRUE(b'I01\n')[1:], == FALSE(b'I00\n')[1:], int(readline(), 0) */
            char Int[readline()] [[INT_RL_FMT]];
        }
        (OpcodesEnum::BININT): {
            s32 Int;
        }
        (OpcodesEnum::BININT1): {
            s8 Int;
        }
        (OpcodesEnum::LONG): {
            /* val = readline()[:-1], val = val and val[-1] == b"L"[0] ? val[:-1]: val */
            char Long[readline()] [[LONG_RL_FMT]]; /* int(val, 0) */
        }
        (OpcodesEnum::BININT2): {
            u16 Int;
        }
        (OpcodesEnum::NONE): {}
        (OpcodesEnum::PERSID): {
            char id[readline()] [[ASCII_RL_FMT]]; /* readline()[:-1].decode("ascii") */
        }
        (OpcodesEnum::BINPERSID): {}
        (OpcodesEnum::REDUCE): {}
        /*
            def _decode_string(self, value):
                # Used to allow strings from Python 2 to be decoded either as bytes or Unicode strings.
                # This should be used only with the STRING, BINSTRING and SHORT_BINSTRING opcodes.
                if self.encoding == "bytes":
                    return value
                else:
                    return value.decode(self.encoding, self.errors)
        */
        (OpcodesEnum::STRING): {
            /* data must be in quotes ("..." or '...'), dataStripped = stripQuote(readline()[:-1]) */
            /* _decode_string(codecs.escape_decode(dataStripped)[0]) */
            char data[readline()] [[STRING_RL_FMT]];
        }
        (OpcodesEnum::BINSTRING): {
            s32 length;
            char data[length]; /* _decode_string(data) */
        }
        (OpcodesEnum::SHORT_BINSTRING): {
            u8 length;
            char data[length]; /* _decode_string(data) */
        }
        (OpcodesEnum::UNICODE): {
            /*
                "raw-unicode-escape":
                Latin-1 encoding with \uXXXX and \UXXXXXXXX for other code points.
                Existing backslashes are not escaped in any way.
            */
            char data[readline()] [[UTF8_RL_FMT]]; /* str(readline()[:-1], "raw-unicode-escape") */
        }
        (OpcodesEnum::BINUNICODE): {
            u32 length;
            char data[length] [[UTF8_FMT]]; /* str(data, "utf-8", "surrogatepass") */
        }
        (OpcodesEnum::APPEND): {}
        (OpcodesEnum::BUILD): {}
        (OpcodesEnum::GLOBAL): {
            char module[readline()] [[UTF8_RL_FMT]]; /* readline()[:-1].decode("utf-8") */
            char name[readline()] [[UTF8_RL_FMT]]; /* readline()[:-1].decode("utf-8") */
        }
        (OpcodesEnum::DICT): {}
        (OpcodesEnum::EMPTY_DICT): {}
        (OpcodesEnum::APPENDS): {}
        (OpcodesEnum::GET): {
            char index[readline()] [[INTEGER_RL_FMT]]; /* int(readline()[:-1]) */
        }
        (OpcodesEnum::BINGET): {
            u8 index;
        }
        (OpcodesEnum::INST): {
            char module[readline()] [[ASCII_RL_FMT]]; /* readline()[:-1].decode("ascii") */
            char name[readline()] [[ASCII_RL_FMT]]; /* readline()[:-1].decode("ascii") */
        }
        (OpcodesEnum::LONG_BINGET): {
            u32 index;
        }
        (OpcodesEnum::LIST): {}
        (OpcodesEnum::EMPTY_LIST): {}
        (OpcodesEnum::OBJ): {}
        (OpcodesEnum::PUT): {
            char index[readline()] [[INTEGER_RL_FMT]]; /* int(readline()[:-1]) */
        }
        (OpcodesEnum::BINPUT): {
            s8 index;
        }
        (OpcodesEnum::LONG_BINPUT): {
            u32 index;
        }
        (OpcodesEnum::SETITEM): {}
        (OpcodesEnum::TUPLE): {}
        (OpcodesEnum::EMPTY_TUPLE): {}
        (OpcodesEnum::SETITEMS): {}
        (OpcodesEnum::BINFLOAT): {
            be double Double;
        }
        /* ---- Protocol 2 ---- */
        (OpcodesEnum::PROTO): {
            u8 version;
        }
        (OpcodesEnum::NEWOBJ): {}
        (OpcodesEnum::EXT1): {
            u8 code;
        }
        (OpcodesEnum::EXT2): {
            u16 code;
        }
        (OpcodesEnum::EXT4): {
            s32 code;
        }
        (OpcodesEnum::TUPLE1): {}
        (OpcodesEnum::TUPLE2): {}
        (OpcodesEnum::TUPLE3): {}
        (OpcodesEnum::NEWTRUE): {}
        (OpcodesEnum::NEWFALSE): {}
        /*
            def decode_long(data):
                r"""Decode a long from a two's complement little-endian binary string.
                >>> decode_long(b"") => 0
                >>> decode_long(b"\xff\x00") => 255
                >>> decode_long(b"\xff\x7f") => 32767
                >>> decode_long(b"\x00\xff") => -256
                >>> decode_long(b"\x00\x80") => -32768
                >>> decode_long(b"\x80") => -128
                >>> decode_long(b"\x7f") => 127
                """
                return int.from_bytes(data, byteorder="little", signed=True)
        */
        (OpcodesEnum::LONG1): {
            u8 length;
            u8 data[length]; /* decode_long(data) */
        }
        (OpcodesEnum::LONG4): {
            s32 length;
            u8 data[length]; /* decode_long(data) */
        }
        /* ---- Protocol 3 (Python 3.x) ---- */
        (OpcodesEnum::BINBYTES): {
            u32 length;
            u8 bytes[length];
        }
        (OpcodesEnum::SHORT_BINBYTES): {
            u8 length;
            u8 bytes[length];
        }
        /* ---- Protocol 4 ---- */
        (OpcodesEnum::SHORT_BINUNICODE): {
            u8 length;
            char data[length] [[UTF8_FMT]]; /* str(data, "utf-8", "surrogatepass") */
        }
        (OpcodesEnum::BINUNICODE8): {
            u64 length;
            char data[length] [[UTF8_FMT]]; /* str(data, "utf-8", "surrogatepass") */
        }
        (OpcodesEnum::BINBYTES8): {
            u64 length;
            u8 bytes[length];
        }
        (OpcodesEnum::EMPTY_SET): {}
        (OpcodesEnum::ADDITEMS): {}
        (OpcodesEnum::FROZENSET): {}
        (OpcodesEnum::NEWOBJ_EX): {}
        (OpcodesEnum::STACK_GLOBAL): {}
        (OpcodesEnum::MEMOIZE): {}
        (OpcodesEnum::FRAME): {
            u64 length;
            Opcodes opcodes[while($ < addressof(length) + sizeof(length) + length)];
        }
        /* ---- Protocol 5 ---- */
        (OpcodesEnum::BYTEARRAY8): {
            u64 length;
            u8 array[length];
        }
        (OpcodesEnum::NEXT_BUFFER): {}
        (OpcodesEnum::READONLY_BUFFER): {}
        (_): std::error(std::format("Unrecognized {}", opcode));
    }
};

struct Pickle{
    Opcodes opcodes[while(!std::mem::eof())];
};

Pickle pickle @ 0x0;
