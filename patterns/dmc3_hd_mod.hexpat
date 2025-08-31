#pragma description Devil May Cry 3 HD .mod 3D model file
#pragma MIME 3d-model/capcom.dmc3-hd-mod

// author = haru233, many thanks to AxCut
// ImHex Hex Pattern File for Capcom's Devil May Cry 3 HD .mod files


import std.core;


struct ModelHeader {
    char ID[4];
    float Version;
    padding[8];
    u8 objectCount;
    u8 boneCount;
    u8 numberTextures;
    u8;
    u32;
    u64;
    u64 skeletonOffset;
    padding[24];
};

struct ObjectInfo {
    u8 meshCount;
    u8;
    u16 numberVertices;
    padding[4];
    u64 meshOffset;
    u32 flags;
    padding[28];
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
    padding[12];
    u64 VerticesPositionsOffset;
    u64 NormalsPositionsOffset;
    u64 UVsPositionsOffset;

    padding[16];
    u64 unknownOffset;

    u64;
    padding[8];
    
    Positions positions[numberVertices] @VerticesPositionsOffset;
    Normals normals[numberVertices] @NormalsPositionsOffset;
    UVs uvs[numberVertices] @UVsPositionsOffset;
    
    
};

struct Mesh {
    u16 numberVertices;
    u16 textureIndex;
    padding[12];
    u64 VerticesPositionsOffset;
    u64 NormalsPositionsOffset;
    u64 UVsPositionsOffset;

    u64 BoneIndicesOffset;
    u64 WeightsOffset;
    padding[8];

    u64;
    padding[8];
    
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
    u8;
};

struct Transform {
    float x;
    float y;
    float z;
    float length; // sqrt(x*x + y*y + z*z)
    padding[16];
};

struct Skeleton{
    u32 hierarchyOffset;
    u32 hierarchyOrderOffset;
    u32 unknownOffset;
    u32 transformsOffset;
};         


    


ModelHeader modelheader @ 0x00;
ObjectInfo objects_info[modelheader.objectCount] @ 0x40;

u32 objectOffset;

struct Object {
   u64 i = std::core::array_index();
   if (modelheader.ID == "SCM ") {
        objectOffset = objects_info[0].meshOffset;
        MeshSCM meshscm[objects_info[i].meshCount] @ objects_info[i].meshOffset;
        
        
    } else {
        objectOffset = objects_info[0].meshOffset;
        Mesh mesh[objects_info[i].meshCount] @ objects_info[i].meshOffset;
    }
};

Object objects[modelheader.objectCount] @objectOffset;

Skeleton skeleton @modelheader.skeletonOffset;

Hierarchy hierarchy[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.hierarchyOffset);

HierarchyOrder hierarchyorder[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.hierarchyOrderOffset);

Unknown unknown[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.unknownOffset);

Transform transform[modelheader.boneCount] @(modelheader.skeletonOffset + skeleton.transformsOffset);
