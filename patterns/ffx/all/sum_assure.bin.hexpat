struct AeonStats {
    u16 hp;
    u16 mp;
    u8 strength;
    u8 defense;
    u8 magic;
    u8 magic_defense;
    u8 accuracy;
    u8 evasion;
    u8 agility;
    u8 luck;
};

AeonStats stats[0xC8] @ 0x14;