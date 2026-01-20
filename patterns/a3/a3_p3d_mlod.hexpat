#pragma author MrClock
#pragma description Arma 3 P3D model format (MLOD)

#pragma endian little

#pragma MIME model/x.a3-p3d-mlod

fn get_data_description() {
    return "MLOD type P3D files are used for authoring 3D models for Arma 3.\nThese files can be carated in and edited in the Object Builder application.\nAll data is stored uncompressed for ease of editing.\nDuring the PBO packing process they are further \"binarized\" into ODOL type P3D files, that are optimized for use by the game engine. (These are no longer editable, the conversion is irreversible.)\n\nP3D model files can by quite large, so by default only the 1st LOD is processed by this pattern. Processing of all LODs can be enabled in the pattern settings.";
};

import std.string;
import std.core;

bool process_all_lods in;

using asciiz = std::string::NullString;

enum FaceType: u32 {
    TRIANGLE = 3,
    QUAD = 4
};

struct Vector {
    float x;
    float y;
    float z;
} [[static,format("formatVector")]];

struct UV {
    float u;
    float v;
} [[static,format("formatUV")]];

enum SurfaceFitting: u8 {
    NORMAL = 0,
    ON_SURFACE = 1,
    ABOVE_SURFACE = 2,
    UNDER_SURFACE = 4,
    KEEP_HEIGHT = 8
};

enum Lighting: u8 {
    NORMAL = 0,
    SHINING = 1,
    SHADOWED = 2,
    FULL_LIT = 4,
    HALF_LIT = 8
};

enum DecalMode: u8 {
    NORMAL = 0,
    DECAL = 1,
    RADIO12 = 2
};

enum Fog: u8 {
    NORMAL = 0,
    NONE = 1,
    SKY = 2
};

enum NormalCalculation: u8 {
    FACE_AREA = 0,
    HIDDE_VERTEX = 1,
    FIXED = 2,
    FACE_ANLGE = 4
};

bitfield VertexFlags {
    padding : 5;
    NormalCalculation normals : 3;
    u8 user;
    padding : 2;
    Fog fog : 2;
    padding : 2;
    DecalMode decal : 2;
    Lighting lighting : 4;
    SurfaceFitting surface : 4;
} [[bitfield_order(std::core::BitfieldOrder::MostToLeastSignificant, 32)]];

struct Vertex {
    Vector position;
    VertexFlags flags;
}[[static,format("formatVertex")]];

struct FacePoint {
    u32 vertex_index;
    u32 normal_index;
    UV uv;
} [[static]];

enum ZBiasFlag: u8 {
    NONE = 0,
    LOW = 1,
    MIDDLE = 2,
    HIGH = 3
};

bitfield FaceFlags {
    user : 7;
    disable_texture_merging : 1;
    padding : 2;
    flat_lighting : 1;
    reversed_face : 1;
    padding : 10;
    ZBiasFlag zbias : 2;
    position : 1;
    padding : 1;
    double_sided_face : 1;
    disable_shadow : 1;
    padding : 4;
} [[bitfield_order(std::core::BitfieldOrder::MostToLeastSignificant, 32)]];

struct Face {
    FaceType type;
    FacePoint points[4];
    FaceFlags flags;
    asciiz texture;
    asciiz material;
} [[format("formatFace")]];

struct Edge {
    u32 vertex_1;
    u32 vertex_2;
} [[sealed,static,format("formatEdge")]];

struct Property {
    char name[64] [[transform("std::string::to_string")]];
    char value[64] [[transform("std::string::to_string")]];
} [[static,sealed,format("formatProperty")]];

struct Tagg {
    bool active;
    asciiz name;
    u32 length;

    if (name == "#EndOfFile#") {
        break;
    }

    match (name) {
        ("#SharpEdges#"): Edge edges[length/8];
        ("#Property#"): Property property;
        ("#Mass#"): float masses[parent.count_verticies];
        ("#UVSet#"): {
            u32 channel;
            UV coordinates[(length - 4) / 8];
        }
        (_): if (std::string::starts_with(name, "#") && std::string::ends_with(name, "#")) {
            u8 unknown_data[length];
        } else {
            u8 vertex_weights[parent.count_verticies];
            u8 face_weights[parent.count_faces];
        }
    }
} [[format("formatTagg")]];

struct P3dmLod {
    char signature[4];
    u32 version_major;
    u32 version_minor;
    u32 count_verticies;
    u32 count_normals;
    u32 count_faces;
    u32; // Unknown data (might be unused model flags)
    Vertex verticies[count_verticies];
    Vector normals[count_normals];
    Face faces[count_faces];
    char tagg_signature[4];
    Tagg taggs[while(true)];
    float resolution;
} [[format("formatP3dmLod")]];

struct P3D {
    char signature[4];
    u32 version;
    u32 count_lods;
    if (!process_all_lods) {
        P3dmLod lod_0;
    } else {
        P3dmLod lods[count_lods];
    }
};

fn formatVector(ref Vector pos) {
    return std::format("[{0:.3f}, {1:.3f}, {1:.3f}]", pos.x, pos.y, pos.z);
};

fn formatUV(ref UV pos) {
    return std::format("[{0:.3f}, {1:.3f}]", pos.u, pos.v);
};

fn formatVertex(ref Vertex vert) {
    return formatVector(vert.position);
};

fn formatFace(ref Face face) {
    return face.type == FaceType::TRIANGLE ? "triangle" : "quad";
};

fn formatEdge(ref Edge edge) {
    return std::format("{0:d} <-> {1:d}", edge.vertex_1, edge.vertex_2);
};

fn formatProperty(ref Property prop) {
    return std::format("\"{0:s}\" = \"{1:s}\"", prop.name, prop.value);
};

fn formatTagg(ref Tagg tagg) {
    if (std::core::has_member(tagg, "vertex_weights")) {
        return std::format("\"{0:s}\" selection", tagg.name);
    } else {
        return std::format("\"{0:s}\"", tagg.name);
    }
};

fn formatP3dmLod(ref P3dmLod lod) {
    return std::format("Resolution: {0}", lod.resolution);
};

P3D file @ 0x0000;
