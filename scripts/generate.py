#!/usr/bin/env python3
# Regenerates encodings/*.tbl from Python's stdlib codecs. Run from anywhere:
#   python3 scripts/generate.py            (re)writes encodings/
#   python3 scripts/generate.py --check    verifies encodings/, writes nothing
import argparse
import codecs
import encodings.aliases
import os
import re
import sys

ENCODINGS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "encodings")

# Hand-authored game-text tables. No codec covers them. Left untouched.
HAND_AUTHORED_FILES = {
    "pokegen1_en.tbl",
    "pokegen3_en.tbl",
}

# codec name -> (IANA name, description). Filenames are lowercase, so this is
# the only place with real capitalization. No library provides these fields.
CODEC_ENCODINGS = {
    "ascii": ("US-ASCII", "Regular ASCII encoding"),
    "big5hkscs": ("Big5", "Big5 encoding for Traditional Chinese (generated from the "
                  "big5hkscs codec, a superset including the Hong Kong Supplementary "
                  "Character Set)"),
    "cp037": ("IBM037", "Extended Binary Coded Decimal Interchange Code, developed by "
              "IBM for their Main Frames"),
    "cp1250": ("windows-1250", "Eastern Europe Windows encoding"),
    "cp1251": ("windows-1251", "Cyrillic Windows encoding"),
    "cp1252": ("windows-1252", "Extended ASCII encoding (Western Windows codepage)"),
    "cp1253": ("windows-1253", "Greek Windows encoding"),
    "cp1254": ("windows-1254", "Turkish Windows encoding"),
    "cp1255": ("windows-1255", "Hebrew Windows encoding"),
    "cp1256": ("windows-1256", "Arabic Windows encoding"),
    "cp1257": ("windows-1257", "Baltic Windows encoding"),
    "cp1258": ("windows-1258", "Vietnamese character encoding"),
    "cp437": ("IBM437", "ASCII encoding with the original IBM PC OEM characters"),
    "cp866": ("IBM866", "Cyrillic DOS/OEM encoding"),
    "cp874": ("windows-874", "Thai character encoding"),
    "cp932": ("Windows-31J", "Shift-JIS with Microsoft/NEC/IBM extensions (aka MS932/CP932)"),
    "cp949": ("EUC-KR", "EUC-KR encoding (generated from the cp949/UHC codec, a superset "
              "of EUC-KR)"),
    "euc_jp": ("EUC-JP", "EUC-JP encoding"),
    "gbk": ("GBK", "GBK encoding for Simplified Chinese"),
    "iso8859_2": ("ISO-8859-2", "Eastern Europe ISO encoding"),
    "iso8859_5": ("ISO-8859-5", "Cyrillic ISO encoding"),
    "iso8859_6": ("ISO-8859-6", "Arabic ISO encoding"),
    "iso8859_7": ("ISO-8859-7", "Greek ISO encoding"),
    "iso8859_8": ("ISO-8859-8", "Hebrew ISO encoding"),
    "iso8859_9": ("ISO-8859-9", "Turkish ISO encoding"),
    "iso8859_13": ("ISO-8859-13", "Baltic ISO encoding"),
    "koi8_r": ("KOI8-R", "Cyrillic KOI8-R encoding (Russian characters)"),
    "koi8_u": ("KOI8-U", "Cyrillic KOI8-U encoding (Ukrainian characters)"),
    "mac_roman": ("macintosh", "Classic Mac OS Roman character encoding"),
    "shift_jis": ("Shift_JIS", "Shift-JIS encoding"),
}

# No stdlib codec for JIS X 0201. Its half-width katakana equal shift_jis's
# single-byte range (see all_files()). Roman set is ASCII except two yen/overline
# positions, patched in below since shift_jis maps those to backslash/tilde.
JIS_X0201_INFO = ("JIS_X0201", "JIS X 0201 encoding (half-width katakana and Roman set)")
JIS_X0201_OVERRIDES = {"5C": "¥", "7E": "‾"}


def normalize(name):
    return re.sub(r"[-: ]", "_", name.lower())


def library_aliases_for(codec_name):
    target = codecs.lookup(codec_name).name
    found = set()
    for alias, module_name in encodings.aliases.aliases.items():
        try:
            if codecs.lookup(module_name).name == target:
                found.add(alias)
        except LookupError:
            continue
    found.discard(codec_name)
    return sorted(found)


def format_value(c):
    if len(c) == 1 and not c.isprintable():
        cp = ord(c)
        return f"\\u{cp:04X}" if cp <= 0xFFFF else f"\\U{cp:08X}"
    return c


