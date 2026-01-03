#pragma author WerWolv
#pragma description Microsoft PE Portable Executable (exe/dll)

#pragma MIME application/x-dosexec
#pragma MIME application/x-msdownload
#pragma MIME application/vnd.microsoft.portable-executable

import hex.dec;
import std.core;
import std.string;
import type.guid;
import type.time;

fn formatNullTerminatedString(str string) {
    return "\"" + std::string::substr(string, 0, std::string::length(string)-1) + "\"";
};

s16 dosMessageOffset;

struct DOSProgramData {
    u8 code[while($ < addressof(this) + dosMessageOffset)];
    // $ is the character that ends text on DOS
    char message[while(std::mem::read_string($-1, 1) != "$")] @ addressof(this) + dosMessageOffset [[format("formatNullTerminatedString")]];
} [[hex::spec_name("e_program")]];

fn finddosmessage() {
    for (u8 cursor = $, cursor < $+16, cursor += 1) {
        if ($[cursor] == 0xBA) { // Message offset instruction
            dosMessageOffset = std::mem::read_unsigned(cursor+1, 2);
            break;
        }
    }
};

struct DOSHeader {
    char signature[2] [[hex::spec_name("e_magic")]];
    u16 extraPageSize [[hex::spec_name("e_cblp")]];
    u16 numberOfPages [[hex::spec_name("e_cp")]];
    u16 relocations [[name("stubRelocations"), hex::spec_name("e_crlc")]];
    u16 headerSizeInParagraphs [[hex::spec_name("e_cparhdr")]];
    u16 minimumAllocatedParagraphs [[hex::spec_name("e_minalloc")]];
    u16 maximumAllocatedParagraphs [[hex::spec_name("e_maxalloc")]];
    u16 initialSSValue [[hex::spec_name("e_ss")]];
    u16 initialRelativeSPValue [[hex::spec_name("e_sp")]];
    u16 checksum [[name("stubChecksum"), hex::spec_name("e_csum")]];
    u16 initialRelativeIPValue [[hex::spec_name("e_ip")]];
    u16 initialCSValue [[hex::spec_name("e_cs")]];
    u16 relocationsTablePointer [[hex::spec_name("e_lfarlc")]];
    u16 overlayNumber [[hex::spec_name("e_ovno")]];
    padding[8];
    u16 oemIdentifier [[hex::spec_name("e_oemid")]];
    u16 oemInformation [[hex::spec_name("e_oeminfo")]];
    padding[20];
    u32 coffHeaderPointer [[hex::spec_name("e_lfanew")]];
};

struct PEHeader {
    DOSHeader dosHeader;
    finddosmessage();
    if (!dosMessageOffset)
        /* Some newer executables have garbage data instead. Four 00
        characters is when 00 (null) stops being part of it instead
        of being the threshold, so it can be used as a limit */
        u8 dosProgramData[while(std::mem::read_unsigned($, 5))] [[hex::spec_name("e_program")]];
    else DOSProgramData dosProgramData;
};

PEHeader peHeader @ 0x00;

enum ArchitectureType : u16 {
    Unknown = 0x00,
    ALPHAAXPOld = 0x183,
    ALPHAAXP = 0x184,
    ALPHAAXP64Bit = 0x284,
    AM33 = 0x1D3,
    AMD64 = 0x8664,
    ARM = 0x1C0,
    ARM64 = 0xAA64,
    ARMNT = 0x1C4,
    CLRPureMSIL = 0xC0EE,
    EBC = 0xEBC,
    I386 = 0x14C,
    I860 = 0x14D,
    IA64 = 0x200,
    LOONGARCH32 = 0x6232,
    LOONGARCH64 = 0x6264,
    M32R = 0x9041,
    MIPS16 = 0x266,
    MIPSFPU = 0x366,
    MIPSFPU16 = 0x466,
    MOTOROLA68000 = 0x268,
    POWERPC = 0x1F0,
    POWERPCFP = 0x1F1,
    POWERPC64 = 0x1F2,
    R3000 = 0x162,
    R4000 = 0x166,
    R10000 = 0x168,
    RISCV32 = 0x5032,
    RISCV64 = 0x5064,
    RISCV128 = 0x5128,
    SH3 = 0x1A2,
    SH3DSP = 0x1A3,
    SH4 = 0x1A6,
    SH5 = 0x1A8,
    THUMB = 0x1C2,
    WCEMIPSV2 = 0x169
} [[hex::spec_name("MachineType")]];

enum PEFormat : u16 {
    ROM = 0x107,
    PE32 = 0x10B,
    PE32Plus = 0x20B
};

enum SubsystemType : u16 {
    Unknown = 0x00,
    Native = 0x01,
    WindowsGUI = 0x02,
    WindowsCUI = 0x03,
    OS2CUI = 0x05,
    POSIXCUI = 0x07,
    Windows9xNative = 0x08,
    WindowsCEGUI = 0x09,
    EFIApplication = 0x0A,
    EFIBootServiceDriver = 0x0B,
    EFIRuntimeDriver = 0x0C,
    EFIROM = 0x0D,
    Xbox = 0x0E,
    WindowsBootApplication = 0x10
};

bitfield Characteristics {
    baseRelocationsStripped : 1 [[hex::spec_name("IMAGE_FILE_RELOCS_STRIPPED")]];
    executableImage : 1 [[hex::spec_name("IMAGE_FILE_EXECUTABLE_IMAGE")]];
    lineNumbersStripped : 1 [[hex::spec_name("IMAGE_FILE_LINE_NUMS_STRIPPED")]];
    symbolsStripped : 1 [[hex::spec_name("IMAGE_FILE_LOCAL_SYMS_STRIPPED")]];
    aggressivelyTrimWorkingSet : 1 [[hex::spec_name("IMAGE_FILE_AGGRESSIVE_WS_TRIM")]];
    largeAddressAware : 1 [[hex::spec_name("IMAGE_FILE_LARGE_ADDRESS_AWARE")]];
    padding : 1;
    bytesReversedLo : 1 [[hex::spec_name("IMAGE_FILE_BYTES_REVERSED_LO")]];
    machine32Bit : 1 [[hex::spec_name("IMAGE_FILE_32BIT_MACHINE")]];
    debugInfoStripped : 1 [[hex::spec_name("IMAGE_FILE_DEBUG_STRIPPED")]];
    removableRunFromSwap : 1 [[hex::spec_name("IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP")]];
    netRunFromSwap : 1 [[hex::spec_name("IMAGE_FILE_NET_RUN_FROM_SWAP")]];
    systemFile : 1 [[hex::spec_name("IMAGE_FILE_SYSTEM")]];
    dll : 1 [[hex::spec_name("IMAGE_FILE_DLL")]];
    uniprocessorMachineOnly : 1 [[hex::spec_name("IMAGE_FILE_UP_SYSTEM_ONLY")]];
    bytesReversedHi : 1 [[hex::spec_name("IMAGE_FILE_BYTES_REVERSED_HI")]];
};

