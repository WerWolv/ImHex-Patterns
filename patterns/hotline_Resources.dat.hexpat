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
import std.hash;
import type.size;
import type.magic;
#ifdef __IMHEX__
import hex.core;
import hex.dec;
#endif

// Container layout, names format, and payload formats follow the openline
// sources: URez.cp (AWRZ + '%_nm'), UPixmap.cp (AWPX), USound.cp (AWSN),
// UIDVarArray.cp (IVA1), MsgBox.r (MSGB), HotlineArchiveStruct.h (harc) and
// HLProtocol.md (FILP).

// ImHex's visualizers take raw bytes, but AWPX images aren't in a format they
// read and AWSN samples are unsigned 8-bit. Converted copies (PNG/BMP files,
// 16-bit samples, text) are appended to this section, so the originals can
// still be shown as they are stored.
std::mem::Section previews = std::mem::create_section("Hotline previews");
u32 previewSectionCount = 1;
str exportBase = "";            // virtual file path (minus extension) of the pixmap being parsed

// The unit tests convert only the first few previews of each kind, as each
// one takes the same code path and large files hold hundreds.
u32 pngPreviewsLeft = 0xFFFFFFFF;
u32 bmpPreviewsLeft = 0xFFFFFFFF;
u32 soundPreviewsLeft = 0xFFFFFFFF;
#ifdef __PL_UNIT_TESTS__
pngPreviewsLeft = 8;
bmpPreviewsLeft = 8;
soundPreviewsLeft = 2;
#endif

fn take_png_preview() {
    if (pngPreviewsLeft == 0) return false;
    pngPreviewsLeft -= 1;
    return true;
};

fn take_bmp_preview() {
    if (bmpPreviewsLeft == 0) return false;
    bmpPreviewsLeft -= 1;
    return true;
};

fn take_sound_preview() {
    if (soundPreviewsLeft == 0) return false;
    soundPreviewsLeft -= 1;
    return true;
};

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

// The `size`-byte name at `address`, with each NUL between words as a space.
// Names in the sample files start with a NUL and use NUL between words
// ("\0logged\0in.awsn"); URez itself just copies them as opaque bytes.
fn clean_name(u128 address, u16 size) {
    u128 end = address + size;
    str s = "";
    str gap = "";
    u128 start = address;
    while (start < end) {
        s128 nul = std::mem::find_sequence_in_range(0, start, end, 0x00);
        if (nul < 0 || nul >= end)                      // the search can match past `end`
            nul = end;
        if (nul > start) {
            s = s + (s == "" ? "" : gap) + std::mem::read_string(start, nul - start);
            gap = "";
        }
        if (nul < end)
            gap = gap + " ";
        start = nul + 1;
    }
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
                        return clean_name(cursor + 6, size);
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
} [[name(clean_name(addressof(data), size)), format("format_name_entry")]];

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

// -- Exporting pixmaps: PNG for colour-table images, BMP for direct colour --

fn bytes_le16(u16 value) {
    return std::format("{:c}{:c}", char(value & 0xFF), char((value >> 8) & 0xFF));
};

