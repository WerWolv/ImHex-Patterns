#pragma author Dominik Tamiollo
#pragma description Preffered Executable Format executable (for Mac OS 7.1.2 - Mac OS 10.4 / BeOS)
#pragma endian big
#pragma pattern_limit 1000000
#pragma magic [4A 6F 79 21] @ 0x00

import std.core;
import std.sys;

struct PEFContainerHeader 
{
    char tag1 [4] [[comment("designates that the container uses an Apple-defined format. This field must be set to Joy! in ASCII.")]];
    char tag2 [4] [[comment("identifies the type of container (currently set to peff in ASCII")]];
    char architecture [4] [[comment("indicates the architecture type that the container was generated for. This field holds the ASCII value pwpc for the PowerPC CFM implementation or m68k for CFM-68K.")]];
    u32 formatVersion [[comment("indicates the version of PEF used in the container. The current version is 1.")]];
    u32 dateTimeStamp [[comment("indicates when the PEF container was created. The stamp follows the Macintosh time-measurement scheme (that is, the number of seconds measured from January 1, 1904)")]];
    u32 oldDefVersion [[comment("contain version information that the Code Fragment Manager uses to check shared library compatibility")]];
    u32 oldImpVersion [[comment("contain version information that the Code Fragment Manager uses to check shared library compatibility")]];
    u32 currentVersion [[comment("contain version information that the Code Fragment Manager uses to check shared library compatibility")]];
    u16 sectionCount [[comment("indicates the total number of sections contained in the container.")]];
    u16 instSectionCount [[comment("indicates the number of instantiated sections. Instantiated sections contain code or data that are required for execution.")]];
    u32 reservedA;
};

enum SectionKind :u8
{
    kPEFCodeSection = 0, // Contains read-only executable code in an uncompressed binary format. A container can have any number of code sections. Code sections are always shared.
    kPEFUnpackedDataSection = 1, // Contains uncompressed, initialized, read/write data followed by zero-initialized read/write data.
    kPEFPackedDataSection = 2, // Contains read/write data initialized by a pattern specification contained in the section’s contents. The contents essentially contain a small program that tells the Code Fragment Manager how to initialize the raw data in memory.
    kPEFConstantSection = 3, // Contains uncompressed, initialized, read-only data. A container can have any number of constant sections, and they are implicitly shared.
    kPEFLoaderSection = 4, // Contains information about imports, exports, and entry points. A container can have only one loader section.
    kPEFDebugSection = 5, // Reserved for future use
    kPEFExecDataSection = 6, // Contains information that is both executable and modifiable. For example, this section can store code that contains embedded data. A container can have any number of executable data sections, each with a different sharing option.
    kPEFExceptionSection = 7, // Reserved for future use
    kPEFTracebackSection = 8  // Reserved for future use
};

enum ShareKind : u8
{
    Process_Share = 1, //Indicates that the section is shared within a process, but a fresh copy is created for different processes.
    Global_Share = 4, // Indicates that the section is shared between all processes in the system.
    Protected_Share = 5 // Indicates that the section is shared between all processes, but is protected. Protected sections are read/write in privileged mode and read-only in user mode. This option is not available in System 7.
};

struct PEFSectionHeader 
{
    s32 nameOffset [[comment("holds the offset from the start of the section name table to the location of the section name. The name of the section is stored as a C-style null-terminated character string.")]];
    u32 defaultAddress [[comment("indicates the preferred address (as designated by the linker) at which to place the section’s instance. If the Code Fragment Manager can place the instance in the preferred memory location, the load-time and link-time addresses are identical and no internal relocations need to be performed.")]];
    u32 totalSize [[comment("indicates the size, in bytes, required by the section’s contents at execution time. For a code section, this size is merely the size of the executable code. For a data section, this size indicates the sum of the size of the initialized data plus the size of any zero-initialized data. Zero-initialized data appears at the end of a section’s contents and its length is exactly the difference of the totalSize and unpackedSize values. For noninstantiated sections, this field is ignored.")]];
    u32 unpackedSize [[comment("is the size of the section’s contents that is explicitly initialized from the container. For code sections, this field is the size of the executable code. For an unpacked data section, this field indicates only the size of the initialized data. For packed data this is the size to which the compressed contents expand. The unpackedSize value also defines the boundary between the explicitly initialized portion and the zero-initialized portion.")]];
    u32 packedSize [[comment("indicates the size, in bytes, of a section’s contents in the container. For code sections, this field is the size of the executable code. For an unpacked data section, this field indicates only the size of the initialized data. For a packed data section this field is the size of the pattern description contained in the section.")]];
    u32 containerOffset [[comment("contains the offset from the beginning of the container to the start of the section’s contents. Packed data sections and the loader section should be 4-byte aligned. Code sections and data sections that are not packed should be at least 16-byte aligned.")]];
    SectionKind sectionKind [[comment("indicates the type of section as well as any special attributes. Note that instantiated read-only sections cannot have zero-initialized extensions.")]];
    ShareKind shareKind [[comment("controls how the section information is shared among processes by the Code Fragment Manager.")]];
    u8 alignment [[comment("indicates the desired alignment for instantiated sections in memory as a power of 2. A value of 0 indicates 1-byte alignment, 1 indicates 2-byte (halfword) alignment, 2 indicates 4-byte (word) alignment, and so on. Note that this field does not indicate the alignment of raw data relative to a container. The Code Fragment Manager does not support this field under System 7.")]];
    u8 reservedA;
    u8 data[packedSize] @ containerOffset;
};


