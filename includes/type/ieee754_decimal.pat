#pragma once

import std.core;
import std.math;
import std.io;
import std.sys;

namespace auto type {
/**
    Types representing IEEE 754 2019 compatible decimal floating point numbers
    defines:
    IEEE754_SUPPRESS_WARNING - suppresses warnings about canonicity of values being decoded
    IEEE754_UNSEAL - show internal bitfields
*/
namespace ieee754
{
    /**
        Decimal floating point numbers can be encoded using one of multiple methods
        Selection of which method to use is implementation specific, and cannot be determined from the binary data alone
    */
    enum decimal_encoding : u8
    {
        binary = 2, // aka binary integer decimal (BID)
        decimal = 10 // aka densely packed decimal (DPD)
    };

    /**
        Type representing a decimal floating point number, taking a custom bias
        @tparam combination_width number of bits to use for the biased exponent
        @tparam significand_width number of bits to use for the trailing significand field
        @tparam encoding whether to use binary or decimal encoding
        @tparam bias exponent bias
    */
    bitfield decimal_with_bias<auto combination_width, auto significand_width, auto encoding, auto bias>
    {
        sign: 1;
        combination: combination_width;
        significand: significand_width;

        //usage assertions, intentionally not suppressible
        std::assert(combination_width > 5, std::format("Invalid combination_width! Expected >5, got {}", combination_width));
        std::assert(significand_width > 0, std::format("Invalid significand_width! Expected >0, got {}", significand_width));
        std::assert((encoding == decimal_encoding::binary) || (encoding == decimal_encoding::decimal), "Invalid encoding! Expected either decimal_encoding::binary or decimal_encoding::decimal");
        std::assert((significand_width % 10) == 0, std::format("Invalid significand_width! Expected multiple of 10, got {}", significand_width));

        //PL currently only supports up to u128
        std::assert((encoding == decimal_encoding::decimal) || ((significand_width + 4) <= 128), std::format("Invalid significand_width for binary encoding! Expected <= 120, got {}", significand_width));
    }
    [[
#ifndef IEEE754_UNSEAL
        sealed,
#endif
        bitfield_order(std::core::BitfieldOrder::MostToLeastSignificant, 1 + combination_width + significand_width),
        format_read("type::ieee754::impl::format_decimal")
    ]];

    /**
        Type representing a decimal floating point number, using the canonical determination of bias
        @tparam combination_width number of bits to use for the biased exponent
        @tparam significand_width number of bits to use for the trailing significand field
        @tparam encoding whether to use binary or decimal encoding
    */
    using decimal<auto combination_width, auto significand_width, auto encoding> = decimal_with_bias<combination_width, significand_width, encoding, (3 * ((1 << (combination_width - 6)) + (significand_width / 10))) - 1>;

