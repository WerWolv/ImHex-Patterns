#pragma once

#include <hex/impl/imhex_check.pat>

/*!
    Library to do HTTP requests
*/

namespace hex::http {

    /**
        Performs a HTTP GET request to the given URL and returns the response body
        @param url URL to perform the request to
        @return Response body
    */
    fn get(str url) {
        return builtin::hex::http::get(url);
    };

}