#include <ffx/utils.hexpat>

bitfield SphereEffect {
    strength : 1;
    defense : 1;
    magic : 1;
    magic_defense : 1;
    agility : 1;
    luck : 1;
    evasion : 1;
    accuracy : 1;
    hp : 1;
    mp : 1;
    ability : 1;
    padding : 4;
    lock : 1;
    
};

struct Block {
    String2 name;
    String2 desc;
    SphereEffect effect;
    u16 ability_id;
    u16 amount;
    u16 icon_id;
};

Block blocks[block_count] @ start_offset;