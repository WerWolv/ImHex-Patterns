#pragma once

/*!
    The Pointer library contains helper functions to deal with pointer types.
    The `relative_to` functions are meant to be used with the `[[pointer_base]]` attribute
*/

namespace std::ptr {

    /**
        Use the offset of the current pointer as start address
        @param offset The pointer's value
        @return The new pointer base
    */
    fn relative_to_pointer(u128 offset) {
        return $;
    };

    /**
        Use the offset of the pointer's parent as start address
        @param offset The pointer's value
        @return The new pointer base
    */
    fn relative_to_parent(u128 offset) {
        return addressof(parent);
    };

    /**
        Use the end of the file as pointer base address and use its value as offset backwards from there
        @param offset The pointer's value
        @return The new pointer base
    */
    fn relative_to_end(u128 offset) {
        return std::mem::size() - offset * 2;
    };

}