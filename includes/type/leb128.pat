#pragma once

import std.io;
import std.mem;

/*!
    Types used to decode Little Endian Base 128 numbers used to store large numbers as space efficiently as possible
*/

namespace auto type {

    /**
        Base LEB128 type. Use `uLEB128` and `sLEB128` instead.
    */
    struct LEB128Base {
        u8 array[while($ == addressof(this) || std::mem::read_unsigned($-1, 1) & 0x80 != 0)] [[hidden]];
    } [[sealed]];

    /**
        A unsigned variant of a LEB128 number
    */
    using uLEB128 = LEB128Base [[format("type::impl::format_uleb128"), transform("type::impl::transform_uleb128")]];

    /**
        A signed variant of a LEB128 number
    */
    using sLEB128 = LEB128Base [[format("type::impl::format_sleb128"), transform("type::impl::transform_sleb128")]];

    /**
        Legacy alias for uLEB128
    */
    using LEB128 = uLEB128;

    namespace impl {

        fn transform_uleb128_array(ref auto array) {
            u128 res = array[0] & 0x7f;
            for(u8 i = 1, array[i-1] & 0x80 != 0, i+=1) {
                res |= u128(array[i] & 0x7f) << 7 * i;
            }
            return res;
        };

        fn transform_sleb128_array(ref auto array) {
            s128 res = type::impl::transform_uleb128_array(array);
            if (res & 1 << ((sizeof(array) / sizeof(u8)) * 7 - 1) != 0) {
                res |= ~0 << (sizeof(array) / sizeof(u8)) * 7;
            }
            return res;
        };

        fn format_uleb128(ref auto leb128) {
            u128 res = type::impl::transform_uleb128_array(leb128.array);
            return std::format("{} ({:#x})", res, res);
        };

        fn transform_uleb128(ref auto leb128) {
            return type::impl::transform_uleb128_array(leb128.array);
        };

        fn format_sleb128(ref auto leb128) {
            s128 res = type::impl::transform_sleb128_array(leb128.array);
            return std::format("{} ({:#x})", res, res);
        };

        fn transform_sleb128(ref auto leb128) {
            return type::impl::transform_sleb128_array(leb128.array);
        };

    }

}
