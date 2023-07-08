#include <std/io.pat>
#include <std/mem.pat>

namespace impl {

    fn transform_Size_array(auto array) {
        u128 res = 0;
        for(u8 i = 0, (array[i] & 0x80 == 0) && (i < 9), i+=1) {
            res <<= 7;
            res |= array[i] & 0x7f;
        }
        res <<= 7;
        res |= array[sizeof(array)-1] & 0x7f;
        return res;
    };
    
    fn format_Size(auto leb128) {
        u128 res = impl::transform_Size_array(leb128.array);
        return std::format("{} ({:#x})", res, res);
    };

    fn transform_Size(auto leb128) {
        return impl::transform_Size_array(leb128.array);
    };
    
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

struct Size {
        u8 array[while(addressof(this) == $ || ((addressof(this)-$ < 9) && (std::mem::read_unsigned($-1, 1) & 0x80 == 0)))] [[hidden]];
} [[sealed, format("impl::format_Size"), transform("impl::transform_Size")]];
    

bitfield Version {
    minor : 4;
    major : 4;
} [[format("impl::format_Version")]];

struct LuaBinaryHeader {
    u32 magic;
    Version version_number;
    u8 format_version;
    u8 error_detection_data[6];
    u8 size_of_int;
    u8 size_of_size_t;
    u8 size_of_number;
    u64 luac_int;
    double luac_num;
};
struct LuaString {
    Size size;
    if (size > 0) {
        char data[size-1];
    }
}[[format("impl::format_LuaString")]];

struct LuaConstant {
    u8 type;
    if (type == 3) {
        u64 data;
    } else if (type == 0x13) {
        double data;
    } else if (type == 0x4 || type == 0x14) {
        LuaString data;
    }
}[[format("impl::format_Constant")]];

struct LuaUpvalue {
    u8 instack;
    u8 idx;
    u8 kind;
};

struct Vector<T> {
    Size size;
    T values[size];
};


struct AbsLineInfo {
    Size pc;
    Size line;
};

struct LocalVar {
    LuaString varname;
    Size startpc;
    Size endpc;
};

struct LuaDebugInfo {
    Vector<s8> lineInfo;
    Vector<AbsLineInfo> abslineinfo;
    Vector<LocalVar> local_vars;
    Vector<LuaString> upvalues;
};

struct LuaFunction {
    LuaString source;
    Size line_defined;
    Size last_line_defined;
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
    u8 size_of_upvalues;
    LuaFunction func;
};

LuaFile file @ 0;
