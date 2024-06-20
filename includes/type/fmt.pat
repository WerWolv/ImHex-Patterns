#pragma once

import std.io;

/*!
    Type that allows specifying its format value using a format string.
    ## Usage

    The following code reads a u32 from the data and formats it as an upper case hexadecimal value with
    a minimum of 8 digits which is prefixed by 0x.

    The format string is the same as passed to `std::format()` and follows the libfmt specification.

    ```rust
        type::Formatted<u32, "0x{:08X}"> hex_formatted_integer @ 0x00;
    ```
*/

namespace auto type {

    /**
        Arbitrarily formatted type
        @tparam T Type to format
        @tparam FormatString libfmt format string to format the value
    */
    struct Formatted<T, auto FormatString> {
        T value;
    } [[sealed, format("type::impl::format_formatted"), transform("type::impl::transform_formatted")]];

    namespace impl {

        fn format_formatted(ref auto formatted) {
            return std::format(std::format("{{0:{}}}", formatted.FormatString), formatted.value);
        };

        fn transform_formatted(ref auto formatted) {
            return formatted.value;
        };

    }

}