fn bytes_be32(u32 value) {
    return bytes_rgba((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
};

// Unused palette entries, so any index a pixel can hold has a colour
str pngBlack = "";
for (u16 i = 0, i < 256 * 3, i += 1)
    pngBlack = pngBlack + std::format("{:c}", char(0));
str pngOpaque = "";             // and fully opaque alpha values
for (u16 j = 0, j < 256, j += 1)
    pngOpaque = pngOpaque + std::format("{:c}", char(0xFF));

fn read_be_section(u128 at) {
    u8 bytes[4] @ at in previews;
    return (u32(bytes[0]) << 24) | (u32(bytes[1]) << 16) | (u32(bytes[2]) << 8) | bytes[3];
};

fn png_crc_piece(u128 at, u32 size, u32 init) {
    u8 bytes[size] @ at in previews;
    return std::hash::crc32(bytes, init, 0x04C11DB7, 0xFFFFFFFF, true, true);
};

// Appends a chunk's CRC; `at` is where its length field was appended. Arrays
// declared in functions are limited to 65536 entries in ImHex, so the CRC is
// taken 64 KiB at a time: each piece starts from the previous CRC with the
// final XOR undone and its bits reversed (the builtin reflects its init).
fn png_end_chunk(u128 at) {
    u32 remaining = read_be_section(at) + 4;
    u128 piece = at + 4;
    u32 crc = std::math::min(remaining, 0x10000);
    crc = png_crc_piece(piece, crc, 0xFFFFFFFF);
    remaining -= std::math::min(remaining, 0x10000);
    while (remaining > 0) {
        piece += 0x10000;
        u32 state = crc ^ 0xFFFFFFFF;
        u32 init = 0;
        for (u8 i = 0, i < 32, i += 1)
            init = init | (((state >> i) & 1) << (31 - i));
        crc = png_crc_piece(piece, std::math::min(remaining, 0x10000), init);
        remaining -= std::math::min(remaining, 0x10000);
    }
    preview_append(bytes_be32(crc));
};

fn png_chunk(str type, str data) {
    png_end_chunk(preview_append(bytes_be32(std::string::length(data)) + type + data));
};

// A palette PNG. AWPX rows are packed MSB-first like PNG's 1/2/4/8-bit ones,
// so each row is copied as it is behind a "no filter" byte, and the zlib
// stream uses stored (uncompressed) blocks. The Adler-32 of the rows is
// summed 16 bytes at a time: split into even and odd bytes, each u128 holds
// eight 16-bit lanes, and multiplying by 1s (or by 8..1) adds the lanes (or
// weights them) into the top lane. The modulo waits until the end.
fn awpx_png(u128 pixelAddr, u32 width, u32 height, u32 rowBytes, u8 depth,
            u128 colorAddr, u16 colorCount, u32 transColor, bool useTrans) {
    // Colours are stored R,G,B,0: four at a time, then any left over
    u16 entries = 1 << depth;
    u16 used = std::math::min(colorCount, entries);
    str palette = "";
    u128 color = 0;
    for (u16 i = 0, i < used / 4 * 4, i += 4) {
        color = builtin::std::mem::read_unsigned(colorAddr + i * 4, 16, std::mem::Endian::Big);
        palette = palette + std::format("{:c}{:c}{:c}{:c}{:c}{:c}{:c}{:c}{:c}{:c}{:c}{:c}",
            char(color >> 120), char(color >> 112), char(color >> 104),
            char(color >> 88), char(color >> 80), char(color >> 72),
            char(color >> 56), char(color >> 48), char(color >> 40),
            char(color >> 24), char(color >> 16), char(color >> 8));
    }
    for (u16 i = used / 4 * 4, i < used, i += 1) {
        color = builtin::std::mem::read_unsigned(colorAddr + i * 4, 4, std::mem::Endian::Big);
        palette = palette + std::format("{:c}{:c}{:c}", char(color >> 24), char(color >> 16), char(color >> 8));
    }
    palette = palette + std::string::substr(pngBlack, 0, (entries - used) * 3);

    // Alpha for the entries up to the last transparent one
    str alpha = "";
    if (useTrans) {
        for (u16 k = 0, k < used, k += 1) {
            s128 found = builtin::std::mem::find_sequence_in_range(k, colorAddr, colorAddr + used * 4,
                (transColor >> 24) & 0xFF, (transColor >> 16) & 0xFF, (transColor >> 8) & 0xFF, transColor & 0xFF);
            if (found < 0)
                break;
            if ((found - colorAddr) % 4 == 0)
                alpha = alpha + std::string::substr(pngOpaque, 0, (found - colorAddr) / 4 - std::string::length(alpha))
                    + std::format("{:c}", char(0));
        }
    }
    u16 alphaCount = std::string::length(alpha);

    u32 lineBytes = (width * depth + 7) / 8;
    u32 rowsPerBlock = 65535 / (lineBytes + 1);
    u32 blocks = (height + rowsPerBlock - 1) / rowsPerBlock;
    u32 idatSize = 2 + blocks * 5 + height * (lineBytes + 1) + 4;
    preview_begin(8 + 25 + 12 + entries * 3 + (alphaCount > 0 ? 12 + alphaCount : 0) + 12 + idatSize + 12);

    u128 offset = preview_append(std::format("{:c}PNG{:c}{:c}{:c}{:c}",
        char(0x89), char(0x0D), char(0x0A), char(0x1A), char(0x0A)));
    png_chunk("IHDR", bytes_be32(width) + bytes_be32(height)
        + std::format("{:c}{:c}{:c}{:c}{:c}", char(depth), char(3), char(0), char(0), char(0)));
    png_chunk("PLTE", palette);
    if (alphaCount > 0)
        png_chunk("tRNS", alpha);

    str filter = std::format("{:c}", char(0));
    u128 idatAt = preview_append(bytes_be32(idatSize) + "IDAT"
        + std::format("{:c}{:c}", char(0x78), char(0x01)));
    // The per-chunk statements are kept few and the variables declared once:
    // this loop runs over every pixel byte.
    // Two 16-byte halves per step: the lane sums are linear, so the halves'
    // lanes are added before weighting, and the first half's bytes get 16
    // more each. Lanes stay below 65536 (four bytes each, weighted by <= 36).
    u32 pairBytes = lineBytes / 32 * 32;
    u8 tail = lineBytes % 16;
    u128 a = 1;
    u128 b = 0;
    u128 rowAddr = 0;
    u128 x = 0;
    u128 x2 = 0;
    u128 odd = 0;
    u128 lanes = 0;
    str block = "";
    for (u32 y = 0, y < height, y += rowsPerBlock) {
        u32 rows = std::math::min(rowsPerBlock, height - y);
        u16 length = rows * (lineBytes + 1);
        block = std::format("{:c}", char(y + rows == height ? 1 : 0)) + bytes_le16(length) + bytes_le16(~length);
        for (u32 r = y, r < y + rows, r += 1) {
            rowAddr = pixelAddr + r * rowBytes;
            block = block + filter + std::mem::read_string(rowAddr, lineBytes);
            b = b + a;                      // the filter byte (0)
            for (u32 c = 0, c < pairBytes, c += 32) {
                x = builtin::std::mem::read_unsigned(rowAddr + c, 16, 2);
                x2 = builtin::std::mem::read_unsigned(rowAddr + c + 16, 16, 2);
                odd = ((x >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF) + ((x2 >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF);
                lanes = (x & 0x00FF00FF00FF00FF00FF00FF00FF00FF) + (x2 & 0x00FF00FF00FF00FF00FF00FF00FF00FF) + odd;
                b = b + 32 * a + 16 * ((((x & 0x00FF00FF00FF00FF00FF00FF00FF00FF) + ((x >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF)) * 0x00010001000100010001000100010001) >> 112)
                    + 2 * ((lanes * 0x00080007000600050004000300020001) >> 112) - ((odd * 0x00010001000100010001000100010001) >> 112);
                a = a + ((lanes * 0x00010001000100010001000100010001) >> 112);
            }
            if (lineBytes - pairBytes >= 16) {
                x = builtin::std::mem::read_unsigned(rowAddr + pairBytes, 16, 2);
                odd = (x >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF;
                lanes = (x & 0x00FF00FF00FF00FF00FF00FF00FF00FF) + odd;
                b = b + 16 * a + 2 * ((lanes * 0x00080007000600050004000300020001) >> 112) - ((odd * 0x00010001000100010001000100010001) >> 112);
                a = a + ((lanes * 0x00010001000100010001000100010001) >> 112);
            }
            if (tail > 0) {                 // as if padded with zeros, less their weight
                x = builtin::std::mem::read_unsigned(rowAddr + lineBytes - tail, tail, 2);
                odd = (x >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF;
                lanes = (x & 0x00FF00FF00FF00FF00FF00FF00FF00FF) + odd;
                x2 = (lanes * 0x00010001000100010001000100010001) >> 112;
                b = b + tail * a + 2 * ((lanes * 0x00080007000600050004000300020001) >> 112) - ((odd * 0x00010001000100010001000100010001) >> 112) - (16 - tail) * x2;
                a = a + x2;
            }
        }
        preview_append(block);
    }
    preview_append(bytes_be32(((b % 65521) << 16) | (a % 65521)));
    png_end_chunk(idatAt);
    png_chunk("IEND", "");
    return offset;
};

// A top-down 32-bit BMP (BITMAPV4HEADER) whose pixels are the R,G,B,x bytes at
// `pixelsAt` in `pixelSection`, used as they are. A zero `alphaMask` means opaque.
fn awpx_bmp(std::mem::Section pixelSection, u128 pixelsAt, u32 width, u32 height, u32 alphaMask) {
    u32 imageSize = width * height * 4;
    str header = "BM" + bytes_le32(14 + 108 + imageSize) + bytes_le32(0) + bytes_le32(14 + 108)
        + bytes_le32(108) + bytes_le32(width) + bytes_le32(-height)       // negative = top-down
        + bytes_le16(1) + bytes_le16(32) + bytes_le32(3)                  // BI_BITFIELDS
        + bytes_le32(imageSize) + bytes_le32(2835) + bytes_le32(2835)    // 72 dpi
        + bytes_le32(0) + bytes_le32(0)
        + bytes_le32(0x000000FF) + bytes_le32(0x0000FF00)                // R, G
        + bytes_le32(0x00FF0000) + bytes_le32(alphaMask)                 // B, A
        + bytes_le32(0x73524742);                                         // 'sRGB'
    for (u8 i = 0, i < 12, i += 1)                                        // endpoints, gamma
        header = header + bytes_le32(0);
    preview_begin(14 + 108 + imageSize);
    u128 offset = preview_append(header);
    std::mem::copy_section_to_section(pixelSection, pixelsAt, previews, offset + 14 + 108, imageSize);
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

    // The image is written out as a PNG (colour table) or BMP (direct colour)
    // in the previews section. ImHex's "image" visualizer decodes that and
    // opens it about 200 px wide, where the "bitmap" one opens at 1:1 - tiny
    // for a 16x16 icon. Notes:
    // - an `@ ... in previews` address is evaluated with previews as the
    //   current section, so the writers must run (reading the file) first;
    // - patterns placed in another section are listed under that section, not
    //   as struct members, so the visualizer goes on the in-file `pixels`;
    // - the file* locals are for PixmapItem, which shows the first layer's
    //   image on the item's own row.
    u128 fileAt = 0;
    std::mem::Section fileSection = previews;
    u128 fileSize = 0;
    str fileExt = "";
    if (plain && (depth == 1 || depth == 2 || depth == 4 || depth == 8) && colorCount > 0 && take_png_preview()) {
        fileAt = awpx_png(pixelAddr, width, height, rowBytes, depth,
                          dataStart + colorDataOffset, colorCount, transColor, useTrans);
        fileSection = previews;
        fileSize = std::mem::get_section_size(fileSection) - fileAt;
        fileExt = ".png";
    } else if (plain && (depth == 24 || depth == 32) && take_bmp_preview()) {
        if (depth == 32 && !useTrans && rowBytes == width * 4) {
            fileAt = awpx_bmp(0, pixelAddr, width, height, 0);   // stored rows as they are
        } else {
            u128 rgbaAt = awpx_direct(pixelAddr, width, height, rowBytes, depth, transColor, useTrans);
            fileAt = awpx_bmp(previews, rgbaAt, width, height, 0xFF000000);
        }
        fileSection = previews;
        fileSize = 14 + 108 + width * height * 4;
        fileExt = ".bmp";
    }

    if (fileSize > 0) {
        u8 file[fileSize] @ fileAt in fileSection [[sealed]];
        u8 pixels[pixelSize] @ pixelAddr [[sealed, hex::visualize("image", file)]];
#ifdef __IMHEX__
        // Also listed in the Virtual Filesystem tab (exportBase is set by ItemData)
        str exportName = exportBase;
        if (std::core::array_index() > 0)
            exportName = std::format("{} layer {}", exportBase, std::core::array_index() + 1);
        hex::core::add_virtual_file(exportName + fileExt, file);
#endif
    } else {
        u8 pixels[pixelSize] @ pixelAddr [[sealed]];  // 16-bit, RLE or interlaced: no image
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

    // The image file PixmapItem shows: the first layer's (none if unsupported)
    u128 shownAt = 0;
    std::mem::Section shownSection = previews;
    u128 shownSize = 0;
    if (layerCount > 0) {
        shownAt = layers[0].fileAt;
        shownSection = layers[0].fileSection;
        shownSize = layers[0].fileSize;
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

    if (compType == SoundCompression::None && (sampleSize == 1 || sampleSize == 2) && chanCount > 0 && sampleRate > 0 && take_sound_preview()) {
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

// ImHex has no text visualizer, so text resources are previewed with the
// "table" one, which shows the formatted value of each entry of an array.
// These zero-size cells (placed on top of their owner, hidden) supply the
// entries: cell i is column i % 2 of row i / 2.
fn format_table_cell(ref auto cell) {
    return cell.text;
};

// -- IVA1: AppWarrior ID -> variable-size item array ('EMSG') --
//
// 'EMSG' resources hold the error messages UError shows: the resource ID is
// the error type (3 = memory, 4 = file system, ...) and each item ID an error
// code of that type.
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

struct IDVarCell {
    u32 row = std::core::array_index() / 2;
    str text = "";
    if (std::core::array_index() % 2 == 0)
        text = std::format("{}", parent.items[row].id);
    else
        text = parent.items[row].text;
} [[format("format_table_cell")]];

struct IDVarArray {
    type::Magic<"IVA1"> magic;
    padding[4];
    u32 textEncoding;
    u32 itemCount;
    IDVarOffset offsets[itemCount + 1] [[hidden]];
    IDVarItem items[itemCount];
    IDVarCell cells[itemCount * 2] @ addressof(this) [[hidden]];
    u32 tableRows = itemCount;
} [[format("format_id_var_array"), hex::visualize("table", cells, 2, itemCount)]];

fn format_id_var_array(ref IDVarArray a) {
    return std::format("{} items", a.itemCount);
};

// "id<tab>message" lines, for the Virtual Filesystem
fn id_var_text(ref IDVarArray a) {
    str text = "";
    for (u32 i = 0, i < a.itemCount, i += 1)
        text = text + a.cells[i * 2].text + "\t" + a.cells[i * 2 + 1].text + "\n";
    return text;
};

// -- MSGB: message box (AppWarrior MsgBox.r / MsgBox.cp) --

enum MsgBoxIcon : s16 {
    None     = 0,
    Stop     = 1000,
    Note     = 1001,
    Caution  = 1002,
    Question = 1003
};

struct PString {
    u8 size;
    char data[size];
} [[sealed, format("format_pstring")]];

fn format_pstring(ref PString p) {
    return std::format("\"{}\"", p.data);
};

fn msgbox_cell_text(u8 cell, s16 icon, s16 sound, str title, str message, str button1, str button2, str button3) {
    if (cell == 0) return "Title";
    if (cell == 1) return title;
    if (cell == 2) return "Message";
    if (cell == 3) return message;
    if (cell == 4) return "Buttons";
    if (cell == 5) {
        str buttons = button1 != "" ? button1 : "OK";    // MsgBox's default
        if (button2 != "") buttons = buttons + " | " + button2;
        if (button3 != "") buttons = buttons + " | " + button3;
        return buttons;
    }
    if (cell == 6) return "Icon";
    if (cell == 7) {
        if (icon == 0) return "None";
        if (icon == 1000) return "Stop (ICON 1000)";
        if (icon == 1001) return "Note (ICON 1001)";
        if (icon == 1002) return "Caution (ICON 1002)";
        if (icon == 1003) return "Question (ICON 1003)";
        return std::format("ICON {}", icon);
    }
    if (cell == 8) return "Sound";
    if (sound == 0) return "None";
    if (sound == 1) return "Beep";
    return std::format("SOUN {}", sound);
};

struct MsgBoxCell {
    str text = msgbox_cell_text(std::core::array_index(), s16(parent.icon), parent.sound,
        parent.title.data, parent.message.data, parent.button1.data, parent.button2.data, parent.button3.data);
} [[format("format_table_cell")]];

struct MessageBox {
    MsgBoxIcon icon;
    s16 picture;
    s16 sound;                  // 0 = none, 1 = beep, else a 'SOUN' ID
    s16 textStyle;
    s16 buttonTextStyle;
    s16 script;
    PString title;
    PString message;            // may hold UText::FormatArg directives (%#s)
    PString button1;            // empty = "OK"
    PString button2;            // empty = no button
    PString button3;
    MsgBoxCell cells[10] @ addressof(this) [[hidden]];
    u32 tableRows = 5;
} [[format("format_message_box"), hex::visualize("table", cells, 2, 5)]];

fn format_message_box(ref MessageBox m) {
    if (m.title.size > 0)
        return std::format("\"{}\" - \"{}\"", m.title.data, m.message.data);
    return std::format("\"{}\"", m.message.data);
};

// "Field: value" lines, for the Virtual Filesystem
fn message_box_text(ref MessageBox m) {
    str text = "";
    for (u8 i = 0, i < 10, i += 2)
        text = text + m.cells[i].text + ": " + m.cells[i + 1].text + "\n";
    return text;
};

// Stores text in the previews section and lists it as a file
fn add_text_file(str path, str text) {
    preview_begin(std::string::length(text));
    u128 at = preview_append(text);
    u8 bytes[std::string::length(text)] @ at in previews;
    hex::core::add_virtual_file(path, bytes);
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
    else if (std::string::ends_with(name, ".dat"))      // 'EMSG': "UMemory().dat"
        name = std::string::substr(name, 0, std::string::length(name) - 4);
    return std::format("{}/{} {}{}", fourcc(type), id, name, extension);
};

// One resource item's raw payload. dataOffset in the owning ItemEntry is
// already an absolute file offset, so a plain pointer resolves it directly.
struct ItemData {
    u32 typeCode = parent.typeCode;

    if (typeCode == 0x255F6E6D) {            // '%_nm'
        NameTable bytes;
    } else if (typeCode == 0x49434F4E || typeCode == 0x5049584D) { // 'ICON', 'PIXM'
        // Exported icons are named by ID only: looking up ~1300 names from
        // '%_nm' (a linear scan each) would add many seconds to every load.
        exportBase = std::format("{}/{}", fourcc(typeCode), parent.id);
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
#ifdef __IMHEX__
        add_text_file(virtual_file_name(typeCode, parent.id, ".txt"), id_var_text(bytes));
#endif
    } else if (typeCode == 0x4D534742) {     // 'MSGB'
        MessageBox bytes;
#ifdef __IMHEX__
        add_text_file(virtual_file_name(typeCode, parent.id, ".txt"), message_box_text(bytes));
#endif
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
    if (t == 0x4D534742) return format_message_box(item.data.bytes);
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
// sections, so they're re-declared here from the payload's shown* locals (or
// the text tables' cells) -
// under names nothing nested reuses, as the attribute resolves a
// section-placed name to the most recently declared pattern with that name.
struct PixmapItem : ItemEntry {
    u8 itemImage[data.bytes.shownSize] @ data.bytes.shownAt in data.bytes.shownSection [[sealed]];
} [[name(format_item_id(this)), format("format_item_entry"), hex::visualize("image", itemImage)]];

struct SoundItem : ItemEntry {
    le s16 itemSound[data.bytes.shownSamples] @ data.bytes.shownAt in data.bytes.shownSection [[sealed]];
} [[name(format_item_id(this)), format("format_item_entry"),
    hex::visualize("sound", itemSound, data.bytes.shownChannels, data.bytes.shownRate)]];

struct ImageItem : ItemEntry {
} [[name(format_item_id(this)), format("format_item_entry"), hex::visualize("image", data.bytes)]];

struct TableItem : ItemEntry {
} [[name(format_item_id(this)), format("format_item_entry"),
    hex::visualize("table", data.bytes.cells, 2, data.bytes.tableRows)]];

struct TypeEntry {
    char type[4] [[hidden]];     // 4-char type code (e.g. "PICT", "cicn", "%_nm")
    u32 itemCount [[hidden]];
    if (type == "ICON" || type == "PIXM")
        PixmapItem items[itemCount] [[inline]];
    else if (type == "SOUN")
        SoundItem items[itemCount] [[inline]];
    else if (type == "GIFf")
        ImageItem items[itemCount] [[inline]];
    else if (type == "EMSG" || type == "MSGB")
        TableItem items[itemCount] [[inline]];
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
