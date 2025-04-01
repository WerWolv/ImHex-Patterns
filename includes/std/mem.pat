#pragma once

/*!
    Library for doing raw memory accesses and other low-level operations.
*/

namespace auto std::mem {

    namespace impl {

        struct MagicSearchImpl<auto Magic, T> {
            s128 address = builtin::std::mem::find_string_in_range(0, $, builtin::std::mem::size(), Magic);
            if (address < 0)
                break;

            $ = address;
            try {
                T data [[inline]];
            } catch {
                T data;
            }
        };

    }

    /**
        A Handle for a custom Section
     */
    using Section = u128;

    /**
        The endianness of a value
     */
    enum Endian : u8 {
        Native  = 0,
        Big     = 1,
        Little  = 2
    };

    /**
        Function that returns true if the cursor position is at the end of the memory
        This is usually used in while-sized arrays in the form of `u8 array[while(!std::mem::eof())]`
        @return True if the cursor is at the end of the memory
     */
    fn eof() {
        return $ >= (std::mem::base_address() + std::mem::size());
    };

    /**
        Function that returns true if the cursor position is at or beyond the given address
        @param address The address to compare against
        @return True if the cursor is at or beyond the given address
    */
    fn reached(u128 address) {
        return $ >= address;
    };

    /**
        Aligns the given value to the given alignment
        @param alignment The alignment to align to
        @param value The value to align
        @return The aligned value
    */
    fn align_to(u128 alignment, u128 value) {
        u128 remainder = value % alignment;

        return remainder != 0 ? value + (alignment - remainder) : value;
    };


    /**
        Gets the base address of the data
        @return The base address of the memory
     */
    fn base_address() {
        return builtin::std::mem::base_address();
    };

    /**
        Gets the size of the data
        @return The size of the memory
     */
    fn size() {
        return builtin::std::mem::size();
    };

    /**
        Finds a sequence of bytes in the data
        @param occurrence_index The index of the occurrence to find
        @param bytes The bytes to find
        @return The address of the sequence
    */
    fn find_sequence(u128 occurrence_index, auto ... bytes) {
        const u128 address = builtin::std::mem::base_address();
        return builtin::std::mem::find_sequence_in_range(occurrence_index, address, address + builtin::std::mem::size(), bytes);
    };

    /**
        Finds a sequence of bytes in a specific region of the data
        @param occurrence_index The index of the occurrence to find
        @param offsetFrom The offset from which to start searching
        @param offsetTo The offset to which to search
        @param bytes The bytes to find
        @return The address of the sequence
    */
    fn find_sequence_in_range(u128 occurrence_index, u128 offsetFrom, u128 offsetTo, auto ... bytes) {
        return builtin::std::mem::find_sequence_in_range(occurrence_index, offsetFrom, offsetTo, bytes);
    };


    /**
        Finds a string in the data
        @param occurrence_index The index of the occurrence to find
        @param string The string to find
        @return The address of the sequence
    */
    fn find_string(u128 occurrence_index, str string) {
        const u128 address = builtin::std::mem::base_address();
        return builtin::std::mem::find_string_in_range(occurrence_index, address, address + builtin::std::mem::size(), string);
    };

    /**
        Finds a string in a specific region of the data
        @param occurrence_index The index of the occurrence to find
        @param offsetFrom The offset from which to start searching
        @param offsetTo The offset to which to search
        @param string The string to find
        @return The address of the sequence
    */
    fn find_string_in_range(u128 occurrence_index, u128 offsetFrom, u128 offsetTo, str string) {
        return builtin::std::mem::find_string_in_range(occurrence_index, offsetFrom, offsetTo, string);
    };

    /**
        Reads a unsigned value from the memory
        @param address The address to read from
        @param size The size of the value to read
        @param [endian] The endianness of the value to read. Defaults to native
        @return The value read
    */
    fn read_unsigned(u128 address, u8 size, Endian endian = Endian::Native) {
        return builtin::std::mem::read_unsigned(address, size, u32(endian));
    };

