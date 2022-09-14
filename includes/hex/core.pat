#pragma once

#include <hex/impl/imhex_check.pat>

namespace hex::core {

    struct Selection {
        bool valid;
        u64 address, size;
    };

    fn get_selection() {
        u128 result = builtin::hex::core::get_selection();

        Selection result;
        if (result == u128(-1)) {
            result.valid    = false;
            result.address  = 0x00;
            result.size     = 0x00;
        } else {
            result.valid    = true;
            result.address  = result >> 64;
            result.size     = result & u64(-1);
        }

        return result;
    };

}