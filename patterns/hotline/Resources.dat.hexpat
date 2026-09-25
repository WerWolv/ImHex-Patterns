#pragma author Scott Anderson
#pragma description Hotline/AppWarrior "AWRZ" flat resource file (*.dat)
#pragma magic [ 41 57 52 5a 00 01 ] @ 0x00
#pragma endian big
#pragma encoding macintosh

import std.core;
import std.io;
import std.math;
import std.mem;
import std.string;
import type.size;
import type.magic;
#ifdef __IMHEX__
import hex.core;
import hex.dec;
#endif

// Container layout, names format, and payload formats follow the openline
// sources: URez.cp (AWRZ + '%_nm'), UPixmap.cp (AWPX), USound.cp (AWSN),
// UIDVarArray.cp (IVA1), HotlineArchiveStruct.h (harc) and HLProtocol.md (FILP).

// ImHex's visualizers take raw bytes, but AWPX colours are stored R,G,B,0 and
// AWSN samples as unsigned 8-bit. Converted copies are appended to this
// section so the originals can still be shown as they are stored.
std::mem::Section previews = std::mem::create_section("Hotline previews");
u32 previewSectionCount = 1;

// Returns the offset the next converted block of `size` bytes will start at.
// Placements are bounds-checked against the size of the *main* data even in
// custom sections, so start a new section before offsets could pass it.
// Callers must read `previews` again afterwards, as it may have changed.
fn preview_begin(u128 size) {
    u128 used = std::mem::get_section_size(previews);
    if (used > 0 && used + size > std::mem::size()) {
        previewSectionCount += 1;
        previews = std::mem::create_section(std::format("Hotline previews {}", previewSectionCount));
    }
    return std::mem::get_section_size(previews);
};

// copy_value_to_section only takes patterns or strings, and strings are copied
// byte-for-byte - so converted data is built up as strings of "{:c}" bytes,
// a row or chunk at a time (one copy per byte is several times slower).
fn preview_append(str bytes) {
    u128 offset = std::mem::get_section_size(previews);
    std::mem::copy_value_to_section(bytes, previews, offset);
    return offset;
};

fn preview_copy(ref auto pattern, u128 size) {
    u128 offset = preview_begin(size);
    std::mem::copy_value_to_section(pattern, previews, offset);
    return offset;
};

// Zero-filled block: a transparent pixel or silence for unsupported formats.
fn preview_blank(u128 size) {
    u128 offset = preview_begin(size);
    std::mem::set_section_size(previews, offset + size);
    return offset;
};

fn bytes_rgba(u8 r, u8 g, u8 b, u8 a) {
    return std::format("{:c}{:c}{:c}{:c}", char(r), char(g), char(b), char(a));
};

fn bytes_le32(u32 value) {
    return bytes_rgba(value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF);
};

fn read_be(u128 address, u8 size) {
    return std::mem::read_unsigned(address, size, std::mem::Endian::Big);
};

fn fourcc(u32 code) {
    return std::format("{:c}{:c}{:c}{:c}",
        char((code >> 24) & 0xFF), char((code >> 16) & 0xFF),
        char((code >> 8) & 0xFF), char(code & 0xFF));
};

// Names in the sample files start with a NUL and use NUL between words
// ("\0logged\0in.awsn"); URez itself just copies them as opaque bytes.
fn clean_name(str name) {
    str s = std::string::replace(name, "\x00", " ");
    while (std::string::starts_with(s, " "))
        s = std::string::substr(s, 1, std::string::length(s) - 1);
    return s;
};

