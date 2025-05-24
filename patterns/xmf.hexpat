#pragma description MMA XMF and MXMF

// This implements:
// RP-030 Specification for XMF Meta File Format 1.0
// RP-031 Type 0 & Type 1 XMF Files (DLS + SMF)
// RP-032 SMF Meta Event for XMF Patch Type Prefix
// RP-039 XMF Meta File Format Updates 1.01
// RP-040 XMF Compressions Definition for “zlib”
// RP-042a Type 2 XMF File (Mobile XMF)
// RP-043 Specification for XMF Meta File Format 2.0
// RP-045 Audio Clips for Mobile XMF
// RP-047 ID3 Metadata for XMF Files

#pragma endian big

// audio/xmfN does not seem to be used
#pragma MIME audio/mobile-xmf

import std.core;
import std.io;
import std.mem;
import std.array;
import std.attrs;
import std.string;
import type.guid;
import hex.dec;
import hex.core;
import type.mmreg;

import * from id3 as ID3;
import * from midi as SMF;
import * from dls as DLS;

// As referred in RP-039, ReferenceTypeID 2 InfileResource does not provide any indication of the length of the target data
// So we just make it extend to EOF
// If you dont like that, set this to false
bool extendIFRtoEOF in;

fn u32ify(u32 vlq) {
    // Converts from variable-length quantity to u32. These numbers are
    // represented 7 bits per byte, most significant bits first. All bytes
    // except the last have bit 7 set, and the last byte has bit 7 clear.
    // If the number is in range 0..127, it is thus represented exactly
    // as one byte.
    u32 n = vlq & 0x7f;
    if (vlq & 0x8000 == 0x8000) {
        n += ((vlq & 0x7f00) >> 8) * 0x80;
    }
    if (vlq & 0x800000 == 0x800000) {
        n += ((vlq & 0x7f0000) >> 8 * 2) * 0x80 * 0x80;
    }
    if (vlq & 0x80000000 == 0x80000000) {
        n += ((vlq & 0x7f000000) >> 8 * 3) * 0x80 * 0x80 * 0x80;
    }
    return n;
};

fn unwrapVLQ(auto vlq) {
    return u32ify(vlq.value);
};

// TODO: We got VLQs up to 19 bytes long for non-registered ids, and how can we handle it...
struct VLQ : std::attr::Literal<"unwrapVLQ"> {
    if (std::mem::read_unsigned($, 1) & 0x80 == 0x80) {
        if (std::mem::read_unsigned($ + 1, 1) & 0x80 == 0x80) {
            if (std::mem::read_unsigned($ + 2, 1) & 0x80 == 0x80) {
                u32 value;
            } else {
                u24 value;
            }
        } else {
            u16 value;
        }
    } else {
        u8 value;
    }
};

struct VLQPointer<T> {
    VLQ addr;
    T deref @ addr;
};

// make it extend to EOF
struct VLQUnsizedPointer {
    VLQ addr;
    if (extendIFRtoEOF) {
        char deref[while(!std::mem::eof())] @ addr;
    }
};

struct VLQPointerToArray<T, auto size> {
    VLQ addr;
    T deref[size] @ addr;
};

using MetaDataStandardResourceFormatID;

// TODO: `ref` seems nonsense, but without it resfmt will not be passed correctly
fn inferResourceSize(u64 addr, ref MetaDataStandardResourceFormatID resfmt) {
    // std::print("2. 0x{:x} {} {} 0x{:x}", $, resfmt, u8(resfmt), addressof(resfmt));
    u64 filesize = 0;
    // std::print("3. 0x{:x} {} {} 0x{:x}", $, resfmt, u8(resfmt), addressof(resfmt));
    if (resfmt == MetaDataStandardResourceFormatID::SMF0
     || resfmt == MetaDataStandardResourceFormatID::SMF1) {
        if (std::mem::read_string(addr, 4) != "MThd") {
            std::warning("A SMF resource does not seem to be a SMF file");
            std::error();
        }
        filesize += 8 + std::mem::read_unsigned(addr+4, 4, std::mem::Endian::Big);
        u16 ntrks = std::mem::read_unsigned(addr+10, 2, std::mem::Endian::Big);
        for (u16 i = 0, i < ntrks, i += 1) {
            if (std::mem::read_string(addr+filesize, 4) != "MTrk") {
                std::warning("A SMF resource does not seem to be a SMF file (when reading its tracks)");
                std::error();
            }
            filesize += 8 + std::mem::read_unsigned(addr+filesize+4, 4, std::mem::Endian::Big);
        }
    } else if (std::core::is_valid_enum(resfmt)) { // If it is not SMF, it is DLS
        if (std::mem::read_string(addr, 4) != "RIFF") {
            std::warning("A DLS resource does not seem to be a RIFF file");
            std::error();
        }
        filesize = 4 + std::mem::read_unsigned(addr+4, 4, std::mem::Endian::Little);
    } else {
        std::warning("Invalid MetaDataStandardResourceFormatID found");
        std::error();
    }
    return filesize;
};

