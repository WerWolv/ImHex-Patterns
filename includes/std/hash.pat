#pragma once

/*!
    The hash library contains various data hash functions
*/

namespace auto std::hash {

    /**
        Calculates the CRC8 hash of the bytes inside of a given pattern
        @param pattern The pattern to calculate the CRC8 hash of
        @param init The CRC8 init value
        @param poly The CRC8 polynomial
        @param xorout The CRC8 XOR-Out value
        @param reflect_in Whether or not the input bytes should be reflected
        @param reflect_out Whether or not the output should be reflected
        @return Calculated CRC8 hash
    */
    fn crc8(ref auto pattern, u8 init, u8 poly, u8 xorout, bool reflect_in, bool reflect_out) {
        return builtin::std::hash::crc8(pattern, init, poly, xorout, reflect_in, reflect_out);
    };

    /**
        Calculates the CRC16 hash of the bytes inside of a given pattern
        @param pattern The pattern to calculate the CRC16 hash of
        @param init The CRC16 init value
        @param poly The CRC16 polynomial
        @param xorout The CRC16 XOR-Out value
        @param reflect_in Whether or not the input bytes should be reflected
        @param reflect_out Whether or not the output should be reflected
        @return Calculated CRC16 hash
    */
    fn crc16(ref auto pattern, u16 init, u16 poly, u16 xorout, bool reflect_in, bool reflect_out) {
        return builtin::std::hash::crc16(pattern, init, poly, xorout, reflect_in, reflect_out);
    };

    /**
        Calculates the CRC32 hash of the bytes inside of a given pattern
        @param pattern The pattern to calculate the CRC32 hash of
        @param init The CRC32 init value
        @param poly The CRC32 polynomial
        @param xorout The CRC32 XOR-Out value
        @param reflect_in Whether or not the input bytes should be reflected
        @param reflect_out Whether or not the output should be reflected
        @return Calculated CRC32 hash
    */
    fn crc32(ref auto pattern, u32 init, u32 poly, u32 xorout, bool reflect_in, bool reflect_out) {
        return builtin::std::hash::crc32(pattern, init, poly, xorout, reflect_in, reflect_out);
    };

    /**
        Calculates the CRC64 hash of the bytes inside of a given pattern
        @param pattern The pattern to calculate the CRC64 hash of
        @param init The CRC64 init value
        @param poly The CRC64 polynomial
        @param xorout The CRC64 XOR-Out value
        @param reflect_in Whether or not the input bytes should be reflected
        @param reflect_out Whether or not the output should be reflected
        @return Calculated CRC64 hash
    */
    fn crc64(ref auto pattern, u64 init, u64 poly, u64 xorout, bool reflect_in, bool reflect_out) {
        return builtin::std::hash::crc64(pattern, init, poly, xorout, reflect_in, reflect_out);
    };

}