#pragma author bwrsandman
#pragma description Microsoft debugging files

#pragma little
#pragma MIME application/x-ms-pdb

import std.math;
import std.mem;
import std.string;
import type.guid;
import type.magic;

enum MsfVersion : u8 {
    SmallMsf,
    BigMsf,
};

u16 globalPageSize = 0;
MsfVersion globalVersion = MsfVersion::BigMsf;

// https://github.com/WerWolv/ImHex-Patterns/issues/499
fn null_string_len(auto buf) {
    u32 i = 0;
    while (buf[i] != 0) {
        i += 1;
    }
    return i + 1;
};

// https://github.com/WerWolv/ImHex-Patterns/issues/499
struct NullStringWorkAround {
    u8 buf[1024] @ $ [[hidden]];
    char data[null_string_len(buf) - 1];
    u8 null_chr [[hidden]];
} [[sealed, format("std::string::impl::format_string"), transform("std::string::impl::format_string")]];

fn divide_round_up(u32 size, u32 page_size) {
    return std::mem::align_to(page_size, size) / page_size;
};

fn get_sum(auto arr) {
    u32 sum = 0;
    for (u32 i = 0, i < sizeof(arr) / sizeof(arr[0]), i += 1)
        sum += arr[i];
    return sum;
};

fn get_stream_num_pages(u32 size) {
    if (size == 0xFFFFFFFF) {
        return 0;
    }
    return divide_round_up(size, globalPageSize);
};

fn copy_pages_to_section(std::mem::Section section, ref u32 page_indices, u32 count) {
    std::mem::set_section_size(section, count * globalPageSize);
    for (u32 i = 0, i < count, i += 1) {
        std::mem::copy_section_to_section(null, page_indices[i] * globalPageSize, section, i * globalPageSize, globalPageSize);
    }
};

fn get_stream_size(ref auto stream_dir, u32 index) {
    match (globalVersion) {
        (MsfVersion::SmallMsf): return stream_dir.streams[index].stream_size;
        (MsfVersion::BigMsf): return stream_dir.stream_sizes[index];
    }
};

enum PdbStreamVersion : u32
{
    VC2 = 19941610,
    VC4 = 19950623,
    VC41 = 19950814,
    VC50 = 19960307,
    VC98 = 19970604,
    VC70Dep = 19990604,
    VC70 = 20000404,
    VC80 = 20030901,
    VC110 = 20091201,
    VC140 = 20140508,
};

enum PdbFeatureSig : u32 {
    VC110 = 20091201,
    VC140 = 20140508,
    NoTypeMerge = 0x4D544F4E,
    MinimalDebugInfo = 0x494E494D,
};

enum TypeStreamVersion : u32
{
    V40 = 19950410,
    V41 = 19951122,
    V50Interim = 19960307,
    V50 = 19961031,
    V70 = 19990903,
    V80 = 20040203,
};

enum TypeRecordKind : u16 {
  LF_MODIFIER = 0x1001,
  LF_POINTER = 0x1002,
  LF_PROCEDURE = 0x1008,
  LF_ARGLIST = 0x1201,
  LF_FIELDLIST = 0x1203,
  LF_BITFIELD = 0x1205,
  LF_INDEX = 0x1404,
  LF_ENUMERATE = 0x1502,
  LF_ARRAY = 0x1503,
  LF_CLASS = 0x1504,
  LF_STRUCTURE = 0x1505,
  LF_UNION = 0x1506,
  LF_ENUM = 0x1507,
  LF_MEMBER = 0x150d,
  LF_FUNC_ID = 0x1601,
  LF_CHAR = 0x8000,
  LF_SHORT = 0x8001,
  LF_USHORT = 0x8002,
  LF_LONG = 0x8003,
  LF_ULONG = 0x8004,
  LF_QUADWORD = 0x8009,
  LF_UQUADWORD = 0x800a
};

enum DbiStreamVersion : u32 {
    V41 = 930803,
    V50 = 19960307,
    V60 = 19970606,
    V70 = 19990903,
    V110 = 20091201
};

enum SectionContribSubstreamHeaderVersion: u32 {
    V60 = 0xeffe0000 + 19970605,
    V2 = 0xeffe0000 + 20140516,
};

