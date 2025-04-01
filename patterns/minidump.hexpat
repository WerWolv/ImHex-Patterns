#pragma author WerWolv
#pragma description Windows MiniDump

#pragma MIME application/x-dmp

import type.time;
import type.types.win32;
import type.size;

using RVA = ULONG32;
using RVA64 = ULONG64;

enum MINIDUMP_STREAM_TYPE : ULONG32 {
    UnusedStream                = 0,
    ReservedStream0             = 1,
    ReservedStream1             = 2,
    ThreadListStream            = 3,
    ModuleListStream            = 4,
    MemoryListStream            = 5,
    ExceptionStream             = 6,
    SystemInfoStream            = 7,
    ThreadExListStream          = 8,
    Memory64ListStream          = 9,
    CommentStreamA              = 10,
    CommentStreamW              = 11,
    HandleDataStream            = 12,
    FunctionTableStream         = 13,
    UnloadedModuleListStream    = 14,
    MiscInfoStream              = 15,
    MemoryInfoListStream        = 16,
    ThreadInfoListStream        = 17,
    HandleOperationListStream   = 18,
    TokenStream                 = 19,
    JavaScriptDataStream        = 20,
    SystemMemoryInfoStream      = 21,
    ProcessVmCountersStream     = 22,
    IptTraceStream              = 23,
    ThreadNamesStream           = 24,
    ceStreamNull                = 0x8000,
    ceStreamSystemInfo          = 0x8001,
    ceStreamException           = 0x8002,
    ceStreamModuleList          = 0x8003,
    ceStreamProcessList         = 0x8004,
    ceStreamThreadList          = 0x8005,
    ceStreamThreadContextList   = 0x8006,
    ceStreamThreadCallStackList = 0x8007,
    ceStreamMemoryVirtualList   = 0x8008,
    ceStreamMemoryPhysicalList  = 0x8009,
    ceStreamBucketParameters    = 0x800A,
    ceStreamProcessModuleMap    = 0x800B,
    ceStreamDiagnosisList       = 0x800C,
    LastReservedStream          = 0xFFFF
};

struct MINIDUMP_LOCATION_DESCRIPTOR {
    type::Size32 DataSize;
    RVA Rva;
};

struct MINIDUMP_MEMORY_DESCRIPTOR {
    ULONG64 StartOfMemoryRange;
    MINIDUMP_LOCATION_DESCRIPTOR Memory;
};

struct MINIDUMP_THREAD {
    ULONG32 ThreadId;
    ULONG32 SuspendCount;
    ULONG32 PriorityClass;
    ULONG32 Priority;
    ULONG64 Teb;
    MINIDUMP_MEMORY_DESCRIPTOR Stack;
    MINIDUMP_LOCATION_DESCRIPTOR ThreadContext;
};

struct MINIDUMP_THREAD_LIST {
    ULONG32 NumberOfThreads;
    MINIDUMP_THREAD Threads[NumberOfThreads];
};

struct VS_FIXEDFILEINFO {
    DWORD dwSignature;
    DWORD dwStrucVersion;
    DWORD dwFileVersionMS;
    DWORD dwFileVersionLS;
    DWORD dwProductVersionMS;
    DWORD dwProductVersionLS;
    DWORD dwFileFlagsMask;
    DWORD dwFileFlags;
    DWORD dwFileOS;
    DWORD dwFileType;
    DWORD dwFileSubtype;
    DWORD dwFileDateMS;
    DWORD dwFileDateLS;
};

struct MINIDUMP_MODULE {
    ULONG64 BaseOfImage;
    type::Size32 SizeOfImage;
    ULONG32 CheckSum;
    type::time32_t TimeDateStamp;
    RVA ModuleNameRva;
    VS_FIXEDFILEINFO VersionInfo;
    MINIDUMP_LOCATION_DESCRIPTOR CvRecord;
    MINIDUMP_LOCATION_DESCRIPTOR MiscRecord;
    ULONG64 Reserved0;
    ULONG64 Reserved1;

