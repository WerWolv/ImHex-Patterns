#pragma author WerWolv
#pragma description STL 3D Model format

#pragma MIME model/stl
#pragma MIME model/x.stl-binary
#pragma MIME model/x.stl-ascii
#pragma MIME application/sla

#include <std/sys.pat>
#include <std/mem.pat>
#include <std/core.pat>

struct Vector3f {
    float x, y, z;
} [[static, format("format_vector3f")]];

fn format_vector3f(Vector3f vec) {
    return std::format("[ {}, {}, {} ]", vec.x, vec.y, vec.z);
};

struct Triangle {
    Vector3f normal;
    Vector3f points[3];
    u16 flags;
} [[static]];

struct BinarySTLHeader {
    char caption[while($[$] != 0x00 && $ - addressof(this) < 80)];
    padding[80 - sizeof(caption)];
    u32 triangleCount;
};

struct STL {    
    if (std::mem::read_string(0, 6) == "solid ")
        std::warning("ASCII STL file!");
    else {
        BinarySTLHeader header;
        Triangle triangles[header.triangleCount];
    }
};

STL stl @ 0x00;

/* Visualize the 3D Model */

struct Vertex {
    Vector3f points[3] @ addressof(stl.triangles[std::core::array_index()].points);
};

struct Model {
    Vertex vertices[stl.header.triangleCount];
} [[highlight_hidden, sealed, hex::visualize("3d", vertices, null)]];

Model model @ 0x00;
