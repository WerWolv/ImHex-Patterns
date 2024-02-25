#pragma once

import std.io;
import std.mem;

import hex.impl.imhex_check;
import hex.dec;

/*!
    Types to automatically decode mangled names
*/

namespace auto hex::type {
	
    /**
        A mangled name string that gets demangled when displayed
    */
    struct MangledName {
        char value[];
    } [[sealed, format("hex::type::impl::format_mangled_name")]];
	
    namespace impl {

        fn format_mangled_name(ref MangledName name) {
            return hex::dec::demangle(name.value);
        };
    }
	
}