bitfield DLLCharacteristics {
    callWhenLoaded : 1;
    callWhenThreadTerminates : 1;
    callWhenThreadStarts : 1;
    callWhenExiting : 1;
    padding : 1;
    highEntropyVA : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_HIGH_ENTROPY_VA")]];
    dynamicBase : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE")]];
    forceIntegrity : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_FORCE_INTEGRITY")]];
    nxCompatible : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_NX_COMPAT")]];
    noIsolation : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_NO_ISOLATION")]];
    noSEH : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_NO_SEH")]];
    doNotBind : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_NO_BIND")]];
    appContainer : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_APPCONTAINER")]];
    isWDMDriver : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_WDM_DRIVER")]];
    supportsControlFlowGuard : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_GUARD_CF")]];
    terminalServerAware : 1 [[hex::spec_name("IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE ")]];
};

bitfield LoaderFlags {
    prestartBreakpoint : 1 [[comment("Invoke a breakpoint instruction before starting the process")]];
    postloadingDebugger : 1 [[comment("Invoke a debugger on the process after it's been loaded")]];
    padding : 30;
} [[comment("(Officially declared reserved by Microsoft)")]];

struct DataDirectory {
    u32 rva;
    u32 size;
};

struct OptionalHeader {
    PEFormat magic;
    u8 majorLinkerVersion;
    u8 minorLinkerVersion;
    u32 sizeOfCode;
    u32 sizeOfInitializedData;
    u32 sizeOfUninitializedData;
    u32 addressOfEntryPoint;
    u32 baseOfCode;
    if (magic == PEFormat::PE32Plus) {
        u64 imageBase;
    }
    else {
        u32 baseOfData;
        u32 imageBase;
    }
    u32 virtualSectionAlignment [[hex::spec_name("sectionAlignment")]];
    u32 rawSectionAlignment [[hex::spec_name("fileAlignment")]];
    u16 majorOperatingSystemVersion;
    u16 minorOperatingSystemVersion;
    u16 majorImageVersion;
    u16 minorImageVersion;
    u16 majorSubsystemVersion;
    u16 minorSubsystemVersion;
    u32 win32VersionValue;
    u32 sizeOfImage;
    u32 sizeOfHeaders;
    u32 checksum;
    SubsystemType subsystem;
    DLLCharacteristics dllCharacteristics;
    if (magic == PEFormat::PE32Plus) {
        u64 sizeOfStackReserve;
        u64 sizeOfStackCommit;
        u64 sizeOfHeapReserve;
        u64 sizeOfHeapCommit;
    }
    else {
        u32 sizeOfStackReserve;
        u32 sizeOfStackCommit;
        u32 sizeOfHeapReserve;
        u32 sizeOfHeapCommit;
    }
    LoaderFlags loaderFlags;
    u32 numberOfRVAsAndSizes [[hex::spec_name("numberOfRvaAndSizes")]];
    DataDirectory directories[numberOfRVAsAndSizes];
};

struct COFFHeader {
    char signature[4];
    ArchitectureType architecture [[hex::spec_name("machine")]];
    u16 numberOfSections;
    type::time32_t timeDateStamp;
    u32 pointerToSymbolTable;
    u32 numberOfSymbols;
    u16 sizeOfOptionalHeader;
    Characteristics characteristics;

    OptionalHeader optionalHeader;
};

COFFHeader coffHeader @ peHeader.dosHeader.coffHeaderPointer;

enum AlignmentType : u8 {
    BoundaryOf1Byte = 1,
    BoundaryOf2Bytes,
    BoundaryOf4Bytes,
    BoundaryOf8Bytes,
    BoundaryOf16Bytes,
    BoundaryOf32Bytes,
    BoundaryOf64Bytes,
    BoundaryOf128Bytes,
    BoundaryOf256Bytes,
    BoundaryOf512Bytes,
    BoundaryOf1024Bytes,
    BoundaryOf2048Bytes,
    BoundaryOf4096Bytes,
    BoundaryOf8192Bytes,
};

fn formatAlignmentBits(u8 value) {
    if (value) {
        AlignmentType enumValue = value;
        return enumValue;
    }
    return value;
};

