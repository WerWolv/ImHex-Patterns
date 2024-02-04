#pragma once

import std.io;
import std.time;

/*!
    Types used to decode various different time formats
*/

namespace type;

/**
    A 32 bit Unix time value
*/
using time32_t = u32 [[format("type::impl::format_time_t")]];

/**
    Alias name for `time32_t` 
*/
using time_t = time32_t;

/**
    A 64 bit Unix time value
*/
using time64_t = u64 [[format("type::impl::format_time_t")]];

/**
    A DOS Date value
*/
using DOSDate = u16 [[format("type::impl::format_dosdate")]];

/**
    A DOS Time value
*/
using DOSTime = u16 [[format("type::impl::format_dostime")]];

/**
    A 64bit FILETIME value
*/
using FILETIME = u64 [[format("type::impl::format_filetime_as_unix")]];

namespace impl {

    fn format_time_t(u128 value) {
        return std::time::format(std::time::to_utc(value));
    };

    fn format_dosdate(u16 value) {
        return std::time::format_dos_date(std::time::to_dos_date(value));
    };

    fn format_dostime(u16 value) {
        return std::time::format_dos_time(std::time::to_dos_time(value));
    };

    fn format_filetime_as_unix(u64 value) {
        return std::time::filetime_to_unix(value);
    };

}