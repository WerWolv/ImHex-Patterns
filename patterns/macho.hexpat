#pragma author WerWolv
#pragma description Mach-O executable

#pragma MIME application/x-mach-binary

import type.size;

enum Magic : u32 {
    _32BitMagic = 0xFEEDFACE,
    _64BitMagic = 0xFEEDFACF
};

enum CpuType : u32 {
    ANY = -1,
    VAX = 1,
    ROMP = 2,
    BS32032 = 4,
    BS32332 = 5,
    MC680x0 = 6,
    I386 = 7,
    X86_64 = CpuType::I386 | 0x100'0000,
    MIPS = 8,
    NS32532 = 9,
    MC98000 = 10,
    HPPA = 11,
    ARM = 12,
    ARM64 = CpuType::ARM | 0x100'0000,
    ARM64_32 = CpuType::ARM | 0x200'0000,
    MC88000 = 13,
    SPARC = 14,
    I860 = be u32(15),
    I860_LITTLE = 16,
    RS6000 = 17,
    POWERPC = 18,
    POWERPC64 = CpuType::POWERPC | 0x100'0000,
    VEO = 255
};

enum SubCpuTypeVAX : u24 {
    ALL = 0,
    VAX780 = 1,
    VAX785 = 2,
    VAX750 = 3,
    VAX730 = 4,
    UVAXI = 5,
    UVAXII = 6,
    VAX8200 = 7,
    VAX8500 = 8,
    VAX8600 = 9,
    VAX8650 = 10,
    VAX8800 = 11,
    UVAXIII = 12
};

enum SubCpuTypeROMP : u24 {
    ALL = 0,
    PC = 1,
    APC = 2,
    _135 = 3
};

enum SubCpuType32XXX : u24 {
    ALL = 0,
    MMAX_DPC = 1,
    SQT = 2,
    MMAX_APC_FPU = 3,
    MMAX_APC_FPA = 4,
    MMAX_XPC = 5
};

enum SubCpuTypeI386 : u24 {
    _386 = 3,
    _486 = 4,
    _486SX =  SubCpuTypeI386::_486 + 128,
    _586 = 5,
    IntelPentium = 5 + (0 << 4),
    IntelPentiumPro = 6 + (1 << 4),
    IntelPentiumIIM3 = 6 + (3 << 4),
    IntelPentiumIIM5 = 6 + (5 << 4),
    IntelPentium4 = 10 + (0 << 4),
};

enum SubCpuTypeMips : u24 {
    ALL = 0,
    R2300 = 1,
    R2600 = 2,
    R2800 = 3,
    R2000a = 4
};

enum SubCpuType680x0 : u24 {
    ALL = 1,
    MC68030 = 1,
    MC68040 = 2,
    MC68030_Only = 3
};

enum SubCpuTypeHPPA : u24 {
    ALL = 0,
    _7100 = 0,
    _7100LC = 1
};

enum SubCpuTypeARM : u24 {
    ALL = 0,
    A500_ARCH = 1,
    A500 = 2,
    A440 = 3,
    M4 = 4,
    V4T = 5,
    V6 = 6,
    V5TEJ = 7,
    XSCALE = 8,
    V7 = 9,
    V7F = 10, /* Cortex A9 */
    V7S = 11, /* Swift */
    V7K = 12  /* Kirkwood40 */
};

enum SubCpuTypeMC88000 : u24 {
    ALL = 0,
    MMAX_JPC = 1,
    MC88100 = 1,
    MC88110 = 2
};

enum SubCpuTypeMC98000 : u24 {
    ALL = 0,
    MC98601 = 1
};

enum SubCpuTypeI860 : u24 {
    ALL = 0,
    _860 = 1
};

enum SubCpuTypeI860Little : u24 {
    ALL = 0 ... 1
};

enum SubCpuTypeRS6000 : u24 {
    ALL = 0 ... 1
};

enum SubCpuTypeSparc : u24 {
    ALL = 0,
    _260 = 1,
    _110 = 2
};

