#pragma author WerWolv
#pragma description Common Object File Format (COFF) executable

#pragma MIME application/x-coff

#include <type/time.pat>
#include <type/size.pat>

enum Machine : u16 {
    Unknown     = 0x0000,
    AM33        = 0x01D3,
    AMD64       = 0x8664,
    ARM         = 0x01C0,
    ARM64       = 0xAA64,
    ARMNT       = 0x01C4,
    EBC         = 0x0EBC,
    I386        = 0x014C,
    IA64        = 0x0200,
    LOONGARCH32 = 0x6232,
    LOONGARCH64 = 0x6264,
    M32R        = 0x9041,
    MIPS16      = 0x0226,
    MIPSFPU     = 0x0366,
    MIPSFPU16   = 0x0466,
    POWERPC     = 0x01F0,
    POWERPCFP   = 0x01F0,
    R4000       = 0x0166,
    RISCV32     = 0x5032,
    RISCV64     = 0x5064,
    RISCV128    = 0x5128,
    SH3         = 0x01A2,
    SH3DSP      = 0x01A3,
    SH4         = 0x01A6,
    SH5         = 0x01A8,
    THUMB       = 0x01C2,
    WCEMIPSV2   = 0x0169
};

bitfield Characteristics {
    relocsStripped          : 1;
    executableImage         : 1;
    lineNumsStripped        : 1;
    localSymsStripped       : 1;
    aggressiveWsTrim        : 1;
    largeAddressAware       : 1;
    padding                 : 1;
    bytesReversedLo         : 1;
    _32BitMachine           : 1;
    debugStripped           : 1;
    removableRunFromSwap    : 1;
    netRunFromSwap          : 1;
    system                  : 1;
    dll                     : 1;
    upSystemOnly            : 1;
    bytesReversedHi         : 1;
};

enum Type : u16 {
    Null    = 0,
    Void    = 1,
    Char    = 2,
    Short   = 3,
    Int     = 4,
    Long    = 5,
    Float   = 6,
    Double  = 7,
    Struct  = 8,
    Union   = 9,
    Enum    = 10,
    MOE     = 11,
    Byte    = 12,
    Word    = 13,
    UInt    = 14,
    DWord   = 15
};

enum StorageClass : u8 {
    EndOfFunction   = 0xFF,
    Null            = 0,
    Automatic       = 1,
    External        = 2,
    Static          = 3,
    Register        = 4,
    ExternalDef     = 5,
    Label           = 6,
    UndefinedLabel  = 7,
    MemberOfStruct  = 8,
    Argument        = 9,
    StructTag       = 10,
    MemberOfUnion   = 11,
    UnionTag        = 12,
    TypeDefinition  = 13,
    UndefinedStatic = 14,
    EnumTag         = 15,
    MemberOfEnum    = 16,
    RegisterParam   = 17,
    BitField        = 18,
    Block           = 100,
    Function        = 101,
    EndOfStruct     = 102,
    File            = 103,
    Section         = 104,
    WeakExternal    = 105,
    CLRToken        = 107
};

struct AuxSymbol {
    u8 data[18];
};

u32 countedSymbols = 0;
struct SymbolTable {
    char name[8];
    u32 value;
    u16 sectionNumber;
    Type type;
    StorageClass storageClass;
    u8 numberOfAuxSymbols;
    
    countedSymbols += 1 + numberOfAuxSymbols;
    
    AuxSymbol auxSymbols[numberOfAuxSymbols];
    
    if (countedSymbols >= parent.header.numberOfSymbols)
        break;
};

struct String {
    char value[];
};

struct StringTable {
    u32 size;
    String strings[while($ < addressof(size) + size)];
};

bitfield SectionFlags {
    padding             : 3;
    typeNoPad           : 1;
    padding             : 1;
    cntCode             : 1;
    initializedData     : 1;
    uninitializedData   : 1;
    lnkOther            : 1;
    lnkInfo             : 1;
    padding             : 1;
    lnkRemove           : 1;
    lnkCOMDAT           : 1;
    padding             : 2;
    gprel               : 1;
    padding             : 1;
    memPurgeable        : 1;
    memLocked           : 1;
    memPreload          : 1;
    alignment           : 4 [[format("format_alignment")]];
    lnkNrelocOvfl       : 1;
    memDiscardable      : 1;
    memNotCached        : 1;
    memNotPaged         : 1;
    memShared           : 1;
    memExecute          : 1;
    memRead             : 1;
    memWrite            : 1;
};

fn format_alignment(u8 alignment) {
    return 1 << alignment;
};

struct Relocations {
    u32 virtualAddress;
    u32 symbolTableIndex;
    Type type;
};

struct Section {
    char name[8];
    type::Size<u32> virtualSize;
    u32 virtualAddress;
    type::Size<u32> sizeOfRawData;
    u32 pointerToRawData;
    u32 pointerToRelocations;
    u32 pointerToLineNumbers;
    u16 numberOfRelocations;
    u16 numberOfLineNumbers;
    SectionFlags characteristics;
    
    u8 rawData[sizeOfRawData] @ pointerToRawData [[sealed]];
    Relocations relocations[numberOfRelocations] @ pointerToRelocations;
};

struct Header {
    Machine machine;
    u16 numberOfSections;
    type::time32_t timeDateStamp;
    u32 pointerToSymbolTable;
    u32 numberOfSymbols;
    u16 sizeOfOptionalHeader;
    Characteristics characteristics;
};


struct COFF {
    Header header;
    
    Section sectionTable[header.numberOfSections];
    
    SymbolTable symbolTable[header.numberOfSymbols] @ header.pointerToSymbolTable;
    StringTable stringTable @ addressof(symbolTable) + sizeof(symbolTable);
};

COFF coff @ 0x00;