bitfield SectionFlags {
    padding : 3;
    doNotPad : 1 [[hex::spec_name("IMAGE_SCN_TYPE_NO_PAD")]];
    padding : 1;
    containsCode : 1 [[hex::spec_name("IMAGE_SCN_CNT_CODE")]];
    containsInitializedData : 1 [[hex::spec_name("IMAGE_SCN_CNT_INITIALIZED_DATA")]];
    containsUninitializedData : 1 [[hex::spec_name("IMAGE_SCN_CNT_UNINITIALIZED_DATA")]];
    linkOther : 1 [[hex::spec_name("IMAGE_SCN_LNK_OTHER")]];
    linkHasInformation : 1 [[hex::spec_name("IMAGE_SCN_LNK_INFO")]];
    padding : 1;
    linkRemove : 1 [[hex::spec_name("IMAGE_SCN_LNK_REMOVE")]];
    linkHasCOMDAT : 1 [[hex::spec_name("IMAGE_SCN_LNK_COMDAT")]];
    padding : 1;
    resetSpeculativeExceptions : 1 [[hex::spec_name("")]];
    globalPointerRelocations : 1 [[hex::spec_name("IMAGE_SCN_GPREL")]];
    purgeable : 1 [[hex::spec_name("IMAGE_SCN_MEM_PURGEABLE")]];
    is16Bit : 1 [[hex::spec_name("IMAGE_SCN_MEM_16BIT")]];
    locked : 1 [[hex::spec_name("IMAGE_SCN_MEM_LOCKED")]];
    preloaded : 1 [[hex::spec_name("IMAGE_SCN_MEM_PRELOAD")]];
    dataAlignment : 4 [[format("formatAlignmentBits")]];
    linkExtendedRelocations : 1 [[hex::spec_name("IMAGE_SCN_LNK_NRELOC_OVFL")]];
    discardable : 1 [[hex::spec_name("IMAGE_SCN_MEM_DISCARDABLE")]];
    notCached : 1 [[hex::spec_name("IMAGE_SCN_MEM_NOT_CACHED")]];
    notPageable : 1 [[hex::spec_name("IMAGE_SCN_MEM_NOT_PAGED")]];
    shared : 1 [[hex::spec_name("IMAGE_SCN_MEM_SHARED")]];
    executed : 1 [[hex::spec_name("IMAGE_SCN_MEM_EXECUTE")]];
    read : 1 [[hex::spec_name("IMAGE_SCN_MEM_READ")]];
    writtenOn : 1 [[hex::spec_name("IMAGE_SCN_MEM_WRITE")]];
};

fn formatSectionName(str string) {
    for (u8 i = 0, i < 8, i += 1) {
        if (std::mem::read_unsigned($+i, 1) == 0) {
            return "\"" + std::string::substr(string, 0, i) + "\"";
        }
    }
};

struct SectionHeader {
    char name[8] [[name("sectionName"), hex::spec_name("name"), format("formatSectionName")]];
    u32 virtualSize;
    u32 rva [[hex::spec_name("virtualAddress")]];
    u32 sizeOfRawData;
    u32 ptrRawData;
    u32 ptrRelocations;
    u32 ptrLineNumbers;
    u16 numberOfRelocations;
    u16 numberOfLineNumbers;
    SectionFlags characteristics;
};

SectionHeader sectionsTable[coffHeader.numberOfSections] @ addressof(coffHeader.optionalHeader) + coffHeader.sizeOfOptionalHeader;

// General Section things
u16 currentSectionIndex;

fn relativeVirtualDifference() {
    return sectionsTable[currentSectionIndex].rva - sectionsTable[currentSectionIndex].ptrRawData;
};

fn wordsize() {
    return std::mem::read_unsigned(addressof(coffHeader.optionalHeader.magic), 2) / 0x41;
};

// Exception Table
bitfield FunctionBitfield {
    prologLength : 8;
    functionLength : 22;
    instructions32Bit : 1;
    exceptionHandler : 1;
};

struct FunctionTableEntry {
    if (coffHeader.architecture == ArchitectureType::MIPSFPU || coffHeader.architecture == ArchitectureType::R3000) {
        u32 beginVA;
        u32 endVA;
        u32 exceptionHandlerPointer;
        u32 handlerDataPointer;
        u32 prologEndVA;
    } else if (coffHeader.architecture == ArchitectureType::ARM || coffHeader.architecture == ArchitectureType::ARM64 || coffHeader.architecture == ArchitectureType::ARMNT ||
                coffHeader.architecture == ArchitectureType::POWERPC || coffHeader.architecture == ArchitectureType::POWERPCFP ||
                coffHeader.architecture == ArchitectureType::SH3 || coffHeader.architecture == ArchitectureType::SH3DSP || coffHeader.architecture == ArchitectureType::SH4) {
        u32 beginVA;
        FunctionBitfield miscellaneousBits;
    } else if (coffHeader.architecture == ArchitectureType::AMD64 || coffHeader.architecture == ArchitectureType::IA64) {
        u32 beginRVA;
        u32 endRVA;
        u32 unwindInformationRVA;
    }
};

struct ExceptionTable {
    FunctionTableEntry functionTableEntries[while($ < (coffHeader.optionalHeader.directories[3].rva - relativeVirtualDifference()) + coffHeader.optionalHeader.directories[3].size)] [[inline]];
};

// Exports Table
struct ExportDirectoryTable {
    u32 flags [[name("exportFlags")]];
    type::time32_t timeDateStamp [[name("exportTimeDateStamp")]];
    u16 majorVersion;
    u16 minorVersion;
    u32 imageNameRVA;
    u32 ordinalBase [[name("exportOrdinalBase")]];
    u32 addressesAmount [[name("exportAddressesAmount")]];
    u32 namePointersAmount [[name("exportNamePointersAmount")]];
    u32 addressTableRVA [[name("exportAddressTableRVA")]];
    u32 namePointerTableRVA [[name("exportNamePointerTableRVA")]];
    u32 ordinalTableRVA [[name("exportOrdinalTableRVA")]];
};

struct ExportAddress {
    if (sectionsTable[currentSectionIndex].ptrRawData > std::mem::read_unsigned($, 4) > sectionsTable[currentSectionIndex].sizeOfRawData) {
        u32 exportRVA;
    }
    else {
        u32 forwarderRVA;
    }
};

struct ExportNamePointer {
    u32 exportNameRVA;
    char exportName[] @ exportNameRVA - relativeVirtualDifference() [[format("formatNullTerminatedString")]];
};

struct ExportsTable {
    ExportDirectoryTable directoryTable;
    ExportAddress exportAddressTable[directoryTable.addressesAmount] @ directoryTable.addressTableRVA - relativeVirtualDifference();
    ExportNamePointer exportNamePointerTable[directoryTable.namePointersAmount] @ directoryTable.namePointerTableRVA - relativeVirtualDifference();
    if (directoryTable.ordinalTableRVA > relativeVirtualDifference()) {
        u16 exportOrdinalTable[directoryTable.namePointersAmount] @ directoryTable.ordinalTableRVA - relativeVirtualDifference();
    }
    if (directoryTable.imageNameRVA > relativeVirtualDifference()) {
        char imageName[] @ directoryTable.imageNameRVA - relativeVirtualDifference() [[format("formatNullTerminatedString")]];
    }
    $ = addressof(this)+coffHeader.optionalHeader.directories[0].size;
};