// Looks up the name of resource (type, id) in the '%_nm' resource whose ID is
// that type code. Works on raw file bytes, so it doesn't depend on the order
// the types appear in the map.
fn find_resource_name(u32 type, u32 id) {
    u128 map = 32 + read_be(28, 4);
    u32 typeCount = read_be(map + 4, 4);
    u128 typeEntry = map + 8;

    for (u32 t = 0, t < typeCount, t += 1) {
        u32 itemCount = read_be(typeEntry + 4, 4);
        u128 items = typeEntry + 8;

        if (read_be(typeEntry, 4) == 0x255F6E6D) { // '%_nm'
            for (u32 i = 0, i < itemCount, i += 1) {
                u128 item = items + i * 16;
                if (read_be(item, 4) != type)
                    continue;

                u128 table = read_be(item + 12, 4);
                u32 count = read_be(table, 4);
                u128 cursor = table + 4;
                for (u32 n = 0, n < count, n += 1) {
                    cursor = table + ((cursor - table + 3) & ~3);
                    u16 size = read_be(cursor + 4, 2);
                    if (read_be(cursor, 4) == id)
                        return clean_name(std::mem::read_string(cursor + 6, size));
                    cursor += 6 + size;
                }
                return "";
            }
        }

        typeEntry = items + itemCount * 16;
    }

    return "";
};

struct Header {
    type::Magic<"AWRZ"> magic;
    u16  version;
    padding[18];
    type::Size32  mapSize;
    type::Size32  dataSize;
};

// A '%_nm' entry: a name string keyed by the resource ID it names, with
// its `id` field always aligned to a 4-byte boundary (relative to the start
// of the '%_nm' resource's own data) - see the RESOURCE NAMES FORMAT comment
// in URez.cp. Alignment padding lands *before* id, not after data.
struct NameEntry {
    padding[while(($ - parent.startAddr) % 4 != 0)];
    s32 id;
    u16 size;
    char data[size];
} [[name(clean_name(data)), format("format_name_entry")]];

fn format_name_entry(ref NameEntry e) {
    return std::format("{} = \"{}\"", e.id, type::escape_bytes(e.data));
};

struct NameTable {
    u128 startAddr = $;
    u32 count;
    NameEntry names[count];

    // The item's dataSize itself is rounded up to a 4-byte boundary, so the
    // last entry can leave a few trailing unused bytes - consume them so the
    // struct's size still matches the containing ItemEntry.dataSize exactly.
    padding[while(($ - startAddr) % 4 != 0)];
} [[format("format_name_table")]];

fn format_name_table(ref NameTable t) {
    return std::format("{} names", t.count);
};

// -- AWPX: AppWarrior flattened pixmap ('ICON', 'PIXM') --

enum PixelCompression : u8 {
    None = 0,
    RLE  = 1
};

enum ColorPacking : u8 {
    RGB  = 0,
    RGBA = 1
};

fn format_rgba(u32 color) {
    return std::format("#{:08X}", color);
};

using Color = u32 [[format("format_rgba")]];   // bytes R, G, B, A (A unused)

// Copies the colour table with alpha forced to 0xFF (0x00 for the
// transparent colour) and returns its offset in the previews section.
fn awpx_palette(u128 address, u16 count, u32 transColor, bool useTrans) {
    // Hot loop (runs for every icon): calls builtins directly, as each
    // user-function call layer adds noticeably to load time.
    str bytes = "";
    for (u16 i = 0, i < count, i += 1) {
        u32 color = builtin::std::mem::read_unsigned(address + i * 4, 4, std::mem::Endian::Big);
        bytes = bytes + std::format("{:c}{:c}{:c}{:c}",
            char((color >> 24) & 0xFF), char((color >> 16) & 0xFF), char((color >> 8) & 0xFF),
            char((useTrans && color == transColor) ? 0x00 : 0xFF));
    }
    preview_begin(count * 4);
    return preview_append(bytes);
};

