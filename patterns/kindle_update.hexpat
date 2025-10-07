#pragma author ptrpaws
#pragma description Kindle Update Package
#pragma magic [ 53 50 30 31 ] @ 0x00 // "SP01"
#pragma endian little

// enums and structs are based on KindleTool source code by Yifan Lu & NiLuJe

enum Magic : u32 {
    SP01 = 0x31305053,
    FB01 = 0x31304246,
    FB02 = 0x32304246,
    FB03 = 0x33304246,
    FC02 = 0x32304346,
    FC04 = 0x34304346,
    FD03 = 0x33304446,
    FD04 = 0x34304446,
    FL01 = 0x31304C46,
    GZIP = 0x00088B1F,
    ZIP  = 0x04034B50,
    CB01 = 0x31304243,
};

enum Device : u16 {
    KindleUnknown                                = 0x00,
    Kindle1                                      = 0x01,
    Kindle2US                                    = 0x02,
    Kindle2International                         = 0x03,
    KindleDXUS                                   = 0x04,
    KindleDXInternational                        = 0x05,
    Kindle3WiFi3G                                = 0x06,
    ValidKindleUnknown_0x07                      = 0x07,
    Kindle3WiFi                                  = 0x08,
    KindleDXGraphite                             = 0x09,
    Kindle3WiFi3GEurope                          = 0x0A,
    ValidKindleUnknown_0x0B                      = 0x0B,
    ValidKindleUnknown_0x0C                      = 0x0C,
    ValidKindleUnknown_0x0D                      = 0x0D,
    Kindle4NonTouch                              = 0x0E,
    Kindle5TouchWiFi3G                           = 0x0F,
    Kindle5TouchWiFi3GEurope                     = 0x10,
    Kindle5TouchWiFi                             = 0x11,
    Kindle5TouchUnknown                          = 0x12,
    KindleVoyageWiFi                             = 0x13,
    ValidKindleUnknown_0x16                      = 0x16,
    KindlePaperWhite2WiFi4GBInternational        = 0x17,
    KindlePaperWhiteWiFi3G                       = 0x1B,
    KindlePaperWhiteWiFi3GCanada                 = 0x1C,
    KindlePaperWhiteWiFi3GEurope                 = 0x1D,
    KindlePaperWhiteWiFi3GJapan                  = 0x1F,
    KindlePaperWhiteWiFi3GBrazil                 = 0x20,
    ValidKindleUnknown_0x21                      = 0x21,
    Kindle4NonTouchBlack                         = 0x23,
    KindlePaperWhiteWiFi                         = 0x24,
    KindleVoyageWiFi3GJapan                      = 0x2A,
    KindleVoyageWiFi3G_0x4F                      = 0x4F,
    KindleVoyageWiFi3GMexico                     = 0x52,
    KindleVoyageWiFi3GEurope                     = 0x53,
    KindleVoyageWiFi3G                           = 0x54,
    KindlePaperWhite2WiFiJapan                   = 0x5A,
    KindlePaperWhite2WiFi3G4GBCanada             = 0x5F,
    KindlePaperWhite2WiFi3G4GBEurope             = 0x60,
    KindlePaperWhite2WiFi3G4GBBrazil             = 0x61,
    KindlePaperWhite2WiFi3G4GB                   = 0x62,
    ValidKindleUnknown_0x99                      = 0x99,
    KindleBasic                                  = 0xC6,
    KindlePaperWhite2WiFi                        = 0xD4,
    KindlePaperWhite2WiFi3G                      = 0xD5,
    KindlePaperWhite2WiFi3GCanada                = 0xD6,
    KindlePaperWhite2WiFi3GEurope                = 0xD7,
    KindlePaperWhite2WiFi3GRussia                = 0xD8,
    KindleBasicKiwi                              = 0xDD,
    KindlePaperWhite2WiFi3GJapan                 = 0xF2,
    KindlePaperWhite2Unknown_0xF4                = 0xF4,
    KindlePaperWhite2Unknown_0xF9                = 0xF9,
    KindleBasic2Unknown_0DU                      = 0x1BC,
    KindlePaperWhite3WiFi                        = 0x201,
    KindlePaperWhite3WiFi3G                      = 0x202,
    KindlePaperWhite3WiFi3GMexico                = 0x204,
    KindlePaperWhite3WiFi3GEurope                = 0x205,
    KindlePaperWhite3WiFi3GCanada                = 0x206,
    KindlePaperWhite3WiFi3GJapan                 = 0x207,
    KindleOasisWiFi                              = 0x20C,
    KindleOasisWiFi3G                            = 0x20D,
    KindleOasisWiFi3GInternational               = 0x219,
    KindleOasisUnknown_0GS                       = 0x21A,
    KindleOasisWiFi3GChina                       = 0x21B,
    KindleOasisWiFi3GEurope                      = 0x21C,
    KindleBasic2                                 = 0x269,
    KindleBasic2White                            = 0x26A,
    KindlePaperWhite3WhiteWiFi                   = 0x26B,
    KindlePaperWhite3WhiteWiFi3GJapan            = 0x26C,
    KindlePW3WhiteUnknown_0KD                    = 0x26D,
    KindlePaperWhite3WhiteWiFi3GInternational    = 0x26E,
    KindlePaperWhite3WhiteWiFi3GInternationalBis = 0x26F,
    KindlePW3WhiteUnknown_0KG                    = 0x270,
    KindlePaperWhite3BlackWiFi32GBJapan          = 0x293,
    KindlePaperWhite3WhiteWiFi32GBJapan          = 0x294,
    KindleOasis2Unknown_0LM                      = 0x295,
    KindleOasis2Unknown_0LN                      = 0x296,
    KindleOasis2Unknown_0LP                      = 0x297,
    KindleOasis2Unknown_0LQ                      = 0x298,
    KindleOasis2WiFi32GBChampagne                = 0x2E1,
    KindleOasis2Unknown_0P2                      = 0x2E2,
    KindleOasis2Unknown_0P6                      = 0x2E6,
    KindleOasis2Unknown_0P7                      = 0x2E7,
    KindleOasis2WiFi8GB                          = 0x2E8,
    KindlePW4Unknown_0PL                         = 0x2F4,
    KindlePaperWhite4WiFi8GB                     = 0x2F7,
    KindleOasis2WiFi3G32GB                       = 0x341,
    KindleOasis2WiFi3G32GBEurope                 = 0x342,
    KindleOasis2Unknown_0S3                      = 0x343,
    KindleOasis2Unknown_0S4                      = 0x344,
    KindleOasis2Unknown_0S7                      = 0x347,
    KindleOasis2WiFi32GB                         = 0x34A,
    KindlePaperWhite4WiFi4G32GB                  = 0x361,
    KindlePaperWhite4WiFi4G32GBEurope            = 0x362,
    KindlePaperWhite4WiFi4G32GBJapan             = 0x363,
    KindlePaperWhite4Unknown_0T4                 = 0x364,
    KindlePaperWhite4Unknown_0T5                 = 0x365,
    KindlePaperWhite4WiFi32GB                    = 0x366,
    KindlePaperWhite4Unknown_0T7                 = 0x367,
    KindlePaperWhite4Unknown_0TJ                 = 0x372,
    KindlePaperWhite4Unknown_0TK                 = 0x373,
    KindlePaperWhite4Unknown_0TL                 = 0x374,
    KindlePaperWhite4Unknown_0TM                 = 0x375,
    KindlePaperWhite4Unknown_0TN                 = 0x376,
    KindleBasic3White8GB                         = 0x3CF,
    KindleBasic3Unknown_0WG                      = 0x3D0,
    KindleBasic3White                            = 0x3D1,
    KindleBasic3Unknown_0WJ                      = 0x3D2,
    KindleOasis3WiFi8GB                          = 0x3D4,
    KindleOasis3WiFi32GB                         = 0x3D5,
    KindleOasis3WiFi4G32GB                       = 0x3D6,
    KindleOasis3WiFi4G32GBIndia                  = 0x3D7,
    KindleOasis3WiFi4G32GBJapan                  = 0x3D8,
    KindleBasic3KidsEdition                      = 0x3AB,
    KindlePaperWhite4WiFi8GBIndia                = 0x402,
    KindlePaperWhite4WiFi32GBIndia               = 0x403,
    KindleBasic3                                 = 0x414,
    KindleOasis3WiFi32GBChampagne                = 0x434,
    KindlePaperWhite4WiFi32GBBlue                = 0x4D8,
    KindlePaperWhite4WiFi32GBPlum                = 0x4D9,
    KindlePaperWhite4WiFi32GBSage                = 0x4DA,
    KindlePaperWhite4WiFi8GBBlue                 = 0x4DB,
    KindlePaperWhite4WiFi8GBPlum                 = 0x4DC,
    KindlePaperWhite4WiFi8GBSage                 = 0x4DD,
    KindlePaperWhite5SignatureEdition            = 0x690,
    KindlePaperWhite5                            = 0x6FF,
    KindlePaperWhite5Unknown_1Q0                 = 0x700,
    KindlePaperWhite5Unknown_1VD                 = 0x7AD,
    KindleBasic4Unknown_1XH                      = 0x7F1,
    KindlePaperWhite5SE_219                      = 0x829,
    KindlePaperWhite5_21A                        = 0x82A,
    KindleScribe16GB_227                         = 0x847,
    KindleBasic4Unknown_22C                      = 0x84C,
    KindleBasic4Unknown_22D                      = 0x84D,
    KindleBasic4Unknown_23A                      = 0x86A,
    KindleScribe_23L                             = 0x874,
    KindleScribe64GB_23M                         = 0x875,
    KindleBasic4Unknown_25T                      = 0x8BB,
    KindleScribeUnknown_263                      = 0x8C3,
    KindleScribeUnknown_270                      = 0x8E0,
    KindleScribeUnknown_27J                      = 0x8F2,
    KindleBasic4_2AP                             = 0x957,
    KindleBasic4_2AQ                             = 0x958,
    KindlePaperWhite5SE_2BH                      = 0x971,
    KindlePaperWhite5Unknown_2BJ                 = 0x972,
    KindleScribeUnknown_2BL                      = 0x974,
    KindleScribeUnknown_2BM                      = 0x975,
    KindlePaperWhite5_2DK                        = 0x9B3,
    KindlePaperWhite6Unknown_33W                 = 0xC7E,
    KindlePaperWhite6Unknown_33X                 = 0xC7F,
    KindlePaperWhite6Unknown_346                 = 0xC86,
    KindlePaperWhite6Unknown_349                 = 0xC89,
    KindleColorSoftUnknown_34X                   = 0xC9F,
    KindleColorSoftUnknown_3H2                   = 0xE22,
    KindlePaperWhite6Unknown_3H3                 = 0xE23,
    KindleColorSoftUnknown_3H4                   = 0xE24,
    KindlePaperWhite6Unknown_3H5                 = 0xE25,
    KindleColorSoftUnknown_3H6                   = 0xE26,
    KindleColorSoftUnknown_3H7                   = 0xE27,
    KindlePaperWhite6Unknown_3H8                 = 0xE28,
    KindleColorSoftUnknown_3H9                   = 0xE29,
    KindlePaperWhite6Unknown_3HA                 = 0xE2A,
    KindleColorSoftUnknown_3HB                   = 0xE2B,
    KindlePaperWhite6Unknown_3J5                 = 0xE45,
    KindleColorSoftUnknown_3J6                   = 0xE46,
    KindlePaperWhite6Unknown_3JS                 = 0xE5A,
    KindleColorSoftUnknown_3JT                   = 0xE5B,
    KindleBasic5Unknown_3KM                      = 0xE75,
    KindleBasic5Unknown_3L2                      = 0xE82,
    KindleBasic5Unknown_3L3                      = 0xE83,
    KindleBasic5Unknown_3L4                      = 0xE84,
    KindleBasic5Unknown_3L5                      = 0xE85,
    KindleBasic5Unknown_3L6                      = 0xE86,
    KindleScribe2Unknown_3UV                     = 0xF9D,
    KindleScribe2Unknown_3V0                     = 0xFA0,
    KindleScribe2Unknown_3V1                     = 0xFA1,
    KindleScribe2Unknown_3X3                     = 0xFE3,
    KindleScribe2Unknown_3X4                     = 0xFE4,
    KindleScribe2Unknown_3X5                     = 0xFE5,
    KindleScribe2Unknown_41D                     = 0x102D,
    KindleScribe2Unknown_41E                     = 0x102E,
    KindleColorSoftUnknown_456                   = 0x10A6,
    KindleBasic5Unknown_A89                      = 0x2909,
    KindlePW3Unknown_TTT                         = 0x6F7B,
};

