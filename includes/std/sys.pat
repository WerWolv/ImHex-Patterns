#pragma once

#include <std/io.pat>

namespace std {

    fn assert(bool condition, str message) {
        if (!condition) {
            std::error(std::format("assertion failed '{0}'", message));
        }
    };

    fn assert_warn(bool condition, str message) {
        if (!condition) {
            std::warning(std::format("assertion failed '{0}'", message));
        }
    };


    fn env(str name) {
        return builtin::std::env(name);
    };

    fn sizeof_pack(auto ... pack) {
        return builtin::std::sizeof_pack(pack);
    };

}