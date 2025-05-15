#pragma author WerWolv
#pragma description Java HPROF Profiler Data Format
#pragma endian big
#pragma magic [ "JAVA PROFILE" ] @ 0x00

#pragma array_limit 0
#pragma pattern_limit 0

import std.mem;
import std.io;
import std.sys;
import std.core;

enum Tag : u8 {
    STRING_IN_UTF8      = 0x01,
    LOAD_CLASS          = 0x02,
    UNLOAD_CLASS        = 0x03,
    STACK_FRAME         = 0x04,
    STACK_TRACE         = 0x05,
    ALLOC_SITES         = 0x06,
    HEAP_SUMMARY        = 0x07,
    START_THREAD        = 0x0A,
    END_THREAD          = 0x0B,
    HEAP_DUMP           = 0x0C,
    HEAP_DUMP_SEGMENT   = 0x1C,
    HEAP_DUMP_END       = 0x2C,
    CPU_SAMPLES         = 0x0D,
    CONTROL_SETTINGS    = 0x0E,
};

u32 id_size = 0;
struct ID {
    match (id_size) {
        (1): u8 value;
        (2): u16 value;
        (4): u32 value;
        (8): u64 value;
        (_): std::error("Invalid ID size");
    }
} [[sealed, format("format_id")]];

fn format_id(ref auto id) {
    return std::format("0x{:0{}X}", id.value, id_size * 2);
};

struct StringInUTF8 {
    ID id;
    char string[parent.length - sizeof(id)];
};

struct LoadClass {
    u32 classSerialNumber;
    ID classObjectId;
    u32 stackTraceSerialNumber;
    ID classNameStringID;
};

struct StackFrame {
    ID stackFrameId;
    ID methodNameStringId;
    ID methodSignatureStringId;
    ID sourceFileNameStringId;
    u32 classSerialNumber;
    u32 lineInformation;
};

struct StackTrace {
    u32 stackTraceSerialNumber;
    u32 threadSerialNumber;
    u32 numberOfFrames;
    ID stackFrameIds[while(!std::mem::reached(addressof(this) + parent.length))];
};

enum SubTag : u8 {
    RootUnknown         = 0xFF,
    RootJNIGlobal       = 0x01,
    RootJNILocal        = 0x02,
    RootJavaFrame       = 0x03,
    RootNativeStack     = 0x04,
    RootStickyClass     = 0x05,
    RootThreadBlock     = 0x06,
    RootMonitorUsed     = 0x07,
    RootThreadObject    = 0x08,
    ClassDump           = 0x20,
    InstanceDump        = 0x21,
    ObjectArrayDump     = 0x22,
    PrimitiveArrayDump  = 0x23
};

enum EntryType : u8 {
    Object  = 2,
    Boolean = 4,
    Char    = 5,
    Float   = 6,
    Double  = 7,
    Byte    = 8,
    Short   = 9,
    Int     = 10,
    Long    = 11
};

struct BasicType<auto Tag> {
    match (Tag) {
        (EntryType::Object):  ID value;
        (EntryType::Boolean): bool value;
        (EntryType::Char):    { padding[1]; char value; }
        (EntryType::Float):   float value;
        (EntryType::Double):  double value;
        (EntryType::Byte):    u8 value;
        (EntryType::Short):   u16 value;
        (EntryType::Int):     u32 value;
        (EntryType::Long):    u64 value;
        (_): std::error("Invalid BasicType type");
    }
} [[sealed, format("format_basic_type")]];

fn format_basic_type(ref auto basicType) {
    return std::format("{}", basicType.value);  
};

struct ConstantPoolEntry {
    u16 constantPoolIndex;
    EntryType type;
    BasicType<type> value;
};

struct ConstantPoolArray {
    u16 size;
    ConstantPoolEntry entries[size];
};

struct StaticFieldEntry {
    ID staticFieldNameStringId;
    EntryType type;
    BasicType<type> value;
};

struct StaicFieldArray {
    u16 size;
    StaticFieldEntry entries[size];
};

struct InstanceField {
    ID fieldNameStringId;
    EntryType fieldType;
};

struct InstanceFieldsArray {
    u16 size;
    InstanceField instanceFields[size];
};

