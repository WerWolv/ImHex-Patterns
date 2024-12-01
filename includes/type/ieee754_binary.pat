#pragma once

import std.core;
import std.math;
import std.io;
import std.sys;

// Types representing IEEE 754 2019 compatible binary floating point numbers
namespace auto type::ieee754
{
    /**
        settings:
        IEEE754_SUPPRESS_USAGE_WARNING - suppresses warnings related to recommendation to use built-in types
    */
    bool IEEE754_SUPPRESS_USAGE_WARNING in;

    /**
        Type representing a binary floating point number, taking a custom bias
        @tparam exponent_width number of bits to use for the biased exponent
        @tparam significand_width number of bits to use for the trailing significand field
        @tparam bias exponent bias
    */
    bitfield binary_with_bias<auto exponent_width, auto significand_width, auto bias>
    {
        sign: 1;
        biased_exponent: exponent_width;
        significand: significand_width;

        //usage assertions, intentionally not suppressible
        std::assert(exponent_width > 0, std::format("Invalid exponent_width! Expected >0, got {}", exponent_width));
        std::assert(significand_width > 0, std::format("Invalid significand_width! Expected >0, got {}", significand_width));

        if(!IEEE754_SUPPRESS_USAGE_WARNING)
        {
            //usage warnings, suppressible
            if((exponent_width == 8) && (significand_width == 23)){ std::warning("IEEE 754 binary32 used, prefer the use of in-built type instead"); }
            else if((exponent_width == 11) && (significand_width == 52)){ std::warning("IEEE 754 binary64 used, prefer the use of in-built type instead"); }
            //else if((exponent_width == 15) && (significand_width == 112)){ std::warning("IEEE 754 binary128 used, prefer the use of in-built type instead"); }
        }
    }
    [[
        bitfield_order(std::core::BitfieldOrder::MostToLeastSignificant, 1 + exponent_width + significand_width),
        format_read("type::ieee754::impl::format_binary"),
        transform("type::ieee754::impl::transform_binary")
    ]];

    /**
        Type representing a binary floating point number, using the canonical determination of bias
        @tparam exponent_width number of bits to use for the biased exponent
        @tparam significand_width number of bits to use for the trailing significand field
    */
    using binary<auto exponent_width, auto significand_width> = binary_with_bias<exponent_width, significand_width, (1 << (exponent_width - 1)) - 1>;

    namespace impl
    {
        fn format_binary(ref auto r)
        {
            //TODO: number of significant digits?
            return std::format("{}", r);
        };

        fn transform_binary(ref auto r)
        {
            s8 sign = r.sign ? -1 : 1;

            //is the exponent all 1's
            if(r.biased_exponent == ((1 << r.exponent_width) - 1))
            {
                if(r.significand != 0)
                {
                    //NaN's
                    //Note: payload not processed / decoded
                    return ((r.significand >> (r.significand_width - 1)) & 1) ? qNaN : sNaN;
                }
                else
                {
                    //Inf's
                    return sign * Inf;
                }
            }
            else if(r.biased_exponent == 0)
            {
                if(r.significand != 0)
                {
                    //subnormal numbers
                    return sign
                            * std::math::pow(2.0, 1 - r.bias)
                            * (0.0 + (double(r.significand) / (1 << r.significand_width)));
                }
                else
                {
                    //0's
                    return sign * 0;
                }
            }
            //normal numbers
            return sign
                    * std::math::pow(2, r.biased_exponent - r.bias)
                    * (1 + (double(r.significand) / (1 << r.significand_width)));
        };
    }

    using binary16 = binary<5, 10>; //aka half
    using binary32 = binary<8, 23>; //aka single or float - prefer the use of inbuilt-type instead
    using binary64 = binary<11, 52>; //aka double - prefer the use of inbuilt-type instead

    //defined in IEEE 754 2019, but not currently supported
    //using binary128 = binary<15, 112>; //aka quadruple - prefer the use of inbuilt-type instead, if available
    //using binary160 = binary<16, 143>;
    //using binary192 = binary<17, 174>;
    //using binary224 = binary<18, 205>;
    //using binary256 = binary<19, 236>; //aka octuple
}