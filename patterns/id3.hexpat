#include <std/mem.pat>

namespace v1 {

    struct Tag {
        char header[3];
        char title[30];
        char artist[30];
        char album[30];
        char year[4];
        char comment[30];
        u8   zero;
        u8   track;
        u8   genre;
    } [[static]];

}

namespace v2 {

    struct SyncSafeInt {
        u8 bytes[4];
    } [[sealed, format("v2::ssi_value"), transform("v2::ssi_value")]];

    fn ssi_value(ref SyncSafeInt n) {
        u32 result = 0;
        for (u8 i = 0, i < 4, i = i + 1) {
            u8 byteval = n.bytes[i] & 0x7F;
            u8 shift = 7 * (4 - i - 1);
            result = result | (byteval << shift);
        }
        return result;
    };

    struct TagVersion {
        u8 major;
        u8 revision;
    };
    
    bitfield TagHeaderFlags {
        unsynchronized : 1;
        extended       : 1;
        experimental   : 1;
        footer         : 1;
        padding        : 4;
    };
    
    struct TagHeader {
        char           identifier[3];
        TagVersion     version;
        TagHeaderFlags flags;
        SyncSafeInt    size;
    };
    
    bitfield ExtendedFlag {
        padding      : 1;
        update       : 1;
        crcpresent   : 1;
        restrictions : 1;
        padding      : 4;
    };

    struct TagExtendedHeader {
        SyncSafeInt  size;
        u8           nflagbytes;
        ExtendedFlag flags[nflagbytes];
        u8           data[size];
    };
    
    struct TagFooter {
        char           identifier[3];
        TagVersion     version;
        TagHeaderFlags flags;
        SyncSafeInt    size;
    };
    
    bitfield FrameFlags {
        padding               : 1;
        tagalterpreservation  : 1;
        filealterpreservation : 1;
        readonly              : 1;
        padding               : 5;
        groupid               : 1;
        padding               : 2;
        compressed            : 1;
        encrypted             : 1;
        unzynchronized        : 1;
        datalengthindicator   : 1;
    };

    enum TextEncoding : u8 {
        ISO88591 = 0x00,
        UTF16BOM = 0x01,
        UTF16BE  = 0x02,
        UTF8     = 0x03,
    };

    struct StringData {
        TextEncoding encoding;
        if (encoding == TextEncoding::UTF16BOM) {
            u16    bom;
            char16 data[(parent.size - 3) / 2];
        } else if (encoding == TextEncoding::UTF16BE)
            be char16 data[(parent.size - 1) / 2];
        else
            char data[parent.size - 1];
    };

    // Hack to work around the fact, that chars may not be compared
    union FrameId {
        char cdata[4];
        u8   ndata[4];
    } [[sealed, format("v2::impl::format_frame_id")]];

    namespace impl {

    fn format_frame_id(ref FrameId id) {
        return id.cdata;
    };

    }
    
    struct Frame {
        FrameId     id;
        SyncSafeInt size;
        FrameFlags  flags;
        if (id.ndata[0] == 'T')
            StringData data;
        else
            u8      data[size];
    };

    fn has_next_frame(u32 size) {
        bool hasnext = $ < size;
        if (hasnext) {
            hasnext = std::mem::read_unsigned($, 1) != 0;
            $ = $ - 1;
        }
        return hasnext;
    };

    struct Tag {
        TagHeader header;
        if (header.flags.extended)
            TagExtendedHeader extendedheader;
        Frame     frames[while(v2::has_next_frame(header.size))];
        if (header.flags.footer)
            TagFooter footer;
    };

}

v2::Tag tag @ 0;
v1::Tag oldtag @ std::mem::size() - 128;