// Enums

enum FileID : u32 {
    XMF_ = 0x584D465F // "XMF_"
};

enum ReferenceTypeID : u8 {
    InlineResource = 0x01,
    InFileResource = 0x02,
    InFileNode = 0x03,
    ExternalResourceFile = 0x04,
    XMFURI = 0x05,
    XMFURIAndNodeID = 0x06
};

enum XMFMetaFileVersion : u32 {
    v1 = 0x312E3030,
    v2 = 0x322E3030
};

enum MetaDataStandardFieldID : u8 { // actually VLQ
    XMFFileType = 0,
    NodeName = 1,
    NodeID = 2,
    ResourceFormat = 3,
    FilenameOnDisk = 4,
    FilenameExtensionOnDisk = 5,
    MacOSFileType = 6,
    MIMEType = 7,
    Title = 8,
    Copyright = 9,
    Comment = 10,
    Autostart = 11,
    Preload = 12,
    ContentDescription = 13,
    ID3Metadata = 14
};

enum MetaDataStandardResourceFormatID : u8 { // actually VLQ
    SMF0 = 0,
    SMF1 = 1,
    DLS1 = 2,
    DLS2 = 3,
    DLS21 = 4,
    MDLS = 5
};

enum StandardTypeID : u8 { // actually VLQ
    Standard = 0,
    MMAManufacturer = 1,
    Registered = 2,
    Nonregistered = 3
};

enum PRLTypeID : u8 {
    Standard = 0,
    MMAManufacturer = 1,
    Registered = 2,
    Nonregistered = 3,
    WTCodecFormatTag = 4,
    WTCodecGUID = 5
};

enum PRGLGroupID : u8 {
    SynthesizerVoice = 0,
    WTCodec = 1,
    WTMemoryConsumption = 2,
    // exclusive means it cuts itself
    AudioClipsExclusive = 3,
    AudioClipsNonexclusive = 4,
    AudioClipsVoice = 5
};

enum PRLStandardID : u8 {
    // PRGL 0
    GM1VoiceCount = 0,
    MDLSVoiceCount = 1,
    MDLSVoiceCountWithControlGroup = 2,

    // PRGL 2
    DLSWTSizeKiB = 3, // Total wavetable data consumption (in kilobytes) for Mobile DLS instruments using (16-bit, 8-bit) PCM samples
    MDLSWTSizeKiB = 4, // Total uncompressed wavetable data (in kilobytes) for Mobile DLS instruments using compressed samples

    // PRGL 5
    AudioClipsCount = 5,

    // PRGL 3
    AudioClipsWTSizeKiB = 6,

    // PRGL 4
    AudioClipsMaxSR = 7, // in kilosamples per 10 seconds

    // PRGL 3
    // in kilobits per 10 seconds
    AudioClipsAverageBitrate = 8,
    AudioClipsMaxBitrate = 9
};

enum StringFormatTypeID : u8 { // actually VLQ
    EASCIIVisible = 0,
    EASCIIHidden = 1,
    UTF16Visible = 2,
    UTF16Hidden = 3,
    SCSUVisible = 4,
    SCSUHidden = 5,
    BinaryVisible = 6,
    BinaryHidden = 7
};

enum StandardUnpackerID : u8 { // actually VLQ
    None = 0,
    ZLIB = 1
};

// Atomic

struct XString {
    VLQ length;
    char data[(length)];
};

// Metadata