    char16 ModuleName[] @ ModuleNameRva + 4 [[hidden]];
} [[format("format_module")]];

fn format_module(ref MINIDUMP_MODULE module) {
    return module.ModuleName;
};

struct MINIDUMP_MODULE_LIST {
    ULONG32 NumberOfModules;
    MINIDUMP_MODULE Modules[NumberOfModules];
};

struct MINIDUMP_MEMORY_LIST {
    ULONG32 NumberOfMemoryRanges;
    MINIDUMP_MEMORY_DESCRIPTOR MemoryRanges[NumberOfMemoryRanges];
};

struct MINIDUMP_EXCEPTION  {
    ULONG32 ExceptionCode;
    ULONG32 ExceptionFlags;
    ULONG64 ExceptionRecord;
    ULONG64 ExceptionAddress;
    ULONG32 NumberParameters;
    padding[4];
    ULONG64 ExceptionInformation[15];
};

struct MINIDUMP_EXCEPTION_STREAM {
    ULONG32 ThreadId;
    padding[4];
    MINIDUMP_EXCEPTION ExceptionRecord;
    MINIDUMP_LOCATION_DESCRIPTOR ThreadContext;
};

struct CPU_INFORMATION {
    ULONG32 VendorId[3];
    ULONG32 VersionInformation;
    ULONG32 FeatureInformation;
    ULONG32 AMDExtendedCpuFeatures;
};

struct MINIDUMP_SYSTEM_INFO {
    USHORT ProcessorArchitecture;
    USHORT ProcessorLevel;
    USHORT ProcessorRevision;
    UCHAR NumberOfProcessors;
    UCHAR ProductType;
    ULONG32 MajorVersion;
    ULONG32 MinorVersion;
    ULONG32 BuildNumber;
    ULONG32 PlatformId;
    RVA CSDVersionRva;
    USHORT SuiteMask;
    USHORT Reserved;
    CPU_INFORMATION Cpu;
};

struct MINIDUMP_THREAD_EX {
    ULONG32 ThreadId;
    ULONG32 SuspendCount;
    ULONG32 PriorityClass;
    ULONG32 Priority;
    ULONG64 Teb;
    MINIDUMP_MEMORY_DESCRIPTOR Stack;
    MINIDUMP_LOCATION_DESCRIPTOR ThreadContext;
    MINIDUMP_MEMORY_DESCRIPTOR BackingStore;
};

struct MINIDUMP_THREAD_EX_LIST {
    ULONG32 NumberOfThreads;
    MINIDUMP_THREAD_EX Threads[NumberOfThreads];
};

struct MINIDUMP_MEMORY_DESCRIPTOR64 {
    ULONG64 StartOfMemoryRange;
    type::Size64 DataSize;
};

struct MINIDUMP_MEMORY64_LIST {
    ULONG64 NumberOfMemoryRanges;
    RVA64 BaseRva;
    MINIDUMP_MEMORY_DESCRIPTOR64 MemoryRanges[NumberOfMemoryRanges];
};

struct MINIDUMP_HANDLE_DESCRIPTOR {
    ULONG64 Handle;
    RVA TypeNameRva;
    RVA ObjectNameRva;
    ULONG32 Attributes;
    ULONG32 GrantedAccess;
    ULONG32 HandleCount;
    ULONG32 PointerCount;
};

struct MINIDUMP_HANDLE_DESCRIPTOR_2 {
    ULONG64 Handle;
    RVA TypeNameRva;
    RVA ObjectNameRva;
    ULONG32 Attributes;
    ULONG32 GrantedAccess;
    ULONG32 HandleCount;
    ULONG32 PointerCount;
    RVA ObjectInfoRva;
    ULONG32 Reserved0;
};

struct MINIDUMP_HANDLE_DATA_STREAM {
    ULONG32 SizeOfHeader;
    ULONG32 SizeOfDescriptor;
    ULONG32 NumberOfDescriptors;
    ULONG32 Reserved;

