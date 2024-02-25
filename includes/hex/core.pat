#pragma once

import hex.impl.imhex_check;

/*!
    Core intrinsic functions to interact with the ImHex Hex Editor
*/

namespace auto hex::core {

    /**
        A type representing a selection in the hex editor
    */
    struct Selection {
        bool valid;
        u64 address, size;
    };

    /**
        Returns the current selection in the hex editor
        @return The current selection
    */
    fn get_selection() {
        u128 selection = builtin::hex::core::get_selection();

        Selection result;
        if (selection == u128(-1)) {
            result.valid    = false;
            result.address  = 0x00;
            result.size     = 0x00;
        } else {
            result.valid    = true;
            result.address  = selection >> 64;
            result.size     = selection & u64(-1);
        }

        return result;
    };

}
