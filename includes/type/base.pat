#pragma once

#include <std/io.pat>
#include <std/math.pat>

namespace type {
    
    using Hex<T> = T [[format("type::impl::format_hex")]];
    using Oct<T> = T [[format("type::impl::format_oct")]];
    using Dec<T> = T [[format("type::impl::format_dec")]];
    using Bin<T> = T [[format("type::impl::format_bin")]];

	namespace impl {

        fn format_number(auto value, str fmt) {
            bool negative = value < 0;
            
            if (negative)
                return std::format("-" + fmt, std::math::abs(value));
            else
                return std::format(fmt, value);
        };

        fn format_hex(auto value) { return format_number(value, "0x{:02X}"); };
        fn format_oct(auto value) { return format_number(value, "0o{:03o}"); };
        fn format_dec(auto value) { return format_number(value, "{}"); };
        fn format_bin(auto value) { return format_number(value, "0b{:08b}"); };

	}

}