enum Platform : u32 {
    Plat_Unspecified = 0x00, MarioDeprecated  = 0x01, Luigi            = 0x02,
    Banjo            = 0x03, Yoshi            = 0x04, YoshimeProto     = 0x05,
    Yoshime          = 0x06, Wario            = 0x07, Duet             = 0x08,
    Heisenberg       = 0x09, Zelda            = 0x0A, Rex              = 0x0B,
    Bellatrix        = 0x0C, Bellatrix3       = 0x0D, Bellatrix4       = 0x0E,
};

enum Board : u32 {
    Board_Unspecified = 0x00,
    Tequila           = 0x03,
    Whitney           = 0x05,
};

enum CertificateNumber : u32 {
    Developer   = 0x00,
    Official_1K = 0x01,
    Official_2K = 0x02,
};

const u8 gtop[256] = {
    0xa7, 0xb7, 0x87, 0x97, 0xe7, 0xf7, 0xc7, 0xd7, 0x27, 0x37, 0x07, 0x17, 0x67, 0x77, 0x47, 0x57, 0xa6, 0xb6, 0x86,
    0x96, 0xe6, 0xf6, 0xc6, 0xd6, 0x26, 0x36, 0x06, 0x16, 0x66, 0x76, 0x46, 0x56, 0xa5, 0xb5, 0x85, 0x95, 0xe5, 0xf5,
    0xc5, 0xd5, 0x25, 0x35, 0x05, 0x15, 0x65, 0x75, 0x45, 0x55, 0xa4, 0xb4, 0x84, 0x94, 0xe4, 0xf4, 0xc4, 0xd4, 0x24,
    0x34, 0x04, 0x14, 0x64, 0x74, 0x44, 0x54, 0xa3, 0xb3, 0x83, 0x93, 0xe3, 0xf3, 0xc3, 0xd3, 0x23, 0x33, 0x03, 0x13,
    0x63, 0x73, 0x43, 0x53, 0xa2, 0xb2, 0x82, 0x92, 0xe2, 0xf2, 0xc2, 0xd2, 0x22, 0x32, 0x02, 0x12, 0x62, 0x72, 0x42,
    0x52, 0xa1, 0xb1, 0x81, 0x91, 0xe1, 0xf1, 0xc1, 0xd1, 0x21, 0x31, 0x01, 0x11, 0x61, 0x71, 0x41, 0x51, 0xa0, 0xb0,
    0x80, 0x90, 0xe0, 0xf0, 0xc0, 0xd0, 0x20, 0x30, 0x00, 0x10, 0x60, 0x70, 0x40, 0x50, 0xaf, 0xbf, 0x8f, 0x9f, 0xef,
    0xff, 0xcf, 0xdf, 0x2f, 0x3f, 0x0f, 0x1f, 0x6f, 0x7f, 0x4f, 0x5f, 0xae, 0xbe, 0x8e, 0x9e, 0xee, 0xfe, 0xce, 0xde,
    0x2e, 0x3e, 0x0e, 0x1e, 0x6e, 0x7e, 0x4e, 0x5e, 0xad, 0xbd, 0x8d, 0x9d, 0xed, 0xfd, 0xcd, 0xdd, 0x2d, 0x3d, 0x0d,
    0x1d, 0x6d, 0x7d, 0x4d, 0x5d, 0xac, 0xbc, 0x8c, 0x9c, 0xec, 0xfc, 0xcc, 0xdc, 0x2c, 0x3c, 0x0c, 0x1c, 0x6c, 0x7c,
    0x4c, 0x5c, 0xab, 0xbb, 0x8b, 0x9b, 0xeb, 0xfb, 0xcb, 0xdb, 0x2b, 0x3b, 0x0b, 0x1b, 0x6b, 0x7b, 0x4b, 0x5b, 0xaa,
    0xba, 0x8a, 0x9a, 0xea, 0xfa, 0xca, 0xda, 0x2a, 0x3a, 0x0a, 0x1a, 0x6a, 0x7a, 0x4a, 0x5a, 0xa9, 0xb9, 0x89, 0x99,
    0xe9, 0xf9, 0xc9, 0xd9, 0x29, 0x39, 0x09, 0x19, 0x69, 0x79, 0x49, 0x59, 0xa8, 0xb8, 0x88, 0x98, 0xe8, 0xf8, 0xc8,
    0xd8, 0x28, 0x38, 0x08, 0x18, 0x68, 0x78, 0x48, 0x58
};