// Unpacks 1/2/4/8-bit pixel rows (most significant bits first, rows padded
// to rowBytes) into one index byte per pixel, and returns the offset.
fn awpx_indices(u128 address, u32 width, u32 height, u32 rowBytes, u8 depth) {
    u128 offset = preview_begin(width * height);
    u8 mask = (1 << depth) - 1;
    for (u32 y = 0, y < height, y += 1) {
        str row = "";
        for (u32 x = 0, x < width, x += 1) {
            u32 bit = x * depth;
            u8 byte = builtin::std::mem::read_unsigned(address + y * rowBytes + bit / 8, 1, std::mem::Endian::Big);
            row = row + std::format("{:c}", char((byte >> (8 - depth - bit % 8)) & mask));
        }
        preview_append(row);
    }
    return offset;
};

// Converts 24/32-bit RGB(x) pixel rows into tightly packed RGBA.
fn awpx_direct(u128 address, u32 width, u32 height, u32 rowBytes, u8 depth, u32 transColor, bool useTrans) {
    u8 bytesPerPixel = depth / 8;
    u128 offset = preview_begin(width * height * 4);
    for (u32 y = 0, y < height, y += 1) {
        str row = "";
        for (u32 x = 0, x < width, x += 1) {
            u32 rgb = builtin::std::mem::read_unsigned(address + y * rowBytes + x * bytesPerPixel, 3, std::mem::Endian::Big);
            row = row + std::format("{:c}{:c}{:c}{:c}",
                char((rgb >> 16) & 0xFF), char((rgb >> 8) & 0xFF), char(rgb & 0xFF),
                char((useTrans && (rgb << 8) == (transColor & 0xFFFFFF00)) ? 0x00 : 0xFF));
        }
        preview_append(row);
    }
    return offset;
};

struct PixmapLayer {
    u32 width;
    u32 height;
    u32 rowBytes;
    type::Size32 miscDataSize;
    u32 colorDataOffset;        // offsets are from the end of the layer headers
    u32 pixelDataOffset;
    u32 miscDataOffset;
    Color transColor;
    padding[2];
    u16 colorCount;
    padding[4];
    u8 depth;
    u8 pixPackType;
    PixelCompression pixCompType;
    u8 pixLaceType;
    ColorPacking colorPackType;
    u8 opts;                    // bit 0 = use transparent color
    padding[2];

    u128 dataStart = addressof(parent) + 16 + parent.layerCount * 48;
    bool useTrans = (opts & 1) != 0;

    if (colorCount > 0)
        Color colors[colorCount] @ dataStart + colorDataOffset;
    if (miscDataSize > 0)
        u8 miscData[miscDataSize] @ dataStart + miscDataOffset [[sealed]];

    bool plain = pixCompType == PixelCompression::None && pixLaceType == 0 && width > 0 && height > 0;
    u128 pixelAddr = dataStart + pixelDataOffset;
    u128 pixelSize = rowBytes * height;

    // Notes on the previews:
    // - an `@ ... in previews` address is evaluated with previews as the
    //   current section, so the converters must run (reading the file) first;
    // - patterns placed in another section are listed under that section, not
    //   as struct members, so the visualizers go on the in-file `pixels`
    //   (visualizers draw their first argument, not the pattern they're on);
    // - the preview* locals describe the converted image for PixmapItem, which
    //   shows the first layer's image on the item's own row.
    u128 paletteAt = 0;
    std::mem::Section paletteSection = previews;
    u16 previewColors = 0;      // palette entries; 0 = the preview is RGBA
    u128 previewAt = 0;
    std::mem::Section previewSection = previews;
    u32 previewWidth = width;
    u32 previewHeight = height;

