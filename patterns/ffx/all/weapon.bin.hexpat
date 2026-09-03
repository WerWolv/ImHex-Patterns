bitfield gearFlags {
    flag1 : 1;
    hidden : 1;
    no_kaizou : 1;
    brotherhood : 1;
    padding : 4;
};

struct Gear {
    u16 always_zero1;
    u8 zero_or_one;
    gearFlags flags;
    u8 character;
    bool armor;
    u16 always_zero2;
    u8 formula;
    u8 power;
    u8 crit;
    u8 slots;
    u8 unk1;
    u8 unk2;
    u16 abi_1;
    u16 abi_2;
    u16 abi_3;
    u16 abi_4;
};

Gear weapons[0x99] @ 0x14;