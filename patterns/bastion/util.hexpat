#include <std/string.pat>
#include <type/leb128.pat>

using StringLEB128 = std::string::SizedString<type::uLEB128> [[sealed]];

struct Vector2<T> {
    T x;
    T y;
} [[format("fmt_vector2f")]];

fn fmt_vector2f(ref auto v) {
    return std::format("({}, {})", v.x, v.y);
};

struct Range<T> {
    T min;
    T max;
} [[format("fmt_range")]];

fn fmt_range(ref auto r) {
    return std::format("{} -> {}", r.min, r.max);
};

struct Pair<K, V> {
    K key;
    V value;
} [[format("fmt_pair")]];

fn fmt_pair(ref auto p) {
    return std::format("{}: {}", p.key, p.value);
};

struct Map<K, V> {
    s32 length [[hidden]];
    Pair<K, V> elements[length] [[inline]];
} [[format("fmt_collection")]];

struct List<T> {
    s32 length [[hidden]];
    T elements[length] [[inline]];
} [[format("fmt_collection")]];

struct Set<T> {
    StringLEB128 name;
    List<T> elements [[inline]];
} [[format("fmt_named")]];

fn fmt_collection(ref auto l) {
    return std::format("Size: {}", l.length);
};

fn fmt_named(ref auto data) {
    return data.name;
};

fn fmt_percent(float value) {
    return std::format("{:.2}%", value * 100);
};