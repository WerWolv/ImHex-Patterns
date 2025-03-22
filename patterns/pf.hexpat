#pragma author MrMcX
#pragma description Parse forensically relevant parts of Windows Prefetch(*.pf) (only uncompressed SCCA version)
/*
The pattern implements the uncompressed SCCA format which is used below Windows 10.
For the newer compressed file format starting with "MAM\x04" has to be decompressed first,
for example using the at https://gist.github.com/dfirfpi/113ff71274a97b489dfd

Thanks to Joachim Metz for his work that this pattern is heavily based on:
https://github.com/libyal/libscca/blob/main/documentation/Windows%20Prefetch%20File%20(PF)%20format.asciidoc
Unknown values commented with "jm:" refer to Joachim Metz' format analysis
*/

#pragma magic [0x54 0x43 0x43 0x41] @ 0x04

#pragma endian little
import std.mem;
import std.string;
import type.time;
import type.magic;

enum WinVer : u32 {
    Windows11 = 31,
    Windows10 = 30,
    Windows8x = 26,
    Windows7orVista = 23,
    WindowsXPor2003 = 17
};

enum Flag : u32 {
    Boot = 0x01,
    Application =0x00
};

fn to_HexString32(u32 value) {
    return std::string::to_upper(std::format("{:08x}", value));
};

using HexString32 = u32 [[format("to_HexString32")]];

struct Header {
    WinVer version;
    type::Magic<"SCCA"> signature;
    u32;
    u32 size;
    char16 program_name[30];
    HexString32 crc_hash;
    Flag flag;
};

struct FileInformation {
    u32 metrics_offset;
    u32 metrics_entry_count;
    u32 trace_chains_offset;
    u32 trace_chains_entry_count;
    u32 filenames_offset;
    u32 filenames_size;
    u32 volumes_information_offset;
    u32 volumes_count;
    u32 volumes_information_size;
    if(header.version >= WinVer::Windows7orVista) {
        padding[8];
    }
    // Times are in FILETIME format (now shown as unix timestamp)
    type::FILETIME last_execution;
    if(header.version >= WinVer::Windows8x) {
        type::FILETIME prev_executions[7];
    }
    if(header.version <= WinVer::Windows10) {
        u128;
    } else {
        u64;
    }
    u32 run_count;
    u32;
    u32 hash_string_offset = 0x0;
    u32 hash_string_size = 0;
    if(header.version >= WinVer::Windows10) {
        u32;
        u32 hash_string_offset;
        u32 hash_string_size;
        padding[76];        
    } else if(header.version == WinVer::Windows8x) {
        u32;
        padding[84];
    } else if(header.version == WinVer::Windows7orVista) {
        padding[80];   
    }
};

struct FileReference {
    u48 mft_entry_index;
    u16 sequence_number;
};

struct FileMetric {
    u32;                    // jm: might be prefetch start time in ms or index into the trace chain array
    u32;                    // jm: might be prefetch duration in ms or number of entries in the trace chain
    if(header.version >= WinVer::Windows7orVista) {
        u32;                // jm: might be Average prefetch duration in ms?
    }
    u32 filename_string_offset;
    u32 filename_string_length;
    u32 flags;
    if(header.version >= WinVer::Windows7orVista) {
        FileReference file_reference;
    }
};

struct TraceChain {
    if(header.version <= WinVer::Windows8x) {
        u32 next_array_entry_index;
    }
    u32 total_block_load_count;
    u8;
    u8;                 // jm: might be sample duration in ms
    u16;
};

struct DirectoryString {
    u16 length;
    char16 value[length+1];
};

struct VolumeInformation {
    auto vi_start = $;
    u32 volume_device_path_offset;
    u32 volume_device_path_length;
    type::FILETIME volume_creation_time;
    HexString32 volume_serial_number;
    u32 file_references_offset;
    u32 file_references_size;
    u32 directory_strings_offset;
    u32 directory_strings_count;
    u32;     
    if(header.version >= WinVer::Windows7orVista) {
        padding[(header.version >= WinVer::Windows10) ? 24 : 28];
        u32;                // jm: might be copy of the number of directory strings
        padding[(header.version >= WinVer::Windows10) ? 24 : 28];
        u32;
    }
    $ = vi_start + volume_device_path_offset;
    char16 volume_device_path[volume_device_path_length];
    $ = vi_start + file_references_offset;
    u32 file_reference_version;
    u32 file_reference_count;
    if(header.version >= WinVer::Windows7orVista) {
        u64;
    }
    FileReference file_references[file_reference_count];
    $ = vi_start + directory_strings_offset;
    DirectoryString directory_strings[directory_strings_count];
};

Header header @ 0x00;
FileInformation info @ 0x54;
FileMetric metrics[info.metrics_entry_count] @ info.metrics_offset;
TraceChain trace_chains[info.trace_chains_entry_count] @ info.trace_chains_offset;
std::string::NullString16 filenames[while(!std::mem::reached(info.hash_string_offset))] @ info.filenames_offset;
// executable_path should be empty below windows 10
char16 executable_path[(info.hash_string_size / 2) - 1] @ info.hash_string_offset;
VolumeInformation volume_informations[info.volumes_count] @ info.volumes_information_offset;
