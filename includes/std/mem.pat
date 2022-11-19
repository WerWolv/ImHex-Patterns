#pragma once

namespace std::mem {
  
    using Section = u128;

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

    fn read_unsigned(u128 address, u8 size, Endian endian = Endian::Native) {
        return builtin::std::mem::read_unsigned(address, size, u32(endian));
    };

    fn read_signed(u128 address, u8 size, Endian endian = Endian::Native) {
        return builtin::std::mem::read_signed(address, size, u32(endian));
    };

    fn read_string(u128 address, u8 size) {
        return builtin::std::mem::read_string(address, size);
    };


    fn create_section(str name) {
        return builtin::std::mem::create_section(name);
    };

    fn delete_section(Section section) {
        builtin::std::mem::delete_section(section);
    };

    fn get_section_size(Section section) {
        return builtin::std::mem::get_section_size(section);
    };

    fn copy_section_to_section(Section from_section, u64 from_address, Section to_section, u64 to_address, u64 size) {
        builtin::std::mem::copy_to_section(from_section, from_address, to_section, to_address, size);
    };

    fn copy_value_to_section(ref auto value, Section to_section, u64 to_address) {
        builtin::std::mem::copy_value_to_section(value, to_section, to_address);
    };



    struct MagicSearch<auto Magic, T> {
        if ($ < (std::mem::size() - std::string::length(Magic) - 1)) {
            char __potentialMagic__[std::string::length(Magic)] [[hidden, no_unique_address]];
            
            if (__potentialMagic__ == Magic) {
                T data [[inline]];
            } else {
                padding[1];
                continue;
            }
        } else {
            padding[1];
            continue;
        }
    };

    union Reinterpreter<From, To> {
        From from;
        To to;
    };

}