// Imports Table
bitfield OrdinalFlagByte {
    padding : 7;
    flag : 1 [[name("ordinalFlag")]];
};

fn formatMangledString(str string) {
    return hex::dec::demangle(formatNullTerminatedString(string));
};

struct ImportsName {
    u16 hint;
    if (std::mem::read_string($, 1) == "?") 
        char name[] [[format("formatMangledString")]];
    else 
        char name[] [[format("formatNullTerminatedString")]];
    if ($ % 2 == 1) { u8 pad; }
};

struct ImportsAddress {
    OrdinalFlagByte ordinalFlagByte @ $+(wordsize()-1);
    if (ordinalFlagByte.flag) {
        u16 ordinalNumber;
        padding[wordsize()-2];
    } else {
        u32 nameTableRVA;
        if (coffHeader.optionalHeader.magic == PEFormat::PE32Plus) {
            padding[4];
        }
    }
};

struct ImportsLookup : ImportsAddress {
    if (!ordinalFlagByte.flag && std::mem::read_unsigned($-wordsize(), wordsize()) > 0) {
        ImportsName name @ nameTableRVA - relativeVirtualDifference();
    }
};

struct ImportsDirectory {
    u32 lookupTableRVA;
    u32 timeDateStamp;
    u32 forwarderChain;
    u32 dllNameRVA;
    u32 addressTableRVA;
};

struct ImportsStructure {
    if (parent.importsDirectoryTable[std::core::array_index()].lookupTableRVA > 0) {
        ImportsLookup lookupTable[while(std::mem::read_unsigned($, wordsize()) != 0)] @ parent.importsDirectoryTable[std::core::array_index()].lookupTableRVA - relativeVirtualDifference();
    }
    if (parent.importsDirectoryTable[std::core::array_index()].addressTableRVA > 0) {
        ImportsAddress addressTable[while(std::mem::read_unsigned($, wordsize()) != 0)] @ parent.importsDirectoryTable[std::core::array_index()].addressTableRVA - relativeVirtualDifference();
    }
    if (parent.importsDirectoryTable[std::core::array_index()].dllNameRVA > 0) {
        char dllName[] @ parent.importsDirectoryTable[std::core::array_index()].dllNameRVA - relativeVirtualDifference() [[format("formatNullTerminatedString")]];
    }
} [[inline]];

struct ImportsTable {
    ImportsDirectory importsDirectoryTable[while(std::mem::read_unsigned($, 16) != 0)];
    ImportsStructure importsStructures[sizeof(importsDirectoryTable)/sizeof(importsDirectoryTable[0])] [[inline]];
    $ = addressof(this)+coffHeader.optionalHeader.directories[1].size;
};

struct DelayedImportsDirectory {
    u32 attributes;
    u32 name;
    u32 moduleHandle;
    u32 delayImportAddressTable;
    u32 delayImportNameTable;
    u32 boundDelayImportTable;
    u32 unloadDelayImportTable;
    u32 timeStamp;
};

struct DelayImportsStructure {
    if (parent.delayImportsDirectoryTable[std::core::array_index()].delayImportNameTable > 0) {
        ImportsLookup delayedLookupTable[while(std::mem::read_unsigned($, wordsize()) != 0)] @ parent.delayImportsDirectoryTable[std::core::array_index()].delayImportNameTable - relativeVirtualDifference();
    }
    if (parent.delayImportsDirectoryTable[std::core::array_index()].name > 0) {
        char dllName[] @ parent.delayImportsDirectoryTable[std::core::array_index()].name - relativeVirtualDifference() [[format("formatNullTerminatedString")]];
    }
} [[inline]];

// https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#delay-load-import-tables-image-only
struct DelayedImportsTable {
    DelayedImportsDirectory delayImportsDirectoryTable[while(std::mem::read_unsigned($, 16) != 0)];
    DelayImportsStructure delayImportsStructures[sizeof(delayImportsDirectoryTable)/sizeof(delayImportsDirectoryTable[0])] [[inline]];
    $ = addressof(this)+coffHeader.optionalHeader.directories[1].size;
};

// General Resource Table things
fn formatNullTerminatedString16(str string) {
    return "\"" + std::string::substr(string, 0, std::string::length(string)) + "\"";
};

// * Bitmap Resource
struct BitmapHeader {
    u32 size [[name("bitmapSize")]];
    u32 width [[name("bitmapWidth")]];
    u32 height [[name("bitmapHeight")]];
    u16 planes [[name("bitmapPlanes")]];
    u16 bitCount [[name("bitmapBitCount")]];
    u32 compression [[name("bitmapCompression")]];
    u32 imageSize [[name("bitmapImageSize")]];
    u32 xPelsPerMeter [[name("bitmapXPelsPerMeter")]];
    u32 yPelsPerMeter [[name("bitmapYPelsPerMeter")]];
    u32 clrUsed [[name("bitmapClrUsed")]];
    u32 clrImportant [[name("bitmapClrImportant")]];
};

struct Colors {
    u8 blue [[color("1F77B4")]];
    u8 green [[color("2CA02C")]];
    u8 red [[color("D62728")]];
    u8 reserved [[color("828282")]];
};

u32 imageDataSize;

struct Bitmap {
    BitmapHeader bmh [[name("bitmapHeader")]];

    if ((bmh.bitCount != 24) && (bmh.bitCount != 32)) {
        Colors rgbq[bmh.clrUsed*((1 << bmh.bitCount)*!bmh.clrUsed)];
        imageDataSize = imageDataSize - sizeof(rgbq);
    }

    u8 imageData[imageDataSize-sizeof(bmh)];
};

// * Cursor Resource
struct Cursor {
    u16 reserved;
    u16 type;
    if (!type) {
        imageDataSize = parent.size-4;
        Bitmap bitmapData [[inline]];
    }
};

// * Dialog Resource
enum AtomType : u16 {
    Button = 0x80,
    Edit,
    Static,
    ListBox,
    ScrollBar,
    ComboBox
};

struct VLSElement {
    if (std::mem::read_unsigned($, 2) == 0xFFFF) {
        u16 atomDefiner;
    }
    else {
        AtomType atom;
    }
};

