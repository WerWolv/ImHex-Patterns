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

    /**
    A nullable pointer, generic over both the pointee type and pointer type.

    By nullable, we mean that if the pointer's value is zero (`0x0`), then the
    value will appear as padding rather than a pointer to something, but
    if the pointer's value is non-zero, that non-zero value will be treated as
    a pointer of type `PointerTy` which points to an element of type `PointeeTy`.

    Example:
    A struct field called `p_myInfo` which is a nullable 64-bit pointer to an
    element of type `MyInfoTy` would be written as:
    ```
    struct MyStruct {
      std::ptr::NullablePtr<MyInfoTy, u64> p_myInfo;
    }
    ```
    */
    struct NullablePtr<PointeeTy, PointerTy> {
        // `pointerValue` is `no_unique_address` because we don't want to advance
        // the current memory location after reading the value of the pointer itself;
        // we want to examine the value at this address to determine what should be
        // displayed. It's also `hidden` so the editor only displays either thee 
        // padding or the populated pointer/pointee field.
        PointerTy pointerValue [[no_unique_address, hidden]];
        if (pointerValue == 0x0) {
            padding[sizeof(PointerTy)];
        } else {
            PointeeTy *data : PointerTy;
        }
    };
}