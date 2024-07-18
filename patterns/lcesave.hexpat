#pragma author DexrnZacAttack
#pragma description Pattern for Minecraft LCE Save Files (after decompression)
#pragma version 1.3.0
#pragma disclaimer This pattern is not affiliated with Mojang Studios nor Microsoft. Minecraft is a trademark of Mojang Studios and Microsoft.
#pragma endian big
/*
 * ^ switch this to little for Switch, PS4, or Xbox One
 * so you'll probs have to switch all of the be to le
*/

// NOTE: This pattern was only tested on Nightly@974c4ba, things may break/not work on older versions.
// ALSO NOTE: SPEGHETTI CODE!

// TODO: re-add nbt pattern
// TODO: clean up getFileType

import std.string;
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
} [[name("(" + getFileType(std::string::to_string(filename)) + ") " + std::string::to_string(this.filename))]];

struct LCEHeader {
    u32 offset [[name("Index Offset")]]; // where the index is located
    u32 count [[name("Index File Count")]]; // amount of files in the index
    u16 minVersion [[name("Minimum LCE file version")]]; // Minimum LCE version supported by file
    u16 curVersion [[name("Current LCE file version")]]; // Version that the file was written with
};

struct LCESave {
    LCEHeader header [[name("Header")]];
    if (header.curVersion > 1)
        LCEIndex index[header.count] @ header.offset [[name("File Index")]]; // the index
    else
        LCEIndex index[header.count / 136] @ header.offset [[name("File Index")]]; // the index (pre-release)
} [[name("Save " + "(Version " + std::string::to_string(header.curVersion) + ")")]];

LCESave Save @ 0x00;
