#pragma author Jake Ryan
#pragma description MagicaVoxel scene description format
#pragma magic [ 56 4F 58 20 ] @ 0
#pragma array_limit 0x100000

import std.io;

// Input and output variables
bool formatColorsAsFloat in;

// Pattern definitions
// https://github.com/ephtracy/voxel-model/blob/master/MagicaVoxel-file-format-vox.txt
// https://github.com/ephtracy/voxel-model/blob/master/MagicaVoxel-file-format-vox-extension.txt
struct VoxHeader
{
    char magic[4];
    u32 version;
};

struct Voxel
{
    u8 x;
    u8 y;
    u8 z;
    u8 colorIndex;
} [[static, format("FormatVoxel")]];

fn FormatVoxel(ref Voxel v)
{
    return std::format("{}, {}, {}", v.x, v.y, v.z);
};

struct RGBA8
{
    u8 r [[color("FF0000")]];
    u8 g [[color("00FF00")]];
    u8 b [[color("0000FF")]];
    u8 a;
} [[static, color(std::format("{:02X}{:02X}{:02X}", r, g, b)), format("FormatRGBA8")]];

fn FormatRGBA8(ref RGBA8 c)
{
    if (formatColorsAsFloat)
    {
        return std::format("{:4.2f}, {:4.2f}, {:4.2f}, {:4.2f}", c.r / 255.0, c.g / 255.0, c.b / 255.0, c.a / 255.0);
    }
    else
    {
        return std::format("{:3}, {:3}, {:3}, {:3}", c.r, c.g, c.b, c.a);
    }
};

struct String
{
    u32 sizeBytes;
    char data[sizeBytes];
} [[format("FormatString")]];

fn FormatString(ref String s)
{
    return std::format("\"{}\"", s.data);
};

struct Vec3 { float x, y, z; };
struct Mat3 { Vec3 r0, r1, r2; };

bitfield Rotation
{
    firstRowIndex  : 2;
    secondRowIndex : 2;
    firstRowSign   : 1;
    secondRowSign  : 1;
    thirdRowSign   : 1;
    padding        : 1;
};

// TODO: RotationToMat3 function

struct KeyValue
{
    String key;
    if (key.data == "_r")
    {
        Rotation value_r;
    }
    else
    {
        String value;
    }
} [[format("FormatKeyValue")]];

fn FormatKeyValue(ref KeyValue kv)
{
    return std::format("{}: {}", kv.key, kv.value);
};

struct Dict
{
    u32 count;
    KeyValue pairs[count] [[inline]];
} [[format("FormatDict")]];

fn FormatDict(ref Dict d)
{
    return std::format("count: {}", d.count);
};

struct Model
{
    s32 modelId;
    Dict attributes;
};

struct Chunk
{
    char id[4];
    u32 sizeBytes;
    u32 childrenBytes;
    
    // Contents of the chunk
    match (id)
    {
        ("MAIN"): {}
        ("PACK"):
        {
            u32 numModels;
        }
        ("SIZE"):
        {
            u32 sizeX, sizeY, sizeZ;
        }
        ("XYZI"):
        {
            u32 numVoxels;
            Voxel voxels[numVoxels];
        }
        ("RGBA"):
        {
            RGBA8 colors[256];
        }
        ("nTRN"):
        {
            s32 nodeId;
            Dict attributes;
            s32 childNodeId;
            s32 reservedMustBeNegative1;
            s32 layerId;
            u32 numFrames;
            Dict frames[numFrames];
        }
        ("nGRP"):
        {
            s32 nodeId;
            Dict attributes;
            u32 numChildren;
            s32 childrenIds[numChildren];
        }
        ("nSHP"):
        {
            s32 nodeId;
            Dict attributes;
            u32 numModels;
            Model models[numModels];
        }
        ("MATL"): // Material properties
        {
            s32 materialId;
            Dict attributes;
        }
        ("LAYR"):
        {
            s32 layerId;
            Dict attributes;
            s32 reservedMustBeNegative1;
        }
        ("rOBJ"): // Rendering attributes
        {
            Dict attributes;
        }
        ("rCAM"): // Camera attributes
        {
            s32 cameraId;
            Dict attributes;
        }
        ("NOTE"): // Names for colors
        {
            u32 numNames;
            String names[numNames];
        }
        ("IMAP"): // Index map
        {
            u32 paletteIndices[256];
        }
        (_):
        {
            u8 data[sizeBytes];
            std::warning(std::format("Unknown chunk ID at 0x{:X}: \"{}\"", $, id));
        }
    }
    
    if (childrenBytes > 0)
    {
        s32 cursorPosBeforeChildren = $;
        Chunk children[while(true)];
    }
    
    // The node with id MAIN is also the root node.
    if (id != "MAIN")
    {
        // We are done parsing the children for this parent if the cursor has advanced parent.childrenBytes bytes since then.
        if ($ - parent.cursorPosBeforeChildren >= parent.childrenBytes)
        {
            break;
        }
    }
} [[format("ChunkFormatter")]];

fn ChunkFormatter(ref Chunk chunk)
{
    return chunk.id;
};

VoxHeader header @ 0 [[inline]];
Chunk mainChunk @ sizeof(header);