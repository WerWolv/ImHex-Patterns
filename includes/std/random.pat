#pragma once

#include <std/limits.pat>

/*!
  Library to generate random numbers. Supports various different distribution types.
*/

namespace std::random {
  
    /**
        Represents the type of distribution to use to generate a random number
    */
    enum Distribution : u8 {
        Uniform           = 0,
        Normal            = 1,
        Exponential       = 2,
        Gamma             = 3,
        Weibull           = 4,
        ExtremeValue      = 5,
        ChiSquared        = 6,
        Cauchy            = 7,
        FisherF           = 8,
        StudentT          = 9,
        LogNormal         = 10,
        Discrete          = 11,
        Bernoulli         = 12,
        Binomial          = 13,
        NegativeBinomial  = 14,
        Geometric         = 15,
        Poisson           = 16
    };

    /**
        Sets the seed of the random number generator
        @param seed Seed to use
    */
    fn set_seed(u64 seed) {
        builtin::std::random::set_seed(seed);
    };

    /**
        Generates a random number using the given distribution with the given parameters.
        The random number generator used internally is C++'s std::mt19937_64 Mersenne Twister implementation.
        @param distribution Distribution to use
        @param param1 This parameter depends on the type of distribution used.
        @param param2 This parameter depends on the type of distribution used.
    */
    fn generate_using(Distribution distribution, auto param1 = 0, auto param2 = 0) {
        return builtin::std::random::generate(u32(distribution), param1, param2);
    };

    
    /**
        Generates a uniformly distributed random number between `min` and `max`
        @param min Minimum number
        @param max Maximum number
    */
    fn generate(u64 min = std::limits::u64_min(), u64 max = std::limits::u64_max()) {
        return std::random::generate_using(Distribution::Uniform, min, max);
    };
  
}
