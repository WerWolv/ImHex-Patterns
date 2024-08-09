#pragma description Lua 5.2 bytecode

import std.io;
import std.mem;

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
    u8 endianness;
    u8 size_of_int;
    u8 size_of_size_t;
    u8 size_of_Instruction;
    u8 lua_Number;
    u8 is_lua_Number_integral;
    char LUAC_TAIL[6];
};

struct LuaString {
    u64 size;
    if (size > 0) {
        char data[size];
    }
}[[format("impl::format_LuaString")]];

struct LuaConstant {
    u8 type;
    if (type == 0) {  // LUA_TNIL
        // NULL
    } else if (type == 1) {  // LUA_TBOOLEAN
        u8 data;
    } else if (type == 3) {  // LUA_TNUMBER
        double data;
    } else if (type == 4) {  // LUA_TSTRING
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
    LuaString source;
    Vector<u32> lineInfo;
    Vector<LocalVar> local_vars;
    Vector<LuaString> upvalues;
};

struct LuaConstants {
    Vector<LuaConstant> constants;
    u32 sizep;  // size of proto
    if (sizep > 0) {
        LuaFunction protos[sizep];
    }
};

struct LuaFunction {
    u32 line_defined;
    u32 last_line_defined;
    u8 number_of_parameters;
    u8 is_vararg;
    u8 maxstacksize;
    Vector<u32> code;
    LuaConstants luaConstants;
    Vector<LuaUpvalue> upvalues;
    LuaDebugInfo debugInfo;
};

struct LuaFile {
    LuaBinaryHeader header;
    LuaFunction func;
};

LuaFile file @ 0;
