#pragma author Li
#pragma description PlayStation Mobile Shader

import std.io;

enum ShaderUniformType : u32 {
    None = 0x0,
    Float = 0x100,
    Float2 = 0x101,
    Float3 = 0x102,
    Float4 = 0x103,
    Float2x2 = 0x111,
    Float3x3 = 0x122,
    Float4x4 = 0x133,
    Int = 0x400,
    Int2 = 0x401,
    Int3 = 0x402,
    Int4 = 0x403,
    Bool = 0x300,
    Bool2 = 0x301,
    Bool3 = 0x302,
    Bool4 = 0x303,
    Sampler2D = 0x8001,
    SamplerCube = 0x8002
};

struct CGXVariant {
    char language[4];
    u32 sourcePtr;
    u32 sourceSz;
    u32 reserved;
    
    char shader[sourceSz] @ sourcePtr;
};

struct CGXUniform {
    u32 uniformNamePtr;
    u32 typeNamePtr;
    u32 unk1;
    ShaderUniformType type;
    u32 size;
    u32 flags;
    
    char name[] @ uniformNamePtr;
    char typeName[] @ typeNamePtr;
};

struct CGXVariantTableEntry {
    u32 namePtr;
    u32 variantListPtr;
    u32 variantCount;
    u32 uniformsPtr;
    u32 uniformsNum;
    u32 attributesNum;
    u32 varyingsNum;
    u32 unk4;
    
    CGXVariant variants[variantCount] @ variantListPtr;
    CGXUniform uniforms[uniformsNum] @ uniformsPtr;
    CGXUniform attributes[attributesNum] @ uniformsPtr + sizeof(uniforms);
    CGXUniform varyings[varyingsNum] @ uniformsPtr + sizeof(uniforms) + sizeof(attributes);
    char name[] @ namePtr;
};


struct CgxHeader {
    char magic[4];
    char cgVer[4];
    char glesVer[4];
    u32 flags;
    u32 unk0;
    u32 unk1;

    u32 vertexShaderVariantsPtr;
    u32 unk2;
    u32 fragmentShaderVariantsPtr;
    u32 unk4;

    u32 headerSize;
    u32 shaderDataPtr;
    u32 stringTblPtr;
    u32 stringTblPtr2;
    u32 totalSize;

    u8 hash[0x14];
   
   CGXVariantTableEntry vertexVariants @ vertexShaderVariantsPtr;
   CGXVariantTableEntry fragmentVariants @ fragmentShaderVariantsPtr;
};

CgxHeader header @ 0x00;

