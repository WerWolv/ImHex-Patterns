#pragma author LolHacksRule
#pragma description Exient XGS Engine Pak

import std.mem;
import std.core;
import type.time;
import type.magic;

//By LolHacksRule

/*
XGSPAK VX only works with games using XGS Engine VX (I think First Touch Games use multiple?), using different versions with them is likely a bad idea as devs can only use one of the three.
XGSPAKV1 can be used with ZLib or Raw content.
Works nearly perfectly on PAKs WITH and WITHOUT folders.
*/

/*
TODO:
Double check XGSPAKV0 from NFS Wii, it's probably similar?
Fix FTG V1 PAK if possible, uses V0 layout
*/

/*
Format info I used:
https://aluigi.altervista.org/bms/angry_birds_go.bms
https://aluigi.altervista.org/bms/angry_birds_starwars.bms
https://aluigi.altervista.org/bms/xpk2.bms
https://aluigi.altervista.org/bms/dls20.bms
*/

enum PakVersion : u8
{
    Version0, //NFS Wii/Trilogy 3DS/DLS
    Version1, //ABGO V1/ABTF, AB Console Ports
    Version2 //ABGO V2+    
};

enum CompressionType : u32
{
    Raw, //NFS Wii/Trilogy 3DS/DLS
    Zlib, //ABGO V1/ABTF, AB Console Ports
    LZ4 //ABGO V2+
};

struct XGSPakHeader
{
    if (std::mem::read_unsigned($, 1) > 2) //Assume BE
    {
        std::core::set_endian(std::mem::Endian::Big);
        char magic[3];
        PakVersion ver;
    }
    else
    {
        PakVersion ver;
        char magic[3];
    }
    u32 folders;
    u32 files; //-1 bcz init folder
    u32 fileContentTableSize;
    if (ver == PakVersion::Version2)
    {
        CompressionType compressionType;
    }
};

struct XGSPakFolderBase
{
    if (Head.ver == PakVersion::Version0)
    {    
        char *name[] : u32[[pointer_base("offToStringTable")]];
        u32 filesInFolder;
        u32 subfolders;
        u32 filesPos;
        u32 foldersPos;
    }
    else
    {
        if (Head.magic == "XPK")
        {
            u32 dummy;
            char *name[] : u32 [[pointer_base("offToStringTable")]];
            u32 dummy2;
            u32 filesPos;
            u32 dummy3;
            u32 foldersPos;
            u32 filesInFolder;
            u32 subfolders;
        }
        else
        {
            //u64 name;
            char *name[] : u64 [[pointer_base("offToStringTable")]];
            u64 filesPos;
            u64 foldersPos;
            u32 filesInFolder;
            u32 subfolders;
        }
    }
};

struct XGSPakContentMeta
{
    if (Head.ver == PakVersion::Version0)
    {    
        char *name[] : u32 [[pointer_base("offToStringTable")]];
        u32 decompFileSize;
        u32 fileOff;
        u32 compressed;
        type::time32_t timestamp;
        u32 compFileSize;
    }
    else
    {
        if (Head.magic == "XPK")
        {
            u32 dummy;
            char *name[] : u32 [[pointer_base("offToStringTable")]];
            u32 decompFileSize;
            u32 fileOff;
            u32 compressed;
            type::time32_t timestamp;
            u32 compFileSize;
            u32 dummy2;
        }
        else
        {
            //u64 name;
            char *name[] : u64 [[pointer_base("offToStringTable")]];
            u32 decompFileSize;
            u32 fileOff;
            u32 compressed;
            type::time32_t timestamp;
            u64 compFileSize;
        }
    }
    if (compressed)
    {
        u8 compressedFile[compFileSize] @ fileOff;
    }
    else
    {
        u8 file[decompFileSize] @ fileOff;
    }
};


XGSPakHeader Head @ $;
//u32 offToStringTable_old = ((0x20*Head.folders)+(0x20*Head.files))+sizeof (Head); //Finicky but it works

fn offToStringTable(u128 offset) {
    match (Head.ver)
    {
        (PakVersion::Version0): return ((0x14*Head.folders)+(0x18*Head.files))+sizeof (Head);
        (PakVersion::Version1 | PakVersion::Version2): return ((0x20*Head.folders)+(0x20*Head.files))+sizeof (Head);
    }
};

XGSPakFolderBase FolderBase[Head.folders] @ $;
XGSPakContentMeta ContentMeta[Head.files] @ $;