#pragma author Hrant (0xZ3R0)
#pragma description DJI Encrypted/Signed Firmware (IM*H)
#pragma endian little

// refs:
// - "Challenges in Dynamic Analysis of Drone Firmware and Its Solutions" (DOI: 10.1109/ACCESS.2024.3425604)
// - "Drone Security and the Mysterious Case of DJI’s DroneID" (DOI: 10.14722/ndss.2023.24217)
// - https://github.com/o-gs/dji-firmware-tools

struct imah_chunk_header {
    s8  id[4];
    u32 offset;
    u32 size;
    u32 attrib;
    u64 address;
    u8  reserved[8];
};

struct imah_header {
    s8  magic[4];
    u32 header_version;
    u32 size;
    u8  reserved[4];
    u32 header_size;
    u32 signature_size;
    u32 payload_size;
    u32 target_size;
    u8  os;
    u8  arch;
    u8  compression;
    u8  anti_version;
    u32 auth_alg;
    u8  auth_key[4];
    u8  enc_key[4];
    u8  scram_key[16];
    s8  name[32];
    u8  type[4];
    u32 version;
    u32 date;
    u32 encr_cksum;
    u8  reserved2[16];
    s8  userdata[16];
    u8  entry[8];
    u32 plain_cksum;
    u32 chunk_num;
    u8  payload_digest[32];
};

imah_header header @ 0x00;
imah_chunk_header chunks[header.chunk_num] @ addressof (header) + sizeof (header);
u8 signature[header.signature_size] @ addressof (chunks) + sizeof (chunks);
u8 payload_start @ addressof (signature) + sizeof (signature);
