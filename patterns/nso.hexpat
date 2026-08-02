#pragma description Nintendo Switch NSO
#pragma author smiRaphi
#pragma magic [ 4E 53 4F 30 ?? 00 00 00 00 00 00 00 ?? 00 00 00] @ 0x00

import type.magic;

struct Data<auto size, auto name> {
    u8 tag_size = 4;
    if (tag_size > size) tag_size = size;
    u8 start[tag_size] @ $ [[name(name + ":start")]];
    padding[size]; // so the size actually shows in the table
    u8 end[tag_size] @ ($ - tag_size) [[name(name + ":end")]];
};

struct MOD0 {
    padding[4];
    u32 offset;
    $ += offset - 8;

    type::Magic<"MOD0"> magic;
    u32 dyn_offset;
    u32 bss_start_offset;
    u32 bss_end_offset;
    u32 eh_frame_hdr_start_offset;
    u32 eh_frame_hdr_end_offset;
    u32 runtime_generated_module_obj_offset;
};

bitfield Flags {
    bool TextCompress:1;
    bool RoCompress:1;
    bool DataCompress:1;
    bool TextHash:1;
    bool RoHash:1;
    bool DataHash:1;
    bool ExecuteOnlyMemory:1;
    bool UseZbicCompression:1;
    padding:24;
};
struct Header {
    type::Magic<"NSO0"> magic;
    u32 version;
    padding[4];
    Flags flags;
    u32 text_file_offset;
    u32 text_mem_offset;
    u32 text_size;
    u32 module_name_offset;
    u32 ro_file_offset;
    u32 ro_mem_offset;
    u32 ro_size;
    u32 module_name_size;
    u32 data_file_offset;
    u32 data_mem_offset;
    u32 data_size;
    u32 bss_size;
    u8 module_id[0x20];
    u32 text_file_size;
    u32 ro_file_size;
    u32 data_file_size;
    padding[0x1C];
    u32 embedded_offset;
    u32 embedded_size;
    u32 dyn_str_offset;
    u32 dyn_str_size;
    u32 dyn_sym_offset;
    u32 dyn_sym_size;
    u8 text_hash[0x20];
    u8 ro_hash[0x20];
    u8 data_hash[0x20];

    char module_name[module_name_size] @ module_name_offset;

    Data<text_file_size,".text"> text @ text_file_offset [[name(".text")]];
    Data<ro_file_size,".rodata"> ro @ ro_file_offset [[name(".rodata")]];
    Data<data_file_size,".data"> data @ data_file_offset [[name(".data")]];

    if (!flags.TextCompress) MOD0 mod0 @ text_file_offset;
};

Header header @ 0;
