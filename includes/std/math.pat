#pragma once

import std.mem;

/*!
	Library containing more advanced mathematical operations.
*/

namespace std::math;

/**
	Compares the values `a` and `b` with each other and returns the smaller of the two
	@param a First value
	@param b Second value
	@return `a` if `a` is smaller than `b`, otherwise `b`
*/
fn min(auto a, auto b) {
	if (a < b)
		return a;
	else
		return b;
};

/**
	Compares the values `a` and `b` with each other and returns the bigger of the two
	@param a First value
	@param b Second value
	@return `a` if `a` is bigger than `b`, otherwise `b`
*/
fn max(auto a, auto b) {
	if (a > b)
		return a;
	else
		return b;
};

/**
	Clamps the value of `x` between `min` and `max`.
	@param x Value
	@param min Minimum value
	@param max Maximum value
	@return `min` if `x` is smaller than `min`, `max` if `x` is bigger than `max`, `x` otherwise
*/
fn clamp(auto x, auto min, auto max) {
	if (x < min)
		return min;
	else if (x > max)
		return max;
	else
		return x;
};

/**
	Returns the absolute value of `x`.
	@param x Value
	@return `x` if `x` is positive, `-x` otherwise
*/
fn abs(auto x) {
	if (x < 0) 
		return -x;
	else 
		return x;
};

/**
	Returns the sign of `x`.
	@param x Value
	@return `1` if `x` is positive, `-1` if `x` is negative, `0` if `x` is zero
*/
fn sign(auto x) {
	if (x > 0)
		return 1;
	else if (x < 0)
		return -1;
	else
		return 0;
};

/**
	Copies the sign of `y` to `x`.
	@param x Value
	@param y Value
	@return `x` if `y` is positive, `-x` if `y` is negative
*/
fn copy_sign(auto x, auto y) {
	if (y >= 0)
		return std::math::abs(x);
	else
		return -std::math::abs(x);
};

/**
	Calculates the factorial of `x`.
	@param x Value
	@return Factorial of `x`
*/
fn factorial(u128 x) {
	u128 result;
	
	result = x;
	while (x > 1) {
		x = x - 1;
		result = result * x;
	}
	
	return result;
};

/**
	Calculates the binomial coefficient of `n` and `k`.
	@param n Value
	@param k Value
	@return Binomial coefficient of `n` and `k`
*/
fn comb(u128 n, u128 k) {
	if (k > n)
		return 0;
	else
		return std::math::factorial(n) / (std::math::factorial(k) * std::math::factorial(n - k));
};

/**
	Calculates the permutation of `n` and `k`.
	@param n Value
	@param k Value
	@return Permutation of `n` and `k`
*/
fn perm(u128 n, u128 k) {
	if (k > n)
		return 0;
	else
		return std::math::factorial(n) / std::math::factorial(n - k);
};

/**
	Floors the value of `value`.
	@param value Value
	@return `value` floored
*/
fn floor(auto value) { return builtin::std::math::floor(value); };

/**
	Ceils the value of `value`.
	@param value Value
	@return `value` ceiled
*/
fn ceil(auto value) { return builtin::std::math::ceil(value); };

/**
	Rounds the value of `value`.
	@param value Value
	@return `value` rounded
*/
fn round(auto value) { return builtin::std::math::round(value); };

/**
	Truncates the value of `value`.
	@param value Value
	@return `value` truncated
*/
fn trunc(auto value) { return builtin::std::math::trunc(value); };


/**
	Calculates the logarithm of `value` with base 10.
	@param value Value
	@return Logarithm of `value` with base 10
*/
fn log10(auto value) { return builtin::std::math::log10(value); };

/**
	Calculates the logarithm of `value` with base 2.
	@param value Value
	@return Logarithm of `value` with base 2
*/
fn log2(auto value) { return builtin::std::math::log2(value); };

/**
	Calculates the natural logarithm of `value`.
	@param value Value
	@return Logarithm of `value` with base `e`
*/
fn ln(auto value) { return builtin::std::math::ln(value); };

/**
	Calculates the floating point modulus of `value`.
	@param value Value
	@return Floating point modulus of `value`
*/
fn fmod(auto value) { return builtin::std::math::fmod(value); };

