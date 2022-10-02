#pragma once

#include <std/io.pat>
#include <std/math.pat>

namespace type {
    
    using float16 = u16 [[format("type::impl::format_float16")]];

    namespace impl {
    
        union U32ToFloatConverter {
            u32 intValue;
            float floatValue;
        };

        fn format_float16(float16 value) {	
            u32 sign = float16 >> 15;
            u32 exponent = (float16 >> 10) & 0x1F;
            u32 mantissa = float16 & 0x3FF;
    
            u32 result = 0x00;
    
            if (exponent == 0) {
                if (mantissa == 0) {
                    result = sign << 31;
                } else {
                    exponent = 0x7F - 14;
    
                    while ((mantissa & (1 << 10)) == 0) {
                        exponent -= 1;
                        mantissa <<= 1;
                    }
    
                    mantissa &= 0x3FF;
                    result = (sign << 31) | (exponent << 23) | (mantissa << 13);
                }
            } else if (exponent == 0x1F) {
                result = (sign << 31) | (0xFF << 23) | (mantissa << 13);
            } else {
                result = (sign << 31) | ((exponent + (0x7F - 15)) << 23) | (mantissa << 13);
            }
            
            U32ToFloatConverter converter;
            converter.intValue = result;
            
            return std::format("{}", converter.floatValue);
        };

    }

}