    if (plain && depth == 8 && rowBytes == width && colorCount > 0) {
        paletteAt = awpx_palette(dataStart + colorDataOffset, colorCount, transColor, useTrans);
        paletteSection = previews;
        u32 palette[colorCount] @ paletteAt in paletteSection;
        u8 pixels[pixelSize] @ pixelAddr [[sealed, hex::visualize("bitmap", this, width, height, palette)]];
        previewColors = colorCount;
        previewAt = preview_copy(pixels, pixelSize);
        previewSection = previews;
    } else if (plain && (depth == 1 || depth == 2 || depth == 4 || depth == 8) && colorCount > 0) {
        paletteAt = awpx_palette(dataStart + colorDataOffset, colorCount, transColor, useTrans);
        paletteSection = previews;
        previewColors = colorCount;
        previewAt = awpx_indices(pixelAddr, width, height, rowBytes, depth);
        previewSection = previews;
        u32 palette[colorCount] @ paletteAt in paletteSection;
        u8 preview[width * height] @ previewAt in previewSection [[sealed]];
        u8 pixels[pixelSize] @ pixelAddr [[sealed, hex::visualize("bitmap", preview, width, height, palette)]];
    } else if (plain && (depth == 24 || depth == 32)) {
        previewAt = awpx_direct(pixelAddr, width, height, rowBytes, depth, transColor, useTrans);
        previewSection = previews;
        u8 preview[width * height * 4] @ previewAt in previewSection [[sealed]];
        u8 pixels[pixelSize] @ pixelAddr [[sealed, hex::visualize("bitmap", preview, width, height)]];
    } else {
        u8 pixels[pixelSize] @ pixelAddr [[sealed]];  // 16-bit, RLE or interlaced: no preview
        previewAt = preview_blank(4);                 // a transparent pixel instead
        previewSection = previews;
        previewWidth = 1;
        previewHeight = 1;
    }
} [[format("format_pixmap_layer")]];

fn format_pixmap_layer(ref PixmapLayer l) {
    return std::format("{}x{} {}-bit", l.width, l.height, l.depth);
};

struct Pixmap {
    type::Magic<"AWPX"> magic;
    u16 version;
    padding[8];
    u16 layerCount;
    PixmapLayer layers[layerCount];

    // The image PixmapItem shows: the first layer's, or a transparent pixel.
    u128 shownPaletteAt = 0;
    std::mem::Section shownPaletteSection = previews;
    u16 shownColors = 0;
    u128 shownAt = 0;
    std::mem::Section shownSection = previews;
    u32 shownWidth = 1;
    u32 shownHeight = 1;
    if (layerCount > 0) {
        shownPaletteAt = layers[0].paletteAt;
        shownPaletteSection = layers[0].paletteSection;
        shownColors = layers[0].previewColors;
        shownAt = layers[0].previewAt;
        shownSection = layers[0].previewSection;
        shownWidth = layers[0].previewWidth;
        shownHeight = layers[0].previewHeight;
    } else {
        shownAt = preview_blank(4);
        shownSection = previews;
    }
} [[format("format_pixmap")]];

fn format_pixmap(ref Pixmap p) {
    if (p.layerCount == 0)
        return "empty pixmap";
    str s = format_pixmap_layer(p.layers[0]);
    for (u16 i = 1, i < p.layerCount, i += 1)
        s = s + ", " + format_pixmap_layer(p.layers[i]);
    return s;
};

// -- AWSN: AppWarrior flattened sound ('SOUN') --

enum SoundCompression : u32 {
    None       = 0,
    IntelADPCM = 0x4950434D  // 'IPCM'
};

