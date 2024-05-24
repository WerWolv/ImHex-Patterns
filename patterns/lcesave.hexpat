#pragma author DexrnZacAttack
#pragma description Pattern for Minecraft LCE Save Files (after decompression)
#pragma version 1.1.0
#pragma disclaimer This pattern is not affiliated with Mojang Studios nor Microsoft. Minecraft is a trademark of Mojang Studios and Microsoft.

#pragma endian big
/*
 * ^ switch this to little for Switch, PS4, or Xbox One
 * so you'll probs have to switch all of the be to le
*/

struct LCEIndex {
    be char16 filename[0x40] [[name("Filename")]]; // name of the file.
    be u32 filesize [[name("Filesize")]]; // how big the file is
    be u32 offset [[name("File Offset")]]; // where the file is located
    be u64 timestamp [[name("File Timestamp (maybe incorrect)")]]; // file last modified date 
    u8 file[filesize] @ offset [[name(filename),comment(this.filename),attribute_name(this.filename)]]; // files in the index
};

struct LCESaveHeader {
    be u32 offset [[name("Index Offset")]]; // where the index is located
    be u32 count [[name("Index File Count")]]; // amount of files in the index
    LCEIndex index[count] @ offset [[name("File Index")]]; // the index
};

LCESaveHeader save @ 0x00;
