#!/usr/bin/env python3
# Regenerates encodings/*.tbl and the README table from Python's stdlib codecs.
# Run from anywhere:
#   python3 scripts/generate.py            (re)writes encodings/ and README.md
#   python3 scripts/generate.py --check    verifies both, writes nothing
import argparse
import codecs
import encodings.aliases
import os
import re
import sys

REPO_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ENCODINGS_DIR = os.path.join(REPO_ROOT, "encodings")
README_PATH = os.path.join(REPO_ROOT, "README.md")

FILE_TABLE_START = "<!-- generate.py: start of File encodings table -->"
FILE_TABLE_END = "<!-- generate.py: end of File encodings table -->"
MULTI_BYTE_TABLE_START = "<!-- generate.py: start of Multi-byte encodings table -->"
MULTI_BYTE_TABLE_END = "<!-- generate.py: end of Multi-byte encodings table -->"

# Hand-authored game-text tables; no codec covers them, but still listed below.
HAND_AUTHORED_FILES = {
    "pokegen1_en.tbl": ("Pokémon (English, Generation 1)",
                         "Character encoding used by the English generation 1 Pokémon games"),
    "pokegen3_en.tbl": ("Pokémon (English, Generation 3)",
                         "Character encoding used by the English generation 3 Pokémon games"),
}

# codec -> (IANA name, description). Name is a display label, not the
# filename. No library provides these fields.
CODEC_ENCODINGS = {
    "ascii": ("US-ASCII", "Basic 7-bit encoding for English text"),
    "big5hkscs": ("Big5", "Encoding for Traditional Chinese text"),
    "cp037": ("IBM037", "Extended Binary Coded Decimal Interchange Code"),
    "cp1250": ("windows-1250", "Windows encoding for Central European languages (Polish, Czech, Hungarian, and others)"),
    "cp1251": ("windows-1251", "Windows encoding for Cyrillic languages (Russian, Bulgarian, Serbian, and others)"),
    "cp1252": ("windows-1252", "Windows encoding for Western European languages (English, French, German, and others)"),
    "cp1253": ("windows-1253", "Windows encoding for the Greek language"),
    "cp1254": ("windows-1254", "Windows encoding for the Turkish language"),
    "cp1255": ("windows-1255", "Windows encoding for the Hebrew language"),
    "cp1256": ("windows-1256", "Windows encoding for the Arabic language"),
    "cp1257": ("windows-1257", "Windows encoding for Baltic languages (Estonian, Latvian, Lithuanian)"),
    "cp1258": ("windows-1258", "Windows encoding for the Vietnamese language"),
    "cp437": ("IBM437", "Original IBM PC encoding, with box-drawing and symbol characters"),
    "cp866": ("IBM866", "DOS encoding for Cyrillic languages (Russian and others)"),
    "cp874": ("windows-874", "Windows encoding for the Thai language"),
    "cp932": ("Windows-31J", "Shift-JIS with Microsoft/NEC/IBM extensions (aka MS932/CP932)"),
    "cp949": ("EUC-KR", "Extended Unix Code encoding for the Korean language"),
    "euc_jp": ("EUC-JP", "Extended Unix Code encoding for the Japanese language"),
    "gbk": ("GBK", "Encoding for Simplified Chinese text"),
    "iso8859_2": ("ISO-8859-2", "ISO encoding for Central European languages (Polish, Czech, Hungarian, and others)"),
    "iso8859_5": ("ISO-8859-5", "ISO encoding for Cyrillic languages (Russian, Bulgarian, Serbian, and others)"),
    "iso8859_6": ("ISO-8859-6", "ISO encoding for the Arabic language"),
    "iso8859_7": ("ISO-8859-7", "ISO encoding for the Greek language"),
    "iso8859_8": ("ISO-8859-8", "ISO encoding for the Hebrew language"),
    "iso8859_9": ("ISO-8859-9", "ISO encoding for the Turkish language"),
    "iso8859_13": ("ISO-8859-13", "ISO encoding for Baltic languages (Estonian, Latvian, Lithuanian)"),
    "koi8_r": ("KOI8-R", "Cyrillic KOI8-R encoding (Russian characters)"),
    "koi8_u": ("KOI8-U", "Cyrillic KOI8-U encoding (Ukrainian characters)"),
    "mac_roman": ("macintosh", "Classic Mac OS encoding for Western European languages"),
    "shift_jis": ("Shift_JIS", "Encoding for Japanese text"),
}

