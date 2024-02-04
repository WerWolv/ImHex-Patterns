#pragma once

/*!
    The hash library contains various data hash functions
*/

namespace std::hash;

/**
    Calculates the CRC32 hash of the bytes inside of a given pattern
    @param pattern The pattern to calculate the crc32 hash of
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