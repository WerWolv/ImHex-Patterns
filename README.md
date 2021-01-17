# ImHex-Patterns

Hex patterns, include patterns and magic files for the use with the ImHex Hex Editor

## Table of Contents

### Hex Patterns

| Name | MIME | Path | Description |
|------|------|------|-------------|
| ELF  | `application/x-executable` | `patterns/elf.hexpat` | ELF header in elf binaries |
| PE32 | `application/x-dosexec` | `patterns/pe32.hexpat` | PE header, COFF header, Standard COFF fields and Windows Specific fields for x86 binaries |
| PE64 | `application/x-dosexec` | `patterns/pe64.hexpat` | PE header, COFF header, Standard COFF fields and Windows Specific fields for x64 binaries |
| MIDI | `audio/midi` | `patterns/midi.hexpat` | MIDI header, event fields provided |

### Include Patterns

| Name | Path | Description |
|------|------|-------------|
| cstdint | `includes/cstdint.hexpat` | C standard style fixed width integer types |

### Magic files

| Name | Path | Description |
|------|------|-------------|
| Nintendo Switch | `magic/nintendo_switch_magic` | Identifies common file types used on the Nintendo Switch |

## Contributing

If you want to contribute a file to the database, please make a PR which adds it to the right folder and adds a new entry to the table in this readme. Thanks a lot :)
