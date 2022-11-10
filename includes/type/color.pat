#pragma once

#include <std/io.pat>
#include <std/core.pat>

namespace type {

    struct RGB8 {
        u8 r, g, b;
    } [[sealed, format("type::impl::format_color")]];

    struct RGBA8 {
        u8 r, g, b, a;
    } [[sealed, format("type::impl::format_color")]];

    bitfield RGB565 {
        r : 5;
        g : 6;
        b : 5;
    } [[sealed, format("type::impl::format_color")]];

    bitfield RGBA4 {
        r : 4;
        g : 4;
        b : 4;
        a : 4;
    } [[sealed, format("type::impl::format_color")]];

    namespace impl {

        fn format_color(ref auto color) {
            if (!std::core::has_member(color, "a")) {
                return std::format("#{0:02X}{1:02X}{2:02X} | rgb({0}, {1}, {2})",
                                    color.r,
                                    color.g,
                                    color.b);
            } else {
                return std::format("#{0:02X}{1:02X}{2:02X}{3:02X} | rgba({0}, {1}, {2}, {3})",
                                    color.r,
                                    color.g,
                                    color.b,
                                    color.a);
            }
        };

    }

}
