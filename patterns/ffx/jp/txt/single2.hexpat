#include <ffx/utils.hexpat>

struct Text {
    String2jp text;
    u16;
    u16;
    u16;
    u16;
} [[format("format_text")]];

fn format_text(ref Text txt) {
    return ffx2jp(txt.text.text);
};

Text texts[block_count] @ start_offset;