#pragma author Glenn Hartmann
#pragma description BTRFS Send Stream format - see https://btrfs.readthedocs.io/en/latest/dev/dev-send-stream.html. Currently supports versions 1 and 2.

#pragma magic [ 62 74 72 66 73 2D 73 74 72 65 61 6D ] @ 0x0

#pragma endian little

import std.hash;
import std.io;
import std.mem;
import std.sys;
import type.guid;
import type.magic;
import type.time;

// See https://btrfs.readthedocs.io/en/latest/dev/dev-send-stream.html#stream-version-1.
enum CommandType : u16 {
    // VERSION 1
    BTRFS_SEND_C_UNSPEC         = 0,
    BTRFS_SEND_C_SUBVOL         = 1,
    BTRFS_SEND_C_SNAPSHOT       = 2,
    BTRFS_SEND_C_MKFILE         = 3,
    BTRFS_SEND_C_MKDIR          = 4,
    BTRFS_SEND_C_MKNOD          = 5,
    BTRFS_SEND_C_MKFIFO         = 6,
    BTRFS_SEND_C_MKSOCK         = 7,
    BTRFS_SEND_C_SYMLINK        = 8,
    BTRFS_SEND_C_RENAME         = 9,
    BTRFS_SEND_C_LINK           = 10,
    BTRFS_SEND_C_UNLINK         = 11,
    BTRFS_SEND_C_RMDIR          = 12,
    BTRFS_SEND_C_SET_XATTR      = 13,
    BTRFS_SEND_C_REMOVE_XATTR   = 14,
    BTRFS_SEND_C_WRITE          = 15,
    BTRFS_SEND_C_CLONE          = 16,
    BTRFS_SEND_C_TRUNCATE       = 17,
    BTRFS_SEND_C_CHMOD          = 18,
    BTRFS_SEND_C_CHOWN          = 19,
    BTRFS_SEND_C_UTIMES         = 20,
    BTRFS_SEND_C_END            = 21,
    BTRFS_SEND_C_UPDATE_EXTENT  = 22,

    // VERSION 2
    BTRFS_SEND_C_FALLOCATE      = 23,
    BTRFS_SEND_C_FILEATTR       = 24,
    BTRFS_SEND_C_ENCODED_WRITE  = 25,
};

// See https://btrfs.readthedocs.io/en/latest/dev/dev-send-stream.html#attributes-tlv-types.
enum AttributeType : u16 {
    // VERSION 1
    BTRFS_SEND_A_UNSPEC              = 0,
    BTRFS_SEND_A_UUID                = 1,
    BTRFS_SEND_A_CTRANSID            = 2,
    BTRFS_SEND_A_INO                 = 3,
    BTRFS_SEND_A_SIZE                = 4,
    BTRFS_SEND_A_MODE                = 5,
    BTRFS_SEND_A_UID                 = 6,
    BTRFS_SEND_A_GID                 = 7,
    BTRFS_SEND_A_RDEV                = 8,
    BTRFS_SEND_A_CTIME               = 9,
    BTRFS_SEND_A_MTIME               = 10,
    BTRFS_SEND_A_ATIME               = 11,
    BTRFS_SEND_A_OTIME               = 12,
    BTRFS_SEND_A_XATTR_NAME          = 13,
    BTRFS_SEND_A_XATTR_DATA          = 14,
    BTRFS_SEND_A_PATH                = 15,
    BTRFS_SEND_A_PATH_TO             = 16,
    BTRFS_SEND_A_PATH_LINK           = 17,
    BTRFS_SEND_A_FILE_OFFSET         = 18,
    BTRFS_SEND_A_DATA                = 19,
    BTRFS_SEND_A_CLONE_UUID          = 20,
    BTRFS_SEND_A_CLONE_CTRANSID      = 21,
    BTRFS_SEND_A_CLONE_PATH          = 22,
    BTRFS_SEND_A_CLONE_OFFSET        = 23,
    BTRFS_SEND_A_CLONE_LEN           = 24,

    // VERSION 2
    BTRFS_SEND_A_FALLOCATE_MODE      = 25,
    BTRFS_SEND_A_FILEATTR            = 26,
    BTRFS_SEND_A_UNENCODED_FILE_LEN  = 27,
    BTRFS_SEND_A_UNENCODED_LEN       = 28,
    BTRFS_SEND_A_UNENCODED_OFFSET    = 29,
    BTRFS_SEND_A_COMPRESSION         = 30,
    BTRFS_SEND_A_ENCRYPTION          = 31,
};

