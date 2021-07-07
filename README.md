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

### Include Patterns

| Name | Path | Description |
|------|------|-------------|
| cstdint | `includes/cstdint.hexpat` | C standard style fixed width integer types |

### Magic files

| Name | Path | Description |
|------|------|-------------|
| Nintendo Switch | `magic/nintendo_switch_magic` | Identifies common file types used on the Nintendo Switch |
| Portable Executable | `magic/portable_executable_magic` | Identifies PE files used on Windows

## Contributing

If you want to contribute a file to the database, please make a PR which adds it to the right folder and adds a new entry to the table in this readme. Thanks a lot :)
