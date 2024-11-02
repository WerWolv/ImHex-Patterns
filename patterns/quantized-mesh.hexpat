#pragma author applecuckoo
#pragma description Cesium quantized-mesh terrain
#pragma endian little

// based on https://github.com/CesiumGS/quantized-mesh
// potential improvements: figure out how to decode values, i.e. high water mark encoding for indices and oct16 for normals

u8 extensionCount;
extensionCount = 3; // NOTE: set this to the amount of extensions in your terrain.

// ZigZag decoder based on protobuf.hexpat by WerWolv

struct ZigZag16 {
	u16 value;
} [[sealed, format("format_zigzag16")]];

fn format_zigzag16(ZigZag16 zigzag) {
	return s16((s16(zigzag.value) << 1) ^ (s16(zigzag.value) >> 15));
};

struct QuantizedMeshHeader {
    double CenterX;
    double CenterY;
    double CenterZ;
    
    float MinimumHeight;
    float MaximumHeight;
    
    double BoundingSphereCenterX;
    double BoundingSphereCenterY;
    double BoundingSphereCenterZ;
    double BoundingSphereRadius;
    
    double HorizonOcclusionPointX;
    double HorizonOcclusionPointY;
    double HorizonOcclusionPointZ;
};

struct VertexData {
    u32 vertexCount;
    ZigZag16 u[vertexCount];
    ZigZag16 v[vertexCount];
    ZigZag16 height[vertexCount];
};

struct IndexData16 {
    u32 triangleCount;
    u16 indices[triangleCount * 3];
};

struct IndexData32 {
    u32 triangleCount;
    u32 indices[triangleCount * 3];
};

struct EdgeIndices16 {
    u32 westVertexCount;
    u16 westIndices[westVertexCount];

    u32 southVertexCount;
    u16 southIndices[southVertexCount];

    u32 eastVertexCount;
    u16 eastIndices[eastVertexCount];

    u32 northVertexCount;
    u16 northIndices[northVertexCount];
};

struct EdgeIndices32 {
    u32 westVertexCount;
    u32 westIndices[westVertexCount];

    u32 southVertexCount;
    u32 southIndices[southVertexCount];

    u32 eastVertexCount;
    u32 eastIndices[eastVertexCount];

    u32 northVertexCount;
    u32 northIndices[northVertexCount];
};

enum ExtensionTypes : u8 {
    OctEncodedVertexNormals = 0x1,
    WaterMask,
    Metadata = 0x4,
};

struct OctEncodedVertexNormals {
    u8 xy[parent.parent.vertdata.vertexCount * 2]; // TODO: 
};

struct WaterMask {
    u8 mask[parent.extensionLength];
};

struct Metadata {
    u32 jsonLength;
    char json[jsonLength];
};

struct ExtensionHeader {
    u8 extensionId;
    u32 extensionLength;
    match (extensionId) {
        (ExtensionTypes::OctEncodedVertexNormals): OctEncodedVertexNormals octVertNormals;
        (ExtensionTypes::WaterMask): WaterMask maskData;
        (ExtensionTypes::Metadata): Metadata metadata;
    }
};

struct QuantizedMesh {
    QuantizedMeshHeader header;
    VertexData vertdata;
    
    if (vertdata.vertexCount > 65536) {
        IndexData32 indexdata;
        EdgeIndices32 edgeindices;
    } else {
        IndexData16 indexdata;
        EdgeIndices16 edgeindices;
    }
    
    ExtensionHeader extensions[extensionCount];
};

QuantizedMesh mesh @ 0x00;