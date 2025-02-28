#pragma author k0tran
#pragma description RPM package format
#pragma endian big
#pragma magic [ ED AB EE DB ] @ 0x00

import std.mem;
import std.core;
import std.string;

enum Magic : u32 {
    magic = 0xEDABEEDB
};

enum PackageType : s16 {
    binary = 0x0000,
    source = 0x0001
};

struct Lead {    
    Magic magic [[hidden]];
    u8 major [[comment("Version major")]];
    u8 minor [[comment("Version minor")]];
    PackageType type [[comment("Binary/Source")]];
    s16 archnum;
    char name[66] [[comment("Package name")]];
    s16 osnum;
    s16 signature_type;
    char reserved[16] [[hidden]];
};

enum HeaderMagic : u24 {
    magic = 0x8EADE8
};

enum Tag : u32 {
    // private
    headerimage         = 61,
    headersignatures    = 62,
    headerimmutable     = 63,
    headerregions       = 64,
    headero18ntable     = 100,
    sig_base            = 256,
    sigsize             = 257,
    siglemd5_1          = 258,
    sigpgp              = 259,
    siglemd5_2          = 260,
    sigmd5              = 261, // or pkgid
    siggpg              = 262,
    sigpgp5             = 263,
    badsha1_1           = 264,
    badsha1_2           = 265,
    pubkeys             = 266,
    dsaheader           = 267,
    rsaheader           = 268,
    sha1header          = 269, // or hdrid
    longsigsize         = 270,
    longarchivesize     = 271,
    // 272 reserved
    sha256header        = 273,
    // 274, 275 reserved
    veritysignatures    = 276,
    veritysignaturealgo = 277,
    openpgp             = 278,
    sig_top             = 279,

    // public
    name                = 1000,
    version             = 1001,
    release             = 1002,
    epoch               = 1003, // or serial
    summary             = 1004,
    description         = 1005,
    buildtime           = 1006,
    buildhost           = 1007,
    installtime         = 1008,
    size                = 1009,
    distribution        = 1010,
    vendor              = 1011,
    gif                 = 1012,
    xpm                 = 1013,
    license             = 1014, // or copyright
    packager            = 1015,
    group               = 1016,
    changelog           = 1017,
    source              = 1018,
    patch               = 1019,
    url                 = 1020,
    os                  = 1021,
    arch                = 1022,
    prein               = 1023,
    postin              = 1024,
    preun               = 1025,
    postun              = 1026,
    oldfilenames        = 1027,
    filesizes           = 1028,
    filestates          = 1029,
    filemdes            = 1030,
    fileuids            = 1031,
    filegids            = 1032,
    filerdevs           = 1033,
    filemtimes          = 1034,
    filemd5s            = 1035,
    filelinktos         = 1036,
    fileflags           = 1037,
    root                = 1038,
    fileusername        = 1039,
    filegroupname       = 1040,
    exclude             = 1041,
    exclusive           = 1042,
    icon                = 1043,
    sourcerpm           = 1044,
    fileverifyflags     = 1045,
    archivesize         = 1046,
    providename         = 1047, // or provides
    requireflags        = 1048,
    requirename         = 1049,
    requireversion      = 1050,
    nosource            = 1051,
    nopatch             = 1052,
    conflictflags       = 1053,
    conflictname        = 1054,
    conflictversion     = 1055,
    defaultprefix       = 1056,
    buildroot           = 1057,
    installprefix       = 1058,
    excludearch         = 1059,
    excludeos           = 1060,
    exclusivearch       = 1061,
    exclusiveos         = 1062,
    autoreqprov         = 1063,
    rpmversion          = 1064,
    triggerscripts      = 1065,
    triggername         = 1066,
    triggerversion      = 1067,
    triggerflags        = 1068,
    triggerindex        = 1069,
    // reserved
    verifyscript        = 1079,
    changelogtime       = 1080,
    changelogname       = 1081,
    changelogtext       = 1082,
    brokenmd5           = 1083,
    prereq              = 1084,
    preinprog           = 1085,
    postinprog          = 1086,
    preunprog           = 1087,
    postunprog          = 1088,
    buildarchs          = 1089,
    obsoletename        = 1090, // or obsoletes
    verifyscriptprog    = 1091,
    triggerscriptprog   = 1092,
    docdir              = 1093,
    cookie              = 1094,
    filedevices         = 1095,
    fileinodes          = 1096,
    filelangs           = 1097,
    prefixes            = 1098,
    instprefixes        = 1099,
    triggerin           = 1100,
    triggerun           = 1101,
    triggerpostun       = 1102,
    autoreq             = 1103,
    autoprov            = 1104,
    capability          = 1105,
    sourcepackage       = 1106,
    oldorigfilenames    = 1107,
    buildprereq         = 1108,
    buildrequires       = 1109,
    buildconflicts      = 1110,
    buildmacros         = 1111,
    provideflags        = 1112,
    provideversion      = 1113,
    obsoleteflags       = 1114,
    obsoleteversion     = 1115,
    dirindexes          = 1116,
    basenames           = 1117,
    dirnames            = 1118,
    origdirindexes      = 1119,
    origbasenames       = 1120,
    origdirnames        = 1121,
    optflags            = 1122,
    disturl             = 1123,
    payloadformat       = 1124,
    payloadcompressor   = 1125,
    payloadflags        = 1126,
    installcolor        = 1127,
    installtid          = 1128,
    removetid           = 1129,
    sha1rhn             = 1130,
    rhnplatform         = 1131,
    platform            = 1132,
    patchesname         = 1133,
    patchesflags        = 1134,
    patchesversion      = 1135,
    cachectime          = 1136,
    cachepkgpath        = 1137,
    cachepkgsize        = 1138,
    cachepkgmtime       = 1139,
    filecolors          = 1140,
    fileclass           = 1141,
    classdict           = 1142,
    filedependsx        = 1143,
    filedependsn        = 1144,
    dependsdict         = 1145,
    sourcepkgid         = 1146,
    filecontexts        = 1147,
    fscontexts          = 1148,
    recontexts          = 1149,
    policies            = 1150,
};

