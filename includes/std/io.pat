#pragma once

namespace std {

    fn print(str fmt, auto ... args) {
        builtin::std::print(fmt, args);
    };

    fn format(str fmt, auto ... args) {
        return builtin::std::format(fmt, args);
    };


    fn error(str message) {
        builtin::std::error(message);
    };

    fn warning(str message) {
        builtin::std::warning(message);
    };

}