struct MsfFileHeader<auto version> {
    if (version == MsfVersion::SmallMsf) {
        type::Magic<"Microsoft C/C++ program database 2.00\x0d\x0a\x1a\x4a\x47\x00\x00"> magic;
    }
    else if (version == MsfVersion::BigMsf) {
        type::Magic<"Microsoft C/C++ MSF 7.00\x0d\x0a\x1a\x44\x53\x00\x00\x00"> magic;
    }
    u32 page_size;
    globalPageSize = page_size;
    if (version == MsfVersion::SmallMsf) {
        u16 active_fpm;
        u16 num_pages;
    }
    else if (version == MsfVersion::BigMsf) {
        u32 active_fpm;
        u32 num_pages;
    }
    u32 stream_dir_size;
    u32 small_stream_pages_map;
    u32 num_stream_dir_pages = divide_round_up(stream_dir_size, page_size);
    if (version == MsfVersion::SmallMsf) {
        u32 num_stream_pages_map = num_stream_dir_pages;
    }
    else if (version == MsfVersion::BigMsf) {
        u32 num_stream_pages_map = divide_round_up(num_stream_dir_pages * sizeof(u32), page_size);
    }
    u32 stream_pages_map[num_stream_pages_map];
    u8 pad[std::mem::align_to(globalPageSize, sizeof(this)) - sizeof(this)] [[export]];
};

struct SmallStreamEntry {
    u32 stream_size;
    u32 ignored;
};

struct StreamDirectory<auto stream_dir_size> {
    if (globalVersion == MsfVersion::SmallMsf) {
        u16 num_streams;
        padding[2];
        SmallStreamEntry streams[num_streams];
        u16 stream_pages[stream_dir_size / sizeof(num_streams) - 1 - num_streams];
    }
    else if (globalVersion == MsfVersion::BigMsf) {
        u32 num_streams;
        u32 stream_sizes[num_streams];
        u32 stream_pages[stream_dir_size / sizeof(num_streams) - 1 - num_streams];
    }
};

struct SmallStreamDirectory<auto stream_dir_size> {
    u16 num_streams;
    padding[2];
    SmallStreamEntry streams[num_streams];
    u16 stream_pages[stream_dir_size / sizeof(u16) - 1 - num_streams];
};

struct BigStreamDirectory<auto stream_dir_size> {
    u32 num_streams;
    u32 stream_sizes[num_streams];
    u32 stream_pages[stream_dir_size / sizeof(num_streams) - 1 - num_streams];
};

fn compute_stream_page_offset(ref auto stream_dir, u32 n) {
    u32 total = 0;
    for (u32 i = 0, i < n, i += 1) {
        total += get_stream_num_pages(get_stream_size(stream_dir, i));
    }
    return total;
};

struct StreamSection<T, auto stream_dir_section, auto stream_section, auto stream_dir, auto stream_index> {
    u32 stream_page_offset = stream_dir.stream_pages[compute_stream_page_offset(stream_dir, stream_index)];
    u32 stream_size = get_stream_size(stream_dir, stream_index);
    u32 num_pages = get_stream_num_pages(stream_size);

    if (stream_size > 0)
    {
        std::mem::set_section_size(stream_section, stream_size);
        std::mem::copy_section_to_section(null, stream_page_offset * globalPageSize, stream_section, 0, stream_size);
        T stream @ 0x00 in stream_section [[export, comment(num_pages > 1 ? std::format("Pages {} to {}", stream_page_offset, stream_page_offset + num_pages - 1) : std::format("Page {}", stream_page_offset))]];
    }
};

struct Page {
    padding[globalPageSize];
};

struct PdbStreamHeader {
    PdbStreamVersion version;
    s32 signature;
    u32 age;
    if (version > PdbStreamVersion::VC70Dep) {
        type::GUID unique_guid;
    }
};

struct HashEntry {
    u32 key;
    u32 value;
};

struct NamedStreams {
    u32 keys_size;
    u8 keys_data[keys_size];
    u32 num_names;
    u32 hash_size;
    u32 present_mask_size;
    u32 present_mask[present_mask_size];
    u32 deleted_mask_size;
    u32 deleted_mask[deleted_mask_size];
    HashEntry hash_entries[num_names];
    u32 num_name_index;
    u32 name_indexes[num_name_index];
};

struct PdbStream<auto size> {
    PdbStreamHeader header;
    NamedStreams named_streams;
    PdbFeatureSig feature_codes[while(!std::mem::reached(size))];
};

