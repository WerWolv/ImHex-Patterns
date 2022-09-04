#pragma once

namespace std::mem {
  
    enum Endian : u8 {
        Native  = 0,
        Big     = 1,
        Little  = 2
    };

    fn eof() {
        return $ >= std::mem::size();
    };

    fn align_to(u128 alignment, u128 value) {
        u128 remainder = value % alignment;

        return remainder != 0 ? value + (alignment - remainder) : value;
    };
  

    fn base_address() {
        return builtin::std::mem::base_address();
    };

    fn size() {
        return builtin::std::mem::size();
    };

    fn find_sequence(u128 occurrence_index, auto ... bytes) {
        return builtin::std::mem::find_sequence_in_range(occurrence_index, builtin::std::mem::base_address(), builtin::std::mem::size(), bytes);
    };

    fn find_sequence_in_range(u128 occurrence_index, u128 offsetFrom, u128 offsetTo, auto ... bytes) {
        return builtin::std::mem::find_sequence_in_range(occurrence_index, offsetFrom, offsetTo, bytes);
    };

    fn read_unsigned(u128 address, u8 size) {
        return builtin::std::mem::read_unsigned(address, size);
    };

    fn read_signed(u128 address, u8 size) {
        return builtin::std::mem::read_signed(address, size);
    };

    fn read_string(u128 address, u8 size) {
        return builtin::std::mem::read_string(address, size);
    };

}