struct PRLEntry {
    PRLTypeID typeID;
    if (typeID == PRLTypeID::Standard) {
        PRLStandardID standardID;
    } else if (typeID == PRLTypeID::MMAManufacturer) {
        VLQ manufacturerID;
        VLQ internalID;
    } else if (typeID == PRLTypeID::Registered) {
        VLQ registeredID;
    } else if (typeID == PRLTypeID::Nonregistered) {
        type::GUID guid;
    } else if (typeID == PRLTypeID::WTCodecFormatTag) {
        type::TypewFormatTag wFormatTag;
    } else if (typeID == PRLTypeID::WTCodecGUID) {
        type::GUID guid;
    }
};

// MXMF
struct MIRCountTableChannel {
    VLQ MIRCount[parent.PlaybackResourceCount];
};

struct ContentDescription {
    VLQ MIPIndex;
    VLQ ChannelCount;
    VLQ PlaybackResourceCount;
    PRLEntry PRL[PlaybackResourceCount];
    PRGLGroupID PRGL[PlaybackResourceCount];
    MIRCountTableChannel MIRCountTable[ChannelCount];
};

struct MetaDataTypeEntry {
    VLQ metadataType;
    VLQ stringFormatTypeID;
    XString langCountrySpec;
};

struct MetaDataTypesTable {
    VLQ size;
    if (size != 0) {
        VLQ numberOfEntries;
        MetaDataTypeEntry typeEntries[numberOfEntries];
    }
};

struct FieldSpecifier {
    if (std::mem::read_unsigned($, 1) == 0) {
        u8;
        // VLQ fieldID;
        MetaDataStandardFieldID fieldID; // standard fieldid is no longer than u8
    } else {
        XString fieldName;
    }
};

struct ContentVersion {
    VLQ metadataType;
    VLQ lengthOfData;
    char versionData[lengthOfData];
};

struct FieldContents {
    VLQ numberOfVersions;
    VLQ lengthOfData;
    if (lengthOfData == 0) {
        u8; // stirngFormatTypeID
    } else {
        if (numberOfVersions == 0) {
            StringFormatTypeID stringFormatTypeID;

            if (parent.fieldSpecifier.fieldID == MetaDataStandardFieldID::XMFFileType) {
                VLQ fileTypeID;
                VLQ revisionID;
            } else if (parent.fieldSpecifier.fieldID == MetaDataStandardFieldID::NodeID) {
                VLQ nodeID;
            } else if (parent.fieldSpecifier.fieldID == MetaDataStandardFieldID::ResourceFormat) {
                StandardTypeID formatTypeID;
                if (formatTypeID == StandardTypeID::Standard) {
                    MetaDataStandardResourceFormatID standardResourceFormatID;
                } else {
                    VLQ resourceFormatID;
                }
            } else if (parent.fieldSpecifier.fieldID == MetaDataStandardFieldID::ContentDescription) {
                ContentDescription contentDescription;
            } else if (parent.fieldSpecifier.fieldID == MetaDataStandardFieldID::ID3Metadata) {
                ID3 id3v2;
            } else {
                char universalData[lengthOfData-sizeof(stringFormatTypeID)];
            }
            padding[addressof(stringFormatTypeID)+lengthOfData-$];
        } else {
            ContentVersion versions[while(!std::mem::reached(addressof(versions)+size))];
        }
    }
};

struct MetaDataItem {
    FieldSpecifier fieldSpecifier;
    FieldContents fieldContents;
};

struct NodeMetaData {
    VLQ size;
    MetaDataItem items[while(!std::mem::reached(addressof(this)+size))];
};

// Unpacker

struct UnpackerID {
    StandardTypeID typeID;
    if (typeID == StandardTypeID::Standard) {
        StandardUnpackerID standardUnpackerID;
    } else {
        VLQ id;
    }
};

struct UnpackerEntry {
    UnpackerID unpackerID;
    VLQ decodedLength;
};

struct NodeUnpackers {
    VLQ size;
    if (size != 0) {
        UnpackerEntry unpackerEntries[while(!std::mem::reached(addressof(this)+size))];
    }
};