# Encodings derived from another one's entries plus overrides; add an
# entry here instead of writing code. source: key to copy entries from.
# key_filter: keep only matching keys. overrides: entries to add/replace.
DERIVED_ENCODINGS = {
    "jis_x0201": {
        "name": "JIS_X0201",
        "description": "JIS X 0201 encoding (half-width katakana and Roman set)",
        "aliases": ["X0201"],
        "source": "shift_jis",
        "key_filter": lambda k: len(k) == 2,
        "overrides": {"5C": "¥", "7E": "‾"},
    },
}

# IANA aliases missing from Python's table. Skip cs-prefixed/numeric ones:
# is_useful_alias() drops them anyway.
EXTRA_ALIASES = {
    "gbk": ["windows-936"],
}


def is_useful_alias(alias):
    """False for numeric or "cs"-prefixed aliases (e.g. "1250", "csBig5"): too generic."""
    a = alias.lower()
    return not (a.isdigit() or a.startswith("cs"))


def normalize(name):
    return re.sub(r"[-: ]", "_", name.lower())


def stem_for(key):
    """Filename stem for a codec or derived key. Never the IANA name."""
    if key in CODEC_ENCODINGS:
        return normalize(codecs.lookup(key).name)
    return normalize(key)


def library_aliases_for(codec_name):
    target = codecs.lookup(codec_name).name
    found = set()
    for alias, module_name in encodings.aliases.aliases.items():
        try:
            if codecs.lookup(module_name).name == target:
                found.add(alias)
        except LookupError:
            continue
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
    """Largest stem each stem safely supersets (or None): -include must
    never redefine a value. Smallest-first order avoids cycles."""
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


def useful_aliases(key, aliases):
    """Aliases worth a file: not the primary's own stem, and useful."""
    stem = stem_for(key)
    return sorted(a for a in aliases if is_useful_alias(a) and normalize(a) != stem)


def all_encodings():
    """(key, name, description, aliases) for every generated primary file."""
    items = [(codec, name, description,
              useful_aliases(codec, set(library_aliases_for(codec)) | set(EXTRA_ALIASES.get(codec, []))))
             for codec, (name, description) in CODEC_ENCODINGS.items()]
    items += [(key, cfg["name"], cfg["description"], useful_aliases(key, cfg["aliases"]))
              for key, cfg in DERIVED_ENCODINGS.items()]
    return items


def build_entries():
    entries_by_key = {codec: gen_codec_entries(codec) for codec in CODEC_ENCODINGS}
    for key, cfg in DERIVED_ENCODINGS.items():
        entries = {k: v for k, v in entries_by_key[cfg["source"]].items()
                   if cfg["key_filter"](k)}
        entries.update(cfg["overrides"])
        entries_by_key[key] = entries

    stems = {key: stem_for(key) for key in entries_by_key}
    full = {stems[key]: entries_by_key[key] for key in entries_by_key}
    return stems, full


def count_entries(fname):
    with open(fname, encoding="utf-8", newline="") as f:
        return sum(1 for line in f if line.strip() and not line.startswith("-"))


def is_codepage(entries):
    """True if every key is one byte and every value is one codepoint
    (what #pragma encoding accepts)."""
    return all(len(k) == 2 for k in entries) and all(len(v) == 1 for v in entries.values())


