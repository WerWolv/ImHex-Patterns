// Qubicle QBCL format

struct String {
	u32 len;
	char string[len];
};

struct Matrix {
	u32 sizex;
	u32 sizey;
	u32 sizez;
	s32 tx;
	s32 ty;
	s32 tz;
	float pivotx;
	float pivoty;
	float pivotz;
	u32 compressedDataSize;
	u8 zip[compressedDataSize];
};

// Rotation matrix according to wikipedia
// https://en.wikipedia.org/wiki/Rotation_matrix#Basic_rotations
struct Matrices {
	float row1[3];
	float row2[3];
	float row3[3];
};

using Node;

struct Model {
	Matrices rotation;
	u32 childCount;
	Node nodes[childCount];
};

struct Compound {
	Matrix matrix;
	u32 childCount;
	Node nodes[childCount];
};

struct Node {
	u32 type;
	u32 unknown;
	String name;
	u8 visible;
	u8 unknown2;
	u8 locked;
	if (type == 0) {
		Matrix matrix;
	} else if (type == 1) {
		Model model;
	} else if (type == 2) {
		Compound compound;
	}
};

struct Header {
	u32 magic;
	u32 version;
	u32 fileversion;
	u32 thumbwidth;
	u32 thumbheight;
	char bgra[thumbwidth * thumbheight * 4];
	String title;
	String desc;
	String metadata;
	String author;
	String company;
	String website;
	String copyright;
	// Maybe change and creation time?
	double time1;
	double time2;
	Node node;
};

Header hdr @0x00;
