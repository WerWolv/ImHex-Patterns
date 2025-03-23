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
}

fn StringLookup(u16 idx) {
    return pex.stringsTable.strings[idx];
};

struct PexVersion {
    u8 MajorVersion;
    u8 MinorVersion;
}[[sealed, format("formatter::pexversion")]];

struct StringReference {
    u16 name;
} [[sealed, format("formatter::structname")]];

// Dynamic array of strings
struct StringsTable {
    u16 count;
    if (count > 0)
        std::string::SizedString<u16> strings[count];
} [[format("formatter::arraycount")]];

struct Time {
    u64 Time;
}[[sealed, format("formatter::time")]];

struct VariableData {
    u8 varType [[format("formatter::vartype")]];
    match (varType)
    {
        (0x0): {} // object pointer
        (0x1): u16 stringVal  [[format("StringLookup")]]; // identifier
        (0x2): u16 stringVal  [[format("StringLookup")]]; // string
        (0x3): s32 intVal; // integer
        (0x4): float floatVal;
        (0x5): bool boolVal;
        (_): std::assert(false, "Unknown type for variable data");
    }
};

struct VariableType {
    u16 name [[format("StringLookup")]];
    u16 varType [[format("StringLookup")]];
};

struct VariableTypes {
    u16 count;
    if (count > 0)
        VariableType parameter[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Instruction {
    u8 op;
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
    ): VariableData argument[3];
    (
        0x22 | // array_findelement
        0x23   // array_rfindelement
    ): VariableData argument[4];
    (
        0x14 | // jmp
        0x1A | // return
        0x25 | // struct_create
        0x2C | // array_removelast
        0x2E   // array_clear
    ): VariableData argument[1];
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
    ): VariableData argument[2];
    (
        0x28 | // array_findstruct
        0x29   // array_rfindstruct
    ): VariableData argument[5];
    (
        0x2F   // array_getallmatchingstructs
    ): VariableData argument[6];
    (
        0x17 | // callmethod
        0x19   // callstatic
    ): {
        VariableData argument[4];
        std::assert(argument[3].varType == 0x3, "VarArgs not integer");
        if (argument[3].intVal > 0)
            VariableData varArgument[argument[3].intVal];
        }
    (
        0x18   // callparent
    ): {
        VariableData argument[3];
        std::assert(argument[2].varType == 0x3, "VarArgs not integer");
        if (argument[2].intVal > 0)
            VariableData varArgument[argument[2].intVal];
        }
    (
        0x30 | // lock_guards
        0x31   // unlock_guards
    ): {
        VariableData argument[1];
        std::assert(argument[0].varType == 0x3, "VarArgs not integer");
        if (argument[0].intVal > 0)
            VariableData varArgument[argument[0].intVal];
        }
    (
        0x32   // try_lock_guards
    ): {
        VariableData argument[2];
        std::assert(argument[1].varType == 0x3, "VarArgs not integer");
        if (argument[1].intVal > 0)
            VariableData varArgument[argument[1].intVal];
        }
    (_): {
        Printf("Invalid opcode: %Xh\n", op);
        std::assert(false, "Invalid opcode");
        }
    }

};

struct Instructions {
    u16 count;
    if (count > 0)
        Instruction instruction[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Function {
    u16 returnType [[format("StringLookup")]];
    u16 docString [[format("StringLookup")]];
    u32 userFlags;
    u8 flags;
    VariableTypes arguments;
    VariableTypes locals;
    Instructions instructions;
};

struct NamedFunction {
    u16 name [[format("StringLookup")]];
    Function function [[inline]];
} [[format("formatter::structname")]];

struct NamedFunctions {
    u16 count;
    if (count > 0)
        NamedFunction function[count] [[inline]];
} [[format("formatter::arraycount")]];

struct State {
    u16 name [[format("StringLookup")]];
    NamedFunctions functions;
} [[format("formatter::structname")]];

struct States {
    u16 count;
    if (count > 0)
        State state[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Property {
    u16 name [[format("StringLookup")]];
    u16 typeName [[format("StringLookup")]];
    u16 docString [[format("StringLookup")]];
    u32 userFlags;
    u8 flags;
    if ((flags & 0x4) != 0)
        u16 autoVarName [[format("StringLookup")]];
    else {
        if ((flags & 0x1) != 0)
            Function readHandler;
        if ((flags & 0x2) != 0)
            Function writeHandler;
    }
} [[format("formatter::structname")]];

struct Properties {
    u16 count;
    if (count > 0)
        Property property[count] [[inline]];
} [[format("formatter::arraycount")]];

struct Variable {
    u16 name [[format("StringLookup")]];
    u16 typeName [[format("StringLookup")]];
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
    u16 name [[format("StringLookup")]];
    u16 typeName [[format("StringLookup")]];
    u32 userFlags;
    VariableData data;
    u8 constFlag;
    u16 docString [[format("StringLookup")]];
} [[format("formatter::typedstructname")]];

struct ObjectStructMembers {
    u16 count;
    if (count > 0)
        ObjectStructMember members[count] [[inline]];
} [[format("formatter::arraycount")]];

struct ObjectStruct {
    u16 name [[format("StringLookup")]];
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
    u16 parentClassName [[format("StringLookup")]];
    u16 docString [[format("StringLookup")]];
    if (g_GameId >= GAMEID::GAME_Fallout4)
        u8  constFlag;
    u32 userFlags;
    u16 autoStateName [[format("StringLookup")]];
    if (g_GameId >= GAMEID::GAME_Fallout4)
        ObjectStructs structs;
    Variables variables;
    if (g_GameId >= GAMEID::GAME_Starfield)
        Guards guards;
    Properties properties;
    States states;
    if (g_GameId == GAMEID::GAME_Fallout76)
        u16 unknown;
};

struct ScriptObject {
    u16 name [[format("StringLookup")]];
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
    u16 name [[format("StringLookup")]];
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
    u16 objectName [[format("StringLookup")]];
    u16 name [[format("StringLookup")]];
    u16 docString [[format("StringLookup")]];
    u32 userFlags;
    StringMembers members;
} [[format("formatter::structname")]];

struct DebugInstructions {
    u16 count;
    if (count > 0)
        u16 lineNumbers[count] [[inline]];
} [[format("formatter::arraycount")]];

struct DebugFunction {
    u16 objectName [[format("StringLookup")]];
    u16 stateName [[format("StringLookup")]];
    u16 name [[format("StringLookup")]];
    u8  functionType [[format("formatter::functiontype")]];
    DebugInstructions instructions;
} [[format("formatter::structname")]];

struct DebugStruct {
    u16 name [[format("StringLookup")]];
    u16 orderName [[format("StringLookup")]];
    StringMembers members;
};

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
