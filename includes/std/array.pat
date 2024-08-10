#pragma once

import std.sys;
import std.core;

/*!
    The array library contains a helper type to make it easier to create multi-dimensional arrays
    and pass arrays to functions as parameters.
*/

namespace auto std {

    /**
        Simple one dimensional array wrapper
        @tparam T The array types
        @tparam Size Number of entries in the array
    */
    struct Array<T, auto Size> {
        T data[Size] [[inline]];
    } [[format("std::impl::format_array")]];

    /**
        Simple array wrapper for an array with a size in bytes
        @tparam T The array types
        @tparam NumBytes Number of bytes the array contains
    */
    struct ByteSizedArray<T, auto NumBytes> {
        u64 startAddress = $;
        T array[while($ - startAddress < NumBytes)] [[inline]];
        
        std::assert($ - startAddress == NumBytes, "Not enough bytes available to fit a whole number of types");
    } [[format("std::impl::format_array")]];


    /**
        An interface type for getting the index of the currently processed element in an array. This is a nice wrapper around `std::core::array_index()`

        To use it, inherit from it and use the `this.index` field to get the index of the current element
    */
    struct IIndexed {
        const u64 index = std::core::array_index();
    };

    namespace impl {

        fn format_array(ref auto array) {
            return "[ ... ]";
        };

    }

}
