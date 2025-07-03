#pragma description Devil May Cry 3 HD .mod 3D model file
#pragma MIME 3d-model/capcom.dmc3-hd-mod

// author = haru233, many thanks to AxCut
// ImHex Hex Pattern File for Capcom's Devil May Cry 3 HD .mod files


import std.core;


struct ModelHeader {
    char ID[4];
    float Version;
    u8 padding0[8];
    u8 objectCount;
    u8 boneCount;
    u8 numberTextures;
    u8 unknown1;
    u32 unknown2;
    u64 unknown3;
    u64 skeletonOffset;
    u8 padding1[24];
};

struct Object {
    u8 meshCount;
    u8 unknown;
    u16 numberVertices;
    u8 padding0[4];
    u64 meshOffset;
    u32 flags;
    u8 padding1[28];
    float X, Y, Z;           
    float radius;
};

struct Positions {
    float positions[3];
};


struct Normals {
    float normal[3];
};


struct UVs {
    s16 uv[2];
};

struct BoneIndices {
    u8 boneindex[4];
};

struct Weights {
    u16 weight[1];
};

struct MeshSCM {
    u16 numberVertices;
    u16 textureIndex;
    u8 padding0[12];
    u64 VerticesPositionsOffset;
    u64 NormalsPositionsOffset;
    u64 UVsPositionsOffset;

    u8 padding2[16];
    u64 unknownOffset;

    u64 unknown;
    u8 padding3[8];
    
    Positions positions[numberVertices] @VerticesPositionsOffset;
    Normals normals[numberVertices] @NormalsPositionsOffset;
    UVs uvs[numberVertices] @UVsPositionsOffset;
    
    
};

struct Mesh {
    u16 numberVertices;
    u16 textureIndex;
    u8 padding0[12];
    u64 VerticesPositionsOffset;
    u64 NormalsPositionsOffset;
    u64 UVsPositionsOffset;

    u64 BoneIndicesOffset;
    u64 WeightsOffset;
    u8 padding1[8];

    u64 unknown;
    u8 padding3[8];
    
    Positions positions[numberVertices] @VerticesPositionsOffset;
    Normals normals[numberVertices] @NormalsPositionsOffset;
    UVs uvs[numberVertices] @UVsPositionsOffset;
    
    BoneIndices b_index[numberVertices] @BoneIndicesOffset;
    Weights weights[numberVertices] @WeightsOffset;
    
   
};


struct Hierarchy {
    u8 hierarchy;
};

struct HierarchyOrder {
    u8 hierarchyorder;
};

struct Unknown {
    u8 unknown;
};

struct Transform {
    float x;
    float y;
    float z;
    float length; // sqrt(x*x + y*y + z*z)
    u8 unknown[16];
};

struct Skeleton{
    u32 hierarchyOffset;
    u32 hierarchyOrderOffset;
    u32 unknownOffset;
    u32 transformsOffset;
};         


    


ModelHeader modelheader @ 0x00;
Object objects[modelheader.objectCount] @ 0x40;

u32 objectOffset;

struct IthMesh {
   u64 i = std::core::array_index();
   if (modelheader.ID == "SCM ") {
        objectOffset = objects[0].meshOffset;
        MeshSCM meshscm[objects[i].meshCount] @ objects[i].meshOffset;
        
        
    } else {
        objectOffset = objects[0].meshOffset;
        Mesh mesh[objects[i].meshCount] @ objects[i].meshOffset;
    }
};

IthMesh meshes[modelheader.objectCount] @objectOffset;

Skeleton skeleton @modelheader.skeletonOffset;

Hierarchy hierarchy[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.hierarchyOffset);

HierarchyOrder hierarchyorder[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.hierarchyOrderOffset);

Unknown unknown[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.unknownOffset);

Transform transform[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.transformsOffset);