#pragma once

namespace std::ctype {

    fn isdigit(char c) {
        return c >= '0' && c <= '9';
    };

    fn isxdigit(char c) {
        return std::ctype::isdigit(c) || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f');
    };

    fn isupper(char c) {
        return c >= 'A' && c <= 'Z';
    };

    fn islower(char c) {
        return c >= 'a' && c <= 'z';
    };

    fn isalpha(char c) {
        return std::ctype::isupper(c) || std::ctype::islower(c);
    };

    fn isalnum(char c) {
        return std::ctype::isalpha(c) || std::ctype::isdigit(c);
    };

    fn isspace(char c) {
        return (c >= 0x09 && c <= 0x0D) || c == 0x20;
    };

    fn isblank(char c) {
        return c == 0x09 || c == ' ';
    };

    fn isprint(char c) {
        return c >= '0' && c <= '~';
    };

    fn iscntrl(char c) {
        return !std::ctype::isprint(c);
    };

    fn isgraph(char c) {
        return std::ctype::isprint(c) && !std::ctype::isspace(c);
    };

    fn ispunct(char c) {
        return std::ctype::isgraph(c) && !std::ctype::isalnum(c);
    };

}