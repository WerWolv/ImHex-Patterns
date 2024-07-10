#pragma once

import std.io;
import std.mem;

/*!
    Library to interact with strings.
*/

namespace auto std::string {

    /**
        Base type for sized strings. Represents a string with its size preceding it.
        @tparam SizeType The type of the size field.
        @tparam DataType The type of the characters.
    */
    struct SizedStringBase<SizeType, DataType> {
        SizeType size;
        DataType data[size];
    } [[sealed, format("std::string::impl::format_string"), transform("std::string::impl::format_string")]];

    /**
        A ASCII string with a prefixed size.
        @tparam SizeType The type of the size field.
    */
    using SizedString<SizeType> = SizedStringBase<SizeType, char>;

    /**
        A UTF-16 string with a prefixed size.
        @tparam SizeType The type of the size field.
    */
    using SizedString16<SizeType> = SizedStringBase<SizeType, char16>;

    /**
        Base type for null-terminated strings. Represents a string with its size determined by the first 0x00 byte found.
        @tparam DataType The type of the characters.
    */
    struct NullStringBase<DataType> {
        DataType string[while(std::mem::read_unsigned($, sizeof(DataType)) != 0x00)];
        DataType null_terminator;
    } [[sealed, format("std::string::impl::format_string"), transform("std::string::impl::format_string")]];

    /**
        A null-terminated ASCII string.
    */
    using NullString = NullStringBase<char>;

    /**
        A null-terminated UTF-16 string.
    */
    using NullString16 = NullStringBase<char16>;

    namespace impl {

        fn format_string(ref auto string) {
            return string.data;
        };

    }

    /**
        Gets the length of a string.
        @param string The string to get the length of.
        @return The length of the string.
    */
    fn length(str string) {
        return builtin::std::string::length(string);
    };

    /**
        Gets the character at a given index.
        @param string The string to get the character from.
        @param index The index of the character to get.
        @return The character at the given index.
    */
    fn at(str string, u32 index) {
        return builtin::std::string::at(string, index);
    };

    /**
        Gets a substring of a string.
        @param string The string to get the substring from.
        @param pos The position of the first character of the substring.
        @param count The number of characters to get.
        @return The substring.
    */
    fn substr(str string, u32 pos, u32 count) {
        return builtin::std::string::substr(string, pos, count);
    };


    /**
        Converts a string to an integer.
        @param string The string to convert.
        @param base The base of the number.
        @return The integer.
    */
    fn parse_int(str string, u8 base) {
        return builtin::std::string::parse_int(string, base);
    };

    /**
        Converts a string to a float.
        @param string The string to convert.
        @return The float.
    */
    fn parse_float(str string) {
        return builtin::std::string::parse_float(string);
    };


    /**
        Converts any type to a string.
        @param x The value to convert.
        @return The string.
    */
    fn to_string(auto x) {
        return std::format("{}", x);
    };

    /**
        Checks if a string starts with a given substring.
        @param string The string to check.
        @param part The substring to check for.
        @return True if the string starts with the substring, false otherwise.
    */
    fn starts_with(str string, str part) {
        return std::string::substr(string, 0, std::string::length(part)) == part;
    };

    /**
        Checks if a string ends with a given substring.
        @param string The string to check.
        @param part The substring to check for.
        @return True if the string ends with the substring, false otherwise.
    */
    fn ends_with(str string, str part) {
        return std::string::substr(string, std::string::length(string) - std::string::length(part), std::string::length(part)) == part;
    };

    /**
        Checks if a string contains a given substring.
        @param string The string to check.
        @param part The substring to check for.
        @return True if the string contains the substring, false otherwise.
    */
    fn contains(str string, str part) {
        s32 string_len = std::string::length(string);
        s32 part_len = std::string::length(part);

        for (s32 i = 0, i <= (string_len - part_len), i += 1) {
            if (std::string::substr(string, i, part_len) == part)
                return true;
        }

        return false;
    };

    /**
        Reverses a string.
        @param string The string to reverse.
        @return The reversed string.
    */
    fn reverse(str string) {    
        str result;
        
        s32 i;
        i = std::string::length(string);
        while (i > 0) {
            i = i - 1;
            result = result + std::string::at(string, i);
        }
            
        return result;
    };

    /**
        Converts a string to upper case.
        @param string The string to convert.
        @return The converted string.
    */
    fn to_upper(str string) {
        str result;
        
        u32 i;
        char c;
        while (i < std::string::length(string)) {
            c = std::string::at(string, i);
            
            if (c >= 'a' && c <= 'z')
                result = result + char(c - 0x20);
            else
                result = result + c;
            
            i = i + 1;
        }
        
        return result;
    };
    
    /**
        Converts a string to lower case.
        @param string The string to convert.
        @return The converted string.
    */
    fn to_lower(str string) {
        str result;
        
        u32 i;
        char c;
        while (i < std::string::length(string)) {
            c = std::string::at(string, i);
            
            if (c >= 'A' && c <= 'Z')
                result = result + char(c + 0x20);
            else
                result = result + c;
            
            i = i + 1;
        }
        
        return result;
    };

    /**
        Replaces all occurrences of a substring with another substring.
        @param string The string to replace in.
        @param pattern The substring to replace.
        @param replace The substring to replace with.
        @return The string with the replacements.
    */
    fn replace(str string, str pattern, str replace) {
        s32 string_len  = std::string::length(string);
        s32 pattern_len = std::string::length(pattern);

        if (pattern_len > string_len || pattern_len * string_len == 0 )
             return string;

        str result;
        s32 string_index;
        s32 remaining_len = string_len;
        while (pattern_len <= remaining_len) {
            if (std::string::substr(string, string_index, pattern_len) == pattern) {
                 result += replace;
                string_index += pattern_len;
             } else {
                result += std::string::at(string, string_index);
                  string_index += 1;
            }
            remaining_len = string_len - string_index;
        }
        result += std::string::substr(string, string_index, remaining_len );
        return result;
    };
}