// ImHex's sound visualizer plays little-endian s16 and refuses clips shorter
// than a few thousand bytes, so widen the samples and pad with silence.
fn awsn_s16(u128 address, u32 count, u8 sampleSize) {
    u128 offset = preview_begin(std::math::max(count * 2, 9600));
    for (u32 chunk = 0, chunk < count, chunk += 1024) {
        str bytes = "";
        u32 end = std::math::min(count, chunk + 1024);
        for (u32 i = chunk, i < end, i += 1) {
            if (sampleSize == 1 && i + 4 <= end) {
                // Despite the "signed" comment in USound.cp, the stored 8-bit
                // samples are centred on 0x80 (classic Mac 'snd ' convention).
                // Four at a time, as each read call is the costly part.
                u32 four = builtin::std::mem::read_unsigned(address + i, 4, std::mem::Endian::Big) ^ 0x80808080;
                bytes = bytes + std::format("{:c}{:c}{:c}{:c}{:c}{:c}{:c}{:c}",
                    char(0), char((four >> 24) & 0xFF), char(0), char((four >> 16) & 0xFF),
                    char(0), char((four >> 8) & 0xFF), char(0), char(four & 0xFF));
                i += 3;
            } else if (sampleSize == 1) {
                bytes = bytes + std::format("{:c}{:c}", char(0), char(builtin::std::mem::read_unsigned(address + i, 1, std::mem::Endian::Big) ^ 0x80));
            } else {
                u16 sample = builtin::std::mem::read_unsigned(address + i * 2, 2, std::mem::Endian::Big);
                bytes = bytes + std::format("{:c}{:c}", char(sample & 0xFF), char(sample >> 8));
            }
        }
        preview_append(bytes);
    }
    std::mem::set_section_size(previews, offset + std::math::max(count * 2, 9600));
    return offset;
};

// Wraps 8-bit samples in a RIFF/WAVE header so the virtual file plays anywhere.
fn awsn_wav(ref auto samples, u32 size, u8 channels, u32 rate) {
    preview_begin(44 + size);
    u128 offset = preview_append("RIFF" + bytes_le32(36 + size) + "WAVEfmt " + bytes_le32(16)
        + bytes_le32(1 | (channels << 16))      // PCM, channel count
        + bytes_le32(rate) + bytes_le32(rate * channels)
        + bytes_le32(channels | (8 << 16))      // block align, bits per sample
        + "data" + bytes_le32(size));
    std::mem::copy_value_to_section(samples, previews, offset + 44);
    return offset;
};

struct Sound {
    type::Magic<"AWSN"> magic;
    u16 version;
    u8 chanCount;
    u8 sampleSize;              // bytes per sample
    u32 sampleRate;             // Hz
    u32 sampleCount;
    padding[8];
    SoundCompression compType;
    type::Size32 dataSize;

    // What SoundItem plays on the item's own row (silence if unsupported).
    u128 shownAt = 0;
    std::mem::Section shownSection = previews;
    u32 shownSamples = 4800;
    u8 shownChannels = 1;
    u32 shownRate = 22050;

    if (compType == SoundCompression::None && (sampleSize == 1 || sampleSize == 2) && chanCount > 0 && sampleRate > 0) {
        u32 sampleValues = dataSize / sampleSize;
        shownAt = awsn_s16($, sampleValues, sampleSize);
        shownSection = previews;
        shownSamples = std::math::max(sampleValues, 4800);
        shownChannels = chanCount;
        shownRate = sampleRate;
        le s16 preview[shownSamples] @ shownAt in shownSection [[sealed]];
        u8 samples[dataSize] [[sealed, hex::visualize("sound", preview, chanCount, sampleRate)]];
    } else {
        u8 samples[dataSize] [[sealed]];  // IMA ADPCM: no preview
        shownAt = preview_blank(shownSamples * 2);
        shownSection = previews;
    }
} [[format("format_sound")]];

fn format_sound(ref Sound s) {
    return std::format("{} Hz, {}-bit, {} ch, {} samples{}",
        s.sampleRate, s.sampleSize * 8, s.chanCount, s.sampleCount,
        s.compType == SoundCompression::None ? "" : ", IMA ADPCM");
};

// -- IVA1: AppWarrior ID -> variable-size item array ('EMSG') --

struct IDVarOffset {
    u32 id;
    u32 offset;                 // from end of the offset table
};

struct IDVarItem {
    u32 index = std::core::array_index();
    u32 id = parent.offsets[index].id;
    char text[parent.offsets[index + 1].offset - parent.offsets[index].offset];
} [[name(std::format("[{}]", id)), format("format_id_var_item")]];