    if (SizeOfDescriptor == 32)
        MINIDUMP_HANDLE_DESCRIPTOR HandleDescriptors[NumberOfDescriptors];
    else if (SizeOfDescriptor == 40)
        MINIDUMP_HANDLE_DESCRIPTOR_2 HandleDescriptors[NumberOfDescriptors];
};

struct MINIDUMP_FUNCTION_TABLE_DESCRIPTOR {
    ULONG64 MinimumAddress;
    ULONG64 MaximumAddress;
    ULONG64 BaseAddress;
    ULONG32 EntryCount;
    type::Size32 SizeOfAlignPad;
};

struct MINIDUMP_FUNCTION_TABLE_STREAM {
    type::Size32 SizeOfHeader;
    type::Size32 SizeOfDescriptor;
    type::Size32 SizeOfNativeDescriptor;
    type::Size32 SizeOfFunctionEntry;
    ULONG32 NumberOfDescriptors;
    ULONG32 SizeOfAlignPad;

    MINIDUMP_FUNCTION_TABLE_DESCRIPTOR FunctionDescriptors[NumberOfDescriptors];
};

struct MINIDUMP_UNLOADED_MODULE {
    ULONG64 BaseOfImage;
    type::Size32 SizeOfImage;
    ULONG32 CheckSum;
    ULONG32 TimeDateStamp;
    RVA ModuleNameRva;

    char16 ModuleName[] @ ModuleNameRva + 4 [[hidden]];
} [[format("format_unloaded_module")]];

fn format_unloaded_module(ref MINIDUMP_UNLOADED_MODULE module) {
    return module.ModuleName;
};

struct MINIDUMP_UNLOADED_MODULE_LIST {
    ULONG32 SizeOfHeader;
    ULONG32 SizeOfEntry;
    ULONG32 NumberOfEntries;

    if (SizeOfHeader > 12)
        padding[header.SizeOfHeader - 12];

    MINIDUMP_UNLOADED_MODULE Modules[NumberOfEntries];
};

struct MINIDUMP_MISC_INFO {
    ULONG32 SizeOfInfo;
    ULONG32 Flags1;
    ULONG32 ProcessId;
    ULONG32 ProcessCreateTime;
    ULONG32 ProcessUserTime;
    ULONG32 ProcessKernelTime;

    if (SizeOfInfo > 24) {
        ULONG32 ProcessorMaxMhz;
        ULONG32 ProcessorCurrentMhz;
        ULONG32 ProcessorMhzLimit;
        ULONG32 ProcessorMaxIdleState;
        ULONG32 ProcessorCurrentIdleState;
    }
};

struct MINIDUMP_MEMORY_INFO {
    ULONG64 BaseAddress;
    ULONG64 AllocationBase;
    ULONG32 AllocationProtect;
    padding[4];
    type::Size64 RegionSize;
    ULONG32 State;
    ULONG32 Protect;
    ULONG32 Type;
    padding[4];
};

struct MINIDUMP_MEMORY_INFO_LIST {
    ULONG SizeOfHeader;
    ULONG SizeOfEntry;
    ULONG64 NumberOfEntries;

    if (SizeOfHeader > 16)
        padding[SizeOfHeader - 16];

    MINIDUMP_MEMORY_INFO Info[NumberOfEntries];
};

struct MINIDUMP_THREAD_INFO {
    ULONG32 ThreadId;
    ULONG32 DumpFlags;
    ULONG32 DumpError;
    ULONG32 ExitStatus;
    ULONG64 CreateTime;
    ULONG64 ExitTime;
    ULONG64 KernelTime;
    ULONG64 UserTime;
    ULONG64 StartAddress;
    ULONG64 Affinity;
};

struct MINIDUMP_THREAD_INFO_LIST {
    ULONG SizeOfHeader;
    ULONG SizeOfEntry;
    ULONG NumberOfEntries;

    if (SizeOfHeader > 12)
        padding[SizeOfHeader - 12];

    MINIDUMP_THREAD_INFO Info[NumberOfEntries];
};

struct MINIDUMP_HANDLE_OPERATION_LIST {
    ULONG32 SizeOfHeader;
    ULONG32 SizeOfEntry;
    ULONG32 NumberOfEntries;
    ULONG32 Reserved;
};

