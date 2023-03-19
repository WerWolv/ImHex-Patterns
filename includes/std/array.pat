#pragma once

/*!
    The array library contains various helper functions and types to make
    it easier to work with Arrays.
*/

namespace std {

    /**
        Simple one dimensional array wrapper
        @tparam T The array types
        @tparam Size Size of the array
    */
    struct Array<T, auto Size> {
        T data[Size] [[inline]];
    };

}