enum SubCpuTypePowerPC : u24 {
    ALL = 0,
    _601 = 1,
    _602 = 2,
    _603 = 3,
    _603e = 4,
    _603ev = 5,
    _604 = 6,
    _604e = 7,
    _620 = 8,
    _750 = 9,
    _7400 = 10,
    _7450 = 11,
    _970 = 100
};

enum SubCpuTypeVEO : u24 {
    _1 = 1,
    _2 = 2,
    _3 = 3,
    _4 = 4,
    ALL = SubCpuTypeVEO::_2
};

bitfield Capabilities {
    padding : 7;
    lib64   : 1;
};

enum FileType : u32 {
    Object = 1,
    Execute = 2,
    FVMLib = 3,
    Core = 4,
    Preload = 5,
    DyLib = 6,
    DyLinker = 7,
    Bundle = 8,
    DyLibStub = 9,
    DSym = 10,
    KExtBundle = 11,
};

bitfield Flags {
    noUndefs    : 1;
    incrLink    : 1;
    dyldLink    : 1;
    binDatLoad  : 1;
    prebound    : 1;
    splitSegs   : 1;
    lazyInit    : 1;
    twoLevel : 1;
    forceFlat : 1;
    noMultiDefs : 1;
    noFixPrebinding : 1;
    prebindable : 1;
    allModsBound : 1;
    subSectionsViaSymbols : 1;
    canonical : 1;
    weakDefines : 1;
    bindsToWeak : 1;
    allowStackExecution : 1;
    rootSafe : 1;
    setuidSafe : 1;
    noReexportedDylibs : 1;
    pie : 1;
    deadStrippableDylib : 1;
    hasTlvDescriptors : 1;
    noHeapExecution : 1;
    appExtensionSafe : 1;
    nlistOutOfSyncWithDyldinof : 1;
    simSupport : 1;
};

struct Header {
    Magic magic;
    CpuType cpuType;
    if (cpuType == CpuType::VAX) SubCpuTypeVAX subCpuType;
    else if (cpuType == CpuType::ROMP) SubCpuTypeROMP subCpuType;
    else if (cpuType == CpuType::BS32032 || cpuType == CpuType::BS32332 || cpuType == CpuType::NS32532) SubCpuType32XXX subCpuType;
    else if (cpuType == CpuType::I386 || cpuType == CpuType::X86_64) SubCpuTypeI386 subCpuType;
    else if (cpuType == CpuType::MIPS) SubCpuTypeMips subCpuType;
    else if (cpuType == CpuType::HPPA) SubCpuTypeHPPA subCpuType;
    else if (cpuType == CpuType::ARM) SubCpuTypeARM subCpuType;
    else if (cpuType == CpuType::MC88000) SubCpuTypeMC88000 subCpuType;
    else if (cpuType == CpuType::MC98000) SubCpuTypeMC98000 subCpuType;
    else if (cpuType == CpuType::I860 || cpuType == CpuType::I860_LITTLE) SubCpuTypeI860 subCpuType;
    else if (cpuType == CpuType::SPARC) SubCpuTypeSparc subCpuType;
    else if (cpuType == CpuType::POWERPC || cpuType == CpuType::POWERPC64) SubCpuTypePowerPC subCpuType;
    else if (cpuType == CpuType::VEO) SubCpuTypeVEO subCpuType;
    else u24 subCpuType;
    Capabilities capabilities;
    FileType fileType;
    u32 numCommands;
    type::Size<u32> sizeOfCommands;
    Flags flags;

    if (magic == Magic::_64BitMagic) padding[sizeof(u32)];
};

enum Command : u32 {
    ReqDyLd = 0x8000'0000,

