#pragma description Unreal Engine 3 UPK
#pragma endian little
#pragma magic [ c1 83 2a 9e ] @ 0x00

import std.io;

#define HEADER_LOCATION 0x00
#define FILE_SIGNATURE 0x9E2A83C1

#define VER_GIGANTIC 867
#define VER_BATMAN_CITY 805

using offset = u32;
bool isCompressed = false;

// Generations Info
struct FGenerationInfo {
    u32 exportcount;
    u32 namecount;
    u32 netobjectcount;
};

// Compressed Chunk Info
struct CompressedChunkInfo {
    offset uncompressedoffset;
    u32 uncompressedsize;
    offset compressedoffset;
    u32 compressedsize;
};

// Name Table Entry
struct FNameEntry {
    s32 namelength;
    char name[];
    u64 nameflags;
};

// Import Table Entry
struct FObjectImport {
    u64 packageid;
    u64 typeid;
    u32 ownerref;
    u64 nameid;
};

// Export Table Entry
struct FObjectExport {
    u32 typeref;
    u32 parentclassref;
    u32 ownerref;
    u64 nameid;
    u32 archetyperef;
    u32 objectflagsh;
    u32 objectflagsl;
    u32 serialsize;
    offset serialoffset;
    u32 exportflags;
    u32 netobjectcount;
    u128 guid;
    u32 unknown1;
    u8 unknown2[netobjectcount * 4];
};

// Main File Header
struct FileHeader {
    // File signature
    u32 signature;
    // Version
    u16 version;
    // Licensee
    u16 licensee;
    // Header Size
    u32 headersize;

    // FolderName
    u32 foldername ;

    // PackageInfo
    char packagegroup[];
    u32 packageflags; // todo: properly expand this

    // GigUnknown
    if (version == VER_GIGANTIC) {
    u32 gigunknown1; // this seems to be unique to gig's upk format
    }

    // Name Table Info
    u32 namecount;
    offset nameoffset;

    // Export Table Info
    u32 exportcount;
    offset exportoffset;

    // Import Table Info
    u32 importcount;
    offset importoffset;

    // Depends Info
    offset dependsoffset;

    // Unknown
    if (version >= VER_BATMAN_CITY) {
        offset serialoffset;
        u32 ueunknown1; // these are present in other ue3 upks
        u32 ueunknown2;
        u32 ueunknown3;
    }

    // GUID
    u128 packageguid;

    // Generations Info
    u32 generationscount;
    FGenerationInfo generations[generationscount];

    // Engine Info
    u32 engineversion;
    u32 cookerversion;

    // Compression Info
    u32 compressionflags;
    u32 compressedchunks;
    CompressedChunkInfo chunks[compressedchunks];
};

// Print Info
fn print_info(FileHeader header) {
    if(header.signature == FILE_SIGNATURE){
        std::print("UPK: Yes");
    } else {
        std::print("UPK: No");
    }

    std::print("Version: {} ",header.version);
    std::print("Licensee: {} ",header.licensee);
    std::print("Compressed: {} ",isCompressed);
    std::print("Name Count: {} ",header.namecount);
    std::print("Import Count: {} ",header.importcount);
    std::print("Export Count: {} ",header.exportcount);
};

FileHeader header @ HEADER_LOCATION;

// Check Compression
if (header.compressionflags != 0 || header.compressedchunks > 0) {
    isCompressed = true;
    print_info(header);
    return;
}

FNameEntry NameTable[header.namecount] @ header.nameoffset;
FObjectImport ImportTable[header.importcount] @ header.importoffset;
FObjectExport ExportTable[header.exportcount] @ header.exportoffset;

print_info(header);