struct MINIDUMP_DIRECTORY {
    MINIDUMP_STREAM_TYPE StreamType;
    MINIDUMP_LOCATION_DESCRIPTOR Location;

    if (StreamType == MINIDUMP_STREAM_TYPE::ThreadListStream)
        MINIDUMP_THREAD_LIST ThreadList @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::ModuleListStream)
        MINIDUMP_MODULE_LIST ModuleList @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::MemoryListStream)
        MINIDUMP_MEMORY_LIST MemoryList @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::ExceptionStream)
        MINIDUMP_EXCEPTION_STREAM  ExceptionInfo @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::SystemInfoStream)
        MINIDUMP_SYSTEM_INFO SystemInfo @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::ThreadExListStream)
        MINIDUMP_THREAD_EX_LIST ThreadExList @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::Memory64ListStream)
        MINIDUMP_MEMORY64_LIST Mem64List @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::CommentStreamA)
        char Comment[] @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::CommentStreamW)
        char16 Comment[] @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::HandleDataStream)
        MINIDUMP_HANDLE_DATA_STREAM HandleData @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::FunctionTableStream)
        MINIDUMP_FUNCTION_TABLE_STREAM FunctionTable @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::UnloadedModuleListStream)
        MINIDUMP_UNLOADED_MODULE_LIST UnloadModuleList @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::MiscInfoStream)
            MINIDUMP_MISC_INFO MiscInfo @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::MemoryInfoListStream)
            MINIDUMP_MEMORY_INFO_LIST MemInfoList @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::ThreadInfoListStream)
            MINIDUMP_THREAD_INFO_LIST ThreadInfoList @ Location.Rva;
    else if (StreamType == MINIDUMP_STREAM_TYPE::HandleOperationListStream)
            MINIDUMP_HANDLE_OPERATION_LIST HandleOperList @ Location.Rva;
};

bitfield MINIDUMP_TYPE {
    MiniDumpWithDataSegs                    : 1;
    MiniDumpWithFullMemory                  : 1;
    MiniDumpWithHandleData                  : 1;
    MiniDumpFilterMemory                    : 1;
    MiniDumpScanMemory                      : 1;
    MiniDumpWithUnloadedModules             : 1;
    MiniDumpWithIndirectlyReferencedMemory  : 1;
    MiniDumpFilterModulePaths               : 1;
    MiniDumpWithProcessThreadData           : 1;
    MiniDumpWithPrivateReadWriteMemory      : 1;
    MiniDumpWithoutOptionalData             : 1;
    MiniDumpWithFullMemoryInfo              : 1;
    MiniDumpWithThreadInfo                  : 1;
    MiniDumpWithCodeSegs                    : 1;
    MiniDumpWithoutAuxiliaryState           : 1;
    MiniDumpWithFullAuxiliaryState          : 1;
    MiniDumpWithPrivateWriteCopyMemory      : 1;
    MiniDumpIgnoreInaccessibleMemory        : 1;
    MiniDumpWithTokenInformation            : 1;
    MiniDumpWithModuleHeaders               : 1;
    MiniDumpFilterTriage                    : 1;
    MiniDumpWithAvxXStateContext            : 1;
    MiniDumpWithIptTrace                    : 1;
    MiniDumpScanInaccessiblePartialPages    : 1;
    padding                                 : 40;
};

struct MINIDUMP_HEADER {
    char Signature[4];
    ULONG32 Version;
    ULONG32 NumberOfStreams;
    RVA StreamDirectoryRva;
    ULONG32 Checksum;
    type::time32_t TimeDateStamp;
    MINIDUMP_TYPE Flags;
};

struct MINIDUMP {
    MINIDUMP_HEADER Header;
    MINIDUMP_DIRECTORY Streams[Header.NumberOfStreams] [[format_entries("format_stream")]];
};

fn format_stream(ref MINIDUMP_DIRECTORY stream) {
    return stream.StreamType;
};

MINIDUMP MiniDump @ 0x00;
