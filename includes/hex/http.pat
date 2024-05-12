#pragma once

import hex.impl.imhex_check;

/*!
    Library to do HTTP requests
*/

namespace auto hex::http {

    /**
        Performs a HTTP GET request to the given URL and returns the response body
        @param url URL to perform the request to
        @return Response body
    */
    fn get(str url) {
        return builtin::hex::http::get(url);
    };

}