    /**
        Reads a signed value from the memory
        @param address The address to read from
        @param size The size of the value to read
        @param [endian] The endianness of the value to read. Defaults to native
        @return The value read
    */
    fn read_signed(u128 address, u8 size, Endian endian = Endian::Native) {
        return builtin::std::mem::read_signed(address, size, u32(endian));
    };

    /**
        Reads a string value from the memory
        @param address The address to read from
        @param size The size of the value to read
        @return The value read
    */
    fn read_string(u128 address, u128 size) {
        return builtin::std::mem::read_string(address, size);
    };

    /**
        Reads a number of bits from the specified bit offset within the specified byte
        @param byteOffset The byte offset within the data
        @param bitOffset The bit offset to start the read at within the current byte
        @param bitSize The total number of bits to read
        @return A u128 containing the value read
    */
    fn read_bits(u128 byteOffset, u128 bitOffset, u64 bitSize) {
        byteOffset += bitOffset >> 3;
        bitOffset = bitOffset & 0x7;
        return builtin::std::mem::read_bits(byteOffset, bitOffset, bitSize);
    };


    /**
        Creates a new custom section with the given name
        @param name The name of the section
        @return The handle to the section
    */
    fn create_section(str name) {
        return builtin::std::mem::create_section(name);
    };

    /**
        Deletes a custom section
        @param section The handle to the section
    */
    fn delete_section(Section section) {
        builtin::std::mem::delete_section(section);
    };

    /**
        Gets the size of a custom section
        @param section The handle to the section
        @return The size of the section
    */
    fn get_section_size(Section section) {
        return builtin::std::mem::get_section_size(section);
    };

    /**
        Changes the size of a custom section
        @param section The handle to the section
        @param size The new size of the section
    */
    fn set_section_size(Section section, u128 size) {
        builtin::std::mem::set_section_size(section, size);
    };

    /**
        Copies a range of bytes from one section into another
        @param from_section The section to copy from
        @param from_address The address to copy from
        @param to_section The section to copy to
        @param to_address The address to copy to
        @param size The size of the range to copy
    */
    fn copy_section_to_section(Section from_section, u64 from_address, Section to_section, u64 to_address, u64 size) {
        builtin::std::mem::copy_to_section(from_section, from_address, to_section, to_address, size);
    };

    /**
        Copies a range of bytes from the main section into a custom section
        @param value The pattern whose bytes should be copied
        @param to_section The section to copy to
        @param to_address The address to copy to
    */
    fn copy_value_to_section(ref auto value, Section to_section, u64 to_address) {
        builtin::std::mem::copy_value_to_section(value, to_section, to_address);
    };

    /**
        Returns the current bit offset when inside of a bitfield.
        @return The current bit offset between 0 and 7
    */
    fn current_bit_offset() {
        return builtin::std::mem::current_bit_offset();
    };


    /**
        Searches for a sequence of bytes and places the given type at that address
        @tparam Magic The magic sequence to search for
        @tparam T The type to place at the address
    */
    struct MagicSearch<auto Magic, T> {
        std::mem::impl::MagicSearchImpl<Magic, T> impl[while(!std::mem::eof())] [[inline]];
    };

    /**
        Reinterprets a value as a different one
        @tparam From The type to reinterpret from
        @tparam To The type to reinterpret to
    */
    union Reinterpreter<From, To> {
        From from_value;
        To to_value;
    };


    /**
        Aligns the cursor to the given alignment
        @tparam alignment The alignment to align to
    */
    struct AlignTo<auto Alignment> {
        padding[Alignment - ((($ - 1) % Alignment) + 1)];
    } [[hidden, sealed]];

    /**
        A type representing a sequence of bytes without any specific meaning
        @tparam Size The size of the sequence
    */
    struct Bytes<auto Size> {
        u8 bytes[Size];
    } [[sealed, format("std::mem::impl::format_bytes")]];

    namespace impl {

        fn format_bytes(auto bytes) {
            return "";
        };

    }

}
