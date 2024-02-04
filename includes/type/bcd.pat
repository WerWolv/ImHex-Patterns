#pragma once

import std.io;

/*!
    Type to decode a BCD (Binary Coded Decimal) number
*/

namespace type;

/**
    Decodes a BCD value where one byte represents a single digit
    @tparam Digits Number of digits
*/
struct BCD<auto Digits> {
    u8 bytes[Digits];
} [[sealed, format_read("type::impl::format_bcd")]];

namespace impl {

    fn format_bcd(ref auto bcd) {
        str result;

        for (u32 i = 0, i < sizeof(bcd.bytes), i += 1) {
            u8 byte = bcd.bytes[i];
            if (byte >= 10)
                return "Invalid";

            result += std::format("{}", byte);
        }

        return result;
    };

}
