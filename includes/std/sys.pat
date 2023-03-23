#pragma once

#include <std/io.pat>

/*!
    Basic helper functions
*/

namespace std {

    /**
        Asserts that a given value is true. If it's not, abort evaluation and print the given message to the console
        @param conditoon The condition that is required to be true
        @param message The message to print in case the assertion doesn't hold
    */
    fn assert(bool condition, str message) {
        if (!condition) {
            std::error(std::format("assertion failed '{0}'", message));
        }
    };

    /**
        Asserts that a given value is true. If it's not, print the given message to the console as a warning
        @param conditoon The condition that is required to be true
        @param message The message to print in case the assertion doesn't hold
    */
    fn assert_warn(bool condition, str message) {
        if (!condition) {
            std::warning(std::format("assertion failed '{0}'", message));
        }
    };


    /**
        Queries the value of a set environment variable given it's name
        @param name The name of the env variable
        @return The value of that variable
    */
    fn env(str name) {
        return builtin::std::env(name);
    };

    /**
        Returns the number of parameters in a parameter pack.
        @param pack The pack to check
        @return Number of parameters in `pack`
    */
    fn sizeof_pack(auto ... pack) {
        return builtin::std::sizeof_pack(pack);
    };

}