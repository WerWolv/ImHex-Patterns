#pragma once

// Explicitly don't add these types to the `type` namespace for usability
// namespace type {

    // using u8        = u8;
    // using u16       = u16;
    // using u32       = u32;
    // using u64       = u64;
    // using u128      = u128;

    using i8        = s8;
    using i16       = s16;
    using i32       = s32;
    using i64       = s64;
    using i128      = s128;

    using f32       = float;
    using f64       = double;

    using usize     = u64;
    using isize     = i64;

// }