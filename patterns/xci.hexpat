#pragma author WerWolv
#pragma description Nintendo Switch XCI cartridge ROM

import std.core;

import type.magic;
import type.size;

#define PAGE_SIZE 0x200

enum RomSize : u8 {
    _1GB = 0xFA,
    _2GB = 0xF8,
    _4GB = 0xF0,
    _8GB = 0xE0,
    _16GB = 0xE1,
    _32GB = 0xE2
};

bitfield Index {
    titleKeyDecIndex    : 4;
    kekIndex            : 4;
};

bitfield Flags {
    autoBoot                            : 1;
    historyErase                        : 1;
    repairTool                          : 1;
    differentRegionCupToTerraDevice     : 1;
    differentRegionCupToGlobalDevice    : 1;
    padding                             : 2;
    hasNewCardHeader                    : 1;
};

struct SelSec {
    u16 t1, t2;
};

struct CardHeader {
    u8 headerSignature[0x100];
    type::Magic<"HEAD"> magic;
    u32 romAreaStartPageAddress;
    u32 backupAreaStartPageAddress;
    Index index [[inline]];
    RomSize romSize;
    u8 cardHeaderVersion;
    Flags flags;
    u64 packageId;
    u32 validDataEndAddress;
    padding[4];
    u8 iv[0x10];
    u64 partitionFsHeaderAddress;
    type::Size<u64> partitionFsHeaderSize;
    u8 partitionFsHeaderHash[0x20];
    u8 initialDataHash[0x20];
    SelSec selSec;
    u32 selT1Key;
    u32 selKey;
    u32 limArea;
    
    u8 cardHeaderEncryptedData[0x70];
};

struct FileEntry {
    u64 dataOffset;
    type::Size<u64> dataSize;
    u32 fileNameOffset;
    type::Size<u32> hashedRegionSize;
    padding[8];
    u8 hash[0x20];
};

struct String {
    char string[];
};

struct File {
    String fileName @ addressof(parent.stringTable) + parent.fileEntryTable[std::core::array_index()].fileNameOffset;
    u8 data[parent.fileEntryTable[std::core::array_index()].dataSize] @ addressof(parent.stringTable) + sizeof(parent.stringTable) + parent.fileEntryTable[std::core::array_index()].dataOffset [[sealed]];
};

struct PartitionFs {
    type::Magic<"HFS0"> magic;
    u32 fileCount;
    type::Size<u32> stringTableSize;
    padding[4];
    FileEntry fileEntryTable[fileCount];
    String stringTable[while($ < (addressof(fileEntryTable) + sizeof(fileEntryTable) + stringTableSize))];
    
    File files[fileCount];
};

struct XCI {
    CardHeader header;
    
    PartitionFs x @ header.romAreaStartPageAddress * PAGE_SIZE;
    
};

XCI xci @ 0x00;