#pragma once

#include <std/mem.pat>

/*!
    The core library contains intrinsics and "compiler magic" functions that
    get extra help from the runtime to fulfill their purpose.
*/

namespace std::core {

    /**
        The default ordering of bitfield members
    */
    enum BitfieldOrder : u8 {
        LeftToRight = 0,
        RightToLeft = 1
    };


    /**
        Checks if a pattern has a specific attribute assigned to it
        @param pattern The pattern to check
        @param attribute The attribute's name to check for
    */
    fn has_attribute(ref auto pattern, str attribute) {
        return builtin::std::core::has_attribute(pattern, attribute);
    };

    /**
        Returns the first parameter of the attribute of a pattern if it has one
        @param pattern The pattern to check
        @param attribute The attribute's name to query
    */
    fn get_attribute_value(ref auto pattern, str attribute) {
        return builtin::std::core::get_attribute_value(pattern, attribute);
    };


    /**
        Sets the current default endianess.
        Any patterns created following this attribute will be created using the set endianess.
        @param endian The new default endianess
    */
    fn set_endian(std::mem::Endian endian) {
        builtin::std::core::set_endian(u32(endian));
    };

    /**
        Gets the current default endianess.
        @return The currently set default endianess
    */
    fn get_endian() {
        return builtin::std::core::get_endian();
    };

    
    /**
        Sets the default bitfield order.
        @param order The new default bitfield order
    */
    fn set_bitfield_order(BitfieldOrder order) {
        builtin::std::core::set_bitfield_order(u32(order));
    };

    /**
        Gets thee current default bitfield order
        @return The currently set default bitfield order
    */
    fn get_bitfield_order() {
        return builtin::std::core::get_bitfield_order();
    };


    /**
        When used inside of a pattern that's being created using a pattern,
        returns the current array index that's being processed.
        If used outside of an array, always yields 0.
        @return The current array index
    */
    fn array_index() {
        return builtin::std::core::array_index();
    };

    /**
        Queries the number of members of a struct, union or bitfield or the number of entries in an array
        @param pattern The pattern to check
        @return The number of members in `pattern`
    */
    fn member_count(ref auto pattern) {
        return builtin::std::core::member_count(pattern);  
    };

    /**
        Checks whether or not a given pattern has a member with a given name
        @param pattern The pattern to check
        @param name The name of the member to look for
        @return True if a member called `name` exists, false otherwise
    */
    fn has_member(ref auto pattern, str name) {
        return builtin::std::core::has_member(pattern, name);  
    };

    /**
        Formats a pattern using it's default formatter or its custom formatter function set through
        the `[[format]]` or `[[format_read]]` attribute
        @param pattern The pattern to format
        @return Formatted string representation of `pattern`
    */
    fn formatted_value(ref auto pattern) {
        return builtin::std::core::formatted_value(pattern);
    };

    /**
        Checks if the given enum value corresponds has a corresponding constant
        @param pattern The enum value to check
        @return True if pattern has a valid enum representation, false if not
    */
    fn is_valid_enum(ref auto pattern) {
        return builtin::std::core::is_valid_enum(pattern);
    };


    /**
        Changes the color of the given pattern to a new color
        @param pattern The pattern to modify
        @param color The RGBA8 color 
    */
    fn set_pattern_color(ref auto pattern, u32 color) {
        builtin::std::core::set_pattern_color(pattern, color);
    };

    /**
        Changes the display name of a given pattern
        @param pattern The pattern to modify
        @param name The new display name of the pattern
    */
    fn set_display_name(ref auto pattern, str name) {
        builtin::std::core::set_display_name(pattern, name);
    }; 
}