struct String {
    char value[];
} [[sealed, format("format_string")]];

fn format_string(String string) 
{
    return string.value;    
};

struct PEFLoaderInfoHeader 
{
    s32 mainSection [[comment("specifies the number of the section in this container that contains the main symbol. If the fragment does not have a main symbol, this field is set to -1.")]];
    u32 mainOffset [[comment("indicates the offset (in bytes) from the beginning of the section to the main symbol.")]];
    s32 initSection [[comment("contains the number of the section containing the initialization function’s transition vector. If no initialization function exists, this field is set to -1.")]];
    u32 initOffset [[comment("indicates the offset (in bytes) from the beginning of the section to the initialization function’s transition vector.")]];
    s32 termSection [[comment("contains the number of the section containing the termination routine’s transition vector. If no termination routine exists, this field is set to -1.")]];
    u32 termOffset [[comment("indicates the offset (in bytes) from the beginning of the section to the termination routine’s transition vector.")]];
    u32 importedLibraryCount [[comment("The importedLibraryCount field (4 bytes) indicates the number of imported libraries.")]];
    u32 totalImportedSymbolCount [[comment("indicates the total number of imported symbols.")]];
    u32 relocSectionCount [[comment("indicates the number of sections containing load-time relocations.")]];
    u32 relocInstrOffset [[comment("indicates the offset (in bytes) from the beginning of the loader section to the start of the relocations area.")]];
    u32 loaderStringsOffset [[comment("Indicates the offset (in bytes) from the beginning of the loader section to the start of the loader string table.")]];
    u32 exportHashOffset [[comment("indicates the offset (in bytes) from the beginning of the loader section to the start of the export hash table. The hash table should be 4-byte aligned with padding added if necessary.")]];
    u32 exportHashTablePower [[comment("indicates the number of hash index values (that is, the number of entries in the hash table). The number of entries is specified as a power of two. For example, a value of 0 indicates one entry, while a value of 2 indicates four entries. If no exports exist, the hash table still contains one entry, and the value of this field is 0.")]];
    u32 exportedSymbolCount [[comment("indicates the number of symbols exported from this container.")]];
};

enum importedLibraryOption :u8
{
  kDefault                      = 0x00,  /* Bits for the PEFImportedLibrary options field.*/
  kPEFWeakImportLibMask         = 0x40, /* The imported library is allowed to be missing.*/
  kPEFInitLibBeforeMask         = 0x80  /* The imported library must be initialized first.*/
};

struct PEFImportedLibrary 
{
    u32 nameOffset  [[comment("Indicates the offset (in bytes) from the beginning of the loader string table to the start of the null-terminated library name.")]];
    u32 oldImpVersion [[comment("Provide version information for checking the compatibility of the imported library.")]];
    u32 currentVersion [[comment("Provide version information for checking the compatibility of the imported library.")]];
    u32 importedSymbolCount [[comment("Indicates the number of symbols imported from this library.")]];
    u32 firstImportedSymbol [[comment("Holds the (zero-based) index of the first entry in the imported symbol table for this library.")]];
    importedLibraryOption options [[comment("The high-order bit (mask 0x80) controls the order that the import libraries are initialized. If set to 0, the default initialization order is used, which specifies that the Code Fragment Manager should try to initialize the import library before the fragment that imports it. When set to 1, the import library must be initialized before the client fragment. The next bit (mask 0x40) controls whether the import library is weak. When set to 1 (weak import), the Code Fragment Manager continues preparation of the client fragment (and does not generate an error) even if the import library cannot be found. If the import library is not found, all imported symbols from that library have their addresses set to 0. You can use this information to determine whether a weak import library is actually present.")]];
    u8 reservedA [[comment("Reserved and must be set to 0.")]];
    u16 reservedB [[comment("Reserved and must be set to 0.")]];
} [[format("format_name")]];

