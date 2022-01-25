namespace std::hash {

    fn crc32(u128 address, u64 size, u32 init, u32 poly) {
        u8 byte;
        u32 crc, mask;
        
        crc = init;
        
        u64 i;
        while (i < size) {
            byte = std::mem::read_unsigned(address + i, 1);
            crc = crc ^ byte;
            
            u8 j;
            while (j < 8) {
                mask = u32(-(crc & 1));
                crc = (crc >> 1) ^ (poly & mask);
                j = j + 1;
            }
            
            i = i + 1;
        }
        
        return u32(~crc);
    };

}