#pragma author Surasia
#pragma description Halo Infinite HavokScript 5.1 "luas"
#pragma magic [ 75 63 73 68 ] @ 0x00

import std.io;
import std.mem;
import std.core;
import std.string;

struct String32 {
    s32 length;
    if (length != 0) {
        char s[length - 1];
        u8 endbyte;
    }
};

struct String64 {
    s64 length;
    if (length != 0) {
        char s[length - 1];
        u8 endbyte;
    }
};

enum lua_endian : u8 {
    little_endian = 1,
    big_endian = 0,
};

enum lua_numbertype : u8 {
    _float = 0,
    _int32 = 1,
};

struct lua_enum {
    s32 value;
    String32 string;
};

struct LuaEnum {
    s32 count;
    lua_enum entries[count];
    };

enum HksOpCode : s8 {
        GETFIELD,
        TEST,
        CALL_I,
        CALL_C,
        EQ,
        EQ_BK,
        GETGLOBAL,
        MOVE,
        SELF,
        RETURN,
        GETTABLE_S,
        GETTABLE_N,
        GETTABLE,
        LOADBOOL,
        TFORLOOP,
        SETFIELD,
        SETTABLE_S,
        SETTABLE_S_BK,
        SETTABLE_N,
        SETTABLE_N_BK,
        SETTABLE,
        SETTABLE_BK,
        TAILCALL_I,
        TAILCALL_C,
        TAILCALL_M,
        LOADK,
        LOADNIL,
        SETGLOBAL,
        JMP,
        CALL_M,
        CALL,
        INTRINSIC_INDEX,
        INTRINSIC_NEWINDEX,
        INTRINSIC_SELF,
        INTRINSIC_LITERAL,
        INTRINSIC_NEWINDEX_LITERAL,
        INTRINSIC_SELF_LITERAL,
        TAILCALL,
        GETUPVAL,
        SETUPVAL,
        ADD,
        ADD_BK,
        SUB,
        SUB_BK,
        MUL,
        MUL_BK,
        DIV,
        DIV_BK,
        MOD,
        MOD_BK,
        POW,
        POW_BK,
        NEWTABLE,
        UNM,
        NOT,
        LEN,
        LT,
        LT_BK,
        LE,
        LE_BK,
        CONCAT,
        TESTSET,
        FORPREP,
        FORLOOP,
        SETLIST,
        CLOSE,
        CLOSURE,
        VARARG,
        TAILCALL_I_R1,
        CALL_I_R1,
        SETUPVAL_R1,
        TEST_R1,
        NOT_R1,
        GETFIELD_R1,
        SETFIELD_R1,
        NEWSTRUCT,
        DATA,
        SETSLOTN,
        SETSLOTI,
        SETSLOT,
        SETSLOTS,
        SETSLOTMT,
        CHECKTYPE,
        CHECKTYPES,
        GETSLOT,
        GETSLOTMT,
        SELFSLOT,
        SELFSLOTMT,
        GETFIELD_MM,
        CHECKTYPE_D,
        GETSLOT_D,
        GETGLOBAL_MEM,
    };

enum HksType : u8
    {
        TNIL,
        TBOOLEAN,
        TLIGHTUSERDATA,
        TNUMBER,
        TSTRING,
        TTABLE,
        TFUNCTION,
        TUSERDATA,
        TTHREAD,
        TIFUNCTION,
        TCFUNCTION,
        TUI64,
        TSTRUCT
    };

bitfield REG_CONST_UNUSED {
    argB : 17 & 0x1ffff;
    argA : 8 & 0xff;
};

bitfield REG_NUM_NUM {
    argC : 9 & 0x1ff;
    argB : 8 & 0xff;
    argA : 8 & 0xff;
};

bitfield REG_NUM_UNUSED {
    argB : 8 & 0xff;
    argA : 8 & 0xff;
    argC : 9 & 0x1ff;
};

