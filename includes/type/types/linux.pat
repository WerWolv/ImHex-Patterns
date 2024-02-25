#pragma once

/*!
    Various data types used in the Linux Kernel
*/

// Explicitly don't add these types to the `type` namespace for usability
// namespace auto type {

    using le16  = le u16;
    using be16  = be u16;
    using le32  = le u32;
    using be32  = be u32;
    using le64  = le u64;
    using be64  = be u64;

// }