#pragma once

#include <std/io.pat>
#include <std/mem.pat>

#include <hex/impl/imhex_check.pat>
#include <hex/dec.pat>

/*!
    Types to automatically decode mangled names
*/

namespace hex::type {
	
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