fn format_md5(auto m) {
    str result = "";
    for(u8 i = 0, i < sizeof(m), i += 1) {
        result += char(gtop[m[i]]);
    }
    return result;
};

struct UpdateSignatureHeader {
    CertificateNumber certificate_number;
    u8 reserved[56] [[hidden]];
};

struct UpdateSignaturePackage {
    UpdateSignatureHeader header;
    match (header.certificate_number) {
        (CertificateNumber::Developer)   : u8 signature[128];
        (CertificateNumber::Official_1K) : u8 signature[128];
        (CertificateNumber::Official_2K) : u8 signature[256];
        (_) : {
            std::error("Unknown certificate type.");
            u8 signature[0];
        }
    }
};

struct RecoveryUpdateV2Package {
    padding[4];
    u64 target_revision;
    u8 md5_sum[32] [[format("format_md5")]];
    u32 magic_1;
    u32 magic_2;
    u32 minor;
    Platform platform;
    u32 header_rev;
    Board board;
    padding[7];
    u8 num_devices;
    Device devices[num_devices];
};

struct OTAUpdatePackage {
    u32 source_revision;
    u32 target_revision;
    Device device;
    u8 optional;
    u8 unused;
    u8 md5_sum[32] [[format("format_md5")]];
};

struct RecoveryUpdatePackage {
    u8 unused[12];
    u8 md5_sum[32] [[format("format_md5")]];
    u32 magic_1;
    u32 magic_2;
    u32 minor;
    Device device;
};