bitfield UNUSED_OFFSET_UNUSED {
    argA : 8 & 0xff;
    argB : 9 & 0x1ff;
    argC : 8 & 0xff;
};


bitfield LuaBitfield {
    HksOpCode OpCode : 7;
    //Arguments : 25; // read on how to process them at https://raw.githubusercontent.com/soupstream/havok-script-tools/main/HavokScriptToolsCommon/HksOpCodes.cs
    match(OpCode) {
        (HksOpCode::LOADK) : REG_CONST_UNUSED arguments;
        (HksOpCode::SETGLOBAL) : REG_CONST_UNUSED arguments;
        (HksOpCode::NEWTABLE) : REG_NUM_NUM arguments;
        (HksOpCode::CLOSURE) : REG_CONST_UNUSED arguments;
        (HksOpCode::RETURN) : REG_NUM_UNUSED arguments;
        (HksOpCode::NEWSTRUCT) : REG_NUM_NUM arguments;
        (HksOpCode::DATA) : UNUSED_OFFSET_UNUSED arguments;
        (_): arguments : 25;
    }
};

struct LuaInstruction {
    LuaBitfield OpCode;
};

struct LuaConstant {
    HksType type;
    if (type == HksType::TNIL) {
    }
    else if (type == HksType::TSTRING) {
        String64 string;
    }
    else if (type == HksType::TNUMBER) {
        float number;
    }
    else if (type == HksType::TBOOLEAN) {
        bool boolean;
    }
    else if (type == HksType::TLIGHTUSERDATA) {
        s64 userdata;
    }
    else {
        s64 data;
    }
};

struct HksLocal {
    String64 string;
    u32 start;
    u32 end;
};


struct LuaFunction {

    s32 upvaluecount;
    s32 paramcount;
    s8 isVarArg;
    s32 slotCount;
    s32 unk;
    s32 instruction_count;
    if ($ % 4 != 0) {
        $ += (4 - ($ % 4));
    }
    LuaInstruction instructions[instruction_count];
    s32 constantCount;
    LuaConstant constants[constantCount];
    s32 HasDebugInfo;
    if (HasDebugInfo != 0) {
        u32 LineCount;
        u32 LocalsCount;
        u32 UpValueCount;
        u32 LineBegin;
        u32 LineEnd;
        String64 path;
        String64 functionName;
        s32 Lines[LineCount];
        HksLocal Locals[LocalsCount];
        String64 UpValues[UpValueCount];
    }
    s32 function_count;
    LuaFunction children[function_count];
};



struct LuaStructHeader {
    String64 name;
    s32 structID;
    s32 pad;
    s24 unk1;
    HksType type;
    s32 unk2;
};


struct LuaStructMember {
    s32 pad;
    LuaStructHeader header;
    s32 index;
};

struct LuaStruct {
    try {
        u32 unk;
        LuaStructHeader ExtendedStructHeader;
        s64 ExtendedStructMemberCount;
        LuaStructMember ExtendedStructMembers[ExtendedStructMemberCount];
        u32 unk2;
    } catch {
        std::print("WARNING: this file does not support structs.");
    }
    try {
        LuaStructHeader StructHeader;
        s64 StructMemberCount;
        LuaStructMember StructMembers[StructMemberCount];
    } catch {
        std::print("WARNING: this file does not support multiple structs.");
    }
};


struct LuaHeader {
    char luaheader[4];
    u8 version;
    u8 format;
    lua_endian Endianness;
    if (Endianness == lua_endian::big_endian) {
        std::core::set_endian(std::mem::Endian::Big);
    } else {
        std::core::set_endian(std::mem::Endian::Little);
    }
    u8 intSize;
    u8 size_tSize;
    u8 instruction_size;
    u8 number_size;
    lua_numbertype numberType;
    u8 flags;
    u8 unknown;
    LuaEnum enums;
    LuaFunction LuaFunctions;
    LuaStruct LuaStructures;
};

