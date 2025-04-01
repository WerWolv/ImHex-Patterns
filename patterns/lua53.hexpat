#pragma description Lua 5.3 bytecode
#pragma magic [ 1B 4C 75 61 53 ] @ 0x00

import std.io;
import type.base;

namespace impl {
    fn format_LuaString(auto string) {
       if (string.size == 0) {
           return "None";
        }
        return std::format("\"{}\"", string.data);
    };

    fn format_Constant(auto constant) {
       return constant.data;
    };

    fn format_Version(auto ver) {
       return std::format("Ver. {}.{}", ver.major, ver.minor);
    };
}
using LuaFunction;

bitfield Version {
    minor : 4;
    major : 4;
} [[format("impl::format_Version")]];

struct LuaBinaryHeader {
    char magic[4];
    Version version_number;
    u8 format_version;
    char LUAC_DATA[6];
    u8 size_of_int;
    u8 size_of_size_t;
    u8 size_of_Instruction;
    u8 size_of_lua_Integer;
    u8 sizeof_lua_Number;
    type::Hex<u64> LUAC_INT;
    double LUAC_NUM;
};

struct LuaString {
    u8 size;
    if (size > 0) {
        char data[size-1];
    }
}[[format("impl::format_LuaString")]];

struct LuaConstant {
    u8 type;
    if (type == 0) {  // LUA_TNIL
        // NULL
    } else if (type == 1) {  // LUA_TBOOLEAN
        u8 data;
    } else if (type == 3) {  // LUA_TNUMFLT
        double data;
    } else if (type == 0x13) {  // LUA_TNUMINT
        u64 data;
    } else if (type == 4 || type == 0x14 ) {  // LUA_TSHRSTR LUA_TLNGSTR
        LuaString data;
    }
}[[format("impl::format_Constant")]];

struct LuaUpvalue {
    u8 instack;
    u8 idx;
};

struct Vector<T> {
    u32 size;
    T values[size];
};

struct LocalVar {
    LuaString varname;
    u32 startpc;
    u32 endpc;
};

struct LuaDebugInfo {
    Vector<u32> lineInfo;
    Vector<LocalVar> local_vars;
    Vector<LuaString> upvalues;
};

struct LuaFunction {
    LuaString source;
    u32 line_defined;
    u32 last_line_defined;
    u8 number_of_parameters;
    u8 is_vararg;
    u8 maxstacksize;
    Vector<u32> code;
    Vector<LuaConstant> constants;
    Vector<LuaUpvalue> upvalues;
    Vector<LuaFunction> protos;
    LuaDebugInfo debugInfo;
};

struct LuaFile {
    LuaBinaryHeader header;
    u8 sizeupvalues;
    LuaFunction func;
};

LuaFile file @ 0;