enum importSymbolClass :u8
{
    kPEFCodeSymbol = 0, // A code address
    kPEFDataSymbol = 1, // A data address
    kPEFTVectSymbol = 2, // A standard procedure pointer
    kPEFTOCSymbol = 3, // A direct data area (Table of Contents ) symbol
    kPEFGlueSymbol = 4, // A linker-inserted glue symbol
};

struct PEFImportSymbol 
{
  importSymbolClass class [[comment("Indicates the class of the imported symbol.")]];
  u24 nameOffset [[comment("Indicates the offset (in bytes) from the beginning of the loader string table to the null-terminated name of the symbol")]];
} [[format("format_name")]];

struct PEFLoaderRelocationHeader 
{
    u16 sectionIndex [[comment("Designates the section number to which this relocation header refers.")]];
    u16 reservedA [[comment("Reserved")]];
    u32 relocCount [[comment("Indicates the number of 16-bit relocation blocks for this section.")]];
    u32 firstRelocOffset [[comment("Indicates the byte offset from the start of the relocations area to the first relocation instruction for this section.")]];
};

enum relocationOpcode : u8
{
    kPEFRelocBySectDWithSkip      = 0x00, /* Binary: 00x_xxxx*/
    
    kPEFRelocBySectC              = 0x20, /* Binary: 010_0000, group is "RelocRun"*/
    kPEFRelocBySectD              = 0x21, /* Binary: 010_0001*/
    kPEFRelocTVector12            = 0x22, /* Binary: 010_0010*/
    kPEFRelocTVector8             = 0x23, /* Binary: 010_0011*/
    kPEFRelocVTable8              = 0x24, /* Binary: 010_0100*/
    kPEFRelocImportRun            = 0x25, /* Binary: 010_0101*/
    
    kPEFRelocSmByImport           = 0x30, /* Binary: 011_0000, group is "RelocSmIndex"*/
    kPEFRelocSmSetSectC           = 0x31, /* Binary: 011_0001*/
    kPEFRelocSmSetSectD           = 0x32, /* Binary: 011_0010*/
    kPEFRelocSmBySection          = 0x33, /* Binary: 011_0011*/
    
    kPEFRelocIncrPosition         = 0x40, /* Binary: 100_0xxx*/
    
    kPEFRelocSmRepeat             = 0x48, /* Binary: 100_1xxx*/
    
    kPEFRelocSetPosition          = 0x50, /* Binary: 101_000x*/
    kPEFRelocLgByImport           = 0x52, /* Binary: 101_001x*/
    kPEFRelocLgRepeat             = 0x58, /* Binary: 101_100x*/
    kPEFRelocLgSetOrBySection     = 0x5A, /* Binary: 101_101x*/
    kPEFRelocUndefinedOpcode      = 0xFF  /* Used in masking table for all undefined values.*/
};


// "RelocBySectDWithSkip" (DDAT)
bitfield RelocBySectDWithSkip
{
    op : 2; // 00
    skipCount : 8;
    relCount : 6;;
};

// "RelocBySectC" (CODE)
// "RelocBySectD" (DATA)
// "RelocTVector12" (DESC)
// "RelocTVector8" (DSC2)
// "RelocVTable8" (VTBL)
// "RelocImportRun" (SYMR) 
bitfield RelocRunGroup
{
    op : 3; // 010
    subOp : 4;
    runLength : 9;
};

// "RelocSmByImport" (SYMB)
// "RelocSmSetSectC" (CDIS)
// "RelocSmSetSectD" (DTIS) 
// "RelocSmBySection" (SECN)
bitfield RelocSmIndexGroup
{
    op : 3; // 011
    subOp : 4;
    index : 9;
};

// "RelocIncrPosition" (DELT)
bitfield RelocIncrPosition
{
    op : 4; // 1000
    offset : 12;
};

// "RelocSmRepeat" (RPT)
bitfield RelocSmRepeat
{
    op : 4; // 1001
    chnks : 4;
    repeatCount : 8;
};

// "RelocSetPosition" (LABS)
bitfield RelocSetPosition
{
    op : 6; // 101000
    offset : 26;
};

// "RelocLgByImport" (LSYM)
bitfield RelocLgByImport
{
    op : 6; // 101001
    index : 26;
};

