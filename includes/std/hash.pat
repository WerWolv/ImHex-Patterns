#pragma once

namespace std::hash {

    fn crc32(ref auto pattern, u32 init, u32 poly) {
        return builtin::std::hash::crc32(pattern, init, poly);
    };

}