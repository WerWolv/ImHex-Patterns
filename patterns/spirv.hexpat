#include "spvopcodes.hexpat"
#include "spvgenerators.hexpat"

struct Version {
    u8 dummy1;
    u8 minor;
    u8 major;
    u8 dummy2;
};

struct Generator {
    u16 version;
    GeneratorID ID;
};

struct Header {
    u32 magic;
    Version version;
    Generator generator;
    u32 bounds;
    u32 schema;
};

struct Instruction {
    Op op;
    u16 words;
    u32 operands[words-1];
};

Header header @ 0x00;

// SPIR-V does not have any footer, increase number of instructions manually if you encounter a bigger shader
Instruction instructions[1024] @ 0x14;