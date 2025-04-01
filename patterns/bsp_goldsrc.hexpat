#pragma description GoldSrc engine map (Half-Life 1)

import std.ptr;
import std.mem;
import std.sys;

#pragma endian little

#define HEADER_LUMPS 15
#define MAX_MAP_HULLS 4
#define NUM_AMBIENTS 4
#define MAXLIGHTMAPS 4

enum LumpIndex : u32 {
	Entities,
	Planes,
	Textures,
	Vertexes,
	Visibility,
	Nodes,
	Texinfo,
	Faces,
	Lighting,
	Clipnodes,
	Leafs,
	Marksurfaces,
	Edges,
	Surfedges,
	Models,
};

struct vec3f
{
	float x, y, z;
};

struct dlump_t
{
	s32 fileofs;
	s32 filelen;
};

struct dheader_t
{
	s32    version;
	dlump_t	lumps[HEADER_LUMPS];
	std::assert(version == 30, "This version of BSP format is unsupported.");
};

struct dmodel_t
{
	vec3f  mins;
	vec3f  maxs;
	vec3f  origin;     // for sounds or lights
	s32    headnode[MAX_MAP_HULLS];
	s32    visleafs;   // not including the solid leaf 0
	s32    firstface;
	s32    numfaces;
};

struct dplane_t
{
	vec3f  normal;
	float  dist;
	s32	   type;
};

struct dtexinfo_t
{
	float  vecs[8];	// texmatrix [s/t][xyz offset]
	s32	   miptex;
	s16	   flags;
	s16	   faceinfo; // -1 no face info otherwise dfaceinfo_t
};

struct dleaf_t
{
	s32 contents;
	s32 visofs;     // -1 = no visibility info
	s16 mins[3];
	s16 maxs[3];
	u16 firstmarksurface;
	u16 nummarksurfaces;
	u8 ambient_level[NUM_AMBIENTS];
};

struct dnode_t
{
	s32 planenum;
	s16 children[2];    // negative numbers are -(leafs + 1), not nodes
	s16 mins[3];
	s16 maxs[3];
	u16 firstface;
	u16 numfaces;   // counting both sides
};

struct dface_t
{
	u16 planenum;
	s16 side;
	s32 firstedge;
	s16 numedges;
	s16 texinfo;
	u8 styles[MAXLIGHTMAPS];
	s32 lightofs;   // start of [numstyles*surfsize] samples
};

struct dedge_t
{
	u16 v[2]; // indices of vertexes
};

struct dclipnode_t
{
	s32 planenum;
	s16 children[2];
};

using dmarkface_t = u16;
using dsurfedge_t = s32;
using dvertex_t = vec3f;

fn get_miptex_pixeldata_size(auto width, auto height, auto offset) {
	if (offset != 0) {
		return std::mem::align_to(4, width * height * 85 / 64 + sizeof(u16) + 768);
	}
	else {
		return 0;
	}
};

struct miptex_t
{
	char   name[16];
	u32	   width;
	u32	   height;
	u32	   offsets[4]; // four mip maps stored
	u8     pixeldata[get_miptex_pixeldata_size(width, height, offsets[0])];
};

dheader_t file_header @ 0x00;

fn get_lump_element_count(auto index, auto elem_size) {
	return file_header.lumps[index].filelen / elem_size;
};

fn get_lump_address(auto index) {
	return file_header.lumps[index].fileofs;
};

fn get_miptex_ptr_base(auto offset) {
	return file_header.lumps[LumpIndex::Textures].fileofs;
};

struct MiptexPointer
{
	miptex_t *data: u32 [[pointer_base("get_miptex_ptr_base"), inline]];
};

struct dmiptexlump_t
{
	s32	nummiptex;
	MiptexPointer dataofs[nummiptex];
};

struct VisibilityData
{
	u8 data[file_header.lumps[LumpIndex::Visibility].filelen];
	u8 pad[std::mem::align_to(4, sizeof(this)) - sizeof(this)];
};

struct LightmapData
{
	u8 data[file_header.lumps[LumpIndex::Lighting].filelen];
	u8 pad[std::mem::align_to(4, sizeof(this)) - sizeof(this)];
};

struct EntityData
{
	char text[];
	u8 pad[std::mem::align_to(4, sizeof(this)) - sizeof(this)];
};

s32 models_count = get_lump_element_count(LumpIndex::Models, sizeof(dmodel_t));
s32 vertexes_count = get_lump_element_count(LumpIndex::Vertexes, sizeof(vec3f));
s32 planes_count = get_lump_element_count(LumpIndex::Planes, sizeof(dplane_t));
s32 leafs_count = get_lump_element_count(LumpIndex::Leafs, sizeof(dleaf_t));
s32 nodes_count = get_lump_element_count(LumpIndex::Nodes, sizeof(dnode_t));
s32 faces_count = get_lump_element_count(LumpIndex::Faces, sizeof(dface_t));
s32 markfaces_count = get_lump_element_count(LumpIndex::Marksurfaces, sizeof(dmarkface_t));
s32 surfedges_count = get_lump_element_count(LumpIndex::Surfedges, sizeof(dsurfedge_t));
s32 edges_count = get_lump_element_count(LumpIndex::Edges, sizeof(dedge_t));
s32 clipnodes_count = get_lump_element_count(LumpIndex::Clipnodes, sizeof(dclipnode_t));
s32 texinfo_count = get_lump_element_count(LumpIndex::Texinfo, sizeof(dtexinfo_t));

dmodel_t models_lump[models_count] @ get_lump_address(LumpIndex::Models);
dvertex_t vertexes_lump[vertexes_count] @ get_lump_address(LumpIndex::Vertexes);
dplane_t planes_lump[planes_count] @ get_lump_address(LumpIndex::Planes);
dleaf_t leafs_lump[leafs_count] @ get_lump_address(LumpIndex::Leafs);
dnode_t nodes_lump[nodes_count] @ get_lump_address(LumpIndex::Nodes);
dface_t faces_lump[faces_count] @ get_lump_address(LumpIndex::Faces);
dmarkface_t markfaces_lump[markfaces_count] @ get_lump_address(LumpIndex::Marksurfaces);
dsurfedge_t surfedges_lump[surfedges_count] @ get_lump_address(LumpIndex::Surfedges);
dedge_t edges_lump[edges_count] @ get_lump_address(LumpIndex::Edges);
dclipnode_t clipnodes_lump[clipnodes_count] @ get_lump_address(LumpIndex::Clipnodes);
dtexinfo_t texinfo_lump[texinfo_count] @ get_lump_address(LumpIndex::Texinfo);
dmiptexlump_t textures_lump @ get_lump_address(LumpIndex::Textures);
VisibilityData visdata_lump @ get_lump_address(LumpIndex::Visibility);
LightmapData lightdata_lump @ get_lump_address(LumpIndex::Lighting);
EntityData entdata_lump @ get_lump_address(LumpIndex::Entities);
