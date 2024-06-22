#pragma once

/*!
    Library to calculate the minimum and maximum values that fit into a given data type
*/

namespace auto std::limits {
    
    /**
        Returns the minimum value that can be stored in a `u8`.
        @return Minimum value
    */
    fn u8_min() {
        return u8(0);
    };
    
    /**
        Returns the maximum value that can be stored in a `u8`.
        @return Maximum value
    */
    fn u8_max() {
        return u8(-1);
    };

    /**
        Returns the minimum value that can be stored in a `s8`.
        @return Minimum value
    */
    fn s8_min() {
        return -s8((std::limits::u8_max() / 2)) - 1;
    };
    
    /**
        Returns the maximum value that can be stored in a `s8`.
        @return Maximum value
    */
    fn s8_max() {
        return s8((std::limits::u8_max() / 2));
    };

    /**
        Returns the minimum value that can be stored in a `u16`.
        @return Minimum value
    */
    fn u16_min() {
        return u16(0);
    };
    
    /**
        Returns the maximum value that can be stored in a `u16`.
        @return Maximum value
    */
    fn u16_max() {
        return u16(-1);
    };
    
    /**
        Returns the minimum value that can be stored in a `s16`.
        @return Minimum value
    */
    fn s16_min() {
        return -s16((std::limits::u16_max() / 2)) - 1;
    };
    
    /**
        Returns the maximum value that can be stored in a `s16`.
        @return Maximum value
    */
    fn s16_max() {
        return s16((std::limits::u16_max() / 2));
    };
    
    /**
        Returns the minimum value that can be stored in a `u32`.
        @return Minimum value
    */
    fn u32_min() {
        return u32(0);
    };
    
    /**
        Returns the maximum value that can be stored in a `u32`.
        @return Maximum value
    */
    fn u32_max() {
        return u32(-1);
    };
    
    /**
        Returns the minimum value that can be stored in a `s32`.
        @return Minimum value
    */
    fn s32_min() {
        return -s32((std::limits::u32_max() / 2)) - 1;
    };
    
    /**
        Returns the maximum value that can be stored in a `s32`.
        @return Maximum value
    */
    fn s32_max() {
        return s32((std::limits::u32_max() / 2));
    };
    
    /**
        Returns the minimum value that can be stored in a `u64`.
        @return Minimum value
    */
    fn u64_min() {
        return u64(0);
    };
    
    /**
        Returns the maximum value that can be stored in a `u64`.
        @return Maximum value
    */
    fn u64_max() {
        return u64(-1);
    };
    
    /**
        Returns the minimum value that can be stored in a `s64`.
        @return Minimum value
    */
    fn s64_min() {
        return -s64((std::limits::u64_max() / 2)) - 1;
    };
    
    /**
        Returns the maximum value that can be stored in a `s64`.
        @return Maximum value
    */
    fn s64_max() {
        return s64((std::limits::u64_max() / 2));
    };
    
    /**
        Returns the minimum value that can be stored in a `u128`.
        @return Minimum value
    */
    fn u128_min() {
        return u128(0);
    };
    
    /**
        Returns the maximum value that can be stored in a `u128`.
        @return Maximum value
    */
    fn u128_max() {
        return u128(-1);
    };
    
    /**
        Returns the minimum value that can be stored in a `s128`.
        @return Minimum value
    */
    fn s128_min() {
        return -s128((std::limits::u128_max() / 2)) - 1;
    };
    
    /**
        Returns the maximum value that can be stored in a `s128`.
        @return Maximum value
    */
    fn s128_max() {
        return s128((std::limits::u128_max() / 2));
    };
    
}
