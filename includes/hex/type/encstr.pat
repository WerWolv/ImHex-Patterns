#pragma once

import hex.impl.imhex_check;

/*!
    Types to work with custom encoded strings using Thiny encoding definitions
*/

namespace auto hex::type {
    
    /**
        A string that was encoded using a custom encoding
        @tparam Data Pattern whose bytes are used in the decoding process
        @tparam EncodingDefinition A string containing a Thingy encoding definition as used by ImHex's custom encoding feature
    */
    struct EncodedString<auto Data, auto EncodingDefinition> {
        builtin::hex::dec::EncodedString<Data, EncodingDefinition> string;
    } [[sealed, format("hex::type::impl::format_encoded_string")]];
    
    namespace impl {

        fn format_encoded_string(ref auto string) {
            return string.string;
        };
    }
    
}