struct MetaString {
    be u16 length;
    char value[length];
};

struct OTAUpdateV2Package {
    u64 source_revision;
    u64 target_revision;
    u16 num_devices;
    Device devices[num_devices];
    u8  critical;
    u8  padding_byte;
    u8 md5_sum[32] [[format("format_md5")]];
    u16 num_metadata;
    MetaString metadata[num_metadata];
};

struct GenericPayload {
    u8 data[];
};

struct FirmwarePayload {
    Magic magic;

    match (magic) {
        (Magic::FB03) : RecoveryUpdateV2Package recovery_v2 [[name("Recovery V2 Header (FB03)")]];
        (Magic::FC04) : OTAUpdateV2Package ota_v2 [[name("OTA V2 Header (FC04/FD04/FL01)")]];
        (Magic::FD04) : OTAUpdateV2Package ota_v2_fd04 [[name("OTA V2 Header (FC04/FD04/FL01)")]];
        (Magic::FL01) : OTAUpdateV2Package ota_v2_fl01 [[name("OTA V2 Header (FC04/FD04/FL01)")]];
        (Magic::FC02) : OTAUpdatePackage ota_v1 [[name("OTA V1 Header (FC02/FD03)")]];
        (Magic::FD03) : OTAUpdatePackage ota_v1_fd03 [[name("OTA V1 Header (FC02/FD03)")]];
        (Magic::FB01) : RecoveryUpdatePackage recovery_v1 [[name("Recovery V1 Header (FB01/FB02)")]];
        (Magic::FB02) : RecoveryUpdatePackage recovery_v1_fb02 [[name("Recovery V1 Header (FB01/FB02)")]];
        (Magic::GZIP) : GenericPayload userdata_gzip [[name("UserData Package (GZIP)")]];
        (Magic::ZIP)  : GenericPayload android_zip [[name("Android Update (ZIP)")]];
        (Magic::CB01) : GenericPayload component_update [[name("Component Update (CB01)")]];
        (_) : {
            std::warning("Unsupported inner package type.");
            u8 unknown_payload_header[0];
        }
    }
};

struct KindleFirmware {
    Magic magic;

    if (magic == Magic::SP01) {
        UpdateSignaturePackage signature_package [[name("Signature Wrapper (SP01)")]];
        FirmwarePayload payload;
    } else {
        // not a signed SP01 package
        $ -= sizeof(magic);
        FirmwarePayload payload;
    }
};

KindleFirmware file @ 0x00;
