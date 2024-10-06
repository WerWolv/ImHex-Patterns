#pragma author DexrnZacAttack
#pragma description Minecraft LCE Save File


// NOTE: SPEGHETTI CODE!

import std.string;
import std.mem;
import std.core;
import hex.dec;
import hex.core;
#pragma pattern_limit 1000000
#pragma array_limit 1000000

fn getFileType(str filename) {
    // EWWWWWWW HOW DO I FIX THIS
    match (std::string::substr(filename, std::string::length(filename) - 4, 4)) {
        (".mcr"):
                if (std::string::starts_with(filename, "r."))
                    return "Overworld Region";
                else if (std::string::starts_with(filename, "DIM-1"))
                    return "Nether Region";
                else if (std::string::starts_with(filename, "DIM1"))
                    return "End Region";
                else
                    return "Unknown Region";
        (".dat"):
            if (std::string::starts_with(filename, "players"))
                return "Player";
            else if (std::string::starts_with(filename, "data/")) {
                if (std::string::starts_with(filename, "data/map_"))
                    return "Map File";
                else
                    return "Other DAT File";
            } else if (std::string::starts_with(filename, "level"))
                return "Level File";
            else
                return "Unknown DAT";
      
        (_): return "File";
    }
};

struct LCEIndex {
    char16 filename[0x40] [[name("File Name")]]; // name of the file.
    u32 filesize [[name("File Size")]]; // how big the file is
    u32 offset [[name("File Offset")]]; // where the file is located
    if (parent.header.curVersion > 1)
        u64 timestamp [[name("File Timestamp")]]; // useless as it writes weirdly, and differently on certain consoles. (e.g using time since last reset, etc)
    u8 file[filesize] @ offset [[name(this.filename),comment(getFileType(std::string::to_string(filename))),attribute_name(this.filename)]]; // files in the index
    hex::core::add_virtual_file(std::string::to_string(filename), file);
} [[name("(" + getFileType(std::string::to_string(filename)) + ") " + std::string::to_string(this.filename))]];


struct LCEHeader {
    u32 offset [[name("Index Offset")]]; // where the index is located
    u32 count [[name("Index File Count")]]; // amount of files in the index
    u16 minVersion [[name("Minimum LCE file version")]]; // Minimum LCE version supported by file
    u16 curVersion [[name("Current LCE file version")]]; // Version that the file was written with
};

struct CompressedSave {
    be u64 zlibSize;
    u8 zlibData[std::mem::size() - 8];
    std::mem::Section zlib = std::mem::create_section(std::format("Compressed Save"));
    hex::dec::zlib_decompress(zlibData, zlib, 15);
    u8 decompressed[zlibSize] @ 0x00 in zlib;
    hex::core::add_virtual_file("save", decompressed);
    std::error("This save is ZLib-compressed, grab the decompressed save from the Virtual Filesystem tab and use this pattern on it.");
};

struct LCESave {
    u8 zlibMagic[2] @ 0x08 [[hidden]];
    // check if header matches
    if (zlibMagic[0] == 0x78 && zlibMagic[1] == 0x9C)
        CompressedSave compSave @ 0x00;    
    
    // if not we will have continued.
    le u16 endianCheck @ 0x0A [[hidden]];
    // check if version is bigger than 14
    if (endianCheck > 14)
        std::core::set_endian(std::mem::Endian::Big);
        
    // rest of the processing
    LCEHeader header [[name("Header")]];
    if (header.curVersion > 1)
        LCEIndex index[header.count] @ header.offset [[name("File Index")]]; // the index
    else
        LCEIndex index[header.count / 136] @ header.offset [[name("File Index")]]; // the index (pre-release)
} [[name("Save " + "(Version " + std::string::to_string(header.curVersion) + ")")]];

LCESave Save @ 0x00;