struct HeapDump {
    SubTag subTag;
    match (subTag) {
        (SubTag::RootUnknown): {
            ID objectId;
        }
        (SubTag::RootJNIGlobal): {
            ID objectId;
            ID jniGlobalRefId;
        }
        (SubTag::RootJNILocal): {
            ID objectId;
            u32 threadSerialNumber;
            u32 frameNumberInStackTrace;
        }
        (SubTag::RootJavaFrame): {
            ID objectId;
            u32 threadSerialNumber;
            u32 frameNumberInStackTrace;
        }
        (SubTag::RootNativeStack): {
            ID objectId;
            u32 threadSerialNumber;
        }
        (SubTag::RootStickyClass): {
            ID objectId;
        }
        (SubTag::RootThreadBlock): {
            ID objectId;
            u32 threadSerialNumber;
        }
        (SubTag::RootMonitorUsed): {
            ID objectId;
        }
        (SubTag::RootThreadObject): {
            ID threadObjectId;
            u32 threadSerialNumber;
            u32 stackTraceSerialNumber;
        }
        (SubTag::ClassDump): {
            ID classObjectId;
            u32 stackTraceSerialNumber;
            ID superClassObjectId;
            ID classLoaderObjectId;
            ID signersObjectId;
            ID protectionDomainObjectId;
            ID reserved[2];
            u32 instanceSize;
            ConstantPoolArray constantPool;
            StaicFieldArray staticFields;
            InstanceFieldsArray instanceFields;            
        }
        (SubTag::InstanceDump): {
            ID objectId;
            u32 stackTraceSerialNumber;
            ID classObjectId;
            u32 numBytes;
            std::mem::Bytes<numBytes> instanceFieldValues;
        }
        (SubTag::ObjectArrayDump): {
            ID arrayObjectId;
            u32 stackTraceSerialNumber;
            u32 numberOfElements;
            ID arrayClassObjectId;
            ID elements[numberOfElements];
        }
        (SubTag::PrimitiveArrayDump): {
            ID arrayObjectId;
            u32 stackTraceSerialNumber;
            u32 numberOfElements;
            EntryType type;
            BasicType<type> value[numberOfElements];
        }
        (_): std::error(std::format("Heap Dump Sub Tag {:02X} at 0x{:08X} {}", u32(subTag), $, std::core::array_index()));
    }
    
    if ($ - addressof(parent.length) + sizeof(parent.length) >= parent.length)
        break;
    
    u8 endTag [[no_unique_address, hidden]];
    if (endTag == 0x2C) {
        padding[1];
        break;
    }
};

struct UnloadClass {
    u32 classSerialNumber;
};

bitfield AllocSitesFlags {
    completeInsteadOfIncremental : 1;
    sortedByLineInsteadOfAllocation : 1;
    forceGc : 1;
    padding : 13;
};

struct AllocSite {
    bool arrayIndicator;
    u32 classSerialNumber;
    u32 stackTraceSerialNumber;
    u32 numberOfLiveBytes;
    u32 numberOfLiveInstances;
    u32 numberOfBytesAllocated;
    u32 numberOfInstancesAllocated;
};

struct AllocSites {
    AllocSitesFlags flags;
    float cutoffRatio;
    u32 totalLiveBytes;
    u32 totalLiveInstances;
    u64 totalBytesAllocated;
    u64 totalInstancesAllocated;
    u32 numSites;
    AllocSite sites[numSites];
};

struct HeapSummary {
    u32 totalLiveBytes;
    u32 totalLiveInstances;
    u64 totalBytesAllocated;
    u64 totalInstancesAllocated;
};

struct StartThread {
    u32 threadSerialNumber;
    ID threadObjectId;
    u32 stackTraceSerialNumber;
    ID threadNameStringId;
    ID threadGroupNameId;
    ID threadParentGroupNameId;
};

struct EndThread {
    u32 threadSerialNumber;
};

struct Sample {
    u32 numberOfSamples;
    u32 stackTraceSerialNumber;
};

struct CpuSamples {
    u32 numSamples;
    Sample samples[numSamples];
};

bitfield ControlSettingsFlags {
    allocTraces : 1;
    cpuSampling : 1;
    padding     : 30;
};

struct ControlSettings {
    ControlSettingsFlags flags;
    u16 stackTraceDepth;
};

struct Record {
    Tag tag;
    u32 time;
    u32 length;
    
    match (tag) {
        (Tag::STRING_IN_UTF8): 
            StringInUTF8 body;
        (Tag::LOAD_CLASS): 
            LoadClass body;
        (Tag::UNLOAD_CLASS): 
            UnloadClass body;
        (Tag::STACK_FRAME): 
            StackFrame body;
        (Tag::STACK_TRACE): 
            StackTrace body;
        (Tag::ALLOC_SITES): 
            AllocSites body;
        (Tag::HEAP_SUMMARY): 
            HeapSummary body;
        (Tag::START_THREAD): 
            StartThread body;
        (Tag::END_THREAD): 
            EndThread body;
        (Tag::HEAP_DUMP | Tag::HEAP_DUMP_SEGMENT): 
            HeapDump heapDumps[while(true)];
        (Tag::HEAP_DUMP_END): 
            std::error("HEAP_DUMP_END Tag without previous HEAP_DUMP or HEAP_DUMP_SEGMENT Tag");
        (Tag::CPU_SAMPLES): 
            CpuSamples body;
        (Tag::CONTROL_SETTINGS): 
            ControlSettings body;
        (_): 
            std::error(std::format("Unknown record type {:02X} at address 0x{:08X}, index {}", u8(tag), addressof(tag), std::core::array_index()));
    }
};

struct Header {
    char format_name[];
    u32 identifier_size;
    id_size = identifier_size;
    u32 timestamp_high;
    u32 time_stamp_low;
};

struct HPROF {
    Header header;
    Record records[while(!std::mem::eof())];
};

HPROF hprof @ 0x00;