#pragma once

/*!
    Alias types to make it easier to move template definitions over from 010 Editor to ImHex
*/

// Explicitly don't add these types to the `type` namespace for usability
// namespace type {

    // using char   = s8;
    using byte      = s8;
    using CHAR      = s8;
    using BYTE      = s8;

    using uchar     = u8;
    using ubyte     = u8;
    using UCHAR     = u8;
    using UBYTE     = u8;


    using short     = s16;
    using int16     = s16;
    using SHORT     = s16;
    using INT16     = s16;
    
    using ushort    = u16;
    using uint16    = u16;
    using USHORT    = u16;
    using UINT16    = u16;
    using WORD      = u16;

    using int       = s32;
    using int32     = s32;
    using long      = s32;
    using INT       = s32;
    using INT32     = s32;
    using LONG      = s32;

    using uint      = u32;
    using uint32    = u32;
    using ulong     = u32;
    using UINT      = u32;
    using UINT32    = u32;
    using ULONG     = u32;
    using DWORD     = u32;

    using int64     = s64;
    using quad      = s64;
    using QUAD      = s64;
    using INT64     = s64;
    using __int64   = s64;

    using uint64    = u64;
    using uquad     = u64;
    using UQUAD     = u64;
    using UINT64    = u64;
    using QWORD     = u64;
    using __uint64  = u64;

    // using float  = float;
    using FLOAT     = float;

    // using double = double;
    using DOUBLE    = double;

// }
