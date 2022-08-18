#pragma once

namespace std::core {

    enum Endian : u8 {
        Native  = 0,
        Big     = 1,
        Little  = 2
    };

    enum BitfieldOrder : u8 {
        LeftToRight = 0,
        RightToLeft = 1
    };


    fn has_attribute(auto pattern, str attribute) {
        return builtin::std::core::has_attribute(pattern, attribute);
    };


    fn get_attribute_value(auto pattern, str attribute) {
        return builtin::std::core::get_attribute_value(pattern, attribute);
    };


    fn set_endian(Endian endian) {
        builtin::std::core::set_endian(endian);
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

}