const u8 num_v1_attribute_types = 25;
const AttributeType v1_attribute_types[num_v1_attribute_types] = {
    AttributeType::BTRFS_SEND_A_UNSPEC,
    AttributeType::BTRFS_SEND_A_UUID,
    AttributeType::BTRFS_SEND_A_CTRANSID,
    AttributeType::BTRFS_SEND_A_INO,
    AttributeType::BTRFS_SEND_A_SIZE,
    AttributeType::BTRFS_SEND_A_MODE,
    AttributeType::BTRFS_SEND_A_UID,
    AttributeType::BTRFS_SEND_A_GID,
    AttributeType::BTRFS_SEND_A_RDEV,
    AttributeType::BTRFS_SEND_A_CTIME,
    AttributeType::BTRFS_SEND_A_MTIME,
    AttributeType::BTRFS_SEND_A_ATIME,
    AttributeType::BTRFS_SEND_A_OTIME,
    AttributeType::BTRFS_SEND_A_XATTR_NAME,
    AttributeType::BTRFS_SEND_A_XATTR_DATA,
    AttributeType::BTRFS_SEND_A_PATH,
    AttributeType::BTRFS_SEND_A_PATH_TO,
    AttributeType::BTRFS_SEND_A_PATH_LINK,
    AttributeType::BTRFS_SEND_A_FILE_OFFSET,
    AttributeType::BTRFS_SEND_A_DATA,
    AttributeType::BTRFS_SEND_A_CLONE_UUID,
    AttributeType::BTRFS_SEND_A_CLONE_CTRANSID,
    AttributeType::BTRFS_SEND_A_CLONE_PATH,
    AttributeType::BTRFS_SEND_A_CLONE_OFFSET,
    AttributeType::BTRFS_SEND_A_CLONE_LEN
};

const u8 num_v2_attribute_types = 7;
const AttributeType v2_attribute_types[num_v2_attribute_types] = {
    AttributeType::BTRFS_SEND_A_FALLOCATE_MODE,
    AttributeType::BTRFS_SEND_A_FILEATTR,
    AttributeType::BTRFS_SEND_A_UNENCODED_FILE_LEN,
    AttributeType::BTRFS_SEND_A_UNENCODED_LEN,
    AttributeType::BTRFS_SEND_A_UNENCODED_OFFSET,
    AttributeType::BTRFS_SEND_A_COMPRESSION,
    AttributeType::BTRFS_SEND_A_ENCRYPTION
};

fn is_in(auto arr, u8 len, AttributeType val) {
    for (u8 i = 0, i < len, i += 1) {
        if (arr[i] == val) {
            return true;
        }
    }
    return false;
};

fn is_v1_attribute_type(AttributeType val) {
    return is_in(v1_attribute_types, num_v1_attribute_types, val);
};

fn is_v2_attribute_type(AttributeType val) {
    return is_in(v2_attribute_types, num_v2_attribute_types, val);
};

struct TimeSpec {
    u64 seconds;
    u32 nanoseconds;
} [[format("format_time_spec")]];

// Formats the "seconds" part of the TimeSpec as a time64_t.
fn format_time_spec(TimeSpec ts) {
    return type::impl::format_time_t(ts.seconds);
};

struct Attribute<auto Version, auto EndAddr> {
    AttributeType type;

    if (Version == 2 && type == AttributeType::BTRFS_SEND_A_DATA) {
        u64 length = EndAddr - $ [[export]];
    } else {
        u16 length;
    }

    u64 pre_data_pos = $;

