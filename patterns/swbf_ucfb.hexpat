#pragma author Josh Lambert
#pragma description Star Wars Battlefront munged data (.lvl, .mvs, .bnk)
#pragma magic [ 75 63 66 62 ] @ 0x00
#pragma endian little

import std.core;
import std.mem;

// Munged game data of Pandemic Studios' Zero engine, as used by the PC versions of
// Star Wars: Battlefront (2004) and Star Wars: Battlefront II (2005): the .lvl archives,
// the .mvs movie archives and the common.bnk sound bank.
//
// A file is one "ucfb" chunk holding a tree of chunks. A chunk is a four-byte tag, a
// little-endian size and a body; the next chunk starts at the next 4-byte boundary, and
// zero words may sit between chunks. Most tags are four ASCII characters. In the sound and
// movie archives most tags are 32-bit FNV-1a hashes of names instead, with each byte ORed
// with 0x20 before it is hashed.
//
// Which tags hold chunks was measured on every .lvl file of the 2004 game's PC release:
// INFO holds chunks only under BARR, inst, Hint and regn, and DATA only under CSHD.
// A lvl_ sub-level starts with its name hash and the size of the chunks that follow.
// Format notes: https://github.com/centrevilletech/battlefront-eternal/blob/19ea2b38c9943ee93309a500cc1024e094374853/docs/formats.md

// Tags of the chunks that hold other chunks. The last four are hashed names.
enum ContainerTag : u32 {
    ucfb          = 0x62666375,
    LVL_          = 0x5f4c564c,
    lvl_          = 0x5f6c766c,
    INFO          = 0x4f464e49,
    DATA          = 0x41544144,
    FMT_          = 0x5f544d46,
    FACE          = 0x45434146,
    tex_          = 0x5f786574,
    modl          = 0x6c646f6d,
    segm          = 0x6d676573,
    skel          = 0x6c656b73,
    gmod          = 0x646f6d67,
    shdw          = 0x77646873,
    GSHD          = 0x44485347,
    CSHD          = 0x44485343,
    zaa_          = 0x5f61617a,
    zaf_          = 0x5f66617a,
    FFAZ          = 0x5a414646,
    SLTM          = 0x4d544c53,
    STSJ          = 0x4a535453,
    SNKS          = 0x534b4e53,
    LEKS          = 0x534b454c,
    entc          = 0x63746e65,
    wpnc          = 0x636e7077,
    ordc          = 0x6364726f,
    expc          = 0x63707865,
    fx__          = 0x5f5f7866,
    coll          = 0x6c6c6f63,
    TREE          = 0x45455254,
    prim          = 0x6d697270,
    tern          = 0x6e726574,
    PCHS          = 0x53484350,
    PTCH          = 0x48435450,
    LPTC          = 0x4354504c,
    WATR          = 0x52544157,
    CUTS          = 0x53545543,
    CUTR          = 0x52545543,
    prp_          = 0x5f707270,
    wrld          = 0x646c7277,
    inst          = 0x74736e69,
    regn          = 0x6e676572,
    BARR          = 0x52524142,
    Hint          = 0x746e6948,
    PATH          = 0x48544150,
    path          = 0x68746170,
    plan          = 0x6e616c70,
    LOWR          = 0x52574f4c,
    COMN          = 0x4e4d4f43,
    STAT          = 0x54415453,
    PASS          = 0x53534150,
    SHDR          = 0x52444853,
    PIPE          = 0x45504950,
    VSP_          = 0x5f505356,
    PSP_          = 0x5f505350,
    sky_          = 0x5f796b73,
    bnd_          = 0x5f646e62,
    load          = 0x64616f6c,
    mcfg          = 0x6766636d,
    snd_          = 0x5f646e73,
    mus_          = 0x5f73756d,
    ffx_          = 0x5f786666,
    SCOP          = 0x504f4353,
    scr_          = 0x5f726373,
    Locl          = 0x6c636f4c,
    font          = 0x746e6f66,
    FTEX          = 0x58455446,
    StreamList    = 0x5bb97f21,
    Stream        = 0x5f6f6d65,
    SoundBankList = 0x5e262256,
    SampleBank    = 0x9a644d15
};

union Tag {
    char text[4];
    u32 value;
    ContainerTag container [[hidden]];
};

fn is_container(ref auto tag, u32 parent_tag) {
    if (tag.value == ContainerTag::INFO)
        return parent_tag == ContainerTag::BARR || parent_tag == ContainerTag::inst || parent_tag == ContainerTag::Hint || parent_tag == ContainerTag::regn;
    if (tag.value == ContainerTag::DATA)
        return parent_tag == ContainerTag::CSHD;
    return std::core::is_valid_enum(tag.container);
};

struct Chunk {
    Tag tag;
    if (tag.value != 0) {
        u32 size;
        u64 end = $ + size;
        if (tag.value == ContainerTag::lvl_) {    // a sub-level
            u32 name_hash;
            u32 chunks_size;
            Chunk chunks[while($ < end)];
        } else if (is_container(tag, parent.tag.value)) {
            Chunk chunks[while($ < end)];
        } else {
            std::mem::Bytes<size> data;
        }
        padding[(4 - (size % 4)) % 4];
    }
};

struct File {
    Tag tag;
    u32 size;
    Chunk chunks[while($ < 8 + size)];
};

File file @ 0x00;