    namespace impl
    {
        fn format_decimal(ref auto r)
        {
            s8 sign = r.sign ? -1 : 1;
            auto w = r.combination_width - 5;

            if((r.combination >> w) & 0b11111 == 0b11111)
            {
                //NaN's
                bool is_signaling = ((r.combination >> (w - 1)) & 1 == 1);
                //Note: payload not processed / decoded
                //Note: NaN might not be canonical
#ifndef IEEE754_SUPPRESS_WARNING
                //check if combination field is canonical (all remaining bits are 0)
                auto remaining_combination_bits = (r.combination & ((1 << (w - 1)) - 1));
                std::assert_warn(remaining_combination_bits == 0, std::format("NaN - remaining combination field bits not canonical! Expected 0, got {}", remaining_combination_bits));
                //TODO: also check if encoding of the payload is canonical
#endif
                return is_signaling ? "sNaN" : "qNaN";
            }
            else if((r.combination >> w) & 0b11111 == 0b11110)
            {
                //Inf's
                //Note: Inf might not be canonical
#ifndef IEEE754_SUPPRESS_WARNING
                //check if combination field is canonical (all remaining bits are 0)
                auto remaining_combination_bits = r.combination & ((1 << w) - 1);
                std::assert_warn(remaining_combination_bits == 0, std::format("Inf - remaining combination field bits not canonical! Expected 0, got {}", remaining_combination_bits));
                std::assert_warn(r.significand == 0, std::format("Inf - significand not canonical! Expected 0, got {}", r.significand));
#endif
                return r.sign ? "-Inf" : "Inf";
            }
            else if(r.encoding == decimal_encoding::binary)
            {
                str output = r.sign ? "-" : "";
                //0 0 e ... e t t t => 00e...e, 0ttt{significand}
                //0 1 e ... e t t t => 01e...e, 0ttt{significand}
                //1 0 e ... e t t t => 10e...e, 0ttt{significand}
                //1 1 0 0 e ... e t => 00e...e, 100t{significand}
                //1 1 0 1 e ... e t => 01e...e, 100t{significand}
                //1 1 1 0 e ... e t => 10e...e, 100t{significand}
                s128 biased_exponent;
                u128 full_significand;
                if((r.combination >> (r.combination_width - 2)) & 0b11 == 0b11)
                {
                    biased_exponent = (r.combination >> 1) & ((1 << (r.combination_width - 3)) - 1);
                    full_significand = ((0b1000 | (r.combination & 0b1)) << r.significand_width) | r.significand;
                }
                else
                {
                    biased_exponent = (r.combination >> 3) & ((1 << (r.combination_width - 3)) - 1);
                    full_significand = ((r.combination & 0b111) << r.significand_width) | r.significand;
                }

                u128 max_value = std::math::pow(10, 3 * (significand_width / 10)) - 1;
                if((full_significand == 0) || (full_significand > max_value))
                {
                    //0s
#ifndef IEEE754_SUPPRESS_WARNING
                    std::assert_warn(full_significand == 0, std::format("0 - significand not canonical! Expected < {}, got {}", max_value, full_significand));
#endif
                    return r.sign ? "-0" : "0";
                }

                return std::format("{}{}E{}{}", sign, full_significand, (biased_exponent - r.bias) < 0 ? "" : "+", biased_exponent - r.bias);
            }
            else if(r.encoding == decimal_encoding::decimal)
            {
                str output = r.sign ? "-" : "";
                //0 0 t t t e ... e => 00e...e, 0ttt.significand
                //0 1 t t t e ... e => 01e...e, 0ttt.significand
                //1 0 t t t e ... e => 10e...e, 0ttt.significand
                //1 1 0 0 t e ... e => 00e...e, 100t.significand
                //1 1 0 1 t e ... e => 01e...e, 100t.significand
                //1 1 1 0 t e ... e => 10e...e, 100t.significand
                s128 biased_exponent = (r.combination & ((1 << w) - 1));
                if((r.combination >> (r.combination_width - 2)) & 0b11 == 0b11)
                {
                    biased_exponent |= (((r.combination >> (r.combination_width - 4)) & 0b11) << w);
                    output = std::format("{}{}.", output, 8 | ((r.combination >> w) & 1));
                }
                else if((((r.combination >> w) & 0b111) == 0) && (r.significand == 0))
                {
                    //0s
                    return r.sign ? "-0" : "0";
                }
                else
                {
                    biased_exponent |= (((r.combination >> (r.combination_width - 2)) & 0b11) << w);
                    output = std::format("{}{}.", output, (r.combination >> w) & 0b111);
                }

                //every 10 bit of significand gets decoded using one of
                //9 8 7 6 5 4 3 2 1 0      2    1    0
                //all small
                //a b c d e f 0 g h i => 0abc 0def 0ghi
                //1 large
                //a b c d e f 1 0 0 i => 0abc 0def 100i
                //a b c g h f 1 0 1 i => 0abc 100f 0ghi
                //g h c d e f 1 1 0 i => 100c 0def 0ghi
                //2 large
                //g h c 0 0 f 1 1 1 i => 100c 100f 0ghi
                //d e c 0 1 f 1 1 1 i => 100c 0def 100i
                //a b c 1 0 f 1 1 1 i => 0abc 100f 100i
                //all large
                //x x c 1 1 f 1 1 1 i => 100c 100f 100i
                for(s128 i = r.significand_width - 10, i >= 0, i -= 10)
                {
                    auto b9 = (r.significand >> i+9) & 1;
                    auto b8 = (r.significand >> i+8) & 1;
                    auto b6 = (r.significand >> i+6) & 1;
                    auto b5 = (r.significand >> i+5) & 1;
                    auto b2 = (r.significand >> i+2) & 1;
                    auto b1 = (r.significand >> i+1) & 1;

                    auto d0 = (r.significand >> i+0) & 1;
                    auto d1 = (r.significand >> i+4) & 1;
                    auto d2 = (r.significand >> i+7) & 1;

                    if(((r.significand >> i+3) & 1) == 0)
                    {
                        d0 |= (b2 << 2) | (b1 << 1);
                        d1 |= (b6 << 2) | (b5 << 1);
                        d2 |= (b9 << 2) | (b8 << 1);
                    }
                    else //b3 == 1
                    {
                        auto b21 = (r.significand >> i+1) & 0b11;
                        if(b21 == 0)
                        {
                            d0 |= 0b1000;
                            d1 |= (b6 << 2) | (b5 << 1);
                            d2 |= (b9 << 2) | (b8 << 1);
                        }
                        else if(b21 == 1)
                        {
                            d0 |= (b6 << 2) | (b5 << 1);
                            d1 |= 0b1000;
                            d2 |= (b9 << 2) | (b8 << 1);
                        }
                        else if(b21 == 2)
                        {
                            d0 |= (b9 << 2) | (b8 << 1);
                            d1 |= (b6 << 2) | (b5 << 1);
                            d2 |= 0b1000;
                        }
                        else //b21 == 0b11
                        {
                            auto b56 = (r.significand >> i+5) & 0b11;
                            if(b56 == 0)
                            {
                                d0 |= (b9 << 2) | (b8 << 1);
                                d1 |= 0b1000;
                                d2 |= 0b1000;
                            }
                            else if(b56 == 1)
                            {
                                d0 |= 0b1000;
                                d1 |= (b9 << 2) | (b8 << 1);
                                d2 |= 0b1000;
                            }
                            else if(b56 == 2)
                            {
                                d0 |= 0b1000;
                                d1 |= 0b1000;
                                d2 |= (b9 << 2) | (b8 << 1);
                            }
                            else //b56 == 0b11
                            {
                                d0 |= 0b1000;
                                d1 |= 0b1000;
                                d2 |= 0b1000;
                            }
                        }
                    }
                    output = std::format("{}{}{}{}", output, d2, d1, d0);
                }

                return std::format("{}E{}{}", output, (biased_exponent - r.bias) < 0 ? "" : "+", biased_exponent - r.bias);
            }
        };
    }

    using decimal32<auto encoding> = decimal<11, 20, encoding>;
    using decimal64<auto encoding> = decimal<13, 50, encoding>;
    using decimal96<auto encoding> = decimal<15, 80, encoding>;
    using decimal128<auto encoding> = decimal<17, 110, encoding>;

    //defined in IEEE 754 2019, but only decimal encoding currently supported
    using decimal160<auto encoding> = decimal<19, 140, encoding>;
    using decimal192<auto encoding> = decimal<21, 170, encoding>;
    using decimal224<auto encoding> = decimal<23, 200, encoding>;
    using decimal256<auto encoding> = decimal<25, 230, encoding>;
}
}