fn unpackData(auto unpackerEntries, auto pattern, std::mem::Section dest) {
    bool unpacked = false;
    std::mem::copy_value_to_section(pattern, dest, 0);
    for (u32 i = 0, i < std::core::member_count(unpackerEntries), i += 1) {
        if (unpackerEntries[i].unpackerID.typeID == StandardTypeID::Standard) {
            if (unpackerEntries[i].unpackerID.standardUnpackerID == StandardUnpackerID::None) {
                continue;
            } else if (unpackerEntries[i].unpackerID.standardUnpackerID == StandardUnpackerID::ZLIB) {
                u8 src[std::mem::get_section_size(dest)] @ 0x00 in dest;
                if (!hex::dec::zlib_decompress(src, dest, 0)) {
                    std::error("Failed to decompress ZLIB data");
                }
                unpacked = true;
            } else {
                std::error("Unrecognized StandardUnpackerID");
            }
        } else {
            std::error("Unsupported UnpackerID");
        }
    }
    return unpacked;
};

// Node

using Node;
using NodeWithPadding;

struct NodeHeader {
    VLQ nodeSize;
    VLQ itemCount;
    VLQ headerSize;
    NodeMetaData nodeMetadata;
    NodeUnpackers nodeUnpackers;
};

fn getResourceFormatIncomplete(ref NodeHeader header, ReferenceTypeID typeID, auto pointerToFileNode) {
    if (header.itemCount != 0) {
        std::error("Cannot fetch resource format from a folder node");
    }
    if (typeID == ReferenceTypeID::InFileNode) {
        return getResourceFormat(pointerToFileNode.deref);
    }
    for (u32 i = 0, i < header.nodeMetadata.size, i += 1) {
        if (header.nodeMetadata.items[i].fieldSpecifier.fieldID == MetaDataStandardFieldID::ResourceFormat) {
            if (header.nodeMetadata.items[i].fieldContents.formatTypeID == StandardTypeID::Standard) {
                return header.nodeMetadata.items[i].fieldContents.standardResourceFormatID;
            }
            return header.nodeMetadata.items[i].fieldContents.resourceFormatID;
        }
    }
};

fn getResourceFormat(ref Node node) {
    if (node.content.typeID == ReferenceTypeID::InFileNode) {
        return getResourceFormat(node.header, node.content.typeID, node.content.pointerToFileNode);
    }
    return getResourceFormat(node.header, node.content.typeID, 0);
};

struct NodeContents {
    ReferenceTypeID typeID;
    if (parent.header.itemCount > 0) {
        if (typeID == ReferenceTypeID::InlineResource) {
            NodeWithPadding children[parent.header.itemCount] [[inline]];
        } else if (typeID == ReferenceTypeID::InFileResource) {
            VLQPointerToArray<NodeWithPadding, parent.header.itemCount> pointerToChildren;
        } else if (typeID == ReferenceTypeID::InFileNode) {
            VLQPointer<Node> pointerToFolderNode;
        } else {
            std::error("Unrecognized or invalid ReferenceTypeID for FolderNode");
        }
    } else {
        if (typeID == ReferenceTypeID::InlineResource) {
            char data[parent.header.nodeSize-($-addressof(parent))];
            if (parent.header.nodeUnpackers.size != 0) {
                try {
                    std::mem::Section unpacked = std::mem::create_section(std::format("Unpacked 0x{:x}", addressof(data)));
                    if (unpackData(parent.header.nodeUnpackers.unpackerEntries, data, unpacked)) {
                        std::print("Data at 0x{:x} in {} bytes decompressed in {} bytes (see Sections)", addressof(data), sizeof(data), std::mem::get_section_size(unpacked));
                        char unpackedData[std::mem::get_section_size(unpacked)] @ 0x00 in unpacked;
                    }
                } catch {
                    std::warning("Something unexpected happened while unpacking data at 0x{:x}", addressof(data));
                }
            }
        } else if (typeID == ReferenceTypeID::InFileResource) {
            VLQ ptr [[hidden, no_unique_address]];
            try {
                MetaDataStandardResourceFormatID resfmt = getResourceFormatIncomplete(parent.header, typeID, 0);
                // std::print("1. 0x{:x} {} {} 0x{:x}", $, resfmt, u8(resfmt), addressof(resfmt));
                VLQPointerToArray<char, inferResourceSize(ptr, resfmt)> pointerToData;
            } catch {
                std::warning(std::format("Failed to deduce size of InFileResource at 0x{:x} pointing to 0x{:x}", addressof(this), ptr));
                if (extendIFRtoEOF) {
                    std::warning("The resource will be extended to the EOF.");
                } else {
                    std::warning("The resource will not be patterned. You can let it extend to EOF by setting extendIFRtoEOF to true in the 'Settings' tab above.");
                }
                VLQUnsizedPointer pointerToData;
            }
        } else if (typeID == ReferenceTypeID::InFileNode) {
            VLQPointer<Node> pointerToFileNode;
        } else if (typeID == ReferenceTypeID::ExternalResourceFile || typeID == ReferenceTypeID::XMFURI) {
            XString externalURI;
        } else if (typeID == ReferenceTypeID::XMFURIAndNodeID) {
            XString uri; // nullable
            VLQ nodeID;
        } else {
            std::error("Unrecognized ReferenceTypeID");
        }
    }
};

