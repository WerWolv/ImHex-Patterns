#pragma endian big

#pragma MIME audio/mp4
#pragma MIME video/mp4
#pragma MIME application/mp4

#include <std/io.pat>
#include <std/mem.pat>
#include <std/string.pat>

fn to_string(auto var) {
    return str(var);
};

fn format_string(auto string) {
    return string.value;
}; 

struct string {
    char value[std::mem::find_sequence_in_range(0, $, std::mem::size(), 0x00) - $];
} [[sealed, format("format_string")]];

struct BaseBox {
    u64 boxSize = 0;
    u64 startOffset = $;
    u64 endOffset = 0;

    u32 size;
    char type[4];

    // Calculate the size of the current box
    // 1. If the size is equal to 1 -> the box size is equal to 'largeSize' attribute.
    // 2. If the size is equal to 0 -> The box extends to the end of the file.
    // 3. Otherwise, size is equaly to the 'size' attribute.
    if (this.size == 1) {
        u64 largeSize;
        boxSize = largeSize;
        endOffset = startOffset + boxSize;
    } else if (this.size == 0) { 
        boxSize = std::mem::size() - startOffset;
        endOffset = std::mem::size();
    } else {
        boxSize = size;
        endOffset = startOffset + boxSize;
    }

    if (this.type == "uuid") {
        char usertype[16];
    }
};

struct FullBox : BaseBox {
    u8 version;
    u24 flags;
};

struct UnknownBox : BaseBox {
    u8 unk[while($ != endOffset)];
};

using brand = u32 [[format("to_string")]];
struct FileTypeBox : BaseBox {
    brand major_brand;
    u32 minor_version;
    brand compatible_brands[(endOffset - $) / sizeof(brand)];
};

struct MovieHeaderBox : FullBox {
    if (this.version == 1) {
        u64 creation_time;
        u64 modification_time;
        u32 timescale;
        u64 duration;
    } else {  // version == 0
        u32 creation_time;
        u32 modification_time;
        u32 timescale;
        u32 duration;
    }
    u32 rate [[comment("Fixed point number 16.16")]];
    u16 volume [[comment("Fixed point number 8.8")]];
    u8 reserved[10] [[sealed]];
    u32 matrix[9];
    u32 preview_time;
    u32 preview_duration;
    u32 poster_time;
    u32 selection_time;
    u32 selection_duration;
    u32 current_time;
    u32 next_track_id;
};

struct TrackHeaderBox : FullBox {
    if (this.version == 1) {
        u64 creation_time;
        u64 modification_time;
        u32 track_id;
        u32 reserved;
        u64 duration;
    } else {  // version == 0
        u32 creation_time;
        u32 modification_time;
        u32 track_id;
        u32 reserved;
        u32 duration;
    }
    u32 reserved_2[2] [[sealed]];
    s16 layer;
    s16 alternate_group;
    s16 volume;
    u16 reserved_3;
    s32 matrix[9];
    u32 width;
    u32 height;
};

struct DataEntryBox : FullBox {
    if (std::string::contains(this.type, "url")) {
        string location;
    } else if (std::string::contains(this.type, "urn")) {
        string name;
        string location;
    } else {
        std::error("Invalid DataEntryBox");
    }
};

struct DataReferenceBox : FullBox {
    u32 entry_count;
    DataEntryBox data_entries[this.entry_count];
};

struct SubDataInformationBox {
    u32 type = std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Big);

    match (str(type)) {
        ("dref"): DataReferenceBox box [[inline]];
        (_): UnknownBox box [[inline]];
    }
} [[name(std::format("DataInformationBox({})", box.type))]];

struct DataInformationBox : BaseBox {
    SubDataInformationBox box[while($ < endOffset)] [[inline]];
};

struct HandlerBox : FullBox {
    u32 component_type;
    u32 handler_type;
    u32 reserved[3];
    char name[endOffset - $];
};

