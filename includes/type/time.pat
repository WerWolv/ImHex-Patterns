#pragma once

#include <std/io.pat>
#include <std/time.pat>

namespace type {
    
    using time32_t = u32 [[format("type::impl::format_time_t")]];
    using time64_t = u64 [[format("type::impl::format_time_t")]];

    namespace impl {

        fn format_time_t(time_t value) {	
            return std::time::format(std::time::to_utc(value));
        };

    }

}
