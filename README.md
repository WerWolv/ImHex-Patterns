# ImHex-Patterns

Hex patterns, include patterns and magic files for the use with the ImHex Hex Editor

## Table of Contents

### Hex Patterns

| Name | MIME | Path | Description |
|------|------|------|-------------|
| BMP  | `image/bmp` | `patterns/bmp.hexpat` | OS2/Windows Bitmap files |
| ELF  | `application/x-executable`, `application/x-sharedlib` | `patterns/elf.hexpat` | ELF header in elf binaries |
| PE   | `application/x-dosexec` | `patterns/pe.hexpat` | PE header, COFF header, Standard COFF fields and Windows Specific fields |
| Intel HEX  | | `patterns/intel_hex.hexpat` | [Intel hexadecimal object file format definition]("https://en.wikipedia.org/wiki/Intel_HEX") |
| MIDI | `audio/midi` | `patterns/midi.hexpat` | MIDI header, event fields provided |
| WAV  | `audio/wav`  | `patterns/wav.hexpat`  | RIFF header, WAVE header, PCM header |
| ZIP  | `application/zip` | `patterns/zip.hexpat` | End of Central Directory Header, Central Directory File Headers |
| PCAP | `application/vnd.tcpdump.pcap` | `patterns/pcap.hexpat` | pcap header and packets | 
| SPIRV | | `patterns/spirv.hexpat` | SPIR-V header and instructions | 
| AFE2 | | `patterns/afe2.hexpat` | Nintendo Switch Atmosphère CFW Fatal Error log | 
| AR | `application/x-archive` | `patterns/ar.hexpat` | Static library archive files | 
| NACP | | `patterns/nacp.hexpat` | Nintendo Switch NACP files | 
| NRO | | `patterns/nro.hexpat` | Nintendo Switch NRO files | 
| PRODINFO | | `patterns/prodinfo.hexpat` | Nintendo Switch PRODINFO | 
| Java Class | `application/x-java-applet` | `patterns/java_class.hexpat` | Java Class files | 
| ARM VTOR | | `patterns/arm_cm_vtor.hexpat` | ARM Cortex M Vector Table Layout | 
| ICO | | `patterns/ico.hexpat` | Icon (.ico) or Cursor (.cur) files | 
| PNG  | `image/png` | `patterns/png.hexpat` | PNG image files | 
| DDS | `image/vnd-ms.dds` | `patterns/dds.hexpat` | DirectDraw Surface |
| TGA | `image/tga` | `patterns/tga.hexpat` | Truevision TGA/TARGA image |
| ISO | | `patterns/iso.hexpat` | ISO 9660 file system |
| VDF | | `patterns/vdf.hexpat` | Binary Value Data Format (.vdf) files | 
| IP | | `patterns/ip.hexpat` | Ethernet II Frames (IP Packets) | 
| UF2 | | `patterns/uf2.hexpat` | [USB Flashing Format](https://github.com/microsoft/uf2) | 

### Scripts

| Name | Path | Description |
|------|------|-------------|
| svd2pat | `scripts/svd2pat.py` | Converts a ARM .svd register MMIO definition file into a pattern |
| csv2tbl | `scripts/csv2tbl.py` | Converts a 010 editor CSV encoding file into a table file |

### Pattern Libraries

| Name | Path | Description |
|------|------|-------------|
| libstd | `includes/std/*` | Pattern Language Standard Libaray |
| cstdint | `includes/cstdint.pat` | C integer types |

### Yara rules

| Name | Path | Description |
|------|------|-------------|
| Official Rules | `yara/official_rules/*` | Official Yara rules repository |

### Magic files

| Name | Path | Description |
|------|------|-------------|
| Nintendo Switch | `magic/nintendo_switch_magic` | Identifies common file types used on the Nintendo Switch |
| Portable Executable | `magic/portable_executable_magic` | Identifies PE files used on Windows

### Constants files

| Name | Path | Description |
|------|------|-------------|
| CRC-16 | `constants/crc16.json` | Constants associated with CRC-16 operations |
| CRC-32 | `constants/crc32.json` | Constants associated with CRC-32 operations |
| HTTP-Codes | `constants/http_status.json` | HTTP Status code values |
| Linux Error Codes | `constants/linux_errors.json` | Values of Linux error results |

### Encoding files

| Name | Path | Description |
|------|------|-------------|
| Arabic ISO | `encodings/arabic_iso.tbl` | Arabic ISO encoding |
| Arabic Windows | `encodings/arabic_windows.tbl` | Arabic Windows encoding |
| ASCII | `encodings/ascii.tbl` | Regular ASCII encoding |
| ASCII+ANSI | `encodings/ascii_ansi.tbl` | Extended ASCII encoding |
| ASCII+OEM | `encodings/ascii_oem.tbl` | ASCII encoding with Windows OEM characters |
| Baltic ISO | `encodings/baltic_iso.tbl` | Baltic ISO encoding |
| Baltic Windows | `encodings/baltic_windows.tbl` | Baltic Windows encoding |
| Cyrillic ISO | `encodings/cyrillic_iso.tbl` | Cyrillic ISO encoding |
| Cyrillic Windows | `encodings/cyrillic_windows.tbl` | Cyrillic Windows encoding |
| Cyrillic KOI8-R | `encodings/cyrillic_koi8_r.tbl` | Cyrillic KOI8-R encoding (Russian Characters) |
| Cyrillic KOI8-U | `encodings/cyrillic_koi8_u.tbl` | Cyrillic KOI8-U encoding (Ukranian Characters) |
| Eastern Europe ISO | `encodings/eastern_europe_iso.tbl` | Eastern Europe ISO encoding |
| Eastern Europe Windows | `encodings/eastern_europe_windows.tbl` | Eastern Europe Windows encoding |
| EBCDIC | `encodings/ebcdic.tbl` | Extended Binary Coded Decimal Interchange Code, developed by IBM for their Main Frames |
| EUC-JP | `encodings/euc_jp.tbl` | EUC-JP encoding with NEC special and IBM extended characters |
| Greek ISO | `encodings/greek_iso.tbl` | Greek ISO encoding |
| Greek Windows | `encodings/greek_windows.tbl` | Greek Windows encoding |
| Hebrew ISO | `encodings/hebrew_iso.tbl` | Hebrew ISO encoding |
| Hebrew Windows | `encodings/hebrew_windows.tbl` | Hebrew Windows encoding |
| ISO/IEC 646 | `encodings/iso_646.tbl` | ISO/IEC 646 encoding, an older version of ASCII |
| ISO/IEC 6937 | `encodings/iso_6937.tbl` | ISO/IEC 6937 encoding, an extension of ASCII containing additional character |
| JIS 0201 | `encodings/jis_x_0201.tbl` | JIS X 0201 encoding in UTF-8 |
| JIS X 0211 | `encodings/jis_x_0211.tbl` | JIS X 0211 encoding in UTF-8 |
| JIS 0213 | `encodings/jis_x_0213.tbl` | JIS X 0213 encoding in UTF-8 |
| Macintosh | `encodings/macintosh.tbl` | Macintosh character encoding used by the Kermit protocol |
| Shift-JIS UTF-8 | `encodings/shiftjis.tbl` | Shift-JIS encoding in UTF-8 |
| Thai | `encodings/thai.tbl` | Thai character encoding |
| Turkish ISO | `encodings/turkish_iso.tbl` | Turkish ISO encoding |
| Turkish Windows | `encodings/turkish_windows.tbl` | Turkish Windows encoding |
| UTF-8 | `encodings/thai.tbl` | UTF-8 encoding |
| Vietnamese | `encodings/thai.tbl` | Vietnamese character encoding |

## Contributing

If you want to contribute a file to the database, please make a PR which adds it to the right folder and adds a new entry to the table in this readme. 
To take advantage of the automatic pattern testing, please consider adding a test file named `<pattern_name>.hexpat.<extension>` to the `/tests/patterns/test_data` directory. Try to keep this file as small as possible so the repository doesn't become excessively large

Thanks a lot :)