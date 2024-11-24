#pragma once

import std.limits;

/*!
    This library contains various helper functions for common bit operations.
*/

namespace auto std::bit {

    /**
        Calculates the number of 1 bits in a given number
        @param x The number
        @return The number of bits set to 1 in `x`
    */
    fn popcount(u128 x) {
        const u128 a = 0x55555555555555555555555555555555;
        const u128 b = 0x33333333333333333333333333333333;
        const u128 c = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;

        x = (x & a) + ((x >> 1) & a);
        x = (x & b) + ((x >> 2) & b);
        x = (x & c) + ((x >> 4) & c);

        return x % 0xFF;
    };

    /**
        Checks if only a single bit is set to 1 in a given number
        @param x The number
        @return True if there's a single bit set to 1 in `x`, false otherwise
    */
    fn has_single_bit(u128 x) {
        return x != 0 && (x & (x - 1)) == 0;
    };

    /**
        Rounds the given number up to the next bigger power of two
        @param x The number
        @return Next bigger power of two that can fit `x`
    */
    fn bit_ceil(u128 x) {
        if (x == 0) return 0;

        u8 i;
        while ((1 << i) < x)
            i = i + 1;

        return 1 << i;
    };

    /**
        Rounds the given number down to the next bigger power of two
        @param x The number
        @return Next smaller power of two
    */
    fn bit_floor(u128 x) {
        if (x == 0) return 0;

        u8 i;
        while ((x >> i) > 0)
            i = i + 1;

        return 1 << (i - 1);
    };

}