// "RelocLgRepeat" (LRPT)
bitfield RelocLgRepeat
{
    op : 6; // 101100
    chnks : 4;
    repeatCount : 22;
};

// "RelocLgSetOrBySection" (LSEC) instruction is a group including the 
// "RelocLgBySection",
// "RelocLgSetSectC"
// "RelocLgSetSectD"
bitfield RelocLgSetOrBySection
{
    op : 6; // 101101
    subOp : 4;
    index : 22;
};


enum relocLgSetOrBySectionAdditionalOpcode :u8
{
  kPEFRelocLgBySectionSubopcode = 0x00, /* Binary: 0000*/
  kPEFRelocLgSetSectCSubopcode  = 0x01, /* Binary: 0001*/
  kPEFRelocLgSetSectDSubopcode  = 0x02  /* Binary: 0010*/
};


struct RelocInstruction 
{
      u8 firstByte[[no_unique_address, hidden]];
      
      if (firstByte & 0b11000000 == 0)
      {
            RelocBySectDWithSkip instruction;
            std::core::set_display_name(this, "RelocBySectDWithSkip");
      }
      else if (firstByte & 0b01000000 == 0x40)
      {
            RelocRunGroup instruction;
            if (instruction.subOp == 0)
            {
                std::core::set_display_name(this, "RelocBySectC");
            }
            else if (instruction.subOp == 1)
            {
                std::core::set_display_name(this, "RelocBySectD");
            }
            else if (instruction.subOp == 2)
            {
                std::core::set_display_name(this, "RelocTVector12");
            }
            else if (instruction.subOp == 3)
            {
                std::core::set_display_name(this, "RelocTVector8");
            }
            else if (instruction.subOp == 4)
            {
                std::core::set_display_name(this, "RelocVTable8");
            }
            else if (instruction.subOp == 5)
            {
                std::core::set_display_name(this, "RelocImportRun");
            }
      }
      else if (firstByte & 0b01100000 == 0x60)
      {
            RelocSmIndexGroup instruction;
            if (instruction.subOp == 0)
            {
                std::core::set_display_name(this, "RelocSmByImport");
            }
            else if (instruction.subOp == 1)
            {
                std::core::set_display_name(this, "RelocSmSetSectC");
            }
            else if (instruction.subOp == 2)
            {
                std::core::set_display_name(this, "RelocSmSetSectD");
            }
            else if (instruction.subOp == 3)
            {
                std::core::set_display_name(this, "RelocSmBySection");
            }
      }
      else if (firstByte & 0b11110000 == relocationOpcode::kPEFRelocIncrPosition << 1)
      {
            RelocIncrPosition instruction;
            std::core::set_display_name(this, "RelocIncrPosition");
      }
      else if (firstByte & 0b11110000 == relocationOpcode::kPEFRelocSmRepeat << 1)
      {
            RelocSmRepeat instruction;
            std::core::set_display_name(this, "RelocSmRepeat");
      }
      else if (firstByte & 0b11111100 == relocationOpcode::kPEFRelocSetPosition << 1)
      {
            RelocSetPosition instruction;
            std::core::set_display_name(this, "RelocSetPosition");
      }
      else if (firstByte & 0b11111100 == relocationOpcode::kPEFRelocLgByImport << 1)
      {
            RelocLgByImport instruction;
            std::core::set_display_name(this, "RelocLgByImport");
      }
      else if (firstByte & 0b11111100 == relocationOpcode::kPEFRelocLgRepeat << 1)
      {
            RelocLgRepeat instruction;
            std::core::set_display_name(this, "RelocLgRepeat");
      }
      else if (firstByte & 0b11111100 == relocationOpcode::kPEFRelocLgSetOrBySection << 1)
      {
            RelocLgSetOrBySection instruction;
            if (instruction.subOp == kPEFRelocLgBySectionSubopcode)
            {
                std::core::set_display_name(this, "RelocLgBySectionSubopcode");
            }
            else if (instruction.subOp == kPEFRelocLgSetSectCSubopcode)
            {
                std::core::set_display_name(this, "RelocLgSetSectCSubopcode");
            }
            else if (instruction.subOp == kPEFRelocLgSetSectDSubopcode)
            {
                std::core::set_display_name(this, "RelocLgSetSectDSubopcode");
            }
      }
};

bitfield PEFExportedSymbolHashSlot 
{
    count : 14;
    start : 18;
};

struct PEFExportedSymbolKey
{
      u16 nameLength;
      u16 hashValue;
};

