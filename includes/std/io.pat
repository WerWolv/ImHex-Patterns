#pragma once

/*!
    The IO library allows formatting strings and outputting text to the console
*/

namespace std;

/**
    Formats the given arguments using the format string and prints the result to the console
    This function uses the C++20 `std::format` or libfmt's `fmt::format` syntax.
    @param fmt Format string
    @param args Values to use in the formatting
*/
fn print(str fmt, auto ... args) {
    builtin::std::print(fmt, args);
};

/**
    Formats the given arguments using the format string and returns the result as a string
    This function uses the C++20 `std::format` or libfmt's `fmt::format` syntax.
    @param fmt Format string
    @param args Values to use in the formatting
    @return The formatted string
*/
fn format(str fmt, auto ... args) {
    return builtin::std::format(fmt, args);
};


/**
    Aborts evaluation of the code immediately and prints a error message to the console
    @param message The message to print
*/
fn error(str message) {
    builtin::std::error(message);
};

/**
    Prints a warning message to the console
    @param message The message to print
*/
fn warning(str message) {
    builtin::std::warning(message);
};