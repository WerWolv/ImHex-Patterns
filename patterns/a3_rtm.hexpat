#pragma author MrClock
#pragma description Arma 3 RTM animation format (plain)

#pragma endian little

#pragma MIME application/x.a3-rtm

import std.mem;
import std.sys;
import std.string;
import std.io;

using lascii = std::string::SizedString<u8> [[format("formatLascii")]];

struct Property {
    float phase;
    lascii name;
    lascii value;
} [[format("formatProperty")]];

struct Bone {
    char name[32];
} [[sealed,static,transform("transformBone"),format("formatBone")]];

struct Transform {
    Bone bone;
    float matrix[12] [[comment("4x4 transformation matrix (with last row omitted)")]];
} [[static,format("formatTransform")]];

struct Frame {
    float phase;
    Transform transforms[parent.count_bones];
} [[static,format("formatFrame")]];

struct Vector {
    float x [[comment("+Left/-Right")]];
    float y [[comment("+Up/-Down (UNUSED)")]];
    float z [[comment("+Forward/-Backward")]];
} [[static,format("formatVector")]];

struct RTM {
    if (std::mem::read_string($, 8) == "RTM_MDAT") {
        char properties_signature[8];
        padding[4];
        u32 count_properties;
        Property properties[count_properties];
    }
    
    std::assert(std::mem::read_string($, 8) == "RTM_0101", "Missing animation data");
    
    char animation_signature[8];
    Vector motion;
    u32 count_frames;
    u32 count_bones;
    Bone bones[count_bones];
    Frame frames[count_frames];
    
    std::assert_warn(std::mem::eof(), "Data ended before EOF");
};

fn formatLascii(ref lascii value) {
    return std::format("\"{:s}\"", value);
};

fn formatProperty(ref Property prop) {
    return std::format("\"{0:s}\" = \"{1:s}\" @ {2:.4f}", prop.name, prop.value, prop.phase);
};

fn transformBone(ref Bone value) {
    return std::string::to_string(value.name);
};

fn formatBone(ref Bone value) {
    return std::format("\"{0:s}\"", value);
};

fn formatTransform(ref Transform transform) {
    return std::format("\"{0:s}\" transform", transform.bone);
};

fn formatFrame(ref Frame frame) {
    return std::format("frame @ {0:.4f}", frame.phase);
};

fn formatVector(ref Vector vec) {
    return std::format("[{0:.2f}, {1:.2f}, {2:.2f}]", vec.x, vec.y, vec.z);
};

RTM file @ 0x0000;