struct VariableLengthStructure {
    if (std::mem::read_unsigned($, 2) == 0xFFFF) {
        VLSElement vlsElement[2];
    }
    else {
        char16 string[] [[format("formatNullTerminatedString16")]];
    }
};

struct DialogTemplate {
    if (parent.parent.parent.parent.id == 0x411) {
        u16 version;
        u16 signature;
        u32 helpContextIdentifier;
        u32 extendedStyles;
        u32 style;
    }
    else {
        u32 style;
        u32 extendedStyles;
    }
    u16 numberOfItems;
    u16 x;
    u16 y;
    u16 width;
    u16 height;
    if (parent.parent.parent.parent.id == 0x409 || parent.parent.parent.parent.id == 0x411) {
        VariableLengthStructure dialogMenu;
        VariableLengthStructure dialogClass;
        char16 dialogTitle[] [[format("formatNullTerminatedString16")]];
        u16 dialogFontSize;
        if (parent.parent.parent.parent.id == 0x411) {
            u16 weight;
            bool italic;
            u8 charset;
        }
        char16 dialogFontTypeface[] [[format("formatNullTerminatedString16")]];
        if (($+2)%16 == 0 || 4 || 8 || 12)
            u16 alignment;
    }
};

struct DialogItemTemplate {
    if (parent.parent.parent.parent.parent.id == 0x411) {
        u32 helpContextIdentifier;
        u32 extendedStyles [[name("itemExtendedStyles")]];
        u32 style [[name("itemStyle")]];
    }
    else {
        u32 style [[name("itemStyle")]];
        u32 extendedStyles [[name("itemExtendedStyles")]];
    }
    u16 x;
    u16 y;
    u16 width;
    u16 height;
    if (parent.parent.parent.parent.parent.id == 0x409 || parent.parent.parent.parent.parent.id == 0x411) {
        u32 controlID;
        VariableLengthStructure windowClass;
        VariableLengthStructure dialogItemTitle;
        u16 extraCount;
    } else {
        u16 controlID;
    }
    if (($+2)%16 == 0 || 4 || 8)
        u16 alignment;
};

struct DialogItem {
    DialogItemTemplate template [[inline]];
    /*if (parent.parent.parent.parent.id == 0x409 || parent.parent.parent.parent.id == 0x411) {
        u8 itemCreationData[template.extraCount];
    }*/
};

struct Dialog {
    DialogTemplate dialogTemplate;
    DialogItem items[dialogTemplate.numberOfItems];
};

// * String Resource
struct StringTableResource {
    std::string::SizedString16<u16> strings[while($ < (parent.dataRVA - relativeVirtualDifference()) + parent.size)];
};

// * GroupCursor Resource
struct GroupCursor {
    u16 assorteddata;
    u16 colors;
    u16 otherassorteddata;
    u16 pixels;
    u16 assorteddataarray[5];
    u16 ordinalName;
};

// * GroupIcon Resource
struct GroupIconHeader {
    u16 reserved;
    u16 type;
    u16 count;
};

struct GroupIconEntry {
    u8 width;
    u8 height;
    u8 colorCount;
    u8 reserved;
    u16 planes;
    u16 bitCount;
    u32 bytesInResource;
    u16 id;
};

struct GroupIcon {
    GroupIconHeader header;
    GroupIconEntry entries[header.count];
};

// * Version Resource
struct VersionEntryHeader {
    u16 length;
    u16 valueLength;
    u16 type;
    char16 key[] [[format("formatNullTerminatedString16")]];
    padding[while(!$[$] && $ < addressof(key)+sizeof(key)+5)];
};

struct StringInfo {
    VersionEntryHeader stringInfoHeader;
    if (stringInfoHeader.valueLength > 0) {
        char16 string[] [[format("formatNullTerminatedString16")]];
        padding[while(!$[$])];
    }
};

struct VersionEntry {
    VersionEntryHeader header [[inline]];
    if (header.key == "StringFileInfo") {
        VersionEntryHeader stringTableHeader;
        StringInfo strings[while($ < addressof(stringTableHeader) + stringTableHeader.length)];
    }
    else if (header.key == "VarFileInfo") {
        VersionEntryHeader varHeader;
        u16 translation[varHeader.valueLength / 2];
    }
    else {
        u8 value[header.valueLength];
        padding[while(!$[$])];
    }
};

struct Version {
    VersionEntryHeader header [[inline]];
    u32 signature;
    u16 structVersion[2];
    u16 fileVersion[4];
    u16 productVersion[4];
    u32 fileFlagsMask[2];
    u32 fileFlags;
    u32 fileOS;
    u32 fileType;
    u32 fileSubType;
    u32 fileTimestamp;
    VersionEntry children[while($ < (parent.dataRVA - relativeVirtualDifference()) + parent.size)];
};

// * Resources Using TrueChar
fn displayTrueChar(u8 value) {
    char chr = char(value);
    str notation = "0x";
    if (value < 0x10) notation += "0";
    if (!value) chr = "␀";
    return "'" + chr + "' (" + std::format(notation + "{:X}", value) + ")";
};

using TrueChar = u8 [[format("displayTrueChar")]];

// Resource Table
enum ResourceID : u32 {
    Cursor = 0x01,
    Bitmap,
    Icon,
    Menu,
    Dialog,
    String,
    Accelerator = 0x09,
    StringData,
    GroupCursor = 0x0C,
    GroupIcon = 0x0E,
    Version = 0x10,
    Manifest = 0x18
};
ResourceID resourceIDType;

struct DataEntry {
    u32 dataRVA;
    u32 size;
    u32 codepage;
    u32 reserved;

    if (resourceIDType == ResourceID::Cursor) {
        Cursor cursor @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::Bitmap || (resourceIDType == ResourceID::Icon && std::mem::read_string((dataRVA - relativeVirtualDifference())+1, 3) != "PNG")) {
        imageDataSize = size;
        Bitmap bitmap @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::Dialog) {
        Dialog dialog @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::String) {
        StringTableResource stringTableResource @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::StringData) {
        TrueChar stringData[size] @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::GroupCursor) {
        GroupCursor groupCursor @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::GroupIcon) {
        GroupIcon groupIcon @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::Version) {
        Version version @ dataRVA - relativeVirtualDifference();
    }
    else if (resourceIDType == ResourceID::Manifest) {
        TrueChar manifest[size] @ dataRVA - relativeVirtualDifference();
    }
    else {
        u8 resource[size] @ dataRVA - relativeVirtualDifference();
    }
};

