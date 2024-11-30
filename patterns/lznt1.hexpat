#pragma description LZNT1
#pragma endian little
#pragma pattern_limit 1000000

/*
 * References:
 * https://github.com/libyal/libfwnt/blob/main/documentation/Compression%20methods.asciidoc
 * https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-xca/5655f4a3-6ba4-489b-959f-e1f407c52f15
 * https://github.com/tuxera/ntfs-3g/blob/edge/libntfs-3g/compress.c
 */

import std.core;
import std.io;
import std.mem;
import std.sys;

using BitfieldOrder = std::core::BitfieldOrder;
bool createDecompressedSection in;
std::mem::Section decompressedSection = 0;
u128 uncompressedDataSize = 0;
u128 maxUnitSize = 4096;

fn appendData(ref auto data) {
    if (createDecompressedSection) {
        std::mem::copy_value_to_section(data,
                                        decompressedSection,
                                        std::mem::get_section_size(decompressedSection));
    }

    uncompressedDataSize += sizeof(data);
};

struct Value {
    u8 value;
};

fn appendU8(u8 data) {
    Value value;
    value.value = data;
    appendData(value);
};

bitfield Flag {
    bool A : 1;
    bool B : 1;
    bool C : 1;
    bool D : 1;
    bool E : 1;
    bool F : 1;
    bool G : 1;
    bool H : 1;
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 8)]];

bitfield CompressedTuple<auto lengthSize, auto displacementSize> {
    std::assert(lengthSize >= 4 && lengthSize <= 12,
        std::format("lengthSize has an invalid value {}. Must be between 4 and 12.", lengthSize));
    std::assert(displacementSize >= 4 && displacementSize <= 12,
        std::format("displacementSizehas an invalid value {}. Must be between 4 and 12.", displacementSize));
    std::assert((lengthSize + displacementSize) == 16,
        std::format("lengthSize {} and displacementSize {} must add up to 16.", lengthSize, displacementSize));
    unsigned length : lengthSize;
    unsigned displacement : displacementSize;
    u16 actualLength = u16(length) + 3 [[export]];
    s16 actualDisplacement = -1 * (s16(displacement) + 1) [[export]];
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 16)]];

fn calculateLengthSize() {
    s8 lengthSize = 12;

    for (u128 i = uncompressedDataSize - 1, i >= 0x10, i = i >> 1) {
        lengthSize = lengthSize - 1;
    }

    if (lengthSize < 4) {
        lengthSize = 4;
    }

    return u8(lengthSize);
};

fn copySequentially(std::mem::Section section, u128 sourcePos, u128 destinationPos, u128 length) {
    for (u128 i = 0, i < length, i = i + 1) {
        std::mem::copy_section_to_section(section,
                                          sourcePos + i,
                                          section,
                                          destinationPos + i,
                                          1);
    }
};

struct Tuple {
    std::assert(uncompressedDataSize > 0,
                "uncompressedDataSize must be greater than zero"
                + " because otherwise there would be no data to backrefrence!");
    u8 ls = calculateLengthSize();
    CompressedTuple<ls, 16 - ls> ct[[inline]];
    std::assert((-1 * ct.actualDisplacement) <= uncompressedDataSize,
                std::format("The actualDisplacement {} is referencing data before the beginning"
                            + " of the current decompressed chunk! Current decompressed size is {}.",
                            ct.actualDisplacement,
                            uncompressedDataSize));

    if (createDecompressedSection) {
        u128 destinationPos = std::mem::get_section_size(decompressedSection);
        u128 destinationBackrefPos = destinationPos + ct.actualDisplacement;
        u128 maxNonOverlap = destinationPos - destinationBackrefPos;

        if (ct.actualLength <= maxNonOverlap) { // Not overlapping
            std::mem::copy_section_to_section(decompressedSection,
                                              destinationBackrefPos,
                                              decompressedSection,
                                              destinationPos,
                                              ct.actualLength);
        } else { // Overlapping
            // Copy non-overlapping part
            std::mem::copy_section_to_section(decompressedSection,
                                              destinationBackrefPos,
                                              decompressedSection,
                                              destinationPos,
                                              maxNonOverlap);
            // Copy overlapping part
            destinationPos += maxNonOverlap;
            destinationBackrefPos += maxNonOverlap;
            copySequentially(decompressedSection, destinationBackrefPos,
                             destinationPos, ct.actualLength - maxNonOverlap);
        }
    }

    uncompressedDataSize += ct.actualLength;
    std::assert(uncompressedDataSize <= maxUnitSize,
                std::format("uncompressedDataSize {} is larger than the maximum allowed size of {}.",
                            uncompressedDataSize,
                            maxUnitSize));
};

struct FlagGroup<auto endOffset> {
    Flag flag [[comment("Each bit represents whether a data element in a group of 8 is compressed "
                        + "with the first value being the least significant bit.")]];
    // (up to) 8 data elements
    if ($ >= endOffset) break;
    if (flag.A) { Tuple A; } else { u8 A; appendU8(A); }
    if ($ >= endOffset) break;
    if (flag.B) { Tuple B; } else { u8 B; appendU8(B); }
    if ($ >= endOffset) break;
    if (flag.C) { Tuple C; } else { u8 C; appendU8(C); }
    if ($ >= endOffset) break;
    if (flag.D) { Tuple D; } else { u8 D; appendU8(D); }
    if ($ >= endOffset) break;
    if (flag.E) { Tuple E; } else { u8 E; appendU8(E); }
    if ($ >= endOffset) break;
    if (flag.F) { Tuple F; } else { u8 F; appendU8(F); }
    if ($ >= endOffset) break;
    if (flag.G) { Tuple G; } else { u8 G; appendU8(G); }
    if ($ >= endOffset) break;
    if (flag.H) { Tuple H; } else { u8 H; appendU8(H); }
};

bitfield ChunkHeader {
    unsigned chunkDataSize : 12 [[comment("The actual value stored is the chunk data size - 1.")]];
    unsigned signatureValue : 3 [[comment("The value is always 3 except in an all-zero chunk header.")]];
    bool isCompressed : 1;
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 16)]];

struct Chunk {
    auto headerPos = $;
    ChunkHeader header;

    /* An all-zero chunk header indicates the end of an LZNT1 compression stream.
       Might not be present if there is not enough space to store it. */
    if (header.chunkDataSize == 0
        && header.signatureValue == 0
        && !header.isCompressed) {
        break;
    }

    std::assert_warn(header.signatureValue == 3,
        std::format("ChunkHeader @ {:#x} has a signatureValue other than 3: {}",
                    headerPos, header.signatureValue));

    u128 actualChunkDataSize = u128(header.chunkDataSize) + 1 [[export]];

    if (header.isCompressed) {
        auto currentEndOffset = $ + actualChunkDataSize;
        uncompressedDataSize = 0;
        FlagGroup<currentEndOffset> data[while($ < currentEndOffset)];
        std::assert($ == currentEndOffset,
            std::format("Invalid size of Chunk @ {:#x}.", headerPos));
    } else {
        std::assert_warn(actualChunkDataSize == maxUnitSize,
                         std::format("actualChunkDataSize {} must be equal to maxUnitSize {}.",
                                     actualChunkDataSize,
                                     maxUnitSize));
        u8 data[actualChunkDataSize];
        appendData(data);
    }
};

struct LZNT1 {
    if (createDecompressedSection) {
        decompressedSection = std::mem::create_section(std::format("decompressed @ {:#x}", $));
    }

    Chunk chunks[while($ < sizeof($))];
};

LZNT1 lznt1 @ 0x00;