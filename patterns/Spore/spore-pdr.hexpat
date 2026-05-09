


#pragma author 0KepOnline
#pragma description Spore EAPd Resource (Binary Patch)

#pragma magic [45 41 50 44] @ 0x00
#pragma endian little

import std.mem;
import std.string;
import std.sys;

// "pd"
#define pd 0x6470
// "snr"
#define snr 0x726e73

#define default_version 3



// Universal parser for strings (both names and hashes)
fn parse_string(auto value) {
    u8 byte = 0;
    try {
        return parse_string(value.text);
    }
    catch {
        try {
            return parse_string(value.data);
        }
        catch {
            try {
                byte = u8(value[0]);
                u32 length = std::string::length(value);
                while (length > 0 && std::string::at(value, length - 1) == ' ') length = length - 1;
                return std::string::to_string(std::string::substr(value, 0, length));
            }
            catch {
                str result = "";
                for (u32 i = 0, i < sizeof(value), i = i + 1) {
                    byte = u8((value >> (i * 8)) & 0xff);
                    if (byte < 0x20) break;
                    result = result + char(byte);
                }
                return result;
            }
        }
    }
    return "";
};

// 4-byte strings that are treated as numbers in the EAPd code
union str32_t {
    u32 number;
    char text[4];
} [[sealed]];

// Universal parser for versions (see which value v1 uses to find out why)
fn parse_version(auto value) {
    str32_t version;
    try {
        version.number = u32(value);
    }
    catch {
        try {
            version.number = u32(value.value);
        }
        catch {
            return default_version;
        }
    }
    if (version.text == " 1.0") return 1;
    return version.number;
};

// 4-byte EAPd Binary Patch version number, similar to str32_t (see which value v1 uses to find out why)
union version_t {
    u32 value [[hidden]];
    if (parse_version(value) == 1) char text[4];
    else u32 number;
} [[sealed]];

// Platform type (from "PlatformType" enum)
enum platform_t: s32 {
    NONE, // Likely unused?
    GENERIC,
    WINDOWS, // The only known platform type so far
    XENON, // Xbox 360?
    PS3,
    REVOLUTION // Wii?
};

// Fancy platform names
fn parse_platform(auto platform) {
    match (platform) {
        (0): return "None";
        (1): return "Generic";
        (2): return "Windows";
        (3): return "Xenon";
        (4): return "PlayStation 3";
        (5): return "Revolution";
    }
    return "Unknown";
};

// .pdr header
struct header_t {
    char signature[4] [[name("Signature"), comment("EAPd signature/magic")]];
    version_t version [[format("parse_version"), name("Version"), comment("EAPd Binary Patch version")]];
    platform_t platform [[format("parse_platform"), name("Platform"), comment("EAPd Binary Patch platform type"), color("a0a0a0")]];
    u32 length [[name("Length"), comment("Full length, including signature and header"), color("a000a0")]];
    u32 patch_count [[name("Patch Count"), comment("Number of EAPd patches stored inside a Binary Patch")]];
    u32 sample_count [[name("Sample Count"), comment("Number of SNR/SNS audio samples stored inside a Binary Patch")]];
};

// Join the asset name and hash, treating it as a file extension
fn get_asset_name(ref auto asset) {
    try {
		if (parse_string(asset.hash) != "") return parse_string(asset.name) + "." + parse_string(asset.hash);
		else return parse_string(asset.name);
    }
    catch {
        return parse_string(asset.name);
    }
    return "";
};

// Length + Payload; same for all versions
struct asset_chunk_t {
    u32 length [[name("Asset Data Length"), comment("Length of data of an asset")]];
    u8 data[length] [[name("Asset Data"), sealed, comment("Raw data of an asset")]];
} [[inline]];

// Asset record: v1 (1.0)
struct asset_v1_t<auto predefined_hash> {
    char name[0x19] [[format("parse_string"), name("Asset Name"), comment("Unique name that is used both internally (by EAPd engine) and externally (in patches)")]];
    asset_chunk_t chunk;
    auto hash = predefined_hash;
} [[name(get_asset_name(this))]];

// Asset record: v2
struct asset_v2_t<auto predefined_hash> {
    std::string::NullString name [[format("parse_string"), name("Asset Name"), comment("Unique name that is used both internally (by EAPd engine) and externally (in patches)")]];
    asset_chunk_t chunk;
    auto hash = predefined_hash;
} [[name(get_asset_name(this))]];

// Asset record: v3
struct asset_v3_t {
    std::string::SizedString<u32> name [[format("parse_string"), name("Asset Name"), comment("Unique name that is used both internally (by EAPd engine) and externally (in patches)")]];
    str32_t hash [[format("parse_string"), name("Asset Hash"), comment("Hardcoded value that determines the type of an asset")]];
    asset_chunk_t chunk;
} [[name(get_asset_name(this))]];



struct EAPdResource {
    header_t header [[name("Header"), comment("EAPd Resource Header")]];
    u32 version = parse_version(header.version);
    s32 platform = header.platform;
    std::assert(platform == 2, std::format("Unsupported EAPd Binary Patch platform ({}): only Windows (2) is supported for now", version));
    match (version) {
        (1): {
            asset_v1_t<pd> patches[header.patch_count] [[name("Patches"), comment("Pd Patches")]];
            asset_v1_t<snr> samples[header.sample_count] [[name("Samples"), comment("SNR/SNS Audio Samples")]];
        }
        (2): {
            asset_v2_t<pd> patches[header.patch_count] [[name("Patches"), comment("Pd Patches")]];
            asset_v2_t<snr> samples[header.sample_count] [[name("Samples"), comment("SNR/SNS Audio Samples")]];
        }
        (3): {
            asset_v3_t patches[header.patch_count] [[name("Patches"), comment("Pd Patches")]];
            asset_v3_t samples[header.sample_count] [[name("Samples"), comment("SNR/SNS Audio Samples")]];
        }
        (_): std::assert(version >= 1 && version <= 3, std::format("Unsupported EAPd Binary Patch version ({})", version));
    }
};

EAPdResource eapdResource @0x00 [[name("EAPd Resource")]];
