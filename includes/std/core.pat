#pragma once

#include <std/mem.pat>

namespace std::core {

    enum BitfieldOrder : u8 {
        LeftToRight = 0,
        RightToLeft = 1
    };


    fn has_attribute(ref auto pattern, str attribute) {
        return builtin::std::core::has_attribute(pattern, attribute);
    };


    fn get_attribute_value(ref auto pattern, str attribute) {
        return builtin::std::core::get_attribute_value(pattern, attribute);
    };


    fn set_endian(std::mem::Endian endian) {
        builtin::std::core::set_endian(u32(endian));
    };

    fn get_endian() {
        return builtin::std::core::get_endian();
    };

    
    fn set_bitfield_order(BitfieldOrder order) {
        builtin::std::core::set_bitfield_order(order);
    };

    fn get_bitfield_order() {
        return builtin::std::core::get_bitfield_order();
    };


    fn array_index() {
        return builtin::std::core::array_index();
    };

    fn member_count(ref auto pattern) {
        return builtin::std::core::member_count(pattern);  
    };

    fn has_member(ref auto pattern, str name) {
        return builtin::std::core::has_member(pattern, name);  
    };

    fn formatted_value(ref auto pattern) {
        return builtin::std::core::formatted_value(pattern);
    };

}
