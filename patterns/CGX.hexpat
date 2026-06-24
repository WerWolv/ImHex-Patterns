import std.io;

enum CGXVariantType : u32 {
    None = 0,
    Vertex = 1,
    Fragment = 2
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
    u32 type;
    u32 unk3;
    u32 unk4;
    
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
    
    CGXVariant varients[variantCount] @ variantListPtr;
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
   
   CGXVariantTableEntry vertexVarients @ vertexShaderVariantsPtr;
   CGXVariantTableEntry fragmentVarients @ fragmentShaderVariantsPtr;
};


CgxHeader header @ 0x00;