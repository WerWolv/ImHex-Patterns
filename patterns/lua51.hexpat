#pragma description Lua 5.1 bytecode

import std.io;

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
};

LuaBinaryHeader header @ 0;

struct LuaString {
    if (header.size_of_size_t == 4) {
        u32 size;
    } else {
        u64 size;
    }
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

struct Vector<T> {
    u32 size;
    if (size > 0) {
        T values[size];
    }
};

struct LocalVar {
    LuaString varname;
    u32 startpc;
    u32 endpc;
};

struct LuaDebugInfo {
    Vector<u32> lineInfo;
    Vector<LocalVar> localVar;
    Vector<LuaString> upvalues;
};

struct LuaConstants{
    Vector<LuaConstant> constants;
    u32 sizep;  // size of proto
    if (sizep > 0) {
        LuaFunction protos[sizep];
    }
};

struct LuaFunction {
    LuaString source;
    u32 linedefined;
    u32 lastlinedefined;
    u8 nups;  // number of upvalues
    u8 numparams;
    u8 is_vararg;
    u8 maxstacksize;
    Vector<u32> code;
    LuaConstants luaConstants;
    LuaDebugInfo debugInfo;
};

LuaFunction toplevelFunction @ 12; // Lua header size is always 12 bytes