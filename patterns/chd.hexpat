#pragma author Lexi Mayfield
#pragma description MAME Compressed Hunks of Data
#pragma endian big

fn CHD_MAKE_TAG(char a, char b, char c, char d) {
    return (u32(u8(a)) << 24) |
           u32(u8((b)) << 16) |
           u32(u8((c)) << 8) |
            u32(u8(d));
};

enum CHDv5_CODEC : u32 {
    NONE = 0,
    ZLIB = CHD_MAKE_TAG('z','l','i','b'),
    ZSTD = CHD_MAKE_TAG('z','s','t','d'),
    LZMA = CHD_MAKE_TAG('l','z','m','a'),
    HUFFMAN = CHD_MAKE_TAG('h','u','f','f'),
    FLAC = CHD_MAKE_TAG('f','l','a','c'),
    CD_ZLIB = CHD_MAKE_TAG('c','d','z','l'),
    CD_ZSTD = CHD_MAKE_TAG('c','d','z','s'),
    CD_LZMA = CHD_MAKE_TAG('c','d','l','z'),
    CD_FLAC = CHD_MAKE_TAG('c','d','f','l'),
    AVHUFF = CHD_MAKE_TAG('a','v','h','u'),
};

enum CHDv5_METADATA_TAG : u32 {
    CHDMETATAG_WILDCARD = 0,
    HARD_DISK_METADATA_TAG = CHD_MAKE_TAG('G','D','D','D'),
    HARD_DISK_IDENT_METADATA_TAG = CHD_MAKE_TAG('I','D','N','T'),
    HARD_DISK_KEY_METADATA_TAG = CHD_MAKE_TAG('K','E','Y',' '),
    PCMCIA_CIS_METADATA_TAG = CHD_MAKE_TAG('C','I','S',' '),
    CDROM_OLD_METADATA_TAG = CHD_MAKE_TAG('C','H','C','D'),
    CDROM_TRACK_METADATA_TAG = CHD_MAKE_TAG('C','H','T','R'),
    CDROM_TRACK_METADATA2_TAG = CHD_MAKE_TAG('C','H','T','2'),
    GDROM_OLD_METADATA_TAG = CHD_MAKE_TAG('C','H','G','T'),
    GDROM_TRACK_METADATA_TAG = CHD_MAKE_TAG('C','H','G','D'),
    DVD_METADATA_TAG = CHD_MAKE_TAG('D','V','D',' '),
    AV_METADATA_TAG = CHD_MAKE_TAG('A','V','A','V'),
    AV_LD_METADATA_TAG = CHD_MAKE_TAG('A','V','L','D'),
};

struct CHDv5UncompressedMap {
    u32 offset;
};

struct CHDv5CompressedMapEntry {
    u8 compression;
    u24 complength;
    u48 offset;
    u16 crc;
};

struct CHDv5CompressedMap {
    u32 length;
    u48 datastart;
    u16 crc;
    u8 lengthbits;
    u8 hunkbits;
    u8 parentunitbits;
    u8 reserved;
};

struct CHDv5MetadataEntry {
    CHDv5_METADATA_TAG metatag;
    u8 flags;
    u24 length;
    u64 next;    
    char entry[length];
    
    if (next != 0) {
        CHDv5MetadataEntry nextMeta @ next;
    }
};

struct CHDv5 {
    CHDv5_CODEC compressors[4];
    u64 logicalbytes;
    u64 mapoffset;
    u64 metaoffset;
    u32 hunkbytes;
    u32 unitbytes;
    u8 rawsha1[20];
    u8 sha1[20];
    u8 parentsha1[20];
    
    if (compressors[0] == CHDv5_CODEC::NONE) {
        CHDv5UncompressedMap map @ mapoffset;
    } else {
        CHDv5CompressedMap map @ mapoffset;
    }
    
    CHDv5MetadataEntry meta @ metaoffset;
};

struct CHD {
    char tag[8];
    u32 length;
    u32 version;
    
    if (version == 5) {
        CHDv5 chd;
    }
};

CHD chd @ 0x00;