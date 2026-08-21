#include <ffx/utils.hexpat>

struct Text {
    String2 text;
    u16;
    u16;
    u16;
    u16;
} [[format("format_text")]];

fn format_text(ref Text txt) {
    return ffx2ascii(txt.text.text);
};

Text texts[block_count] @ start_offset;