struct TypeStreamHeader {
    TypeStreamVersion version;
    u32 header_size;
    u32 type_index_begin;
    u32 type_index_end;
    u32 type_record_bytes;
    u16 hash_stream_index;
    u16 hash_aux_stream_index;
    u32 hash_key_size;
    u32 num_hash_buckets;
    s32 hash_value_buffer_offset;
    u32 hash_value_buffer_length;
    s32 index_offset_buffer_offset;
    u32 index_offset_buffer_length;
    s32 hash_adj_buffer_offset;
    u32 hash_adj_buffer_length;
};

struct TypeRecordHeader {
    u16 size;
    TypeRecordKind kind;
    u8 kind_specific_data[std::math::max(0, size - sizeof(size) - sizeof(kind))];
    u8 pad[std::mem::align_to(4, sizeof(this)) - sizeof(this)] [[export]];
};

struct TypeStream {
    TypeStreamHeader header;
    TypeRecordHeader type_records[while(!std::mem::reached(sizeof(header) + header.type_record_bytes))];
};

struct ItemStream<auto size> {
    if (globalVersion == MsfVersion::BigMsf)
        TypeStreamHeader header;
    // TODO: pad to go away once the rest is decoded
    u8 pad[size] [[export]];
};

struct DbiStreamHeader {
    type::Magic<"\xff\xff\xff\xff"> signature;
    DbiStreamVersion version;
    u32 age;
    u16 global_symbol_index_stream;
    u16 build_number;
    u16 public_symbol_index_stream;
    u16 pdb_dll_version;
    u16 global_symbol_stream;
    u16 pdb_dll_rbld;
    s32 module_info_size;
    s32 section_contributions_size;
    s32 section_map_size;
    s32 source_info_size;
    s32 type_server_map_size;
    u32 mfc_type_server_index;
    s32 optional_debug_header_size;
    s32 edit_and_continue_size;
    u16 flags;
    u16 machine;
    padding[4];
};

struct DbiSectionContribEntry {
    u16 section;
    padding[2];
    s32 offset;
    s32 size;
    u32 characteristics;
    u16 module_index;
    padding[2];
    u32 data_crc;
    u32 reloc_crc;
};

struct DbiSectionContribEntry2 {
    u16 section;
    padding[2];
    s32 offset;
    s32 size;
    u32 characteristics;
    u16 module_index;
    padding[2];
    u32 data_crc;
    u32 reloc_crc;
    u32 coff_section;
};

bitfield DbiModuleInfoFlags {
    bool written: 1;
    bool ec_enabled: 1;
    padding: 6;
    u8 tsm_index; 
};

fn strlen_in_section(u128 addr, std::mem::Section section) {
    u32 len = 0;
    while (std::mem::read_unsigned(addr + len, 1, section) != 0x00)
        len += 1;
    return len;
};

struct DbiModuleInfo {
    u32 old_module_index;
    DbiSectionContribEntry section_contrib;
    DbiModuleInfoFlags flags;
    u16 stream;
    u32 sym_byte_size;
    u32 c11_byte_size;
    u32 c13_byte_size;
    u16 source_file_count;
    padding[2];
    u32 unused2;
    u32 source_file_name_index;
    u32 pdb_file_path_name_index;
    NullStringWorkAround module_name;
    NullStringWorkAround obj_file;
    u8 pad[std::mem::align_to(4, sizeof(this)) - sizeof(this)] [[export]];
};

struct DbiModulesSubstream {
    DbiModuleInfo entries[while($ < addressof(this) + parent.header.module_info_size)];
};

struct DbiSectionContributionsSubstream {
    SectionContribSubstreamHeaderVersion version;
    match (version) {
        (SectionContribSubstreamHeaderVersion::V60): DbiSectionContribEntry contribs[(parent.header.section_contributions_size - sizeof(version)) / sizeof(DbiSectionContribEntry)];
        (SectionContribSubstreamHeaderVersion::V2): DbiSectionContribEntry2 contribs[(parent.header.section_contributions_size - sizeof(version)) / sizeof(DbiSectionContribEntry2)];
    }
};

bitfield DbiSectionMapEntryFlags {
    bool Read: 1;
    bool Write: 1;
    bool Execute: 1;
    bool AddressIs32Bit: 1;
    padding: 4;
    bool IsSelector: 1;
    bool IsAbsoluteAddress: 1;
    bool IsGroup: 1;
};

struct DbiSectionMapEntry {
    DbiSectionMapEntryFlags flags;
    u16 overlay;
    u16 group;
    u16 frame;
    u16 section_name;
    u16 class_name;
    u32 offset;
    u32 section_length;
};

