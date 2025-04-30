#pragma author Jake Ryan
#pragma description MagicaVoxel scene description format
#pragma magic [ 56 4F 58 20 ] @ 0
#pragma array_limit 0x100000

import std.io;
import std.core;

// Input and output variables

// If true, color data will be formatted as normalized floats.
bool formatColorsAsFloat in;

// If true, chunks will be treated as though they were in a single big array instead of a hierarchy.
bool readChunksAsLinear in;

bool attemptRecoveryOnChunkSizeMismatch in;

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

struct Vec3 { float v[3]; };
struct Mat3 { Vec3 r0, r1, r2; } [[format("FormatMat3")]];

fn FormatMat3(ref Mat3 m)
{
    return std::format("({}, {}, {}) ({}, {}, {}) ({}, {}, {})", 
        m.r0.v[0], m.r0.v[1], m.r0.v[2], 
        m.r1.v[0], m.r1.v[1], m.r1.v[2], 
        m.r2.v[0], m.r2.v[1], m.r2.v[2]);
};

bitfield Rotation
{
    firstRowIndex  : 2;
    secondRowIndex : 2;
    firstRowSign   : 1;
    secondRowSign  : 1;
    thirdRowSign   : 1;
    padding        : 1;
};

// Unused, but demonstrates how a 3x3 matrix could be constructed from Rotation.
fn RotationToMat3(Rotation r)
{
    Mat3 mat;
    mat.r0.v[r.firstRowIndex] = -(r.firstRowSign * 2 - 1);
    mat.r1.v[r.secondRowIndex] = -(r.secondRowSign * 2 - 1);
    mat.r2.v[0] = -(r.thirdRowSign * 2.0 - 1) * !(r.firstRowIndex == 0 || r.secondRowIndex == 0);
    mat.r2.v[1] = -(r.thirdRowSign * 2.0 - 1) * !(r.firstRowIndex == 1 || r.secondRowIndex == 1);
    mat.r2.v[2] = -(r.thirdRowSign * 2.0 - 1) * !(r.firstRowIndex == 2 || r.secondRowIndex == 2);
    return mat;
};

struct KeyValue
{
    String key;
    // Depending on the key, the value must be parsed as one or more floats or integers.
    String value;
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
    s32 cursorPosBeforeContent = $;
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
            // The documentation says this field is i32x256, but it's u8x256 in actual models.
            u8 paletteIndices[256];
        }
        (_):
        {
            u8 unknownData[sizeBytes];
            std::warning(std::format("Unknown chunk ID at 0x{:X}: \"{}\"", $, id));
        }
    }
    
    s32 actualContentSize = ($ - cursorPosBeforeContent);
    if (actualContentSize != sizeBytes)
    {
        str warningTextSecondHalf = std::format("Content size mismatch! Expected: {}. Actual: {}", sizeBytes, actualContentSize);
        str warningText = std::format("Chunk at 0x{:X} with id {}: {}", addressof(this), id, warningTextSecondHalf);
        if (attemptRecoveryOnChunkSizeMismatch)
        {
            std::warning(warningText);
        }
        else
        {
            std::error(warningText);
        }
        // Limited recovery- reading past EoF is still possible if chunk is nested.
        // Setting readChunksAsLinear to true can make recovery more robust as the outermost array will be broken out of.
        break;
    }
    
    if (childrenBytes > 0 && !readChunksAsLinear)
    {
        s32 cursorPosBeforeChildren = $;
        Chunk children[while(true)];
    }
    
    // The node with id MAIN is also the root node.
    if (id != "MAIN" && !readChunksAsLinear)
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
Chunk mainChunk[readChunksAsLinear ? 0 : 1] @ $ [[inline]];
Chunk chunks[while(readChunksAsLinear && !std::mem::eof())] @ $;

if (std::core::member_count(mainChunk) > 0)
{
    std::core::set_display_name(mainChunk[0], "mainChunk");
}