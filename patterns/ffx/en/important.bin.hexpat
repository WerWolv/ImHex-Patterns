#include "std/core.pat"
#include "std/io.pat"
#include <ffx/utils.hexpat>

struct KeyItem<auto id> {
    String2 name;
    String2 description;
    u16 icon;
    u16;
} [[format("format_key_item")]];

fn format_key_item(ref KeyItem<usize> item) {
    return std::format("{:04X} - {} ({})", 0xa000 + item.id, ffx2ascii(item.name.text), ffx2ascii(item.description.text));
};

KeyItem<std::core::array_index()> items[max_idx + 1] @ start_offset;