fn format_id_var_item(ref IDVarItem i) {
    return std::format("\"{}\"", type::escape_bytes(i.text));
};

struct IDVarArray {
    type::Magic<"IVA1"> magic;
    padding[4];
    u32 textEncoding;
    u32 itemCount;
    IDVarOffset offsets[itemCount + 1] [[hidden]];
    IDVarItem items[itemCount];
} [[format("format_id_var_array")]];

fn format_id_var_array(ref IDVarArray a) {
    return std::format("{} items", a.itemCount);
};

// -- harc: Hotline archive ('harc'), each file a zlib-compressed FILP --

struct PString64 {
    u8 size;
    char data[size];
    padding[63 - size];
} [[sealed, format("format_pstring64")]];

fn format_pstring64(ref PString64 s) {
    return s.data;
};

struct FlatInfo {
    u128 start = $;
    char platform[4];           // 'AMAC' or 'MWIN'
    char typeCode[4];
    char creatorCode[4];
    u32 flags;
    u32 platformFlags;
    padding[32];
    u8 createDate[8];
    u8 modifyDate[8];
    u16 nameScript;
    u16 nameSize;
    char name[nameSize];
    if ($ - start + 2 <= parent.dataSize) {
        u16 commentSize;
        char comment[commentSize];
    }
    padding[parent.dataSize - ($ - start)];
} [[format("format_flat_info")]];

fn format_flat_info(ref FlatInfo i) {
    return std::format("\"{}\" '{}'/'{}'", i.name, i.typeCode, i.creatorCode);
};

struct FlatFork {
    char forkType[4];           // 'INFO', 'DATA' or 'MACR'
    u32 compressionType;
    padding[4];
    type::Size32 dataSize;
    if (forkType == "INFO")
        FlatInfo info;
    else
        u8 data[dataSize] [[sealed]];
} [[name(forkType), format("format_flat_fork")]];

fn format_flat_fork(ref FlatFork f) {
    if (f.forkType == "INFO")
        return format_flat_info(f.info);
    return std::format("{} bytes", f.dataSize);
};

struct FlatFile {
    type::Magic<"FILP"> magic;
    u16 version;
    padding[16];
    u16 forkCount;
    FlatFork forks[forkCount];
};

#ifdef __IMHEX__
// Exposes the file's DATA fork (the actual file contents) in ImHex's Virtual
// Filesystem tab. A function, as struct bodies can't contain loops.
fn add_data_fork_file(ref FlatFile flatFile, str path) {
    for (u16 f = 0, f < flatFile.forkCount, f += 1) {
        if (flatFile.forks[f].forkType == "DATA")
            hex::core::add_virtual_file(path, flatFile.forks[f].data);
    }
};
#endif

struct ArchivePathItem {
    u16 script;
    u8 size;
    char name[size];
} [[sealed, format("format_archive_path_item")]];

fn format_archive_path_item(ref ArchivePathItem p) {
    return p.name;
};

struct ArchiveFile {
    char entryType[4];          // 'file', 'fldr', 'link' or 'text'
    padding[4];
    type::Size16 pathSize;
    u16 pathCount;
    ArchivePathItem path[pathCount];
    u16 rsvdSize;
    padding[rsvdSize];
    char compressionType[4];    // 'zlib'
    type::Size32 decompressedSize;
    type::Size32 compressedSize;
    u8 compressedData[compressedSize] [[sealed]];

#ifdef __IMHEX__
    if (compressionType == "zlib") {
        // The stream has no zlib end marker, so zlib_decompress stops with the
        // section padded to its buffer size - trim it to the declared size.
        std::mem::Section section = std::mem::create_section(std::format("harc: {}", path[pathCount - 1].name));
        hex::dec::zlib_decompress(compressedData, section, 15);
        if (std::mem::get_section_size(section) >= decompressedSize) {
            std::mem::set_section_size(section, decompressedSize);
            FlatFile flatFile @ 0x00 in section;
            add_data_fork_file(flatFile, std::format("harc/{}", path[pathCount - 1].name));
        } else {
            std::warning(std::format("harc: '{}' failed to decompress", path[pathCount - 1].name));
        }
    }
#endif
} [[name(path[pathCount - 1].name), format("format_archive_file")]];

