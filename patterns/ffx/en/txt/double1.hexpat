#include <ffx/utils.hexpat>

struct Text {
    String name;
    String description;
} [[format("format_text")]];

fn format_text(ref Text txt) {
    return std::format("{} ({})", ffx2ascii(txt.name.text), ffx2ascii(txt.description.text));
};

Text texts[block_count] @ start_offset;