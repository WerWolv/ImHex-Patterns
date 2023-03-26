#pragma once

#include <hex/impl/imhex_check.pat>

/*!
    Library to allow decoding of more complex values
*/

namespace hex::dec {

    /**
        Demangles a mangled name into a human readable name
        @param mangled_name The mangled name
        @return The demangled name
    */
    fn demangle(str mangled_name) {
        return builtin::hex::dec::demangle(mangled_name);
    };

}