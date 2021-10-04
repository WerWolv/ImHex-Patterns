namespace std::ptr {

    fn relative_to_pointer(u128 offset) {
        return $ + offset;
    };

    fn relative_to_parent(u128 offset) {
        return addressof(parent) + offset;
    };

    fn relative_to_end(u128 offset) {
        return std::mem::size() - offset;
    };

}