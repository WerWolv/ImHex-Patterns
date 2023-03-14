#pragma once

namespace std::hash {

    fn crc32(ref auto pattern, u32 init, u32 poly, u32 xorout, bool reflect_in, bool reflect_out) {
        return builtin::std::hash::crc32(pattern, init, poly, xorout, reflect_in, reflect_out);
    };

}