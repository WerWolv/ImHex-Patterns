#pragma author ISSOtm <imhex@eldred.fr>
#pragma description Object files for the RGBDS Game Boy assembly toolchain
// Documentation: https://rgbds.gbdev.io/docs/rgbds.5

#pragma magic [ 52 47 42 39 ] @ 0x00
#pragma endian little

#include <std/string.pat>

using LONG = u32;
using BYTE = u8;
using STRING = std::string::NullString;

char magic[4] @ 0;
LONG revNum @ $;
LONG nbSym @ $;
LONG nbSect @ $;

namespace fstack {
    enum Type : BYTE {
        REPT,
        File,
        Macro,
    };
    struct Node {
        LONG parentID;
        LONG parentLineNo;
        Type type;
        if (type != Type::REPT) {
            STRING name;
        } else {
            LONG depth;
            LONG iters[depth];
        }
    };

    LONG nbNodes @ $;
    Node nodes[nbNodes] @ $;
}

namespace sym {
    enum Type : BYTE {
        Local,
        Import,
        Exported,
    };
    struct Symbol {
        STRING name;
        Type type;
        if (type != Type::Import) {
            LONG nodeID;
            LONG lineNo;
            LONG sectionID;
            LONG value;
        }
    };

    Symbol symbols[nbSym] @ $;
}

namespace sect {
    enum PatchType : BYTE {
        DB,
        DW,
        DL,
        JR,
    };
    struct Patch {
        LONG nodeID;
        LONG lineNo;
        LONG ofs;
        LONG pcSectID;
        LONG pcOfs;
        PatchType type;
        LONG rpnSize;
        BYTE rpn[rpnSize];
    };

    enum Type : BYTE {
        WRAM0,
        VRAM,
        ROMX,
        ROM0,
        HRAM,
        WRAMX,
        SRAM,
        OAM,
    };
    bitfield Attrs {
        Type type       : 6;
        bool isFragment : 1;
        bool isUnion    : 1;
    };
    struct Section {
        STRING name;
        LONG size;
        Attrs attrs;
        LONG address;
        LONG bank;
        BYTE alignment;
        LONG alignOfs;
        if (attrs.type == Type::ROMX || attrs.type == Type::ROM0) {
            BYTE data[size];
            LONG nbPatches;
            Patch patches[nbPatches];
        }
    };

    Section sections[nbSect] @ $;
}

namespace assert {
    enum Type : BYTE {
        Warn,
        Err,
        Fatal,
    };
    struct Assertion {
        LONG nodeID;
        LONG lineNo;
        LONG ofs;
        LONG pcSectID;
        LONG pcOfs;
        Type type;
        LONG rpnSize;
        BYTE rpn[rpnSize];
        STRING msg;
    };

    LONG nbAsserts @ $;
    Assertion assertions[nbAsserts] @ $;
}