struct Header {
    u32 magic;
    u32 version;
    u64 RootStructAltGUID;
    u64 AssetChecksum;
    u32 DependencyCount;
    s32 DataBlockCount;
    s32 TagStructCount;
    s32 DataReferenceCount;
    s32 TagReferenceCount;
    u32 StringTableSize;
    u32 ZoneSetDataSize;
    u32 Unk_0x34;
    u32 HeaderSize;
    u32 DataSize;
    u32 ResourceDataSize;
    u32 ActualResoureDataSize;
    u8 HeaderAlignment;
    u8 TagDataAlignment;
    u8 ResourceDataAlignment;
    u8 ActualResourceDataAlignment;
    s32 IsResource;
};

struct _s_tagblock {
    char tagblock[16];
    s32 count;
};

struct _s_resource {
    char resource[12];
    s32 count;
};

struct _s_data {
    char data[24];
};


struct Data_Block {
    u32 Size;
    u16 Padding;
    u16 Section;
    u64 Offset;
};

struct Tag_Def_Structure {
    s64 GUID_1;
    s64 GUID_2;
    u16 Type;
    u16 Unk_0x12;
    s32 TargetIndex;
    s32 FieldBlock;
    u32 FieldOffset;
};

struct Tag_Dependency {
    char GroupTag[4] [[format("std::string::reverse")]];
    u32 NameOffset;
    u64 AssetID;
    u32 GlobalID;
    u32 Unk_0x14;
};

struct Data_Reference {
    s32 ParentStructIndex;
    s32 Unk_0x04;
    s32 TargetIndex;
    s32 FieldBlock;
    u32 FieldOffset;
};

struct _s_tagref {
    s64 GlobalHandle;
    s32 ref_id_int;
    s32 ref_id_sub;
    s32 ref_id_center_int;
    char TagGroupRev[4] [[format("std::string::reverse")]];
    s32 local_handle;
};

struct Tag_Fixup_Reference {
    s32 FieldBlock;
    u32 FieldOffset;
    u32 NameOffset;
    s32 DependencyIndex;
    _s_tagref tagreference @ header.HeaderSize + datablocks[FieldBlock].Offset + FieldOffset;
};

struct InternalStruct {
    s64 vtablespace;
    u32 global_tag_id;
    char local_tag_handle[4];
};

struct LuaReferencedTagContainer {
   _s_tagref tagReference;
};
struct LuaScriptTagDefinition {
   u32 luaFileName;
   _s_data luaFileData;
   char luaFileNameString[256];
   _s_tagblock referencedTags_count;
   LuaHeader lua_header;
   try {
    char pad[14];
    LuaReferencedTagContainer referencedTags[referencedTags_count.count];
   } catch {
    std::print("This file does not support referenced Tags.");
   }
};


// TAG LAYOUT
Header header @ 0x00;
Tag_Dependency Dependencies[header.DependencyCount] @ 0x50;
Data_Block datablocks[header.DataBlockCount] @ header.DependencyCount * 0x18 + 0x50;
Tag_Def_Structure tagdefstructure[header.TagStructCount] @ header.DependencyCount * 0x18 + 0x50 + header.DataBlockCount * 0x10;
Data_Reference Data_References[header.DataReferenceCount] @ header.DependencyCount * 0x18 + 0x50 + header.DataBlockCount * 0x10 + header.TagStructCount * 0x20;
Tag_Fixup_Reference tagfixupreference[header.TagReferenceCount] @ header.DependencyCount * 0x18 + 0x50 + header.DataBlockCount * 0x10 + header.TagStructCount * 0x20 + header.DataReferenceCount * 0x14;
char ZoneSet[header.ZoneSetDataSize] @ header.HeaderSize - header.ZoneSetDataSize;
InternalStruct internalstruct @ header.HeaderSize;
LuaScriptTagDefinition lua_script @ header.HeaderSize + 16;
