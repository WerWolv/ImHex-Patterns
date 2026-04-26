#pragma author DexrnZacAttack
#pragma description Minecraft Infdev 20100624 Zone File
#pragma repo https://github.com/Team-Lodestone/ImHex-Patterns
#pragma version 1.0.0

#pragma magic [13 73 70 00] @ 0x00
#pragma endian big

import std.core;
import std.io;
import type.magic;

using long = s64;
using int = s32;
using short = s16;
using byte = s8;

bitfield u4 {
   low : 4;
   high : 4;
} [[static, inline]];

namespace InfdevZone {
    using ZoneFile;

    namespace Slot {
        int CHUNKS_PER_ZONE_BITS = 5;
        int CHUNKS_PER_ZONE = 1 << CHUNKS_PER_ZONE_BITS;

        int CHUNK_WIDTH = 16;
        int CHUNK_DEPTH = 16;
        int CHUNK_HEIGHT = 128;

        int CHUNK_HEADER_SIZE = 256;
        int CHUNK_SIZE = CHUNK_WIDTH * CHUNK_DEPTH * CHUNK_HEIGHT;
        int CHUNK_LAYERS = 3;
        int CHUNK_SIZE_BYTES = CHUNK_SIZE * CHUNK_LAYERS + CHUNK_HEADER_SIZE;

        /** Returns a slot from chunk coords
         *
         * @param cx Chunk X coordinate
         * @param cz Chunk Z coordinate
         * @return A slot for the given coords
         */
        fn getSlot(int cx, int cz) {
           int zoneX = cx >> CHUNKS_PER_ZONE_BITS;
           int zoneZ = cz >> CHUNKS_PER_ZONE_BITS;
           int offX = cx - (zoneX << CHUNKS_PER_ZONE_BITS);
           int offZ = cz - (zoneZ << CHUNKS_PER_ZONE_BITS);

           return offX + offZ * CHUNKS_PER_ZONE;
        };

        bitfield Properties {
            unused : 63 [[hidden]];
            terrainPopulated : 1;
        };

        struct Header {
            int x;
            int z;

            long inhabitedTime;
            Properties properties;

            padding[CHUNK_HEADER_SIZE - ($ - addressof(this))];
        };

        // or should this be called Chunk?
        // We need to figure out the actual terminology lmao
        struct Slot {
            InfdevZone::Slot::Header header [[inline]];

            byte blocks[CHUNK_SIZE];
            u4 data[CHUNK_SIZE / 2];
            u4 skyLight[CHUNK_SIZE / 2];
            u4 blockLight[CHUNK_SIZE / 2];
            byte heightmap[CHUNK_WIDTH * CHUNK_DEPTH] [[hex::visualize("bitmap", this, CHUNK_WIDTH, CHUNK_DEPTH)]];
        } [[name(std::format("Chunk @ {}, {}", header.x, header.z))]];
    }

    namespace ZoneFile {
        int FILE_HEADER_SIZE = 4096;
        int MAGIC_NUMBER = 0x13737000;
        int VERSION = 0x0000;

        struct Header {
            int magic;
            if (magic != MAGIC_NUMBER) {
                std::error(std::format("Magic value '{:#04x}' does not match expected magic '{:#04x}'", magic, MAGIC_NUMBER));
            }

            short version;
            if (version != VERSION) {
                std::error(std::format("Version '{:#02x}' does not match expected version '{:#02x}'", version, VERSION));
            }

            short slotCount;
            short slotLocations[slotCount];
        };

        /** Returns the offset in the data where a slot should be written
         *
         * @param slot The slot to get the offset of
         */
        fn getSlotOffset(int slot) {
            return (slot - 1) * CHUNK_SIZE_BYTES + FILE_HEADER_SIZE;
        };

        struct SlotElement {
              // std::print("{}", std::core::array_index());

              int loc = parent.header.slotLocations[std::core::array_index()];
              u64 idx = InfdevZone::ZoneFile::getSlotOffset(loc);

              if (idx != 0 && idx <= std::mem::size()) {
                InfdevZone::Slot::Slot slot @ idx;
              } else {
                if (idx == 0) {
                    std::warning(std::format("Skipping empty slot"));
                } else {
                    std::warning(std::format("Skipping invalid slot {} (would place at index {:#06x})", loc, idx));
                }
              }
        } [[inline]];

        struct ZoneFile {
            InfdevZone::ZoneFile::Header header [[inline]];

            InfdevZone::ZoneFile::SlotElement slots[header.slotCount];
        };
    }
}

#ifndef INF624_ZONE_USE_LIB
InfdevZone::ZoneFile::ZoneFile zone @ 0x00;
#endif
