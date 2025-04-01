#pragma author applecuckoo
#pragma description Cesium quantized-mesh terrain
#pragma endian little

// based on https://github.com/CesiumGS/quantized-mesh
// potential improvements: figure out high water mark encoding for indices

import std.math;
import std.io;

u8 extensionCount;
extensionCount = 0; // NOTE: set this to the amount of extensions in your terrain.

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

// Oct16 decode based on https://github.com/loicgasser/quantized-mesh-tile/blob/master/quantized_mesh_tile/utils.py

fn signNotZero(float v) {
    if (v < 0.0)
    return -1.0;
    else
    return 1.0;
};

fn fromSnorm(u8 value) {
    return float(std::math::clamp(value, 0.0, 255.0) / 255.0 * 2.0 - 1.0);
};

struct Oct16 {
    u8 x;
    u8 y;
}[[sealed, format("format_oct16")]];

fn format_oct16(Oct16 oct) {
    float xOut;
    float yOut;
    float zOut;

    xOut = fromSnorm(oct.x);
    yOut = fromSnorm(oct.y);
    zOut = 1.0 - (std::math::abs(xOut) + std::math::abs(yOut));

    if (zOut < 0.0) {
        float oldX;

        oldX = xOut;
        xOut = (1.0 - std::math::abs(yOut)) * signNotZero(oldX);
        yOut = (1.0 - std::math::abs(oldX)) * signNotZero(yOut);
    }

    return std::format("{}, {}, {}", xOut, yOut, zOut);
};

struct OctEncodedVertexNormals {
    Oct16 xy[parent.parent.vertdata.vertexCount];
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