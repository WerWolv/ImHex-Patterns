#pragma author Luke
#pragma description TIC-80 Cartridge
#include <std/mem.pat>

enum TypeValue : u8 {
    CHUNK_TILES = 1,
    CHUNK_SPRITES = 2,
    CHUNK_COVER_DEP = 3,
    CHUNK_MAP = 4,
    CHUNK_CODE = 5,
    CHUNK_FLAGS = 6,
    CHUNK_SAMPLES = 9,
    CHUNK_WAVEFORM = 10,
    CHUNK_PALETTE = 12,
    CHUNK_PATTERNS_DEP = 13,
    CHUNK_MUSIC = 14,
    CHUNK_PATTERNS = 15,
    CHUNK_CODE_ZIP = 16,
    CHUNK_DEFAULT = 17,
    CHUNK_SCREEN = 18,
    CHUNK_BINARY = 19
};

bitfield FlagChunk {
    Flag0 : 1;
    Flag1 : 1;
    Flag2 : 1;
    Flag3 : 1;
    Flag4 : 1;
    Flag5 : 1;
    Flag6 : 1;
    Flag7 : 1;
};

bitfield BankAndTypeField {
    TypeValue Type : 5 [[comment("The type of chunk.")]];
    Bank : 3 [[comment("The bank # of the chunk.")]];
};

struct Chunk {
    BankAndTypeField BankAndType [[comment("This byte stores both the bank and type.")]];
    le u16 Size [[comment("The size of the chunk. (Value 0 = 65536 except for CHUNK_DEFAULTs)")]];
    padding[1];
    if (Size == 0 && BankAndType.Type != TypeValue::CHUNK_DEFAULT) {
        u8 Data[65536] [[comment("The chunk data. Interpret according to the type.")]];
    } else {
        u8 Data[Size] [[comment("The chunk data. Interpret according to the type.")]];
    }
};

Chunk File[while($ < std::mem::size())] @ 0x00;