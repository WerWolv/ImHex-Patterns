import std.array;
import std.io;
import std.mem;
import type.magic;
import type.bcd;

/// Source: https://merthsoft.com/linkguide/ti83+/fformat.html

struct Header {
    type::Magic<"**TI83F*\x1A\x0A\x00">;
    char comment[0x2A];
    le u16 datasize;
} [[static]];

enum StorageType: u8 {
    Archive = 0x80,
    RAM = 0x00
};

// Source: https://merthsoft.com/linkguide/ti83+/packet.html#vartypes
// Source: https://education.ti.com/en/customer-support/knowledge-base/ti-83-84-plus-family/product-usage/34933
// Although 8e (TI 84 Plus CE flash) files are listed for completeness, they use a different file format and magic number
enum VariableType: u8 {
    RealNumber = 0x00, // 8xn
    RealList = 0x01, // 8xl
    Matrix = 0x02, // 8xm
    Yvar = 0x03, // 8xy
    String = 0x04, // 8xs
    Program = 0x05, // 8xp, 8xz
    ProtectedProgram = 0x06, // 8xp, 8xz
    Picture = 0x07, // 8xi
    GDB = 0x08, // 8xd
    Window = 0x0B, // 8xw
    Complex = 0x0C, // 8xc
    ComplexList = 0x0D, // 8xl
    Window = 0x0F, // 8xw
    RclWindw = 0x10, // 8xz
    TblSet = 0x11, // 8xt
    Backup = 0x13, // Packet header, 8xb
    DeleteFlash = 0x14, // Packet header
    AppVar = 0x15, // 8xv, 8xy
    Group = 0x17, // 8xg
    DirectoryList = 0x19, // Packet header
    FlashOS = 0x23, // Packet header, 8eu, 8xu, 8cu apparently?
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

struct TIReal {
    bitfield Flags {
        padding : 1;
        bool isUndefined : 1;
        bool isComplex : 1;
        padding : 1;
        padding : 2;
        bool isModified : 1;
        padding : 1
    };
    flags Flags;
    u8 biasedExponent;
    type::bcd<7> mantissa;
} [[static]];

struct TIComplex {
    TIReal real;
    TIReal imag;
} [[static]];

struct TIList {
    le u16 count;
    TIReal content[count];
};

struct TIMatrix {
    u8 col;
    u8 row;
    TIReal content[col][row];
};

struct TIToken {
    u8 firstByte [[hidden, no_unique_address]];
    match (firstByte) {
        (0x5D ... 0x63 | 0xAA | 0x7E | 0xBB): {
            char16;
        },
        (_): {
            char;
        }  
    }
};

/// Used for Yvar, Str and Prgm
struct TITokens {
    le u16 count;
    TIToken content[count] [[inline]];
};

enum TISequenceMode {
    Web = 0x80 & 0x01,
    uv  = 0x80 & 0x04,
    vw  = 0x80 & 0x08,
    uw  = 0x80 & 0x10
};

bitfield TIModeSet {
    bool ExprOff : 1;
    padding : 7;
    TISequenceMode sequenceMode;
    bool Dot : 1;
    bool Simul : 1;
    bool GridOn : 1;
    bool PolarGC : 1;
    bool CoordOff : 1;
    bool AxesOff : 1;
    bool LabelOn : 1;
    padding : 1;
};

enum TIGraphStyle {
    Solid = 0,
    Thick = 1,
    ShadeAbove = 2,
    ShadeBelow = 3,
    Trace = 4,
    Animate = 5,
    DottedLine = 6
};

enum TIGraphMode {
    Function = 0x10,
    Parametric = 0x40,
    Polar = 0x20,
    Sequence = 0x80
};

struct TIFunction {
    u8 flags;
    TITokens content;
};

struct TIGDB {
    le u16 length;
    padding[1];
    TIGraphMode mode;
    TIModeSet settings;
    TIReal Xmin;
    TIReal Xmax;
    TIReal Xscl;
    TIReal Ymin;
    TIReal Ymax;
    TIReal Yscl;
    match (mode) {
        (TIGraphMode::Function): {
            TIReal Xres;
            TIGraphStyle styles[10];
            TIFunction functions[10];
        },
        (TIGraphMode::Parametric): {
            TIReal Tmin;
            TIReal Tmax;
            TIReal Tstep;
            TIGraphStyle styles[6];
            TIFunction functions[2][6];
        },
        (TIGraphMode::Polar): {
            TIReal THETAmin;
            TIReal THETAmax;
            TIReal THETAstep;
            TIGraphStyle styles[6];
            TIFunction functions[6];
        },
        (TIGraphMode::Sequence): {
            TIReal PlotStart;
            TIReal nMax;
            TIReal uOfnMinFirst;
            TIReal vOfnMinFirst;
            TIReal nMin;
            TIReal uOfnMinSecond;
            TIReal vOfnMinSecond;
            TIReal wOfnMinFirst;
            TIReal PlotStep;
            TIReal wOfnMinSecond;
            TIGraphStyle styles[3];
            TIFunction functions[3];
        }
    }
};

struct TIWindowSet {
    le u16 magic;
    if (magic == 0xD0) { padding[1]; } // currently used windowset
    padding[1];
    TIReal Xmin;
    TIReal Xmax;
    TIReal Xscl;
    TIReal Ymin;
    TIReal Ymax;
    TIReal Yscl;
    TIReal Thmin;
    TIReal Thmax;
    TIReal Thstep;
    TIReal Tmin;
    TIReal Tmax;
    TIReal Tstep;
    TIReal PlotStart;
    TIReal nMax;
    TIReal uFirst;
    TIReal vFirst;
    TIReal uSecond;
    TIReal vSecond;
    TIReal wFirst;
    TIReal PlotStep;
    TIReal Xres;
    TIReal wSecond;
};

struct TITblSet {
    le u16 magic;
    TIReal TblMin;
    TIReal TblStep;
} [[static]]; 

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