using ResourceDirectory;

bitfield OffsetField {
    offset : 31;
    pointingToDirectory : 1;
};

struct DataField {
    if ($[$+3] >= 0x80) {
        OffsetField offsetToData;
        ResourceDirectory directory @ coffHeader.optionalHeader.directories[2].rva - relativeVirtualDifference() + offsetToData.offset;
    }
    else {
        u32 offsetToData;
        DataEntry dataEntry @ coffHeader.optionalHeader.directories[2].rva - relativeVirtualDifference() + offsetToData;
    }
} [[inline]];

struct IdDirectoryEntry {
    if ($ > coffHeader.optionalHeader.directories[2].rva - relativeVirtualDifference() + 0x10 + 8*(parent.directoryTable.nameEntriesAmount + parent.directoryTable.idEntriesAmount)) {
        u32 id;
    }
    else {
        ResourceID id;
        resourceIDType = std::mem::read_unsigned(addressof(id), 4);
    }

    DataField datafield;
};

struct NameDirectoryEntry {
    OffsetField offsetToName;
    std::string::SizedString16<u16> name @ coffHeader.optionalHeader.directories[2].rva - relativeVirtualDifference() + offsetToName.offset;

    DataField datafield;
};

struct ResourceDirectoryTable {
    u32 characteristics;
    u32 timeDateStamp;
    u16 majorVersion;
    u16 minorVersion;
    u16 nameEntriesAmount;
    u16 idEntriesAmount;
};

struct ResourceDirectory {
    ResourceDirectoryTable directoryTable [[hex::spec_name("resourceDirectoryTable")]];
    NameDirectoryEntry nameEntries[directoryTable.nameEntriesAmount];
    IdDirectoryEntry idEntries[directoryTable.idEntriesAmount];
};

struct ResourceTable {
    ResourceDirectory rootDirectory;
    $ = addressof(this)+coffHeader.optionalHeader.directories[2].size;
};

// Base Relocations Table
enum BaseRelocationType : u8 {
    Absolute,
    High,
    Low,
    HighLow,
    HighAdjacent,
    Reserved = 6,
    DIR64 = 10
};

enum MIPSBaseRelocationType : u8 {
    Absolute,
    High,
    Low,
    HighLow,
    HighAdjacent,
    MIPSJMPAddress,
    Reserved,
    MIPSJMPAddress16 = 9,
    DIR64
};

enum ARMBaseRelocationType : u8 {
    Absolute,
    High,
    Low,
    HighLow,
    HighAdjacent,
    ARMMOV32,
    Reserved,
    DIR64 = 10
};

enum RISCVBaseRelocationType : u8 {
    Absolute,
    High,
    Low,
    HighLow,
    HighAdjacent,
    RISCVHigh20,
    Reserved,
    RISCVLow12I,
    RISCVLow12S,
    DIR64 = 10
};

enum THUMBBaseRelocationType : u8 {
    Absolute,
    High,
    Low,
    HighLow,
    HighAdjacent,
    ARMMOV32,
    Reserved,
    ThumbMOV32,
    DIR64 = 10
};

enum LoongarchBaseRelocationType : u8 {
    Absolute,
    High,
    Low,
    HighLow,
    HighAdjacent,
    Reserved = 6,
    MarkLA = 8,
    DIR64 = 10
};

fn formatBaseRelocationType(u8 value) {
    if (coffHeader.architecture == ArchitectureType::MIPS16 || coffHeader.architecture == ArchitectureType::MIPSFPU || coffHeader.architecture == ArchitectureType::MIPSFPU16 ||
        coffHeader.architecture == ArchitectureType::R3000 || coffHeader.architecture == ArchitectureType::R4000 || coffHeader.architecture == ArchitectureType::R10000) {
        MIPSBaseRelocationType mipsTypeBits = value;
        return mipsTypeBits;
    }
    else if (coffHeader.architecture == ArchitectureType::ARM || coffHeader.architecture == ArchitectureType::ARM64 || coffHeader.architecture == ArchitectureType::ARMNT) {
        ARMBaseRelocationType armTypeBits = value;
        return armTypeBits;
    }
    else if (coffHeader.architecture == ArchitectureType::RISCV32 || coffHeader.architecture == ArchitectureType::RISCV64 || coffHeader.architecture == ArchitectureType::RISCV128) {
        RISCVBaseRelocationType riscvTypeBits = value;
        return riscvTypeBits;
    }
    else if (coffHeader.architecture == ArchitectureType::THUMB) {
        THUMBBaseRelocationType thumbTypeBits = value;
        return thumbTypeBits;
    }
    else if (coffHeader.architecture == ArchitectureType::LOONGARCH32 || coffHeader.architecture == ArchitectureType::LOONGARCH64) {
        LoongarchBaseRelocationType loongarchTypeBits = value;
        return loongarchTypeBits;
    }
    else {
        BaseRelocationType genericTypeBits = value;
        return genericTypeBits;
    }
};

bitfield BaseRelocationWord {
    offset : 12;
    type : 4 [[format("formatBaseRelocationType")]];
};

struct BaseRelocationBlock {
    u32 pageRVA;
    u32 blockSize;
    BaseRelocationWord word[while($ < addressof(this) + this.blockSize)] [[inline]];
};

struct BaseRelocationTable {
    BaseRelocationBlock baseRelocationBlocks[while($ < addressof(this) + coffHeader.optionalHeader.directories[5].size)] [[inline]];
};

// Debug Table
enum DebugType : u32 {
    Unknown,
    COFF,
    Codeview,
    FPO,
    Misc,
    Exception,
    Fixup,
    OmapToSRC,
    OmapFromSRC,
    Borland,
    CLSID = 11,
    REPRO = 16,
    ExtendedDLLCharacteristics = 20
};

struct RSDS {
    char signature[4];
    type::GUID guid;
    u32 age;
    char path[] [[format("formatNullTerminatedString")]];
};