struct DbiSectionMapSubstream {
    u16 num_segments;
    u16 num_logical_segments;
    DbiSectionMapEntry entries[while($ < addressof(this) + parent.header.section_map_size)];
};

struct DbiSourcesSubstream {
    u16 num_modules;
    u16 num_sources;
    u16 module_file_starts[num_modules];
    u16 module_file_counts[num_modules];
    u32 file_offsets[get_sum(module_file_counts)];
    u8 names_buffer[parent.header.source_info_size - sizeof(this)];
};

struct DbiTypeServerEntry {
    u32 signature;
    u32 age;
    u16 stream;
    NullStringWorkAround pdb_path;
};

struct DbiTypeServerMapSubstream {
    if (parent.header.type_server_map_size) {
        u32 count;
        DbiTypeServerEntry entries[count];
    }
};

struct NamesMapEntry {
    u32 offset;
};

struct DbiEditAndContinueSubstream {
    type::Magic<"\xfe\xef\xfe\xef"> signature;
    u32 hash_version;    // 1 or 2
    u32 strings_size;
    char strings[strings_size];
    u32 bucket_count;
    NamesMapEntry buckets[bucket_count];
    u32 names_count;
};

struct DbiOptionalDebugHeaderSubstream {
    u16 fpo_data;
    u16 exception_data;
    u16 fixup_data;
    u16 omap_to_src;
    u16 omap_from_src;
    u16 section_header_data;
    u16 token_rid_map;
    u16 xdata;
    u16 pdata;
    u16 new_fpo_data;
    u16 original_section_header_data;
};

struct DbiStream {
    DbiStreamHeader header;
    DbiModulesSubstream modules;
    DbiSectionContributionsSubstream section_contributions;
    DbiSectionMapSubstream section_map;
    DbiSourcesSubstream sources;
    DbiTypeServerMapSubstream type_server_map;
    DbiEditAndContinueSubstream edit_and_continue;
    DbiOptionalDebugHeaderSubstream optional_debug_header;
};

struct MsfFile {
    try {
        MsfVersion version = MsfVersion::SmallMsf [[export]];
        MsfFileHeader<version> header;
    }
    catch {
        MsfVersion version = MsfVersion::BigMsf [[export]];
        MsfFileHeader<version> header;
    }
    globalVersion = version;

    if (version == MsfVersion::SmallMsf) {
        u32 stream_dir_page_indices[header.num_stream_dir_pages] @ addressof(header.stream_pages_map);
    }
    else if (version == MsfVersion::BigMsf ){
        u128 stream_dir_map_section = std::mem::create_section("Stream Pages Map");
        copy_pages_to_section(stream_dir_map_section, header.stream_pages_map, header.num_stream_pages_map);
        u32 stream_dir_page_indices[header.num_stream_dir_pages] @ 0x00 in stream_dir_map_section;
    }

    std::mem::Section stream_dir_section = std::mem::create_section("Stream Directory");
    copy_pages_to_section(stream_dir_section, stream_dir_page_indices, header.num_stream_dir_pages);

    StreamDirectory<header.stream_dir_size> stream_dir @ 0x00 in stream_dir_section;
        
    u32 pdb_pages = get_stream_num_pages(get_stream_size(stream_dir, 1));
    u32 tpi_pages = get_stream_num_pages(get_stream_size(stream_dir, 2));
    u32 dbi_pages = get_stream_num_pages(get_stream_size(stream_dir, 3));
    u32 ipi_pages = get_stream_num_pages(get_stream_size(stream_dir, 4));
    
    std::mem::Section pdb_section = std::mem::create_section("PDB Information");
    StreamSection<PdbStream<get_stream_size(stream_dir, 1)>, stream_dir_section, pdb_section, stream_dir, 1> pdb;

    std::mem::Section tpi_section = std::mem::create_section("Type Information");
    StreamSection<TypeStream, stream_dir_section, tpi_section, stream_dir, 2> tpi; 
  
    std::mem::Section dbi_section = std::mem::create_section("Debug Information");
    StreamSection<DbiStream, stream_dir_section, dbi_section, stream_dir, 3> dbi;

    std::mem::Section ipi_section = std::mem::create_section("Item Information");
    StreamSection<ItemStream<get_stream_size(stream_dir, 4)>, stream_dir_section, ipi_section, stream_dir, 4> ipi;

    Page pages[header.num_pages] @ 0;
};

MsfFile file @ 0;
