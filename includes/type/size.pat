#pragma once
#include <std/io.pat>

namespace type {

    using Size8   = u8   [[format("type::impl::size_formatter")]];
    using Size16  = u16  [[format("type::impl::size_formatter")]];
    using Size32  = u32  [[format("type::impl::size_formatter")]];
    using Size64  = u64  [[format("type::impl::size_formatter")]];
    using Size128 = u128 [[format("type::impl::size_formatter")]];

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