def gen_codec_entries(codec_name):
    entries = {}
    for b0 in range(0x100):
        key1 = bytes([b0])
        try:
            entries[key1.hex().upper()] = key1.decode(codec_name)
            continue
        except UnicodeDecodeError:
            pass
        for b1 in range(0x100):
            key2 = bytes([b0, b1])
            try:
                entries[key2.hex().upper()] = key2.decode(codec_name)
            except UnicodeDecodeError:
                continue
        if codec_name == "euc_jp" and b0 == 0x8F:  # JIS X 0212 supplementary plane
            for b1 in range(0x100):
                for b2 in range(0x100):
                    key3 = bytes([b0, b1, b2])
                    try:
                        entries[key3.hex().upper()] = key3.decode(codec_name)
                    except UnicodeDecodeError:
                        continue
    return entries


def find_bases(full_by_stem):
    """For each stem, the largest stem it is a safe superset of, or None.

    X is a safe superset of Y if every key/value pair in Y also occurs in X.
    -include must never need X to redefine a value from Y, since ImHex may
    not support that. Processing stems smallest-first, and only comparing
    against already-processed stems, prevents include cycles."""
    bases = {}
    processed = {}
    for stem in sorted(full_by_stem, key=lambda s: (len(full_by_stem[s]), s)):
        entries = full_by_stem[stem]
        best_stem, best_size = None, -1
        for other_stem, other_entries in processed.items():
            if len(other_entries) <= best_size:
                continue
            if all(entries.get(k) == v for k, v in other_entries.items()):
                best_stem, best_size = other_stem, len(other_entries)
        bases[stem] = best_stem
        processed[stem] = entries
    return bases


def dump_entries(entries):
    lines = [f"{k}={format_value(entries[k])}"
             for k in sorted(entries, key=lambda k: (len(k), int(k, 16)))]
    return "\n".join(lines) + "\n"


def build_primary_body(name, description, include_stem, entries):
    lines = [f"-name {name}"]
    if description:
        lines.append(f"-description {description}")
    if include_stem:
        lines.append(f"-include {include_stem}")
    lines.append(dump_entries(entries).rstrip("\n"))
    return "\n".join(lines) + "\n"


def build_alias_body(primary_stem):
    return f"-alias {primary_stem}\n"


def all_files():
    entries_by_key = {codec: gen_codec_entries(codec) for codec in CODEC_ENCODINGS}
    entries_by_key["jis_x0201"] = {k: v for k, v in entries_by_key["shift_jis"].items()
                                    if len(k) == 2}
    entries_by_key["jis_x0201"].update(JIS_X0201_OVERRIDES)

    stems = {key: normalize(codecs.lookup(key).name if key in CODEC_ENCODINGS else key)
             for key in entries_by_key}
    full = {stems[key]: entries for key, entries in entries_by_key.items()}
    bases = find_bases(full)

    files = {}
    alias_targets = {}

    def register(display_key, name, description, aliases):
        stem = stems[display_key]
        entries = entries_by_key[display_key]
        base_stem = bases[stem]
        own = entries if base_stem is None else \
            {k: v for k, v in entries.items() if k not in full[base_stem]}
        files[stem + ".tbl"] = build_primary_body(name, description, base_stem, own)

        for alias in aliases:
            alias_fname = normalize(alias) + ".tbl"
            if alias_fname == stem + ".tbl":
                continue
            if alias_fname in alias_targets and alias_targets[alias_fname] != stem:
                raise SystemExit(f"alias collision: {alias_fname} wants both "
                                  f"{alias_targets[alias_fname]} and {stem}")
            alias_targets[alias_fname] = stem
            files[alias_fname] = build_alias_body(stem)

    for codec, (name, description) in CODEC_ENCODINGS.items():
        register(codec, name, description, library_aliases_for(codec))
    name, description = JIS_X0201_INFO
    register("jis_x0201", name, description, ["X0201", "csHalfWidthKatakana"])

    return files


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true",
                         help="verify encodings/ matches, write nothing")
    args = parser.parse_args()

    os.chdir(ENCODINGS_DIR)

    expected = all_files()
    actual_names = {f for f in os.listdir(".") if f.endswith(".tbl")} - HAND_AUTHORED_FILES
    expected_names = set(expected)

    problems = []
    missing = sorted(expected_names - actual_names)
    extra = sorted(actual_names - expected_names)
    if missing:
        problems.append("missing files: " + ", ".join(missing))
    if extra:
        problems.append("unexpected files (not produced by generate.py): " + ", ".join(extra))

    mismatched = []
    for fname in sorted(expected_names & actual_names):
        with open(fname, encoding="utf-8", newline="") as f:
            current = f.read()
        if current != expected[fname]:
            mismatched.append(fname)
    if mismatched:
        problems.append("out of date: " + ", ".join(mismatched))

    if args.check:
        if problems:
            for p in problems:
                print("generate.py --check:", p, file=sys.stderr)
            sys.exit(1)
        print("encodings/ is up to date with generate.py")
        return

    for fname, content in expected.items():
        with open(fname, "w", encoding="utf-8", newline="") as f:
            f.write(content)
    for fname in extra:
        os.remove(fname)
    print(f"wrote {len(expected)} files")


if __name__ == "__main__":
    main()
