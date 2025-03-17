#pragma magic [ 50 41 47 45 ] @ 0x00 // PAGE 
#pragma author "5h4rrK"
#pragma description "KERNEL DUMP"

import std.core;
import std.io;
import std.array;

#define COMMENT_SIZE 0x80

fn format_values(auto val){
    return std::format("{:#x}", val);
};

fn format_size_values(auto val){
    return std::format(
        "{:#x} ({}) ",
        val,
        std::format("{:#x}",val * 0x1000)
    );

};

union DUMP_FILE_ATTRIBUTES {
    u32 bitfields[[name("BitFields")]];
    u32 attributes[[name("Attributes")]];
};

enum DUMP_TYPE : u32 {
    FULL_DUMP = 0x01,
    BITMAP_DUMP = 0x05
};

struct EXCEPTION_RECORD64
{
    u32 exception_code[[name("ExceptionCode"), format("format_values")]];
    u32 exception_flags[[name("ExceptionFlags"), format("format_values")]];
    u64 exception_record[[name("ExceptionRecord"), format("format_values")]];
    u64 exception_address[[name("ExceptionAddress"), format("format_values")]];
    u32 number_parameters[[name("NumberParameters"), format("format_values")]];
    u32 unused_alignment[[name("Alignment"), format("format_values")]];
    u64 exception_information[15][[name("ExceptionInformation")]];
}; 

struct PHYSICAL_MEMORY_RUN64 {
    u64 base_page [[ name("BasePage"), format("format_size_values"),   comment("StartOffset = BasePage * PageSize")]];
    u64 page_count[[ name("PageCount"),format("format_size_values"),  comment("Length = PageCount * PageSize")]];
}[[name("PHYSICAL_MEMORY_RUN_ENTRY")]];

struct PHYSICAL_MEMORY_DESCRIPTOR64 {
    u32  no_of_runs [[name("NumberOfRuns")]];
    char description[4][[name("Description")]];
    u64  no_of_pages[[name("NumberOfPages"),format("format_values")]];
    // PHYSICAL_MEMORY_RUN64 pmr64[no_of_runs] [[name("PHYSICAL_MEMORY_RUN64")]];
    std::Array<PHYSICAL_MEMORY_RUN64, no_of_runs> pmrObjs[[name("PHYSICAL_MEMORY_RUN64")]];

};

struct DUMP_HEADER64 {
    char signature[4][[name("Signature")]];
    char validdump[4][[name("ValidDump")]];
    u32  major_version[[name("MajorVersion")]];
    u32  minor_version[[name("MinorVersion")]];
    u64  dtb [[name("DirectoryBaseTable"),format("format_values")]];
    u64  pfn [[name("PfnDataBase"), format("format_values")]];
    u64  ploadedmodulelist [[name("PsLoadedModuleList"), format("format_values")]];
    u64  pactiveprocesshead [[name("PsActiveProcessHead"), format("format_values")]];
    u32  machine_type [[name("MachineImageType"), format("format_values")]];
    u32  processor_counts [[name("ProcessorsCount")]];
    u32  bug_check [[name("BugCheckCode"), format("format_values")]];
    u32  bug_check_code_desc[[name("BugCheckCodeDescription"), format("format_values")]];
    u64  bug_check_param1[[name("BugCheckCodeParameter1"), format("format_values")]];
    u64  bug_check_param2[[name("BugCheckCodeParameter2"), format("format_values")]];
    u64  bug_check_param3[[name("BugCheckCodeParameter3"), format("format_values")]];
    u64  bug_check_param4[[name("BugCheckCodeParameter4"), format("format_values")]];
    char version_user[0x20][[name("VersionUser")]];
    u64  kdbg[[name("KdDebuggerDataBlock"), format("format_values")]];
    PHYSICAL_MEMORY_DESCRIPTOR64 phys_mem_desc[[name("PHYSICAL_MEMORY_DESCRIPTOR64")]];
    char mem_block_buffer[0x260][[name("PhysicalMemoryBlockBuffer")]];
    char context_record[0xbb8][[name("ContextRecord")]];
    EXCEPTION_RECORD64 excr[[name("EXCEPTION_RECORD64")]];
    DUMP_TYPE dmp_type[[name("DumpType")]];
    char desc1[4][[name("Description")]];
    u64 req_dump_space[[name("RequiredDumpSpace"), format("format_values")]];
    u64 sys_time[[name("SystemTime"), format("format_values")]];
    char comment[COMMENT_SIZE][[name("Comment")]];
    u64 sys_up_time[[name("SystemUpTime"), format("format_values")]];
    u32 min_dmp_fields[[name("MiniDumpFields"), format("format_values")]];
    u32 sec_data_state[[name("SecondaryDataState"), format("format_values")]];
    u32 product_type[[name("ProductType"), format("format_values")]];
    u32 suite_mask[[name("SuiteMask"), format("format_values")]];
    u32 writer_status[[name("WriterStatus"), format("format_values")]];
    char unused1[[name("Unused1")]];
    char secondary_version[[name("KdSecondaryVersion")]];
    char unused2[2][[name("Unused2")]];
    DUMP_FILE_ATTRIBUTES dfa[[name("DUMP_FILE_ATTRIBUTES")]];
    u32 boot_id[[name("BootId")]];
    char reserved[0xfa8][[name("Reserved")]];

};

DUMP_HEADER64 dmp @ 0x00 [[name("DumpHeader")]];
