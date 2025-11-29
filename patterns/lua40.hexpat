#pragma description Lua 4.0 bytecode
#pragma magic [ 1B 4C 75 61 40 ] @ 0x00
// based off of https://www.lua.org/source/4.0/dump.c.html

import std.io;

namespace impl {
    fn format_LuaString(auto string) {
       if (string.size == 0) {
           return "None";
        }
        return std::format("\"{}\"", string.data);
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
    u8 id_chunk;
    char magic[3];       
    Version version;
    u8 endianness;
    u8 size_of_int;
    u8 size_of_size_t;
    u8 size_of_instruction; // ???
    u8 size_INSTRUCTION;      // SIZE_INSTRUCTION in Lua 4 source
    u8 size_OP;          // SIZE_OP
    u8 size_B;           // SIZE_B
    u8 size_number;      // sizeof(Number)
    
    if (size_number == 4) {
        u32 TEST_NUMBER;
    } else {
        u64 TEST_NUMBER;
    }
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

struct Vector<T> {
    if (header.size_of_int == 4) {
        u32 size;
    } else {
        u64 size;
    }
    if (size > 0) {
        T values[size];
    }
};

struct LocalVar {
    LuaString varname;
    if (header.size_of_int == 4) {
        u32 startpc;
        u32 endpc;
    } else {
        u64 startpc;
        u64 endpc;
        
    }
};

struct LuaDebugInfo {
    Vector<LocalVar> localVar;
    if (header.size_of_int == 4) {
        Vector<u32> lineInfo;     // i think this is correct
    } else {
        Vector<u64> lineInfo;
    }

};

bitfield LuaNumber {
    raw : header.size_number;
};

struct LuaConstants{
    Vector<LuaString> stringConstants;
    if (header.size_of_int == 4) {
        Vector<u32> intConstants;
    } else {
        Vector<u64> intConstants;
    }
    Vector<LuaFunction> protos;    
};

struct LuaFunction {
    LuaString source;
    if (header.size_of_int == 4) {
        u32 linedefined;
        u32 numparams;    
    } else {
        u64 linedefined;
        u64 numparams;   
    }
    u8 is_vararg;
    
    if (header.size_of_int == 4) {
        u32 maxstacksize;
    } else {
        u64 maxstacksize;
    }
    
    LuaDebugInfo debugInfo;
    LuaConstants luaConstants;
    if (header.size_of_int == 4) {
        Vector<u32> code;
    } else {
        Vector<u64> code;
    }
};

LuaFunction toplevelFunction @ 0x15; // Lua header size is always same size