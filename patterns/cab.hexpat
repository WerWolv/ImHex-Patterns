#pragma author The Wandering Trader
#pragma description Microsoft Cabinet (CAB) Files
#pragma magic [4D 53 43 46] @ 0x00

import type.time;
import type.magic;
import type.size;

fn format_string(auto string) {
    return std::format("{}",string);
};

bitfield flags {
    bool cfhdrPREV_CABINET : 1;
    bool cfhdrNEXT_CABINET : 1;
    bool cfhdrRESERVE_PRESENT : 1;
    padding : 13;
};

struct CFHEADER {
    type::Magic<"MSCF"> signature;
    u32 reserved1;
    type::Size32 cbCabinet;
    u32 reserved2;
    u32 coffFiles;
    u32 reserved3;
    u8 versionMajor;
    u8 versionMinor;
    u16 cFolders;
    u16 cFiles;
    flags flags;
    u16 setID;
    u16 iCabinet;
    if (flags.cfhdrRESERVE_PRESENT) {
        type::Size16 cbCFHeader;
        type::Size8 cbCFFolder;
        type::Size8  cbCFData;
        u8 abReserve[cbCFHeader];
    }
    if (flags.cfhdrPREV_CABINET) {
        char szCabinetPrev[] [[format("format_string")]];
        char szDiskPrev[] [[format("format_string")]];
    }
    if (flags.cfhdrNEXT_CABINET) {
        char szCabinetNext[] [[format("format_string")]];
        char szDiskNext[] [[format("format_string")]];
    }
};

enum typeCompress : u8{
    tcompMASK_TYPE = 0x000F,
    tcompTYPE_NONE = 0x0000,
    tcompTYPE_MSZIP = 0x0001,
    tcompTYPE_QUANTUM = 0x0002,
    tcompTYPE_LZX = 0x0003,
};

using CFDATA;

struct CFFOLDER {
    u32 coffCabStart;
    u16 cCfData;
    typeCompress typeCompress;
    u8 compressionLevel;
    if (CFHEADER.flags.cfhdrRESERVE_PRESENT) {
        u8 abReserve[CFHEADER.cbCFFolder];
    }
    CFDATA CFDATA[cCfData] @ coffCabStart;
};

bitfield attribs {
    bool _A_RDONLY : 1;
    bool _A_HIDDEN : 1;
    bool _A_SYSTEM : 1;
    padding : 2;
    bool _A_ARCH : 1;
    bool _A_EXEC : 1;
    bool _A_NAME_IS_UTF : 1;
    padding : 8;
};

struct CFFILE {
    type::Size32 cbFile;
    u32 uoffFolderStart;
    u16 iFolder;
    type::DOSDate date;
    type::DOSTime time;
    attribs attribs;
    if (attribs._A_NAME_IS_UTF) {
        char16 szName[];
    } else {
        char szName[] [[format("format_string")]];
    }
    
    
};

struct CFDATA {
    u32 csum;
    type::Size16 cbData;
    type::Size16 cbUncomp;
    if (CFHEADER.flags.cfhdrRESERVE_PRESENT) {
        u8 abReserve[CFHEADER.cbCFData];
    }
    u8 ab[cbData];
};

CFHEADER CFHEADER @ 0;
CFFOLDER CFFOLDER[CFHEADER.cFolders] @ $;
CFFILE CFFILE[CFHEADER.cFiles] @ $;