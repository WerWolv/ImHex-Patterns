#pragma once

#include <std/io.pat>
#include <std/time.pat>

namespace type {

    using time32_t = u32 [[format("type::impl::format_time_t")]];
    using time64_t = u64 [[format("type::impl::format_time_t")]];
    using dosdate16_t = u16 [[format("type::impl::format_dosdate16_t")]];
    using dostime16_t = u16 [[format("type::impl::format_dostime16_t")]];

    namespace impl {

        fn format_time_t(u128 value) {
            return std::time::format(std::time::to_utc(value));
        };

        fn format_dosdate16_t(u16 value) {
            return std::time::format_dos_date(std::time::to_dos_date(value));
        };

        fn format_dostime16_t(u16 value) {
            return std::time::format_dos_time(std::time::to_dos_time(value));
        };

    }

}
