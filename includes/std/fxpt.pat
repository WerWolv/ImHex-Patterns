#pragma once

/*!
    Library for doing arithmetic with fixed point numbers and converting them from/to floating point numbers.
*/

namespace auto std::fxpt {

    /**
        A fixed point value
    */
    using fixed = s128;

    /**
        Converts a fixed point value into a floating point value
        @param fxt The fixed point value to convert
        @param precision The bits of precision the new value should have
        @return The floating point representation of fxt
    */
    fn to_float(fixed fxt, u32 precision) {
        return double(fxt) / double((1 << precision));
    };
    
    /**
        Converts a floating point value into a fixed point value
        @param flt The floating point value to convert
        @param precision The bits of precision the new value should have
        @return The fixed point representation of flt
    */
    fn to_fixed(double flt, u32 precision) {
        return s128((flt * (1 << precision)));
    };

    /**
        Changes the number of bits used to represent the decimal part of the given fixed point number
        @param value The fixed point value to convert
        @param start_precision The current number of bits used
        @param end_precision The new number of bits used
        @return `value` as a new fixed point number with `end_precision` bits of precision
    */
    fn change_precision(fixed value, u32 start_precision, u32 end_precision) {
        return std::fxpt::to_fixed(std::fxpt::to_float(value, start_precision), end_precision);
    };
    
    /**
        Adds two fixed point numbers with a given precision together
        @param a First fixed point number
        @param b Second fixed point number
        @param precision The precision of `a` and `b`
        @return Result of the addition of `a` and `b`
    */
    fn add(fixed a, fixed b, u32 precision) {
        return a + b;
    };
    
    /**
        Subtracts two fixed point numbers with a given precision together
        @param a First fixed point number
        @param b Second fixed point number
        @param precision The precision of `a` and `b`
        @return Result of the subtraction of `a` and `b`
    */
    fn subtract(fixed a, fixed b, u32 precision) {
        return a - b;
    };
    
    /**
        Multiplies two fixed point numbers with a given precision together
        @param a First fixed point number
        @param b Second fixed point number
        @param precision The precision of `a` and `b`
        @return Result of the multiplication of `a` and `b`
    */
    fn multiply(fixed a, fixed b, u32 precision) {
        return (a * b) / (1 << precision);
    };
    
    /**
        Divides two fixed point numbers with a given precision together
        @param a First fixed point number
        @param b Second fixed point number
        @param precision The precision of `a` and `b`
        @return Result of the division of `a` and `b`
    */
    fn divide(fixed a, fixed b, u32 precision) {
        return (a << precision) / b;
    };

}
