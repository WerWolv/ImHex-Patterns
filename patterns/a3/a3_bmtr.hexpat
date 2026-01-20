#pragma author MrClock
#pragma description Arma 3 RTM animation format (binarized)

#pragma endian little

#pragma MIME application/x.a3-bmtr

fn get_data_description() {
    return "Binarized RTM (BMTR) animation files are the PBO packed versions of plain RTMs.\n Binarized files are optimized for use by the game engine, and they are not editable.\nBone transformations are stored as relative quaternion-vector pairs.\nData blocks are conditionally LZO1X compressed (these are not supported by this pattern).";
};

import std.string;
import std.sys;
import type.float16;

using asciiz = std::string::NullString [[format("formatAsciiz")]];
using half = type::float16 ;
struct s16float {
    s16 data;
} [[sealed,static,transform("transforms16float"), format("transforms16float")]];

struct Property {
    padding[4];
    asciiz name;
    float phase;
    asciiz value;
} [[format("formatProperty")]];

struct Vector<DataType> {
    DataType x [[comment("+Left/-Right")]];
    DataType y [[comment("+Up/-Down (UNUSED)")]];
    DataType z [[comment("+Forward/-Backward")]];
} [[static]];

struct Quaternion {
    s16float x;
    s16float y;
    s16float z;
    s16float w;
} [[static,format("formatQuaternion")]];

struct Transform {
    Quaternion orientation;
    Vector<half> position [[format("formatVectorHalf")]];
} [[static]];

struct Frame {
    u32 count_bones;
    bool compressed = count_bones * sizeof(Transform) >= 1024;
    if (parent.version > 4) {
        u8 lzo_flag;
        compressed = lzo_flag > 0;
    }
    
    if (compressed) {
        std::error("Transformations are LZO compressed and compressed length is unknown");
    } else {
        Transform transforms[count_bones];
    }
};

struct BMTR {
    char signature[4];
    u32 version;
    padding[1];
    Vector<float> motion [[format("formatVectorFloat")]];
    u32 count_frames;
    padding[4];
    u32 count_bones;
    u32 count_bones_again;
    
    std::assert_warn(count_bones == count_bones_again, "Mismatch between bone counts");
    
    asciiz bones[count_bones];
    
    if (version >= 4) {
        padding[4];
        u32 count_properties;
        Property properties[count_properties];
    }
    
    u32 count_phases;
    std::assert_warn(count_frames == count_phases, "Frame and phase counts do not match");
    
    bool compressed = count_phases * sizeof(float) >= 1024;
    if (version > 4) {
        u8 lzo_flag;
        compressed = lzo_flag > 0;
    }
    
    if (compressed) {
        std::error("Phases are LZO compressed and compressed length is unknown");
    } else {
        float phases[count_phases];
    }
    
    Frame frames[count_frames];
};

fn transforms16float(ref s16float value) {
    return float(value.data) / 16384;
};

fn formatAsciiz(ref asciiz value) {
    return std::format("\"{:s}\"", value);
};

fn formatProperty(ref Property prop) {
    return std::format("\"{0:s}\" = \"{1:s}\" @ {2:.4f}", prop.name, prop.value, prop.phase);
};

fn formatVectorHalf(ref Vector<half> vec) {
    return std::format(
        "[{0}, {1}, {2}]",
        type::impl::format_float16(vec.x),
        type::impl::format_float16(vec.y),
        type::impl::format_float16(vec.z)
    );
};

fn formatVectorFloat(ref Vector<float> vec) {
    return std::format("[{0:.2f}, {1:.2f}, {2:.2f}]", vec.x, vec.y, vec.z);
};

fn formatQuaternion(ref Quaternion q) {
    return std::format("[{0:.2f}, {1:.2f}, {2:.2f}, {3:.2f}]", q.x, q.y, q.z, q.w);
};

BMTR file @ 0x0000;
