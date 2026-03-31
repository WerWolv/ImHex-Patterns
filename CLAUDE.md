# ImHex-Patterns Project Notes

This is a fork of ImHex-Pattern, created to improve the MP4 parsing in particular. The file where all the work is being done is patterns/newmp4.hexpat


To test that the code of newmp4.hexpat is correct run the following command. This should be done after editing the file

imhex --verbose --pl run --pattern /home/ekirprivat/git/ImHex-Patterns/patterns/newmp4.hexpat --input /home/ekirprivat/media/video_with_gps_data.mp4 


This repository is the community pattern database for the [ImHex Hex Editor](https://github.com/WerWolv/ImHex). Files here appear in ImHex's Content Store and are bundled with releases.

## Repository Structure

- `patterns/` — Binary format definitions (`.hexpat` files) using ImHex's Pattern Language
- `includes/` — Pattern libraries/helpers for reuse across patterns
- `magic/` — Custom libmagic definitions for file type detection
- `encodings/` — Custom encodings in `.tbl` format
- `nodes/` — Custom Data Processor nodes
- `themes/` — Custom ImHex themes
- `constants/` — Constants definition files
- `scripts/` — Code generation and automation scripts
- `yara/` — Custom Yara rules
- `tests/patterns/test_data/` — Test files for pattern unit tests

## Adding a New Pattern

1. Add the `.hexpat` file to `patterns/`
2. Add a test file `<pattern_name>.hexpat.<ext>` to `tests/patterns/test_data/` (keep under ~100 KiB; no copyrighted files)
3. Add an entry to the Table of Contents in `README.md`
4. Submit a PR

## Notes

<!-- Add your own project notes here -->