fn format_archive_file(ref ArchiveFile f) {
    return std::format("'{}', {} bytes ({} compressed)", f.entryType, f.decompressedSize, f.compressedSize);
};

struct Archive {
    type::Magic<"harc"> magic;
    u32 version;
    type::Size32 archiveSize;
    padding[16];
    PString64 archiveName;
    u16 fileCount;
    u16 fileAutoLaunch;         // 1-based file index, 0 = none
    u16 rsvd3Size;
    padding[rsvd3Size];
    ArchiveFile files[fileCount];
} [[format("format_archive")]];

fn format_archive(ref Archive a) {
    return std::format("{} files", a.fileCount);
};

// -- Resource map --

fn virtual_file_name(u32 type, s32 id, str extension) {
    str name = find_resource_name(type, id);
    if (name == "")
        return std::format("{}/{}{}", fourcc(type), id, extension);

    // Names are often the original file names ("banner.gif", "login.awsn")
    if (std::string::ends_with(name, extension))
        extension = "";
    else if (std::string::ends_with(name, ".awsn"))
        name = std::string::substr(name, 0, std::string::length(name) - 5);
    return std::format("{}/{} {}{}", fourcc(type), id, name, extension);
};

// One resource item's raw payload. dataOffset in the owning ItemEntry is
// already an absolute file offset, so a plain pointer resolves it directly.
struct ItemData {
    u32 typeCode = parent.typeCode;

    if (typeCode == 0x255F6E6D) {            // '%_nm'
        NameTable bytes;
    } else if (typeCode == 0x49434F4E || typeCode == 0x5049584D) { // 'ICON', 'PIXM'
        Pixmap bytes;
    } else if (typeCode == 0x534F554E) {     // 'SOUN'
        Sound bytes;
#ifdef __IMHEX__
        if (bytes.compType == SoundCompression::None && bytes.sampleSize == 1) {
            u128 wavAt = awsn_wav(bytes.samples, bytes.dataSize, bytes.chanCount, bytes.sampleRate);
            u8 wav[44 + bytes.dataSize] @ wavAt in previews [[sealed]];
            hex::core::add_virtual_file(virtual_file_name(typeCode, parent.id, ".wav"), wav);
        }
#endif
    } else if (typeCode == 0x454D5347) {     // 'EMSG'
        IDVarArray bytes;
    } else if (typeCode == 0x68617263) {     // 'harc'
        Archive bytes;
    } else if (typeCode == 0x47494666) {     // 'GIFf'
        u8 bytes[parent.dataSize] [[sealed, hex::visualize("image", this)]];
#ifdef __IMHEX__
        hex::core::add_virtual_file(virtual_file_name(typeCode, parent.id, ".gif"), bytes);
#endif
    } else if (typeCode == 0x4D6F6F56) {     // 'MooV'
        u8 bytes[parent.dataSize] [[sealed]];
#ifdef __IMHEX__
        hex::core::add_virtual_file(virtual_file_name(typeCode, parent.id, ".mov"), bytes);
#endif
    } else {
        u8 bytes[parent.dataSize];
    }
};

struct ItemEntry {
    // Items follow their TypeEntry's 8-byte header, 16 bytes each. (Not read
    // via parent.type: in the derived item types below, `parent` in this
    // base body isn't the TypeEntry.)
    u32 typeCode = read_be($ - 8 - std::core::array_index() * 16, 4);
    s32 id [[hidden]];
    u32 attrib;
    type::Size32 dataSize;
    u32 dataPtr [[hidden]];
    ItemData data @ dataPtr [[inline]];
} [[name(format_item_id(this)), format("format_item_entry")]];

