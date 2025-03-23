#pragma author Scrivener07 and Jonathan Ostrus
#pragma description Bethesda Papyrus executable compiled script file

#pragma magic [FA 57 C0 DE] @ 0x00
#pragma magic [DE C0 57 FA] @ 0x00

import std.sys;
import std.core;
import std.string;
import std.time;

enum GAMEID : u16 {
    GAME_Skyrim     = 1,
    GAME_Fallout4   = 2,
    GAME_Fallout76  = 3,
    GAME_Starfield  = 4
};

GAMEID g_GameId;

namespace formatter {

    fn pexversion(ref auto data) {
        return std::format("{}.{}", data.MajorVersion, data.MinorVersion);
    };

    fn structname(ref auto data) {
        return StringLookup(data.name);
    };

    fn typedstructname(ref auto data) {
        return std::format("{0} {1}", StringLookup(data.typeName), StringLookup(data.name));
    };

    fn time(ref auto data) {
        // We will only support dates back to the epoch
        std::time::Time time64 = std::time::to_utc(data.Time);
        return std::time::format(time64, "%c");
    };

    fn vartype(u8 data) {
        match (data)
        {
            (0x0): return "object";
            (0x1): return "identifier";
            (0x2): return "string";
            (0x3): return "integer";
            (0x4): return "float";
            (0x5): return "bool";
            (_):   return "Unknown type";
        }
    };
    
    fn vartypestruct(ref auto data) {
        return formatter::vartype(data.varType);
    };

    fn arraycount(ref auto data) {
        return std::format("[{}]", data.count);
    };

    fn functiontype(u8 data) {
        match(data) {
            (0): return "regular";
            (1): return "property getter";
            (2): return "property setter";
            (3): std::assert(true, "Unknown function type");
        }
    };

    fn resolveop(u8 op) {
        match (op)
        {
            (0x00): return "nop";
            (0x01): return "iadd";
            (0x02): return "fadd";
            (0x03): return "isub";
            (0x04): return "fsub";
            (0x05): return "imul";
            (0x06): return "fmul";
            (0x07): return "idiv";
            (0x08): return "fdiv";
            (0x09): return "imod";
            (0x0A): return "not";
            (0x0B): return "ineg";
            (0x0C): return "fneg";
            (0x0D): return "assign";
            (0x0E): return "cast";
            (0x0F): return "cmp_eq";
            (0x10): return "cmp_lt";
            (0x11): return "cmp_lte";
            (0x12): return "cmp_gt";
            (0x13): return "comp_gte";
            (0x14): return "jmp";
            (0x15): return "jmpt";
            (0x16): return "jmpf";
            (0x17): return "callmethod";
            (0x18): return "callparent";
            (0x19): return "callstatic";
            (0x1A): return "return";
            (0x1B): return "strcat";
            (0x1C): return "propget";
            (0x1D): return "propset";
            (0x1E): return "array_create";
            (0x1F): return "array_length";
            (0x20): return "array_getlement";
            (0x21): return "array_setelement";
            (0x22): return "array_findelement";
            (0x23): return "array_rfindelement";
            (0x24): return "is";
            (0x25): return "struct_create";
            (0x26): return "struct_get";
            (0x27): return "struct_set";
            (0x28): return "array_findstruct";
            (0x29): return "array_rfindstruct";
            (0x2A): return "array_add";
            (0x2B): return "array_insert";
            (0x2C): return "array_removelast";
            (0x2D): return "array_remove";
            (0x2E): return "array_clear";
            (0x2F): return "array_getallmatchingstructs";
            (0x30): return "lock_guards";
            (0x31): return "unlock_guards";
            (0x32): return "try_lock_guards";
            (_): return "Unknown";
        }
    };

    fn resolveopstruct(auto data) {
        return formatter::resolveop(data.op);
    };

}

fn StringLookup(u16 idx) {
    return pex.stringsTable.strings[idx];
};

struct PexVersion {
    u8 MajorVersion;
    u8 MinorVersion;
} [[sealed, format("formatter::pexversion")]];

using StringReference = u16 [[format("StringLookup")]];

// Dynamic array of strings
struct StringsTable {
    u16 count;
    if (count > 0)
        std::string::SizedString<u16> strings[count];
} [[format("formatter::arraycount")]];

struct Time {
    u64 Time;
} [[sealed, format("formatter::time")]];

struct VariableData {
    u8 varType [[format("formatter::vartype")]];
    match (varType)
    {
        (0x0): {} // object pointer
        (0x1): StringReference stringVal; // identifier
        (0x2): StringReference stringVal; // string
        (0x3): s32 intVal; // integer
        (0x4): float floatVal;
        (0x5): bool boolVal;
        (_): std::assert(false, "Unknown type for variable data");
    }
} [[format("formatter::vartypestruct")]];

