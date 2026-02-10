#pragma author DexrnZacAttack
#pragma description SNES SPC-700 Sound File
#pragma magic [ 53 4E 45 53 2D 53 50 43 37 30 30 20 53 6F 75 6E 64 20 46 69 6C 65 20 44 61 74 61 ] @ 0x00
#pragma version 1.0.0

import std.mem;

// https://wiki.superfamicom.org/spc-and-rsn-file-format
namespace SPC {
    namespace ID666 {
        enum ID666Bool : u8 {
            True = 26,
            False = 27
        };
        
        struct TextMain {
            char songTitle[32];
            char gameTitle[32];
            char dumperName[16];
            char comments[32];
            char dumpDate[11];
            u24 secondsTillFadeout;
            u32 fadeMs;
            u8 fadeMsHigh;
            char songArtist[32];
            u8 defaultChannelDisabled; // inverse bool
            u8 dumperEmu;
            char reserved[45];
        };
        
        struct BinaryMain {
            char songTitle[32];
            char gameTitle[32];
            char dumperName[16];
            char comments[32];
            char dumpDate[4];
            // unused
            u32;
            u24;
            // end unused
            u24 secondsTillFadeout;
            char fadeMs[4]; // why
            char songArtist[32];
            u8 defaultChannelDisabled; // inverse bool
            u8 dumperEmu;
            char reserved[46];
        };
        
        namespace Extended {
            enum SubChunkType : u8 {
                Header,
                String,
                Integer = 4
            };
        
            enum SubChunkId : u8 {
                SongName = 0x01,
                GameName = 0x02,
                ArtistName = 0x03,
                DumperName = 0x04,
                DateDumped = 0x05,
                EmulatorUsed = 0x06,
                Comments = 0x07,
                OfficialSoundtrackTitle = 0x10,
                OstDisc = 0x11,
                OstTrack = 0x12,
                PublisherName = 0x13,
                CopyrightYear = 0x14,
                IntroductionLength = 0x30,
                LoopLength = 0x31,
                EndLength = 0x32,
                FadeLength = 0x33,
                MutedVoices = 0x34,
                LoopCount = 0x35,
                PreampLevel = 0x36
            };
        
            struct SubChunk {
                std::mem::AlignTo<4>;
                SubChunkId id;
                SubChunkType type;
                u16 dat;
                if (type != SubChunkType::Header) {
                    if (type == SubChunkType::String) {
                    char data[dat];
                    } else {
                    u8 data[dat];
                    }
                }
            };
        
            struct Chunk {
                u64 off = $;
                u8 type[4];
                u32 size;
                SubChunk sc[while($ < off + size)];
            };
        
            struct Main {
                if (!std::mem::eof())
                    Chunk chunk;
            };
        }
    }

    struct Main {
        char signature[33];
        u16;
        ID666::ID666Bool hasId666;
        u8 versionMinor;
        u16 registerPc;
        u8 registerA;
        u8 registerX;
        u8 registerY;
        u8 registerPSW;
        u8 registerSpLow;
        u16 registerReserved;
        
        if (hasId666 == ID666::ID666Bool::True) {
            ID666::BinaryMain id666;
        }
        
        u8 ram[65536];
        u8 dspRegisters[128];
        u8 unused[64];
        u8 ramExtra[64];
        ID666::Extended::Main id666Extended;
    };
}

#ifndef SPC_USE_LIB
    SPC::Main spc @ 0x00;
#endif
