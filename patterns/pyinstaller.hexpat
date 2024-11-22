#pragma description PyInstaller binray

#pragma endian big

import std.mem;

// Reference:
//     https://pyinstaller.org/en/stable/advanced-topics.html

//  typedef struct _cookie {
//      char magic[8]; /* 'MEI\014\013\012\013\016' */
//       uint32_t len;  /* len of entire package */
//       uint32_t TOC;  /* pos (rel to start) of TableOfContents */
//       int  TOClen;   /* length of TableOfContents */
//       int  pyvers;   /* new in v4 */
//       char pylibname[64];    /* Filename of Python dynamic library. */
//   } COOKIE;

u8 cookieStructLength = 88;

struct Cookie {
    char signature[8];
    u32 len;
    u32 TOC[[comment("Table of Content")]];
    s32 TOClen;
    s32 pyVers;
    char pyLibName[64];
};

u32 cookieOffset = std::mem::find_sequence(0, 'M', 'E', 'I', 0x0C, 0x0B, 0x0A, 0x0B, 0x0E);
Cookie cookie @ cookieOffset;

u32 startOffset = cookieOffset + cookieStructLength - cookie.len;
u32 tocOffset =  startOffset + cookie.TOC;

struct ZlibArchive {
    char pyzMagic[4];
    char pyMagic[4];
    u32 pyzTOCPos[[comment("Table of Content of the embedded PYZ")]];
};

//   typedef struct _toc {
//       int  structlen;  /* len of this one - including full len of name */
//       uint32_t pos;    /* pos rel to start of concatenation */
//       uint32_t len;    /* len of the data (compressed) */
//       uint32_t ulen;   /* len of data (uncompressed) */
//       char cflag;      /* is it compressed (really a byte) */
//       char typcd;      /* type code -'b' binary, 'z' zlib, 'm' module,
//                         * 's' script (v3),'x' data, 'o' runtime option  */
//       char name[1];    /* the name to save it as */
//                        /* starting in v5, we stretch this out to a mult of 16 */
//   } TOC;

u32 tocStructLength = 18;

enum TypeCode : u8 {
    Binary = 98,
    Zlib = 122,
    Module = 109,
    Script = 115,
    Data = 120,
    RuntimeOption = 111,
};

struct TOC {
    s32 structLen;
    u32 pos;
    u32 len[[comment("len of the data (compressed)")]];
    u32 uLen[[comment("len of data (uncompressed)")]];
    bool cFlag[[comment("is it compressed")]];
    TypeCode typcd;
    char name[this.structLen - tocStructLength];

    if(typcd == TypeCode::Zlib) {
        ZlibArchive zlibArchive @ startOffset + this.pos;
    }
};


TOC toc[while( $ < cookie.TOClen + tocOffset)] @ tocOffset;