    if (is_v1_attribute_type(type)) {
        match (type) {
            (AttributeType::BTRFS_SEND_A_UNSPEC):          std::error("got unspecified attribute type");
            (AttributeType::BTRFS_SEND_A_UUID):            type::GUID uuid;
            (AttributeType::BTRFS_SEND_A_CLONE_UUID):      type::GUID clone_uuid;
            (AttributeType::BTRFS_SEND_A_CTRANSID):        u64 ctransid;
            (AttributeType::BTRFS_SEND_A_INO):             u64 ino;
            (AttributeType::BTRFS_SEND_A_SIZE):            u64 size;
            (AttributeType::BTRFS_SEND_A_MODE):            u64 mode;
            (AttributeType::BTRFS_SEND_A_UID):             u64 uid;
            (AttributeType::BTRFS_SEND_A_GID):             u64 gid;
            (AttributeType::BTRFS_SEND_A_RDEV):            u64 rdev;
            (AttributeType::BTRFS_SEND_A_CTIME):           TimeSpec ctime;
            (AttributeType::BTRFS_SEND_A_MTIME):           TimeSpec mtime;
            (AttributeType::BTRFS_SEND_A_ATIME):           TimeSpec atime;
            (AttributeType::BTRFS_SEND_A_OTIME):           TimeSpec otime;
            (AttributeType::BTRFS_SEND_A_XATTR_NAME):      char xattr_name[length];
            (AttributeType::BTRFS_SEND_A_XATTR_DATA):      u8 xattr_data[length];
            (AttributeType::BTRFS_SEND_A_PATH):            char path[length];
            (AttributeType::BTRFS_SEND_A_PATH_TO):         char path_to[length];
            (AttributeType::BTRFS_SEND_A_PATH_LINK):       char path_link[length];
            (AttributeType::BTRFS_SEND_A_FILE_OFFSET):     u64 file_offset;
            (AttributeType::BTRFS_SEND_A_DATA):            u8 data[length];
            (AttributeType::BTRFS_SEND_A_CLONE_CTRANSID):  u64 clone_ctransid;
            (AttributeType::BTRFS_SEND_A_CLONE_PATH):      char clone_path[length];
            (AttributeType::BTRFS_SEND_A_CLONE_OFFSET):    u64 clone_offset;
            (AttributeType::BTRFS_SEND_A_CLONE_LEN):       u64 clone_len;
            (_):                                           std::error(std::format("unknown v1 attribute type: {} (this is a bug in the pattern)", type));
        }
    } else if (Version == 2 && is_v2_attribute_type(type)) {
        match (type) {
            (AttributeType::BTRFS_SEND_A_FALLOCATE_MODE):      u32 fallocate_mode;
            (AttributeType::BTRFS_SEND_A_FILEATTR):            u64 fileattr;
            (AttributeType::BTRFS_SEND_A_UNENCODED_FILE_LEN):  u64 unencoded_file_len;
            (AttributeType::BTRFS_SEND_A_UNENCODED_LEN):       u64 unencoded_len;
            (AttributeType::BTRFS_SEND_A_UNENCODED_OFFSET):    u64 unencoded_offset;
            (AttributeType::BTRFS_SEND_A_COMPRESSION):         u32 compression;
            (AttributeType::BTRFS_SEND_A_ENCRYPTION):          u32 encryption;
            (_):                                               std::error(std::format("unknown v2 attribute type: {} (this is a bug in the pattern)", type));
        }
    } else {
        std::error(std::format("unknown attribute type: {}", type));
    }

    std::assert($ - pre_data_pos == length,
        std::format("bad attribute length: expected {}, got {}", length, $ - pre_data_pos));
};

// Length-defined array of |Attribute|s. As the name suggests, |ByteLength| is the array length in
// bytes, not in elements.
struct Attributes<auto Version, auto ByteLength> {
    u64 end_addr = addressof(this) + ByteLength;
    Attribute<Version, end_addr> attributes[while(!std::mem::reached(end_addr))] [[inline]];
};

// The actual command structure. This is intended to be embedded inside a |Command| and
// [[inline]]d, so the user will never see the type name.
struct CommandInternal<auto Version> {
    u32 attributes_byte_length;
    CommandType type;
    u32 checksum; // CRC32C with initial seed 0
    Attributes<Version, attributes_byte_length> attributes;
};

// Wrapper structure around a CommandInternal to verify the checksum.
struct Command<auto Version> {
    CommandInternal<Version> command [[inline]];
    std::mem::Section mySection = std::mem::create_section("checksum buffer");
    std::mem::set_section_size(mySection, sizeof(command));
    std::mem::copy_value_to_section(command, mySection, 0x0);

    // The checksum needs to be computed on the entire |command|, but with its |checksum| member
    // zeroed out, so we have to copy the data into a Section and modify it.
    CommandInternal<Version> section_command @ 0x0 in mySection;
    std::assert(sizeof(command) == sizeof(section_command),
        std::format("|section_command| is the wrong size: expected {}, got {}",
            sizeof(command), sizeof(section_command)));
    section_command.checksum = 0;

    // For some reason, running the crc32 on |section_command| directly always gets the wrong value.
    u8 data[sizeof(command)] @ 0x0 in mySection;
    u32 crc32c = std::hash::crc32(data, 0 /* init */, 0x1EDC6F41 /* poly */,
        0 /* xorout */, true /* reflect_in */, true /* reflect_out */);
    std::assert(crc32c == command.checksum,
        std::format("bad command checksum: expected {}, got {}", command.checksum, crc32c));

    std::mem::delete_section(mySection);
};

struct SendStream {
    type::Magic<"btrfs-stream"> magic;
    padding[1];
    u32 version;
    std::assert(version >= 1 && version <= 2,
        std::format("Only versions 1 and 2 are currently supported (got version {})", version));
    Command<version> commands[while(!std::mem::eof())];
};

SendStream send_stream @ 0x0;
std::assert(std::mem::eof(), "Parsing did not consume whole file.");
