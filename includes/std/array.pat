#pragma once

/*!
    The array library contains a helper type to make it easier to create multi-dimensional arrays
    and pass arrays to functions as parameters.
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
