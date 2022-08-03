#pragma once

#include <std/io.pat>
#include <std/math.pat>

namespace type {
    
    using float16 = u16 [[format("type::impl::format_float16")]];

	namespace impl {

        fn format_float16(float16 value) {	
            float sign = (value >> 15) == 0b01 ? -1.0 : 1.0;
            float exponent = std::math::pow(2.0, float((value >> 10) & 0x1F) - 14);
            u16 mantissa = value & 0x3FF;
            
            float fraction = 0;
            for (s8 i = 9, i >= 0, i -= 1) {
                if ((mantissa & (1 << i)) != 0) {
                    fraction += 1.0 / std::math::pow(2.0, (10.0 - i));
                }
            }
            
            return std::format("{:f}", sign * exponent * fraction);     
        };

	}

}