enum exportSymbolClass :u8
{
    kPEFAbsoluteExport            = -2,   /* The symbol value is an absolute address.*/
    kPEFReexportedImport          = -3    /* The symbol value is the index of a reexported import.*/
};

struct PEFExportSymbol 
{
  exportSymbolClass class [[comment("Indicates the class of the exported symbol.")]];
  u24 nameOffset [[comment("Indicates the offset (in bytes) from the beginning of the loader string table to the null-terminated name of the symbol")]];
};

struct PEFExportedSymbol 
{
    PEFExportSymbol classAndName [[comment("The first byte designates the symbol class of the exported symbol. See \"symbolClass\" enum. Flag bits for exported symbols are reserved for future use. The following 3 bytes designate the offset from the beginning of the loader string table to the name of the symbol. The name of the symbol is not null terminated, but you can determine the length of the string from the upper 2 bytes of the symbol’s hash word (found in the export key table).")]];
    u32 symbolValue [[comment("Typically indicates the offset from the beginning of the symbol’s section to the exported symbol.")]];
    s16 sectionIndex [[comment("Indicates the number of the section that contains this symbol. Note that this is a signed field.")]];
};

PEFContainerHeader containerHeader @ 0x00;
PEFSectionHeader sectionsTable[containerHeader.sectionCount] @ sizeof(containerHeader);

fn getFirstSectionInContainer() 
{
    u32 minOff = 0xFFFFFFFF;
    for (u32 i = 0, i < containerHeader.sectionCount, i += 1)
    {
        u32 sectionOffset = sectionsTable[i].containerOffset;
        if (sectionOffset < minOff)
        {
            minOff = sectionOffset;
        }
    }
    return minOff;
};

u32 firstSectionOffset = getFirstSectionInContainer();
u32 sectionNameTableBase = sizeof(containerHeader) + sizeof(sectionsTable);

String sectionNameTable[while($ < firstSectionOffset)] @ sectionNameTableBase;

fn getLoaderSection() 
{
    for (u32 i = 0, i < containerHeader.sectionCount, i += 1)
    {
        if (sectionsTable[i].sectionKind == SectionKind::kPEFLoaderSection)
        {
            return sectionsTable[i].containerOffset;
        }
    }
};

u32 loaderOffset = getLoaderSection();
PEFLoaderInfoHeader loaderHeader @ loaderOffset;

u32 loaderStringTableOffset = loaderOffset + loaderHeader.loaderStringsOffset;
String loaderStringTable[while($ < loaderOffset + loaderHeader.exportHashOffset)] @ loaderStringTableOffset;

fn format_name(auto pat) 
{
    u32 i = 0;

    u32 nameAddress = loaderStringTableOffset + pat.nameOffset;
    String string @ nameAddress;
    return string;
};

PEFImportedLibrary importTableHeaders[loaderHeader.importedLibraryCount] @ loaderOffset + sizeof(loaderHeader);

u32 importSymbolsOffset = loaderOffset + sizeof(loaderHeader) + loaderHeader.importedLibraryCount * sizeof(PEFImportedLibrary);
PEFImportSymbol importSymbols[loaderHeader.totalImportedSymbolCount] @ importSymbolsOffset;

u32 relocationHeaderOffset = importSymbolsOffset + sizeof(importSymbols);
PEFLoaderRelocationHeader relocationHeaders[loaderHeader.relocSectionCount] @ relocationHeaderOffset;

u32 relocBegin = loaderOffset + loaderHeader.relocInstrOffset;
u32 relocSize = loaderOffset + loaderHeader.loaderStringsOffset - relocBegin;
RelocInstruction relocationInstructions[while(($-relocBegin) < relocSize)] @ relocBegin;

u32 exportSlotNum = 2 * loaderHeader.exportHashTablePower; // 2 ^ loaderHeader.exportHashTablePower
u32 exportDataOffset = loaderOffset + loaderHeader.exportHashOffset;
u32 exportSymbolKeysOffset = exportDataOffset + sizeof(PEFExportedSymbolHashSlot) * exportSlotNum;
u32 exportedSymbolsOffset = exportSymbolKeysOffset + sizeof(PEFExportedSymbolKey) * loaderHeader.exportedSymbolCount;
PEFExportedSymbolHashSlot exportSlots[exportSlotNum] @ exportDataOffset;
PEFExportedSymbolKey exportSymbolKeys[loaderHeader.exportedSymbolCount] @ exportSymbolKeysOffset;
PEFExportedSymbol exportedSymbols[loaderHeader.exportedSymbolCount] @ exportedSymbolsOffset;