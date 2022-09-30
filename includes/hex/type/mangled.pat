#pragma once

#include <std/io.pat>
#include <std/mem.pat>

#include <hex/impl/imhex_check.pat>
#include <hex/dec.pat>

namespace hex::type {
	
    struct MangledName {
        char value[];
    } [[sealed, format("format_mangled_name")]];
	
    namespace impl {

        fn format_mangled_name(ref MangledName name) {
            return hex::dec::demangle(name.value);
        };
    }
	
}

