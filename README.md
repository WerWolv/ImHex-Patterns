# ImHex-Patterns

Hex patterns, include patterns and magic files for the use with the ImHex Hex Editor

## Table of Contents

### Hex Patterns

| Name | MIME | Path | Description |
|------|------|------|-------------|
| BMP  | `image/bmp` | `patterns/bmp.hexpat` | OS2/Windows Bitmap files |
| ELF  | `application/x-executable`, `application/x-sharedlib` | `patterns/elf.hexpat` | ELF header in elf binaries |
| PE   | `application/x-dosexec` | `patterns/pe.hexpat` | PE header, COFF header, Standard COFF fields and Windows Specific fields |
| Intel HEX  | `text/plain` | `patterns/intel_hex.hexpat` | [Intel hexadecimal object file format definition]("https://en.wikipedia.org/wiki/Intel_HEX") |
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

### Scripts

| Name | Path | Description |
|------|------|-------------|
| svd2pat | `scripts/svd2pat.py` | Converts a ARM .svd register MMIO definition file into a pattern |

### Pattern Libraries

| Name | Path | Description |
|------|------|-------------|
| libstd | `includes/libstd/*` | Pattern Language Standard Libaray |
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
| ANSI | `encodings/ansi.tbl` | ANSI encoding |
| EUC-JP | `encodings/euc_jp.tbl` | EUC-JP encoding with NEC special and IBM extended characters |
| ISO/IEC 646 | `encodings/iso_646.tbl` | ISO/IEC 646 encoding, an older version of ASCII |
| ISO/IEC 6937 | `encodings/iso_6937.tbl` | ISO/IEC 6937 encoding, an extension of ASCII containing additional character |
| Shift-JIS with half-width characters | `encodings/shiftjis_halfchars.tbl` | Shift-JIS encoding including half-width characters at 0xA1 - 0xDF |
| Shift-JIS UTF-8 | `encodings/shiftjis.tbl` | Shift-JIS encoding in UTF-8 |
| JIS 0201 | `encodings/jis_x_0201.tbl` | JIS X 0201 encoding in UTF-8 |
| JIS X 0211 | `encodings/jis_x_0211.tbl` | JIS X 0211 encoding in UTF-8 |
| JIS 0213 | `encodings/jis_x_0213.tbl` | JIS X 0213 encoding in UTF-8 |

## Contributing

If you want to contribute a file to the database, please make a PR which adds it to the right folder and adds a new entry to the table in this readme. Thanks a lot :)
