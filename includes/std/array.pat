#pragma once

namespace std {

    struct Array<T, auto Size> {
        T data[Size] [[inline]];
    };

}