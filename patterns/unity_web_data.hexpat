#pragma author unidentifiedfox
#pragma description Unity Web Data 1.0

#pragma magic ["UnityWebData1.0\0"] @ 0x00
#pragma endian little

import std.mem;

struct FileEntry {
    u32 fileOffset;
    u32 fileSize;
    u32 filePathSize;
    char filePath[filePathSize];

    std::mem::Bytes<fileSize> fileData @ fileOffset [[name(filePath)]];
};

struct Header {
    char signature[16];
    u32 headerSize;

    FileEntry entries[while($ < headerSize)];
};

Header header @ 0x00;