struct Node {
    NodeHeader header;
    padding[header.headerSize-sizeof(header)];
    NodeContents content;
};

struct NodeWithPadding {
    Node node;
    padding[node.header.nodeSize-sizeof(node)];
};

// File

struct FileHeader {
    FileID fileID;
    XMFMetaFileVersion fileVer;
    if (fileVer == XMFMetaFileVersion::v2) {
        u32 fileTypeID;
        u32 fileTypeRevisionID;
    }
    VLQ fileSize;
    MetaDataTypesTable metadataTypesTable;
    VLQ treeStart;
    VLQ treeEnd;
};

fn fetchChild(ref Node tree, u32 idx) {
    if (tree.header.itemCount == 0) {
        std::error("Cannot fetch child from a file node");
    }
    if (tree.content.typeID == ReferenceTypeID::InlineResource) {
        return tree.content.children[idx].node;
    }
    if (tree.content.typeID == ReferenceTypeID::InFileResource) {
        return tree.content.pointerToChildren[idx].node;
    }
    if (tree.content.typeID == ReferenceTypeID::InFileNode) {
        return fetchChild(tree.content.pointerToFolderNode.deref, idx);
    }
    std::error("Unrecognized or invalid ReferenceTypeID for FolderNode");
};

fn fetchData(ref Node node) {
    if (node.header.itemCount != 0) {
        std::error("Cannot fetch data from a folder node");
    }
    if (node.content.typeID == ReferenceTypeID::InlineResource) {
        try {
            return node.content.unpackedData;
        }
        u8 pattern[sizeof(node.content.data)] @ addressof(node.content.data) in 0;
        return pattern;
    }
    if (node.content.typeID == ReferenceTypeID::InFileResource) {
        try {
            u8 pattern[sizeof(node.content.pointerToData.deref)] @ addressof(node.content.pointerToData.deref) in 0;
            return pattern;
        } catch {
            std::mem::Section errsec = std::mem::create_section("");
            std::mem::copy_value_to_section(std::format("Failed to deref InFileResource at 0x{:x} pointing to 0x{:x}", addressof(node.content), node.content.pointerToData.addr), errsec, 0);
            u8 errmsg[std::mem::get_section_size(errsec)] @ 0x00 in errsec;
            return errmsg;
        }
    }
    if (node.content.typeID == ReferenceTypeID::InFileNode) {
        return fetchData(node.content.pointerToFileNode.deref);
    }
    std::error("Unrecognized or unsupported ReferenceTypeID {}", node.content.typeID);
};

fn formatNodeName(ref Node node) {
    try {
        return std::format("{:X}h.{}", addressof(node), std::string::replace(std::core::formatted_value(getResourceFormat(node)), "MetaDataStandardResourceFormatID::", ""));
    }
    return std::format("{:X}h", addressof(node));
};

fn visualizeTree(str prefix, ref Node tree) {
    if (tree.header.itemCount == 0) {
        hex::core::add_virtual_file(std::format("{}{}", prefix, formatNodeName(tree)), fetchData(tree));
    } else {
        for (u32 i = 0, i < tree.header.itemCount, i += 1) {
            visualizeTree(std::format("{}{:X}h/", prefix, addressof(tree)), fetchChild(tree, i));
        }
    }
};

FileHeader fileHeader @ 0x00;
Node tree @ fileHeader.treeStart;

visualizeTree("/", tree);