struct DebugDirectory {
    u32 characteristics;
    type::time32_t timeDateStamp;
    u16 majorVersion;
    u16 minorVersion;
    DebugType type;
    u32 sizeOfData;
    u32 virtualAddressOfRawData;
    u32 pointerOfRawData;
};

struct DebugData {
    DebugDirectory directory;
    if (std::mem::read_string(directory.pointerOfRawData, 4) == "RSDS") {
        RSDS rsds @ directory.pointerOfRawData;
    }
    else {
        u8 data[directory.sizeOfData] @ directory.pointerOfRawData;
    }
    $ = addressof(this)+coffHeader.optionalHeader.directories[6].size;
};

// TLS Table
struct TLSTable {
    if (coffHeader.optionalHeader.magic == PEFormat::PE32Plus) {
        u64 rawDataStartVA;
        u64 rawDataEndVA;
        u64 indexAddress;
        u64 callbacksAddress;
    }
    else {
        u32 rawDataStartVA;
        u32 rawDataEndVA;
        u32 indexAddress;
        u32 callbacksAddress;
    }
    u32 zeroFillSize;
    u32 characteristics;
    $ = addressof(this)+coffHeader.optionalHeader.directories[9].size;
};

// CRT Section
struct CRTSection {
    u64 virtualAddresses[while($ < sectionsTable[currentSectionIndex].ptrRawData + sectionsTable[currentSectionIndex].sizeOfRawData)];
};

// Sections
struct LineNumber {
    if (std::mem::read_unsigned($+4) > 0) {
        u32 virtualAddress;
    } else {
        u32 symbolTableIndex;
    }
    u32 lineNumber;
};

bool dataDirectoryInSection[coffHeader.optionalHeader.numberOfRVAsAndSizes];

fn checkForDataDirectory() {
    for (u32 i = 0, i < coffHeader.optionalHeader.numberOfRVAsAndSizes, i += 1)
        if (coffHeader.optionalHeader.directories[i].rva - relativeVirtualDifference() < sectionsTable[currentSectionIndex].ptrRawData+sectionsTable[currentSectionIndex].sizeOfRawData
         && coffHeader.optionalHeader.directories[i].rva - relativeVirtualDifference() >= $)
            dataDirectoryInSection[i] = true;
};

fn noDataDirectories() {
    for (u32 i = 0, i < coffHeader.optionalHeader.numberOfRVAsAndSizes, i += 1)
        if (dataDirectoryInSection[i]) return false;
    return true;
};

fn clearDirectoryChecks() {
    for (u32 i = 0, i < coffHeader.optionalHeader.numberOfRVAsAndSizes, i += 1)
        dataDirectoryInSection[i] = false;
};

struct Section {
    checkForDataDirectory();
    if (noDataDirectories()) {
        if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".CRT")) // CRT section
            CRTSection crtSection;
        else
            u8 freeformSection[sectionsTable[currentSectionIndex].sizeOfRawData];     // Freeform data section
    }
    else {
        if (dataDirectoryInSection[0]) {
            ExportsTable exportTable @ coffHeader.optionalHeader.directories[0].rva - relativeVirtualDifference();
        }
        if (dataDirectoryInSection[1]) {
            ImportsTable importTable @ coffHeader.optionalHeader.directories[1].rva - relativeVirtualDifference();
        }
        if (dataDirectoryInSection[2]) {
            ResourceTable resourceTable @ coffHeader.optionalHeader.directories[2].rva - relativeVirtualDifference();
        }
        if (dataDirectoryInSection[3]) {
            ExceptionTable exceptionTable @ coffHeader.optionalHeader.directories[3].rva - relativeVirtualDifference();
        }
        if (dataDirectoryInSection[5]) {
            BaseRelocationTable baseRelocationTable @ coffHeader.optionalHeader.directories[5].rva - relativeVirtualDifference();
        }
        if (dataDirectoryInSection[6]) {
            DebugData debugData @ coffHeader.optionalHeader.directories[6].rva - relativeVirtualDifference();
        }
        if (dataDirectoryInSection[7]) {
            char copyright[] @ coffHeader.optionalHeader.directories[7].rva - relativeVirtualDifference() [[format("formatNullTerminatedString")]];
        }
        if (dataDirectoryInSection[9]) {
            TLSTable tlsTable @ coffHeader.optionalHeader.directories[9].rva - relativeVirtualDifference();
        }
        if (dataDirectoryInSection[13]) {
            DelayedImportsTable delayedImportTable @ coffHeader.optionalHeader.directories[13].rva - relativeVirtualDifference();
        }
    }
    clearDirectoryChecks();

    LineNumber lineNumbers[sectionsTable[currentSectionIndex].numberOfLineNumbers] @ sectionsTable[currentSectionIndex].ptrLineNumbers;

    // Next section
    if (sectionsTable[currentSectionIndex].sizeOfRawData > 0)                   // If the size of the next section is bigger than 0
        $ = addressof(this) + sectionsTable[currentSectionIndex].sizeOfRawData; // Put the current offset at the start of it to account for any bytes left
    if (currentSectionIndex < coffHeader.numberOfSections-1)                    // If it's not the last section (to not make $ the address of an inexistent section)
        $ = sectionsTable[currentSectionIndex+1].ptrRawData;                    // Put the current offset at the next section's address
    currentSectionIndex += 1;                                                   // Make the current section index the next section's index
} [[name(sectionsTable[currentSectionIndex-1].name)]];

Section sections[coffHeader.numberOfSections] @ coffHeader.optionalHeader.sizeOfHeaders * !sectionsTable[0].sizeOfRawData
                                                + sectionsTable[0].ptrRawData * (sectionsTable[0].sizeOfRawData>0);

// Symbol & String Tables
enum SectionNumberType : s16 {
    Undefined = 0,
    Absolute = -1,
    Debug = -2
};

enum SymbolTypeMSB : u8 {
    Null = 0x00,
    Pointer = 0x10,
    Function = 0x20,
    Array = 0x30
};

