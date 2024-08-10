#pragma author Surasia
#pragma description Halo Infinite Tag

import std.string;
import type.guid;

u32 fileStart = 0;

enum TagSectionType : u16
{
    header,
    tagData,
    resourceData
};


enum TagStructType : u16
{
    mainStruct,
    tagBlock,
    resource,
    custom,
    literal
};


struct TagHeader
{
    char magic[4];
    s32 version;
    u64 hash;
    u64 checksum;
    u32 dependencyCount;
    u32 dataBlockCount;
    u32 tagStructCount;
    u32 dataReferenceCount;
    u32 tagReferenceCount;
    u32 stringTableSize;
    u32 zoneSetDataSize;
    u32 unknown0;
    u32 headerSize;
    fileStart = headerSize;
    u32 dataSize;
    u32 resourceDataSize;
    u32 actualResourceDataSize;
    u8 headerAlignment;
    u8 tagDataAlignment;
    u8 resourceDataAlignment;
    u8 actualResourceAlignment;
    u32 unknown1;
};


struct TagDependency
{
    char tagGroup[4] [[format("std::string::reverse")]];
    u32 nameOffset;
    u64 assetId;
    u32 globalId;
    u32 parentTag;
};


struct TagDataBlock
{
    u32 entrySize;
    u16 pad;
    TagSectionType section;
    u64 offset;
    if (section == TagSectionType::tagData)
    {
        char dataBlock[entrySize] @ fileStart + offset;
    }
};


struct TagStruct
{
    type::GUID guid;
    TagStructType type;
    u16 unknown0;
    s32 targetIndex;
    s32 fieldBlockIndex;
    u32 fieldOffset;
};


struct TagDataReference
{
    s32 parentStructIndex;
    s32 unknown0;
    s32 targetIndex;
    s32 fieldBlockIndex;
    u32 fieldOffset;
};


struct TagReference
{
    s32 fieldBlockIndex;
    u32 fieldOffset;
    u32 nameOffset;
    s32 dependencyIndex;
};


struct TagZonesetHeader
{
    s32 version;
    u32 zonesetCount;
    u32 footerCount;
    s32 parentCount;
};


struct TagZonesetInstanceHeader
{
    s32 stringId;
    u32 tagCount;
    u32 parentCount;
    u32 footerCount;
};


struct TagZonesetTag
{
    u32 globalId;
    s32 stringId;

};


struct TagZonesetInstance
{
    TagZonesetInstanceHeader header;
    TagZonesetTag tags[header.tagCount];
    TagZonesetTag footers[header.footerCount];
    s32 parents[header.parentCount];

};


struct TagZoneset
{
    TagZonesetHeader zoneset_header;
    TagZonesetInstance instances[zoneset_header.zonesetCount];
};


struct Tag
{
    TagHeader header;
    TagDependency dependencies[header.dependencyCount];
    TagDataBlock data_blocks[header.dataBlockCount];
    TagStruct tag_structs[header.tagStructCount];
    TagDataReference data_references[header.dataReferenceCount];
    TagReference tag_references[header.tagReferenceCount];
    TagZoneset zonesets;
    if (header.headerSize != $)
    {
        std::print("Header size is wrong, additional data in tag");
        $ = header.headerSize;
        std::print("Data offset now at: {}", $);
    }
};


Tag tag_root @ 0x00;