import std.array;
import std.io;
import std.mem;
import type.magic;

/// Source: https://merthsoft.com/linkguide/ti83+/fformat.html

struct Header {
    type::Magic<"**TI83F*">;
    char mysteryBytes[3];
    char comment[0x2A];
    le u16 datasize;
} [[static]];

enum StorageType: u8 {
    Archive = 0x80,
    RAM = 0x00
};

// Source: https://merthsoft.com/linkguide/ti83+/packet.html#vartypes
// Although 8e (TI 84 Plus CE flash) files are listed for completeness, they use a different file format and magic number
enum VariableType: u8 {
    RealNumber = 0x00, // 8xn
    RealList = 0x01, // 8xl
    Matrix = 0x02, // 8xm
    Yvar = 0x03, // 8xy
    String = 0x04, // 8xs
    Program = 0x05, // 8xp
    ProtectedProgram = 0x06, // 8xp
    Picture = 0x07, // 8xi
    GDB = 0x08, // 8xd
    Window = 0x0B, // 8xw
    Complex = 0x0C, // 8xc
    ComplexList = 0x0D, // 8xl
    Window = 0x0F, // 8xw
    RclWindw = 0x10, // 8xz
    TblSet = 0x11, // 8xt
    Backup = 0x13, // Packet header
    DeleteFlash = 0x14, // Packet header
    AppVar = 0x15, // 8xv
    Group = 0x17, // 8xg
    DirectoryList = 0x19, // Packet header
    FlashOS = 0x23, // Packet header, 8eu, 8xu apparently?
    FlashApp = 0x24, // Packet header, 8ek, 8xk apparently?
    IDLIST = 0x26, // Packet header
    Certificate = 0x27, // Packet header, 8xq apparently?
    Clock = 0x29 // Packet header
};

struct Variable {
    le u16 entryFormat;
    le u16 length;
    VariableType type;
    char name[8];
    if (entryFormat == 0xD) {
        u8 version;
        StorageType storage;
    }
    le u16 length2;
    u8 content[length];
    
};

Header header @ 0;
std::ByteSizedArray<Variable, header.datasize> content @ 0x37;
le u16 checksum @ 0x37+header.datasize;

fn makeChecksum() {
    u32 sum = 0;
    for (u32 i = 0, i < header.datasize, i = i + 1) {
        sum += std::mem::read_unsigned(0x37+i, 8, std::mem::Endian::Little);
    }
    u16 result = sum & 0xFFFF;
    return result;
};

u16 realChecksum out;
realChecksum = makeChecksum();
