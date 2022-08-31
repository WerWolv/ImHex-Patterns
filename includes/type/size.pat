namespace type {

    using Size8   = u8   [[format("type::impl::size_formatter")]];
    using Size16  = u16  [[format("type::impl::size_formatter")]];
    using Size32  = u32  [[format("type::impl::size_formatter")]];
    using Size64  = u64  [[format("type::impl::size_formatter")]];
    using Size128 = u128 [[format("type::impl::size_formatter")]];

    namespace impl {

        fn size_formatter(u128 size) {
            u32 i = 0;
            while (size >= 1024 && i <= 6) {
                i += 1;
                size /= 1024;
            }
            
            str result = std::format("{} ", size);
            
            if (i == 0 && size == 1)
                return result + "Byte";
            else if (i == 0)
                return result + "Bytes";
            else if (i == 1)
                return result + "kiB";
            else if (i == 2)
                return result + "MiB";
            else if (i == 3)
                return result + "GiB";
            else if (i == 4)
                return result + "TiB";
            else if (i == 5)
                return result + "PiB";
            else
                return result + "EiB";
        };

    }

}