# ImHex decodes these without a table file.
ALGORITHMIC_ENCODINGS = [
    ("UTF-8", "Unicode Transformation Format, 8-bit"),
    ("UTF-16BE", "Unicode Transformation Format, 16-bit, big-endian"),
    ("UTF-16LE", "Unicode Transformation Format, 16-bit, little-endian"),
    ("UTF-32BE", "Unicode Transformation Format, 32-bit, big-endian"),
    ("UTF-32LE", "Unicode Transformation Format, 32-bit, little-endian"),
]


def readme_rows(stems, full):
    file_encodings, multi_byte = [], []

    for key, name, description, aliases in all_encodings():
        stem = stems[key]
        entries = full[stem]
        row = (name, stem, description, len(entries), aliases)
        (file_encodings if is_codepage(entries) else multi_byte).append(row)

    for fname, (name, description) in HAND_AUTHORED_FILES.items():
        stem = fname[:-len(".tbl")]
        multi_byte.append((name, stem, description, count_entries(fname), []))

    for name, description in ALGORITHMIC_ENCODINGS:
        multi_byte.append((name, None, description, None, []))

    return file_encodings, multi_byte


def build_readme_table(rows):
    lines = ["| IANA Name | Path | Description | Entries | Aliases |",
              "|------|------|-------------|---------|---------|"]
    for name, stem, description, entries, aliases in rows:
        alias_text = ", ".join(f"`{a}`" for a in aliases) if aliases else "(none)"
        if stem is None:
            path = f"`{name}` (Algorithmic)"
            entries_text = "Universal"
        else:
            link = f"encodings/{stem}.tbl"
            path = f"[`{link}`]({link})"
            entries_text = str(entries)
        lines.append(f"| {name} | {path} | {description} | {entries_text} | {alias_text} |")
    return "\n".join(lines) + "\n"


def apply_table(content, start, end, table):
    pattern = re.compile(re.escape(start) + r"\n.*?\n" + re.escape(end), re.DOTALL)
    replacement = f"{start}\n{table}{end}"
    new_content, count = pattern.subn(replacement, content, count=1)
    if count == 0:
        raise SystemExit(f"README.md: markers not found (expected {start!r})")
    return new_content


def all_files(stems, full):
    bases = find_bases(full)
    files = {}
    alias_targets = {}

    for key, name, description, aliases in all_encodings():
        stem = stems[key]
        entries = full[stem]
        base_stem = bases[stem]
        own = entries if base_stem is None else \
            {k: v for k, v in entries.items() if k not in full[base_stem]}
        if stem + ".tbl" in files:
            raise SystemExit(f"primary collision: two encodings both normalize to {stem}.tbl")
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

    return files


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true",
                         help="verify encodings/ and README.md match, write nothing")
    args = parser.parse_args()

    os.chdir(ENCODINGS_DIR)

    stems, full = build_entries()
    expected = all_files(stems, full)
    actual_names = {f for f in os.listdir(".") if f.endswith(".tbl")}.difference(HAND_AUTHORED_FILES)
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

    with open(README_PATH, encoding="utf-8", newline="") as f:
        readme_current = f.read()
    file_encodings, multi_byte = readme_rows(stems, full)
    readme_expected = apply_table(readme_current, FILE_TABLE_START, FILE_TABLE_END,
                                   build_readme_table(file_encodings))
    readme_expected = apply_table(readme_expected, MULTI_BYTE_TABLE_START, MULTI_BYTE_TABLE_END,
                                   build_readme_table(multi_byte))
    if readme_current != readme_expected:
        problems.append("README.md is out of date")

    if args.check:
        if problems:
            for p in problems:
                print("generate.py --check:", p, file=sys.stderr)
            sys.exit(1)
        print("encodings/ and README.md are up to date with generate.py")
        return

    for fname, content in expected.items():
        with open(fname, "w", encoding="utf-8", newline="") as f:
            f.write(content)
    for fname in extra:
        os.remove(fname)
    with open(README_PATH, "w", encoding="utf-8", newline="") as f:
        f.write(readme_expected)
    print(f"wrote {len(expected)} files and README.md")


if __name__ == "__main__":
    main()
