import std.io;

/*!
    Types used to pretty print size values
*/

namespace auto type {

    /**
        A generic size type which displays its value in Bytes (or kiB, MiB, GiB, TiB, PiB, EiB if larger)
        @tparam T Underlying type
    */
    using Size<T> = T [[format("type::impl::size_formatter")]];

    /**
        A 8 bit size type
    */
    using Size8   = Size<u8>;
    /**
        A 16 bit size type
    */
    using Size16  = Size<u16>;
    /**
        A 32 bit size type
    */
    using Size32  = Size<u32>;
    /**
        A 64 bit size type
    */
    using Size64  = Size<u64>;
    /**
        A 128 bit size type
    */
    using Size128 = Size<u128>;

    namespace impl {

        fn size_formatter(u128 size) {
            double sizeFloat = size;
            
            u32 i = 0;
            while (sizeFloat >= 1024 && i <= 6) {
                i += 1;
                sizeFloat /= 1024;
            }
            
            if (i == 0) {
                if (size == 1)
                    return std::format("{} Byte", size);
                else
                    return std::format("{} Bytes", size);   
            } else {
                str result = std::format("{:.3f} ", sizeFloat);

                if (i == 1)
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
            }
        };

    }

}