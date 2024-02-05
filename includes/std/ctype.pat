#pragma once

/*!
    The ctype library has functions to check if a character is part of a specific category
    of ASCII characters.
*/

namespace auto std::ctype {

    /**
        Checks if the given character `c` is a digit between '0' and '9'
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isdigit(char c) {
        return c >= '0' && c <= '9';
    };

    /**
        Checks if the given character `c` is a hexadecimal digit between '0' and '9', `A` and `F` or `a` and `f`
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isxdigit(char c) {
        return std::ctype::isdigit(c) || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f');
    };

    /**
        Checks if the given character `c` is a upper case letter between 'A' and 'Z'
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isupper(char c) {
        return c >= 'A' && c <= 'Z';
    };

    /**
        Checks if the given character `c` is a lower case letter between 'a' and 'z'
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn islower(char c) {
        return c >= 'a' && c <= 'z';
    };

    /**
        Checks if the given character `c` is either a upper or lower case letter between 'A' and 'Z' or 'a' and 'z'
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isalpha(char c) {
        return std::ctype::isupper(c) || std::ctype::islower(c);
    };

    /**
        Checks if the given character `c` is a upper or lower case letter or a number
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isalnum(char c) {
        return std::ctype::isalpha(c) || std::ctype::isdigit(c);
    };

    /**
        Checks if the given character `c` is a space character
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isspace(char c) {
        return (c >= 0x09 && c <= 0x0D) || c == 0x20;
    };

    /**
        Checks if the given character `c` is a invisible character
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isblank(char c) {
        return c == 0x09 || c == ' ';
    };

    /**
        Checks if the given character `c` has a printable glyph
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isprint(char c) {
        return c >= '0' && c <= '~';
    };

    /**
        Checks if the given character `c` is a control code
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn iscntrl(char c) {
        return !std::ctype::isprint(c);
    };

    /**
        Checks if the given character `c` has a visible glyph
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn isgraph(char c) {
        return std::ctype::isprint(c) && !std::ctype::isspace(c);
    };

    /**
        Checks if the given character `c` is a punctuation character
        @param c The character to check
        @return True if `c` is part of this range, false otherwise
    */
    fn ispunct(char c) {
        return std::ctype::isgraph(c) && !std::ctype::isalnum(c);
    };

}