    Segment = 0x01,
    SymTab = 0x02,
    SymSeg = 0x03,
    Thread = 0x04,
    UnixThread = 0x05,
    LoadFVMLib = 0x06,
    IdFVMLib = 0x07,
    Ident = 0x08,
    FVMFile = 0x09,
    PrePage = 0x0A,
    DySymTab = 0x0B,
    LoadDyLib = 0x0C,
    IdDyLib = 0x0D,
    LoadDyLinker = 0x0E,
    IdDyLinker = 0x0F,
    PreboundDyLib = 0x10,
    Routines = 0x11,
    SubFramework = 0x12,
    SubUmbrella = 0x13,
    SubClient = 0x14,
    SubLibrary = 0x15,
    TwoLevelHints = 0x16,
    PrebindCksum = 0x17,
    LoadWeakDyLib = 0x18 | Command::ReqDyLd,
    Segment64 = 0x19,
    Routines64 = 0x1A,
    UUID = 0x1B,
    RPath = 0x1C | 0x8000'0000,
    CodeSignature = 0x1D,
    SegmentSplitInfo = 0x1E,
    ReExportDyLib = 0x1F | Command::ReqDyLd,
    LazyLoadDyLib = 0x20,
    EncryptionInfo = 0x21,
    DyLdInfo = 0x22,
    DyLdInfoOnly = 0x22 | Command::ReqDyLd,
    LoadUpwardDyLib = 0x23 | Command::ReqDyLd,
    VersionMinMacOSX = 0x24,
    VersionMinIPhoneOS = 0x25,
    FunctionStarts = 0x26,
    DyLdEnvironment = 0x27,
    Main = 0x28 | Command::ReqDyLd,
    DataInCode = 0x29,
    SourceVersion = 0x2A,
    DyLibCodeSignDRS = 0x2B
};

struct CommandUUID {
    u128 uuid;
};

struct Section {
    char sectionName[16];
    char segmentName[16];
    u32 address;
    type::Size<u32> size;
    u32 offset;
    u32 align;
    u32 reloff;
    u32 numRelocs;
    u32 flags;
    padding[8];

    if (offset > 0)
        u8 data[size] @ offset [[sealed]];
};

struct CommandSegment {
    char segmentName[16];
    u32 vmAddress;
    type::Size<u32> vmSize;
    u32 fileOffset;
    type::Size<u32> fileSize;
    u32 maxProtection;
    u32 initProtection;
    u32 numSections;
    u32 flags;

    Section sections[numSections];

    if (fileOffset > 0)
        u8 data[fileSize] @ fileOffset [[sealed]];
};

struct Section64 {
    char sectionName[16];
    char segmentName[16];
    u64 address;
    type::Size<u64> size;
    u32 offset;
    u32 align;
    u32 reloff;
    u32 numRelocs;
    u32 flags;
    padding[12];

    if (offset > 0)
        u8 data[size] @ offset [[sealed]];
};

struct CommandSegment64 {
    char segmentName[16];
    u64 vmAddress;
    type::Size<u64> vmSize;
    u64 fileOffset;
    type::Size<u64> fileSize;
    u32 maxProtection;
    u32 initProtection;
    u32 numSections;
    u32 flags;

    Section64 sections[numSections];

    if (fileOffset > 0)
        u8 data[fileSize] @ fileOffset [[sealed]];
};

union lc_str {
    u32 offset; 
};

struct Dylib {
    lc_str name; // always 24
    u32 timestamp;
    u32 current_version;
    u32 compatibility_version;
};

struct LoadDyLib {
    Dylib dylib [[inline]];
};

struct LoadCommand {
    Command command;
    type::Size<u32> commandSize;

    if (command == Command::UUID)
        CommandUUID data;
    else if (command == Command::Segment)
        CommandSegment data;
    else if (command == Command::Segment64)
        CommandSegment64 data;
    else if (command == Command::LoadDyLib) {
        LoadDyLib dylib;
        std::string::NullString dylib_name;
        $ += commandSize - dylib.dylib.name.offset - 1 - std::string::length(dylib_name); // null terminated
    }
    else
        u8 data[commandSize - 8] [[sealed]];
};

struct MachO {
    Header header;
    LoadCommand loadCommands[header.numCommands];
};

MachO macho @ 0x00;