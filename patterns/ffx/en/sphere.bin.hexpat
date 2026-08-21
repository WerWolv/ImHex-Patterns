#include <ffx/utils.hexpat>

bitfield NodeTypes {
    Strength : 1;
    Defense : 1;
    Magic : 1;
    MagicDefense : 1;
    Agility : 1;
    Luck : 1;
    Evasion : 1;
    Accuracy : 1;
    Hp : 1;
    Mp : 1;
    Ability : 1;
};

enum SphereType : u16 {
    None = 0x0,
    Activation = 0x1,
    Modification = 0x2,
};

enum SphereRole : u16 {
    Power = 0x00,
    Mana = 0x01,
    Speed = 0x02,
    Ability = 0x03,
    Fortune = 0x04,
    Special = 0x05,
    Skill = 0x06,
    WhiteMagic = 0x07,
    BlackMagic = 0x08,
    Master = 0x09,
    Lv1Key = 0x0A,
    Lv2Key = 0x0B,
    Lv3Key = 0x0C,
    Lv4Key = 0x0D,
    Luck = 0x0E,
    Hp = 0x0F,
    Mp = 0x10,
    Return = 0x11,
    Friend = 0x12,
    Teleport = 0x13,
    Warp = 0x14,
    Strength = 0x15,
    Defense = 0x16,
    Magic = 0x17,
    MagicDefense = 0x18,
    Agility = 0x19,
    Evasion = 0x1A,
    Accuracy = 0x1B,
    Clear = 0x1C,
    Attribute = 0x1D,
};

struct Sphere {
    String2 description;
    SphereType sphere_type;
    NodeTypes activates;
    u32 unk5;
} [[format("format_sphere")]];

fn format_sphere(ref Sphere sphere) {
    return ffx2ascii(sphere.description.text);
};

Sphere spheres[0x31] @ start_offset;