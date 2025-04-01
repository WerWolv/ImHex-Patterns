#pragma once

import std.io;
import std.math;

/*!
    Types used to change the base of the displayed integer value.
    Used like `type::Hex<u32> hexNumber;`, `type::Oct<u16> octalNumber;`
*/

namespace auto type {
    
    /**
        Integer type representing a Hexadecimal value. Displays its value in hexadecimal format.
        @tparam T Integer type to use
    */
    using Hex<T> = T [[format("type::impl::format_hex")]];

    /**
        Integer type representing a Octal value. Displays its value in octal format.
        @tparam T Integer type to use
    */
    using Oct<T> = T [[format("type::impl::format_oct")]];

    /**
        Integer type representing a Decimal value. Displays its value in decimal format.
        @tparam T Integer type to use
    */
    using Dec<T> = T [[format("type::impl::format_dec")]];

    /**
        Integer type representing a Binary value. Displays its value in binary format.
        @tparam T Integer type to use
    */
    using Bin<T> = T [[format("type::impl::format_bin")]];

    namespace impl {

            fn format_number(auto value, str fmt) {
                bool negative = value < 0;
            
                if (negative)
                    return std::format("-" + fmt, std::math::abs(value));
                else
                    return std::format(fmt, value);
            };

            fn format_hex(auto value) { return type::impl::format_number(value, "0x{:02X}"); };
            fn format_oct(auto value) { return type::impl::format_number(value, "0o{:03o}"); };
            fn format_dec(auto value) { return type::impl::format_number(value, "{}"); };
            fn format_bin(auto value) { return type::impl::format_number(value, "0b{:08b}"); };

    }

}
