#include "std/core.pat"
#include "std/io.pat"
#include <ffx/utils.hexpat>

struct NameCluster<auto id> {
    String0 _names[7] [[single_color, color("60B7FC"), format("format_names")]];
    String0 _names_hira[7] [[single_color, color("58C845")]];
    u16 model_ids[7] [[color("D92D2D")]];
    padding[2];
} [[format("format_cluster")]];

fn format_names(ref String0 names) {
    return std::format(
            "  Tidus: {}\n   Yuna: {}\n  Auron: {}\nKimahri: {}\n  Wakka: {}\n   Lulu: {}\n  Rikku: {}",
            ffx2ascii(names[0].text),
            ffx2ascii(names[1].text),
            ffx2ascii(names[2].text),
            ffx2ascii(names[3].text),
            ffx2ascii(names[4].text),
            ffx2ascii(names[5].text),
            ffx2ascii(names[6].text));
};

fn format_cluster(NameCluster<usize> cluster) {
    return std::format("{:04X}", cluster.id);
};

NameCluster<0x5000 + std::core::array_index()> names[max_idx + 1] @ start_offset;