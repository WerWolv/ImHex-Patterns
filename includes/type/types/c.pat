#pragma once

/*!
    Alias definitions for all C stdint and regular data types
*/

// Explicitly don't add these types to the `type` namespace for usability
// namespace type {

    using uint8_t       = u8;
    using uint16_t      = u16;
    using uint32_t      = u32;
    using uint64_t      = u64;
    using __uint64_t    = u64;
    using uint128_t     = u128;
    using __uint128_t   = u128;

    using int8_t        = s8;
    using int16_t       = s16;
    using int32_t       = s32;
    using int64_t       = s64;
    using __int64_t     = s64;
    using int128_t      = s128;
    using __int128_t    = s128;

    using size_t        = u64;
    using ssize_t       = s64;

    using uintptr_t     = u64;
    using intptr_t      = s64;
    using ptrdiff_t     = s64;

    // using char       = char;
    using wchar_t       = char16;
    using char8_t       = char;
    using char16_t      = char16;
    using char32_t      = u32;

    using short         = s16;
    using int           = s32;
    using long          = s32;

// }