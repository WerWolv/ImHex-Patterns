#pragma author Luke
#pragma description TIC-80 Cartridge

bitfield BankAndTypeField {
    Type : 5 [[comment("The type of chunk.")]];
    Bank : 3 [[comment("The bank # of the chunk.")]];
};

struct Chunk {
    BankAndTypeField BankAndType [[comment("This byte stores both the bank and type.")]];
    le u16 Size [[comment("The size of the chunk. (Value 0 = 65536 except for type 17)")]];
    padding[1];
    if (Size == 0 && BankAndType.Type != 17) {
        u8 Data[65536] [[comment("The chunk data. Interpret according to the type.")]];
    } else {
        u8 Data[Size] [[comment("The chunk data. Interpret according to the type.")]];
    }
};

// Copy-paste until chunks reach the end of the file (tuned to default_lua by default)
Chunk chunk1 @ $;
Chunk chunk2 @ $;
Chunk chunk3 @ $;
Chunk chunk4 @ $;
Chunk chunk5 @ $;