fn format_item_id(ref auto item) {
    if (item.typeCode == 0x255F6E6D)
        return std::format("'{}' names", fourcc(item.id));
    return std::format("{}", item.id);
};

fn format_item_summary(ref auto item) {
    u32 t = item.typeCode;
    if (t == 0x255F6E6D) return format_name_table(item.data.bytes);
    if (t == 0x49434F4E || t == 0x5049584D) return format_pixmap(item.data.bytes);
    if (t == 0x534F554E) return format_sound(item.data.bytes);
    if (t == 0x454D5347) return format_id_var_array(item.data.bytes);
    if (t == 0x68617263) return format_archive(item.data.bytes);
    if (t == 0x47494666) return std::format("GIF image, {} bytes", item.dataSize);
    if (t == 0x4D6F6F56) return std::format("QuickTime movie, {} bytes", item.dataSize);
    return std::format("{} bytes", item.dataSize);
};

// The '%_nm' lookup is a linear scan, so it lives in the (lazily evaluated)
// format rather than [[name]], which is evaluated eagerly for every item.
fn format_item_entry(ref auto item) {
    str name = "";
    if (item.typeCode != 0x255F6E6D)
        name = find_resource_name(item.typeCode, item.id);
    if (name == "")
        return format_item_summary(item);
    return std::format("\"{}\" - {}", name, format_item_summary(item));
};

// Items whose row itself carries the preview (an eye button before the value),
// so there's no digging down to a layer's pixels. The previews live in other
// sections, so they're re-declared here from the payload's shown* locals -
// under names nothing nested reuses, as the attribute resolves a
// section-placed name to the most recently declared pattern with that name.
struct PixmapItem : ItemEntry {
    u32 itemPalette[data.bytes.shownColors] @ data.bytes.shownPaletteAt in data.bytes.shownPaletteSection;
    u8 itemImage[data.bytes.shownWidth * data.bytes.shownHeight * (data.bytes.shownColors > 0 ? 1 : 4)]
        @ data.bytes.shownAt in data.bytes.shownSection [[sealed]];
} [[name(format_item_id(this)), format("format_item_entry"),
    hex::visualize("bitmap", itemImage, data.bytes.shownWidth, data.bytes.shownHeight, itemPalette)]];

struct SoundItem : ItemEntry {
    le s16 itemSound[data.bytes.shownSamples] @ data.bytes.shownAt in data.bytes.shownSection [[sealed]];
} [[name(format_item_id(this)), format("format_item_entry"),
    hex::visualize("sound", itemSound, data.bytes.shownChannels, data.bytes.shownRate)]];

struct ImageItem : ItemEntry {
} [[name(format_item_id(this)), format("format_item_entry"), hex::visualize("image", data.bytes)]];

struct TypeEntry {
    char type[4] [[hidden]];     // 4-char type code (e.g. "PICT", "cicn", "%_nm")
    u32 itemCount [[hidden]];
    if (type == "ICON" || type == "PIXM")
        PixmapItem items[itemCount] [[inline]];
    else if (type == "SOUN")
        SoundItem items[itemCount] [[inline]];
    else if (type == "GIFf")
        ImageItem items[itemCount] [[inline]];
    else
        ItemEntry items[itemCount] [[inline]];
} [[name(type), format("format_type_entry")]];

fn format_type_entry(ref TypeEntry t) {
    return std::format("'{}' [{}]", t.type, t.itemCount);
};

struct ResourceMap {
    u32 checkOffset [[hidden]];
    std::assert(checkOffset + 4 == $, "");
    u32 typeCount [[hidden]];
    TypeEntry types[typeCount] [[inline]];
};

struct HL_DatFile {
    Header header;
    u8 resourceData[header.dataSize] [[hidden]];
    ResourceMap map;
};

HL_DatFile file @ 0x00 [[inline]];
