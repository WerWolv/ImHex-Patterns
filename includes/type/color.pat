#pragma once

import std.io;
import std.core;

/*!
    Types representing RGB or RGBA colors. The decoded color will be displayed in their color field
*/

namespace auto type {

    /**
        Type representing a generic RGBA color with a variable number of bits for each color
        @tparam R Number of bits used for the red component
        @tparam G Number of bits used for the green component
        @tparam B Number of bits used for the blue component
        @tparam A Number of bits used for the alpha component
    */
    bitfield RGBA<auto R, auto G, auto B, auto A> {
        r : R;
        g : G;
        b : B;
        if (A > 0) a : A;
    } [[sealed, format("type::impl::format_color"), color(std::format("{0:02X}{1:02X}{2:02X}FF", r, g, b))]];

    /**
        Type representing a generic RGB color with a variable number of bits for each color
        @tparam R Number of bits used for the red component
        @tparam G Number of bits used for the green component
        @tparam B Number of bits used for the blue component
    */
    using RGB<auto R, auto G, auto B> = RGBA<R,G,B,0>;


    /**
        Type representing a RGBA color with 8 bits for the red component, 8 bits for green, 8 bits for blue and 8 bits for alpha
    */
    using RGBA8    = RGBA<8,8,8,8>;

    /**
        Type representing a RGB color with 8 bits for the red component, 8 bits for green and 8 bits for blue
    */
    using RGB8     = RGB<8,8,8>;

    /**
        Type representing a RGB color with 5 bits for the red component, 6 bits for green and 5 bits for blue
    */
    using RGB565   = RGB<5,6,5>;

    /**
        Type representing a RGBA color with 4 bits for the red component, 4 bits for green, 4 bits for blue and 4 bits for alpha
    */
    using RGB4444  = RGBA<4,4,4,4>;

    /**
        Type representing a RGBA color with 5 bits for the red component, 5 bits for green, 5 bits for blue and 1 bits for alpha
    */
    using RGBA5551 = RGBA<5,5,5,1>;


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