/**
	Calculates the value of `base` raised to the power of `exp`.
	@param base Base
	@param exp Exponent
	@return `base` raised to the power of `exp`
*/
fn pow(auto base, auto exp) { return builtin::std::math::pow(base, exp); };

/**
	Calculates the value of the natural number `e`	raised to the power of `value`.
	@param value Exponent
	@return `e` raised to the power of `value`
*/
fn exp(auto value) { return builtin::std::math::exp(value); };

/**
	Calculates the square root of `value`.
	@param value Value
	@return Square root of `value`
*/
fn sqrt(auto value) { return builtin::std::math::sqrt(value); };

/**
	Calculates the cubic root of `value`.
	@param value Value
	@return Cubic root of `value`
*/
fn cbrt(auto value) { return builtin::std::math::cbrt(value); };

/**
	Calculates the sine of `value`.
	@param value Angle value in radians
	@return Sine of `value`
*/
fn sin(auto value) { return builtin::std::math::sin(value); };

/**
	Calculates the cosine of `value`.
	@param value Angle value in radians
	@return Cosine of `value`
*/
fn cos(auto value) { return builtin::std::math::cos(value); };

/**
	Calculates the tangent of `value`.
	@param value Angle value in radians
	@return Tangent of `value`
*/
fn tan(auto value) { return builtin::std::math::tan(value); };

/**
	Calculates the arc sine of `value`.
	@param value Angle value in radians
	@return Arc sine of `value`
*/
fn asin(auto value) { return builtin::std::math::asin(value); };

/**
	Calculates the arc cosine of `value`.
	@param value Value
	@return Arc cosine of `value` in radians
*/
fn acos(auto value) { return builtin::std::math::acos(value); };

/**
	Calculates the arc tangent of `value`.
	@param value Value
	@return Arc tangent of `value` in radians between `-pi/2` and `pi/2`
*/
fn atan(auto value) { return builtin::std::math::atan(value); };

/**
	Calculates the arc tangent of `value`.
	@param y Value representing the proportion of the y-coordinate
	@param x Value representing the proportion of the x-coordinate.
	@return Arc tangent of `value` in radians between `-pi` and `pi`
*/
fn atan2(auto y, auto x) { return builtin::std::math::atan2(y, x); };

/**
	Calculates the hyperbolic sine of `value`.
	@param value Angle value in radians
	@return Hyperbolic sine of `value`
*/
fn sinh(auto value) { return builtin::std::math::sinh(value); };

/**
	Calculates the hyperbolic cosine of `value`.
	@param value Angle value in radians
	@return Hyperbolic cosine of `value`
*/
fn cosh(auto value) { return builtin::std::math::cosh(value); };

/**
	Calculates the hyperbolic tangent of `value`.
	@param value Angle value in radians
	@return Hyperbolic tangent of `value`
*/
fn tanh(auto value) { return builtin::std::math::tanh(value); };


/**
	Calculates the arc hyperbolic sine of `value`.
	@param value Value
	@return Arc hyperbolic sine of `value`
*/
fn asinh(auto value) { return builtin::std::math::asinh(value); };

/**
	Calculates the arc hyperbolic cosine of `value`.
	@param value Value
	@return Arc hyperbolic cosine of `value`
*/
fn acosh(auto value) { return builtin::std::math::acosh(value); };

/**
	Calculates the arc hyperbolic tangent of `value`.
	@param value Value
	@return Arc hyperbolic tangent of `value`
*/
fn atanh(auto value) { return builtin::std::math::atanh(value); };


/**
	Options to use with the `std::math::accumulate` function.
*/
enum AccumulateOperation : u8 {
	Add 		= 0,
	Multiply 	= 1,
	Modulo 		= 2,
	Min 		= 3,
	Max 		= 4
};

/**
	Calculates the sum of all values in the specified memory range.
	@param start Start address
	@param end End address
	@param valueSize Size of each value in bytes
	@param section Section to use
	@param operation Operation to use
	@param endian Endianness to use
	@return Sum of all values in the specified memory range
*/
fn accumulate(u128 start, u128 end, u128 valueSize, std::mem::Section section = 0, AccumulateOperation operation = AccumulateOperation::Add, std::mem::Endian endian = std::mem::Endian::Native) {
	return builtin::std::math::accumulate(start, end, valueSize, section, u128(operation), u128(endian));
};
