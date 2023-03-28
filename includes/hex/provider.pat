#pragma once

/*!
    Library to interact with the currently loaded provider.
*/

namespace hex::prv {
    
    
    /**
        Queries information from the currently loaded provider. The kind of information that's available depends on the provider that's loaded
        
        > **Available information**
        > - File Provider
        >   - `file_path() -> str`
        >   - `file_name() -> str`
        >   - `file_extension() -> str`
        >   - `creation_time() -> time_t`
        >   - `access_time() -> time_t`
        >   - `modification_time() -> time_t`
        >   - `permissions() -> u16`
        > - Disk Provider
        >   - `file_path() -> str`
        >   - `sector_size() -> u128`
        > - GDB Provider
        >   - `ip() -> str`
        >   - `port() -> u16`
        > - Process Memory Provider
        >   - `region_address(regionName) -> u64`
        >   - `region_size(regionName) -> u64`
        >   - `process_id() -> u32`
        >   - `process_name() -> str`
        
        @param category Information category
        @param argument Extra argument to pass along
    */
    fn get_information(str category, str argument = "") {
        return builtin::hex::prv::get_information(category, argument);
    };
    
}
