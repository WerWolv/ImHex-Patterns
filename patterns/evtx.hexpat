#pragma endian little

struct Header {
	char Signature[0x8];
    u64 First_chunk_number;
    u64 Last_chunk_number;
    u64 Next_record_identifier;
	u32 Header_size;
	u16 Minor_format_version;
	u16 Major_format_version;
    u16 Header_block_size;
	u16 Number_of_chunks;
	u8 Unknown[0x4C];
    u32 File_Flag;
    u32 CheckSum;
    u8 Unknown2[3968];
};

struct BinaryXML{
    u8 Fragment_header_token;
    u8 Major_version;
    u8 Minor_version;
    u8 Flags;
};

struct Event_Record{
    u32 Signature;
    u32 Size;
    u64 Event_record_identifier;
    u64 Written_data_amd_time;
    BinaryXML binaryxml;
};

struct Chunk{
   	char Signature[0x8];
   	u64 First_event_record_number;
   	u64 Last_event_record_number;
   	u64 First_event_record_identifier;
   	u64 Last_event_record_identifier;
   	u32 Header_size;
   	u32 Last_event_record_data_offset;
    u32 Free_space_offset;
    u32 Event_records_checksum;
    u8 Unknown[64];
    u32 Unknown2;
    u32 Checksum;
    u8 Common_string_offset_array[256];
    u8 TemplatePtr[128];
    Event_Record event_record;
};

struct Evtx {
    Header header;
    Chunk chunk;
};

Evtx evtx @ 0x00;
