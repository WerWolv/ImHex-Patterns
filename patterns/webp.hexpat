#pragma author applecuckoo
#pragma description Google WebP

#pragma endian little
#pragma MIME image/webp

// based off of ttf.hexpat by Rebuild and wav.hexpat by WerWolv

import std.mem;
import std.core;
import type.magic;

struct RiffHeader {
    char ckID[4] [[comment("Container Signature"), name("RIFF Header Signature")]];
    u32  ckSize [[comment("Size of RIFF Header"), name("RIFF Chunk Size")]];
    char format[4] [[comment("RIFF format"), name("WAVE Header Signature")]];
};

struct WebPChunk {
    char chunkId[4];
    u32  chunkSize;
};

bitfield VP8XFlags {
    padding : 1;
    A : 1;
    X : 1;
    E : 1;
    L : 1;
    I : 1;
    padding : 2;
};

struct OneBase {
    u24 value;
} [[sealed, format("format_onebase")]];

fn format_onebase(OneBase onebase) {
    return onebase.value + 1;
};

struct WebPVP8XData {
    VP8XFlags flags;
    padding[3];
    OneBase canvasWidth;
    OneBase canvasHeight;
};

struct WebPANIMData {
    u32 backgroundColor;
    u16 loopCount;
};

bitfield ANMFFlags {
    D : 1;
    B : 1;
    padding : 6;
};

bitfield WebPVP8LHeader {
    widthMinusOne : 14;
    heightMinusOne : 14;
    alphaUsed : 1;
    version : 3;
};

struct WebPVP8LData {
    type::Magic<"\x2f"> id;
    WebPVP8LHeader header;
};

u32 frameSize;

struct WebPANMFData {
    u24 frameX;
    u24 frameY;
    OneBase frameWidth;
    OneBase frameHeight;
    u24 frameDuration;
    ANMFFlags flags;
    u8 data[parent.chunkHeader.chunkSize - 16]; // lazy fix - can't be bothered implementing subchunks
    
};

bitfield ALPHFlags {
    C : 2;
    F : 2;
    P : 2;
    padding : 2;
};

u32 paddedChunkSize;

struct WebPData {
    WebPChunk chunkHeader;
    paddedChunkSize = (chunkHeader.chunkSize + 1) >> 1 << 1;
    match (chunkHeader.chunkId) {
        ("VP8X"): WebPVP8XData VP8XData;
        ("ANIM"): WebPANIMData ANIMData;
        ("ANMF"): { 
            WebPANMFData ANMFData;
            padding[paddedChunkSize - sizeof(ANMFData)];
        }
        ("VP8L"): {
        WebPVP8LHeader VP8LData;
        u8 image[chunkHeader.chunkSize-3];
        padding[paddedChunkSize - sizeof(VP8LData) - sizeof(image)];
        }
        ("ALPH"): {
            ALPHFlags flags;
            u8 ALPHData[chunkHeader.chunkSize-1];
            padding[paddedChunkSize - sizeof(ALPHData) - sizeof(flags)];
        }
        (_): {
            u8 data[chunkHeader.chunkSize];
            padding[paddedChunkSize - sizeof(data)];
        }
    }
} [[name(std::format("Chunk ({})", chunkHeader.chunkId))]];;

RiffHeader header @0x00;
WebPData data[while (!std::mem::eof())] @ $;
