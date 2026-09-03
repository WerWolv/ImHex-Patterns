#include <ffx/utils.hexpat>

struct Text {
    String0Jp name;
    String0Jp description;
} [[format("format_text")]];

fn format_text(ref Text txt) {
    return std::format("{} ({})", ffx2jp(txt.name.text), ffx2jp(txt.description.text));
};

Text texts[block_count] @ start_offset;