struct VideoMediaHeaderBox : FullBox {
    u16 graphicsmode;
    u16 opcolor[3];
};

struct SubMediaInformationBox {
    u32 type = std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Big);

    match (str(type)) {
        ("vmhd"): VideoMediaHeaderBox box [[inline]];
        ("hdlr"): HandlerBox box [[inline]];
        ("dinf"): DataInformationBox box [[inline]];
        (_): UnknownBox box [[inline]];
        // TODO: Add stbl
    }
} [[name(std::format("MediaInformationBox({})", box.type))]];

struct MediaInformationBox : BaseBox {
    SubMediaInformationBox box[while($ < endOffset)] [[inline]];
};

struct MediaHeaderBox : FullBox {
    if (this.version == 1) {
        u64 creation_time;
        u64 modification_time;
        u32 timescale;
        u64 duration;
    } else { // version==0
        u32 creation_time;
        u32 modification_time;
        u32 timescale;
        u32 duration;
    }
    u16 language [[comment("ISO-639-2/T language code")]];
    u16 quality;
};

struct SubMediaBox {
    u32 type = std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Big);

    match (str(type)) {
        ("mdhd"): MediaHeaderBox box [[inline]];
        ("hdlr"): HandlerBox box [[inline]];
        ("minf"): MediaInformationBox box [[inline]];
        (_): UnknownBox box [[inline]];
    }
} [[name(std::format("MediaBox({})", box.type))]];

struct MediaBox : BaseBox {
    SubMediaBox box[while($ < endOffset)] [[inline]];
};

struct EditListEntry64 {
    u64 segment_duration;
    s64 media_time;
    s16 media_rate_integer;
    s16 media_rate_fraction;
};

struct EditListEntry32 {
    u32 segment_duration;
    s32 media_time;
    s16 media_rate_integer;
    s16 media_rate_fraction;
};

struct EditListBox : FullBox {
    u32 entry_count;
    if (this.version == 1) {
        EditListEntry64 entry_list[this.entry_count];
    } else {  // version 0
        EditListEntry32 entry_list[this.entry_count];
    }
};

struct SubEditBox {
    u32 type = std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Big);

    match (str(type)) {
        ("elst"): EditListBox box [[inline]];
        (_): UnknownBox box [[inline]];
    }
} [[name(std::format("EditBox({})", box.type))]];

struct EditBox : BaseBox {
    SubEditBox box[while($ < endOffset)] [[inline]];
};

struct SubTrackBox {
    u32 type = std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Big);

    match (str(type)) {
        ("mdia"): MediaBox box [[inline]];
        ("edts"): EditBox box [[inline]];
        ("tkhd"): TrackHeaderBox box [[inline]];
        (_): UnknownBox box [[inline]];
    }
} [[name(std::format("TrackBox({})", box.type))]];

struct TrackBox : BaseBox {
    SubTrackBox box[while($ < endOffset)] [[inline]];
};

struct SubMovieBox {
    u32 type = std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Big);

    match (str(type)) {
        ("mvhd"): MovieHeaderBox box [[inline]];
        ("trak"): TrackBox box [[inline]];
        (_): UnknownBox box [[inline]];
        // TODO: Add "iods" box
    }
} [[name(std::format("MovieBox({})", box.type))]];

struct MovieBox : BaseBox {
    SubMovieBox box[while($ < endOffset)] [[inline]];
};

struct MediaDataBox : BaseBox {
    u8 data[while($ < endOffset)] [[sealed]];
};

struct Box {
    u32 type = std::mem::read_unsigned($ + 4, 4, std::mem::Endian::Big);

    match (str(type)) {
        ("ftyp"): FileTypeBox box [[inline]];
        ("moov"): MovieBox box [[inline]];
        ("mdat"): MediaDataBox box [[inline]];
        (_): UnknownBox box [[inline]];
    }
} [[name(std::format("Box({})", box.type))]];

Box mp4[while(!std::mem::eof())] @ 0x0;