enum IndexType : u32 {
    _null = 0,
    _char = 1,
    _int8 = 2,
    _int16 = 3,
    _int32 = 4,
    _int64 = 5,
    _string = 6,
    _bin = 7,
    _string_array = 8,
};

struct Index {
    Tag tag;
    IndexType type;
    u32 offset [[comment("Store offset")]];
    u32 count [[comment("N of that datatype")]];
};

struct String {
    char string_array_item[];
} [[sealed]];

struct StoreEntry {
    auto i = std::core::array_index();
    auto p = parent.offset + parent.index[i].offset;
    auto c = parent.index[i].count;
    str info = std::format("{:X} {}", parent.index[i].offset, parent.index[i].tag);
    match (parent.index[i].type) {
        (IndexType::_char): char store_entry[c] @ p [[sealed, comment(info)]];
        (IndexType::_int8): s8 store_entry[c] @ p [[sealed, comment(info)]];
        (IndexType::_int16): s16 store_entry[c] @ p [[sealed, comment(info)]];
        (IndexType::_int32): s32 store_entry[c] @ p [[sealed, comment(info)]];
        (IndexType::_int64): s64 store_entry[c] @ p [[sealed, comment(info)]];
        (IndexType::_string): char store_entry[] @ p [[sealed, comment(info)]];
        (IndexType::_bin): u8 store_entry[c] @ p [[sealed, comment(info)]];
        (IndexType::_string_array): String store_entry[c] @ p [[sealed, comment(info)]];
    }
};

struct Header {
    HeaderMagic magic;
    u8 version;
    u8 reserved[4] [[hidden]];
    u32 amount [[comment("Amount of Index entries")]];
    u32 size [[comment("Header data len")]];
    
    Index index[amount];
    auto offset = $;
    StoreEntry store[amount];
    $ += size;
};

struct RPM {
    Lead lead;
    std::mem::MagicSearch<"\x8e\xad\xe8", Header> header;
    u8 lzma_archive[while(!std::mem::eof())] [[comment("LZMA + CPIO")]];
};


RPM package @ 0x00;
