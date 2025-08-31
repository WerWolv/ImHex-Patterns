#pragma once

import hex.impl.imhex_check;

/*!
    Types to decode JSON and JSON-like file formats into a pattern tree
*/

namespace auto hex::type {
    
    /**
        Type representing a JSON string
        @tparam Size size of the string
    */
    struct Json<auto Size> {
        char __data[Size] [[hidden, no_unique_address]];
        builtin::hex::dec::Json<__data> json [[merge]];
    };

    /**
        Type representing Bson data 
        @tparam Size size of the data
    */
    struct Bson<auto Size> {
        u8 __data[Size] [[hidden, no_unique_address]];
        builtin::hex::dec::Bson<__data> bson [[merge]];
    };

    /**
        Type representing Cbor data 
        @tparam Size size of the data
    */
    struct Cbor<auto Size> {
        u8 __data[Size] [[hidden, no_unique_address]];
        builtin::hex::dec::Cbor<__data> cbor [[merge]];
    };

    /**
        Type representing Bjdata data 
        @tparam Size size of the data
    */
    struct Bjdata<auto Size> {
        u8 __data[Size] [[hidden, no_unique_address]];
        builtin::hex::dec::Bjdata<__data> bjdata [[merge]];
    };

    /**
        Type representing Msgpack data 
        @tparam Size size of the data
    */
    struct Msgpack<auto Size> {
        u8 __data[Size] [[hidden, no_unique_address]];
        builtin::hex::dec::Msgpack<__data> msgpack [[merge]];
    };

    /**
        Type representing Ubjson data 
        @tparam Size size of the data
    */
    struct Ubjson<auto Size> {
        u8 __data[Size] [[hidden, no_unique_address]];
        builtin::hex::dec::Ubjson<__data> ubjson [[merge]];
    };
    
}

