// Based on https://github.com/mietek/theunarchiver/wiki/StuffIt5Format and https://github.com/ParksProjets/Maconv/blob/master/docs/stuffit/Stuffit_v5.md

#pragma endian big
#pragma MIME application/x-stuffit

#include <std/io.pat>
#include <std/time.pat>

namespace v5 {

    bitfield Flags1 {
        padding : 1;
        folder : 1;
        encrypted : 1;
        padding : 5;
    } [[left_to_right]];
    
    bitfield Flags2 {
        padding : 7;
        resource_fork : 1;
        padding : 8;
    } [[left_to_right]];
    
    using MacOSHFSPlusDate = u32 [[format("v5::format_macos_date")]];
    
    fn format_macos_date(MacOSHFSPlusDate date) {
        return std::time::format(std::time::to_utc(date - 2082844800));
    };
    
    struct Header {
        char magic[0x50];
        u32 unknown1;
        u32 archiveSize;
        u32 entriesOffset;
        u32 unknown2;
    };
    
    struct EntryHeader {
        u32 magic;
        u8 version;
        u8 unknown1;
        u16 headerSize;
        u8 unknown2;
        Flags1 flags;
        MacOSHFSPlusDate creationDate, modificationDate;
        u32 prevEntryOffset, nextEntryOffset, parentEntryOffset;
        u16 nameSize;
        u16 headerChecksum;
        
        u32 dataForkUncompressedLength, dataForkCompressedLength;
        u16 dataForkChecksum;
        u16 unknown3;
    };
    
    enum CompressionMethod : u8 {
        None            = 0x00, // No compression
        Rle90           = 0x01, // Run length encoding
        Compress        = 0x02, // Compress LZW algorithm, 14 bit max code length, block mode
        StuffIt3        = 0x03, // Simple Huffman encoding for individual bytes
        StuffIt5        = 0x05, // LZAH
        StuffIt8        = 0x08, // Miller-Wegman
        StuffIt13       = 0x0D, // LZSS and Huffman
        Stuffit14       = 0x0E, // Unknown
        StuffItArsenic  = 0x0F  // BWT and arithmetic coding
    };
    
    struct Entry {
        EntryHeader header;
        if (header.flags.folder) {
            u16 numFiles;
            
            if (header.dataForkUncompressedLength)
                std::print("Folder entry {} is special!", std::core::array_index());
        } else {
            CompressionMethod compressionMethod;
        }
        
        u8 passwordDataLength;
        u8 passwordInformation[passwordDataLength];
        char fileName[header.nameSize];
        u16 commentSize;
        u16 unknown2;
        char comment[commentSize];
        
        if (!header.flags.folder) {
            Flags2 flags;
            u16 unknown3;
            char fileType[4];
            u32 fileCreator;
            u16 macOSFinderFlags;
            u32 unknown4;
            u32 unknown5;
            u8 unknown6[6];
            
            if (header.version == 1)
                u32 unknown7;
                            
            u8 compressedData[header.dataForkCompressedLength] [[sealed]];
            
            if (header.nextEntryOffset == 0x00)
                break;
            else
                $ = header.nextEntryOffset;
        }
    };
    
    struct StuffIt {
        Header header;
        
        Entry entries[while(true)] @ header.entriesOffset;
    };
    
}

v5::StuffIt stuffIt @ 0x00;