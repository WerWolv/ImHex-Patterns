#pragma description MS Windows Vista Event Log
#pragma MIME application/x-ms-evtx
#pragma endian little

struct Header {
    char signature[0x8];
    u64  first_chunk_number;
    u64  last_chunk_number;
    u64  next_record_identifier;
    u32  header_size;
    u16  minor_format_version;
    u16  major_format_version;
    u16  header_block_size;
    u16  number_of_chunks;
    u8   unknown[0x4C];
    u32  file_Flag;
    u32  checkSum;
    u8   unknown2[3968];
};

struct BinaryXML{
    u8 fragment_header_token;
    u8 major_version;
    u8 minor_version;
    u8 flags;
};

struct Event_Record{
    u32 signature;
    u32 size;
    u64 event_record_identifier;
    u64 written_data_amd_time;
    BinaryXML binaryxml;
};

struct Chunk{
    char signature[0x8];
    u64 first_event_record_number;
    u64 last_event_record_number;
    u64 first_event_record_identifier;
    u64 last_event_record_identifier;
    u32 header_size;
    u32 last_event_record_data_offset;
    u32 free_space_offset;
    u32 event_records_checksum;
    u8 unknown[64];
    u32 unknown2;
    u32 checksum;
    u8 common_string_offset_array[256];
    u8 templatePtr[128];
    Event_Record event_record;
};

struct Evtx {
    Header header;
    Chunk chunk;
};

Evtx evtx @ 0x00;
