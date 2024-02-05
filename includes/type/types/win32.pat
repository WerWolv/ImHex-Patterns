#pragma once

/*!
    Alias definitions for various type names used in Windows applications
*/

// Explicitly don't add these types to the `type` namespace for usability
// namespace auto type {

    using BYTE      = u8;
    using WORD      = u16;
    using DWORD     = u32;
    using QWORD     = u64;
    using DWORDLONG = u64;
    using DWORD32   = u32;
    using DWORD64   = u64;

    using INT       = s32;
    using UINT      = u32;
    using FLOAT     = float;
    using SHORT     = s16;
    using USHORT    = u16;
    using BOOL      = bool;
    using BOOLEAN   = bool;

    using INT8      = s8;
    using INT16     = s16;
    using INT32     = s32;
    using INT64     = s64;
    using UINT8     = u8;
    using UINT16    = u16;
    using UINT32    = u32;
    using UINT64    = u64;

    using LONG      = s32;
    using ULONG     = u32;
    using LONG32    = s32;
    using ULONG32   = u32;
    using LONG64    = s64;
    using ULONG64   = u64;
    using LONGLONG  = s64;
    using ULONGLONG = u64;

    using SIZE_T    = u64;
    using SSIZE_T   = s64;

    using UCHAR     = u8;
    using CHAR      = char;
    using CCHAR     = char;

    using ATOM      = WORD;
    using PVOID     = SIZE_T;
    using HANDLE    = PVOID;
    using HINSTANCE = HANDLE;
    using HRESULT   = LONG;

// }