struct VariableType {
    StringReference name;
    StringReference varType;
};

struct VariableTypes {
    u16 count;
    if (count > 0)
        VariableType parameter[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Instruction {
    u8 op [[format("formatter::resolveop")]];
    match (op)
    {
    (
        0x00   // nop
    ): {}
    (
        0x01 | // iadd
        0x02 | // fadd
        0x03 | // isub
        0x04 | // fsub
        0x05 | // imul
        0x06 | // fmul
        0x07 | // idiv
        0x08 | // fdiv
        0x09 | // imod
        0x0F | // cmp_eq
        0x10 | // cmp_lt
        0x11 | // cmp_lte
        0x12 | // cmp_gt
        0x13 | // comp_gte
        0x1B | // strcat
        0x1C | // propget
        0x1D | // propset
        0x20 | // array_getlement
        0x21 | // array_setelement
        0x24 | // is
        0x26 | // struct_get
        0x27 | // struct_set
        0x2A | // array_add
        0x2B | // array_insert
        0x2D   // array_remove
    ): VariableData arguments[3];
    (
        0x22 | // array_findelement
        0x23   // array_rfindelement
    ): VariableData arguments[4];
    (
        0x14 | // jmp
        0x1A | // return
        0x25 | // struct_create
        0x2C | // array_removelast
        0x2E   // array_clear
    ): VariableData arguments[1];
    (
        0x0A | // not
        0x0B | // ineg
        0x0C | // fneg
        0x0D | // assign
        0x0E | // cast
        0x15 | // jmpt
        0x16 | // jmpf
        0x1E | // array_create
        0x1F   // array_length
    ): VariableData arguments[2];
    (
        0x28 | // array_findstruct
        0x29   // array_rfindstruct
    ): VariableData arguments[5];
    (
        0x2F   // array_getallmatchingstructs
    ): VariableData arguments[6];
    (
        0x17 | // callmethod
        0x19   // callstatic
    ): {
        VariableData arguments[4];
        std::assert(arguments[3].varType == 0x3, "VarArgs not integer");
        if (arguments[3].intVal > 0)
            VariableData vararguments[arguments[3].intVal];
        }
    (
        0x18   // callparent
    ): {
        VariableData arguments[3];
        std::assert(arguments[2].varType == 0x3, "VarArgs not integer");
        if (arguments[2].intVal > 0)
            VariableData vararguments[arguments[2].intVal];
        }
    (
        0x30 | // lock_guards
        0x31   // unlock_guards
    ): {
        VariableData arguments[1];
        std::assert(arguments[0].varType == 0x3, "VarArgs not integer");
        if (arguments[0].intVal > 0)
            VariableData vararguments[arguments[0].intVal];
        }
    (
        0x32   // try_lock_guards
    ): {
        VariableData arguments[2];
        std::assert(arguments[1].varType == 0x3, "VarArgs not integer");
        if (arguments[1].intVal > 0)
            VariableData vararguments[arguments[1].intVal];
        }
    (_): {
        std::print("Invalid opcode: {:02x}", op);
        std::assert(false, "Invalid opcode");
        }
    }
} [[format("formatter::resolveopstruct")]];;

struct Instructions {
    u16 count;
    if (count > 0)
        Instruction instruction[count] [[inline]];
} [[format("formatter::arraycount")]];

/*
 
 this "BaseFunction" struct is used by the Papyrus struct property
 getter and setter functions, and by regular named functions.
 
 */
struct BaseFunction {
    StringReference returnType;
    StringReference docString;
    u32 userFlags;
    u8 flags;
    VariableTypes arguments;
    VariableTypes locals;
    Instructions instructions;
};

struct NamedFunction {
    StringReference name;
    BaseFunction function [[inline]];
} [[format("formatter::structname")]];

struct NamedFunctions {
    u16 count;
    if (count > 0)
        NamedFunction function[count] [[inline]];
} [[format("formatter::arraycount")]];

struct State {
    StringReference name;
    NamedFunctions functions;
} [[format("formatter::structname")]];

struct SyncStates {
    u16 count;
    if (count > 0)
        StringReference names[count] [[inline]];
} [[format("formatter::arraycount")]];

struct States {
    u16 count;
    if (count > 0)
        State state[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Property {
    StringReference name;
    StringReference typeName;
    StringReference docString;
    u32 userFlags;
    u8 flags;
    if ((flags & 0x4) != 0)
        StringReference autoVarName;
    else {
        if ((flags & 0x1) != 0)
            BaseFunction readHandler;
        if ((flags & 0x2) != 0)
            BaseFunction writeHandler;
    }
} [[format("formatter::structname")]];

struct Properties {
    u16 count;
    if (count > 0)
        Property property[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Variable {
    StringReference name;
    StringReference typeName;
    u32 userFlags;
    VariableData data;
    if (g_GameId >= GAMEID::GAME_Fallout4)
        u8 constFlag;
} [[format("formatter::structname")]];;

struct Variables {
    u16 count;
    if (count > 0)
        Variable variable[count] [[inline]];
} [[format("formatter::arraycount")]];

struct ObjectStructMember {
    StringReference name;
    StringReference typeName;
    u32 userFlags;
    VariableData data;
    u8 constFlag;
    StringReference docString;
} [[format("formatter::typedstructname")]];

struct ObjectStructMembers {
    u16 count;
    if (count > 0)
        ObjectStructMember members[count] [[inline]];
} [[format("formatter::arraycount")]];

struct ObjectStruct {
    StringReference name;
    ObjectStructMembers members;
} [[format("formatter::structname")]];

struct ObjectStructs {
    u16 count;
    if (count > 0)
        ObjectStruct structs[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Guards {
    u16 count;
    if (count > 0)
        StringReference names[count] [[inline]];
} [[format("formatter::arraycount")]];

struct ScriptObjectData {
    StringReference parentClassName;
    StringReference docString;
    if (g_GameId >= GAMEID::GAME_Fallout4)
        u8  constFlag;
    u32 userFlags;
    StringReference autoStateName;
    if (g_GameId >= GAMEID::GAME_Fallout4)
        ObjectStructs structs;
    Variables variables;
    if (g_GameId >= GAMEID::GAME_Starfield)
        Guards guards;
    Properties properties;
    States states;
    if (g_GameId == GAMEID::GAME_Fallout76)
        SyncStates syncStates;
};

struct ScriptObject {
    StringReference name;
    u32 length;
    ScriptObjectData data;

    // The BGS Compiler sets length to sizeof(data) + sizeof(length)
    // The Caprica compiler sets the length to just sizeof(data)
    // Since we have no way to identify which compiler is used we'll check
    // both and just hope it isn't short exactly 4 bytes
    std::assert(sizeof(data) == length - 4 || sizeof(data) == length, "Length of object data in state missmatch.");
};

struct ScriptObjects {
    u16 count;
    if (count > 0)
        ScriptObject scriptObjects[count] [[inline]];
} [[format("formatter::arraycount")]];

struct UserFlag {
    StringReference name;
    u8  flagIndex;
} [[format("formatter::structname")]];

struct UserFlags {
    u16 count;
    if (count > 0)
        UserFlag userFlags[count] [[inline]];
} [[format("formatter::arraycount")]];

struct StringMembers {
    u16 count;
    if (count > 0)
        StringReference members[count] [[inline]];
} [[format("formatter::arraycount")]];

struct DebugPropertyGroup {
    StringReference objectName;
    StringReference name;
    StringReference docString;
    u32 userFlags;
    StringMembers members;
} [[format("formatter::structname")]];

struct DebugInstructions {
    u16 count;
    if (count > 0)
        u16 lineNumbers[count] [[inline]];
} [[format("formatter::arraycount")]];

struct DebugFunction {
    StringReference objectName;
    StringReference stateName;
    StringReference name;
    u8  functionType [[format("formatter::functiontype")]];
    DebugInstructions instructions;
} [[format("formatter::structname")]];

struct DebugStruct {
    StringReference parentName;
    StringReference name;
    StringMembers members;
} [[format("formatter::structname")]];

struct DebugFunctions {
    u16 count;
    if (count > 0)
        DebugFunction functions[count] [[inline]];
} [[format("formatter::arraycount")]];

struct DebugPropertyGroups {
    u16 count;
    if (count > 0)
        DebugPropertyGroup groups[count] [[inline]];
} [[format("formatter::arraycount")]];

struct DebugStructs {
    u16 count;
    if (count > 0)
        DebugStruct structs[count] [[inline]];
} [[format("formatter::arraycount")]];

struct DebugInfo {
    bool hasDebugInfo;
    if (hasDebugInfo)
    {
        Time modificationTime;
        DebugFunctions functions;
        if (g_GameId >= GAMEID::GAME_Fallout4)
        {
            DebugPropertyGroups groups;
            DebugStructs structs;
        }
    }
};

// Header
struct Header {
    u32 Magic;
    PexVersion pexVersion;
    GAMEID GameID; g_GameId = GameID;
    Time CompilationTime;
    std::string::SizedString<u16> SourceFileName;
    std::string::SizedString<u16> UserName;
    std::string::SizedString<u16> MachineName;
};

struct PEX {
    if (std::mem::read_unsigned(0, 4) == le u32(0xDEC057FA))
       std::core::set_endian(std::mem::Endian::Big);
    else
        std::core::set_endian(std::mem::Endian::Little);

    Header header;
    StringsTable stringsTable;
    DebugInfo debugInfo;
    UserFlags userFlags;
    ScriptObjects scriptObjects;
};

PEX pex @ 0x00;