enum SymbolTypeLSB : u8 {
    Null = 0x00,
    Void = 0x01,
    Char = 0x02,
    Short = 0x03,
    Integer = 0x04,
    Long = 0x05,
    Float = 0x06,
    Double = 0x07,
    Struct = 0x08,
    Union = 0x09,
    Enum = 0x0A,
    MemberOfEnum = 0x0B,
    Byte = 0x0C,
    Word = 0x0D,
    UInt = 0x0E,
    DWord = 0x0F
};

enum StorageClassType : s8 {
    EndOfFunction = -1,
    Null = 0,
    Automatic = 1,
    External = 2,
    Static = 3,
    Register = 4,
    DefinedExternally = 5,
    Label = 6,
    UndefinedLabel = 7,
    MemberOfStruct = 8,
    Argument = 9,
    StructTag = 10,
    MemberOfUnion = 11,
    UnionTag = 12,
    TypeDefinition = 13,
    UndefinedStatic = 14,
    EnumTag = 15,
    MemberOfEnum = 16,
    RegisterParameter = 17,
    Bitfield = 18,
    Block = 100,
    BlockFunction = 101,
    EndOfStruct = 102,
    File = 103,
    Section = 104,
    WeakExternal = 105,
    CLRToken = 107
};

struct SymbolNameOffset {
    padding[4];
    u32 offset [[name("nameOffset")]];
} [[inline]];

struct SymbolType {
    SymbolTypeMSB msb;
    SymbolTypeLSB lsb;
};

fn formatSymbolType(SymbolType value) {
    return "{ " + std::string::to_string(value.msb) + " | " + std::string::to_string(value.lsb) + " }";
};

struct Symbol {
    if (std::mem::read_unsigned($, 4) == 0)
        SymbolNameOffset nameOffset;
    else char shortName[8];
    u32 value;
    SectionNumberType sectionNumber;
    SymbolType type [[format("formatSymbolType")]];
    StorageClassType storageClass;
    u8 numberOfAuxSymbols;
};

bool checkForSymbols in;

Symbol symbolTable[checkForSymbols * coffHeader.numberOfSymbols] @ coffHeader.pointerToSymbolTable;

struct SymbolString {
    char string[] [[format("formatNullTerminatedString")]];
} [[inline]];

struct StringTable {
    u32 size;
    SymbolString strings[while($ < addressof(this) + size)];
} [[inline]];

StringTable stringTable[sizeof(symbolTable)>0] @ addressof(symbolTable) + sizeof(symbolTable);

// Rich Header
bool checkForRichHeader in;
u16 richHeaderEndPosition;
u32 richHeaderPosition;
fn findRichHeader() {
    if (checkForRichHeader) {
        for (u16 richEndCursor = peHeader.dosHeader.coffHeaderPointer, richEndCursor > peHeader.dosHeader.headerSizeInParagraphs*16, richEndCursor -= 1) {
            if (std::mem::read_string(richEndCursor, 4) == "Rich") {
                richHeaderEndPosition = richEndCursor;
                //0x18 is the size of a Rich Header body with one product
                for (u16 richCursor = richHeaderEndPosition - 0x18, richCursor > peHeader.dosHeader.headerSizeInParagraphs*16, richCursor -= 1) {
                    if (str(std::mem::read_unsigned(richCursor, 4) ^ std::mem::read_unsigned(richHeaderEndPosition+4, 4)) == "DanS") {
                        richHeaderPosition = richCursor;
                        break;
                    }
                }
                break;
            }
        }
    }
};
findRichHeader();

fn formatHexadecimally(auto value) {
    return std::string::to_string(value) + " (" + std::format("0x{:X}", value) + ")";
};
fn unmask(u32 value) {
    return formatHexadecimally(value ^ std::mem::read_unsigned(richHeaderEndPosition+4, 4));
};
fn unmaskBuild(u32 value) {
    return formatHexadecimally(value ^ std::mem::read_unsigned(richHeaderEndPosition+4, 2));
};
fn unmaskProduct(u16 type) {
    str value = "Unknown";
    str notation = "0x";
    if (type ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2) < 0x10) { notation += "0"; }
    match(type ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2)) {
        (0x00): value = "Unmarked";
        (0x01): value = "Imports";
        (0x04): value = "STDLIBDLL";
        (0x06): value = "VS97CVTRes";
        (0x0A): value = "VS98CCompiler";
        (0x0B): value = "VS98CPPCompiler";
        (0x0C): value = "OldNames";
        (0x0E): value = "MASM613";
        (0x0F): value = "VS2003Assembler";
        (0x16): value = "VC6SP5";
        (0x19): value = "VS2002Linker";
        (0x1C): value = "VS2002CCompiler";
        (0x1D): value = "VS2002CPPCompiler";
        (0x5D): value = "VS2003SDKIMP";
        (0x60): value = "VS2003CPPCompiler";
        (0x6D): value = "VS2005CCompiler";
        (0x6E): value = "VS2005CPPCompiler";
        (0x7B): value = "VS2005Linker";
        (0x93): value = "VS2008Linker";
        (0x9D): value = "Linker12";
        (0x9E): value = "MASM10";
        (0xAA): value = "VS2010CCompiler";
        (0xAB): value = "VS2010CPPCompiler";
        (0xFF): value = "VS2015CVTRes";
        (0x101 | 0x102): value = "VS2015Linker";
        (0x103): value = "VS2015Assembler";
        (0x104): value = "VS2015CCompiler";
        (0x105): value = "VS2015CPPCompiler";
    }
    return value + " (" + std::format(notation + "{:X}", type ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2)) + ")";
};

struct Product {
    u16 buildNumber [[format("unmaskBuild")]];
    u16 productID [[format("unmaskProduct")]];
    u32 objectCount [[format("unmask")]];
};

fn formatSignature(auto value) {
    return "\"DanS\"";
};
using NullPadding = u32 [[format("unmask")]];

struct RichHeader {
    char maskedSignature[4] [[format("formatSignature")]];
    NullPadding nullPadding[3];
    Product products[while($ < richHeaderEndPosition)];
    char signature[4];
    u32 mask;
};

struct RichHeaderContainer { if (checkForRichHeader) RichHeader richHeader; };
RichHeaderContainer richHeaderContainer @ richHeaderPosition [[inline]];
