namespace std::ptr {

    fn relative_to_pointer(u128 offset) {
        return $;
    };

    fn relative_to_parent(u128 offset) {
        return addressof(parent);
    };

    fn relative_to_end(u128 offset) {
        return std::mem::size() - offset * 2;
    };

}