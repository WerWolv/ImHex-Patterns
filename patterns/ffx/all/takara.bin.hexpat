struct Treasure {
    u8 type;
    u8 amount;
    u16 item_id;
};

u16 max_idx @ 0xA;
u32 start_offset @ 0x10;
Treasure treasures[max_idx + 1] @ start_offset;