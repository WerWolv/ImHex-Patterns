#pragma MIME model/stl
#pragma MIME model/x.stl-binary
#pragma MIME model/x.stl-ascii
#pragma MIME application/sla

#include <std/sys.pat>
#include <std/mem.pat>

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
	char caption[];
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