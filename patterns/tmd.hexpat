#pragma description Nintendo TMD
#pragma author smiRaphi
// #pragma magic [ 00 01 00 0? ] @ 0x0 // too generic
// "Root-CA000000" for different Signature sizes
#pragma magic [ 52 6F 6F 74 2D 43 41 30 30 30 30 30 30 ] @ 0x240
#pragma magic [ 52 6F 6F 74 2D 43 41 30 30 30 30 30 30 ] @ 0x140
#pragma magic [ 52 6F 6F 74 2D 43 41 30 30 30 30 30 30 ] @ 0x80
#pragma endian big
import type.time;

#define MIN_CERT_SIZE 0x180

struct Signature {
    u32 type;
    match (type) {
        (0x010000|0x010003):{
            u8 data[0x200];
            padding[0x3C];
        }
        (0x010001|0x010004):{
            u8 data[0x100];
            padding[0x3C];
        }
        (0x010002|0x010005):{
            u8 data[0x3C];
            padding[0x40];
        }
    }
};
struct Cert {
    Signature sig;
    char issuer[0x40];
    u32 type;
    char name[0x40];
    le type::time32_t date;
    match (type) {
        (0):{
            u8 modulus[0x200];
            u32 exponent;
            padding[0x34];
        }
        (1):{
            u8 modulus[0x100];
            u32 exponent;
            padding[0x34];
        }
        (2):{
            u8 modulus[0x3C];
            padding[0x3C];
        }
    }
};
struct TMDContent {
    u32 cid;
    u16 index;
    u16 type;
    u64 csize;
    if (parent.version == 1) u8 sha256[0x20];
    else u8 sha1[0x14];
};
struct TMDInfo {
    u16 cid;
    u16 ccc;
    u8 sha256[0x20];
};
struct TMD {
    Signature sig;
    char issuer[0x40];
    u8 version;
    u8 ca_crl_version;
    u8 signed_crl_version;
    bool is_vwii;
    u64 system_version;
    u64 title_id;
    u32 type;
    u16 group_id;

    if (version == 1) {
        le u32 save_data_size;
        le u32 srl_private_size;
        padding[4];
        u8 srl_flag;
        padding[0x31];
    } else {
        padding[2];
        u16 region;
        u8 ratings[0x10];
        padding[12];
        u8 ipc_mask[12];
        padding[0x12];
    }
    u32 access_rights;
    u16 title_version;
    u16 content_count;
    u16 boot_index;
    u16 minor_version;
    if (version == 1) {
        u8 sha256[0x20];
        TMDInfo tmd_info[0x40];
    }
    TMDContent content[content_count];

    if ($ + MIN_CERT_SIZE <= sizeof($))
        Cert tmd_cert;
    if ($ + MIN_CERT_SIZE <= sizeof($))
        // can't think of a better name, it's the cert for the cert of the tmd & tik
        Cert cert_cert;
};

TMD tmd @ $;
