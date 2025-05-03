# ImHex Database

This repository serves as a database for files to use with the [ImHex Hex Editor](https://github.com/WerWolv/ImHex). It currently contains

- [Patterns](/patterns) - Binary Format definitions for the Pattern Language
- [Pattern Libraries](/includes) - Libraries that make using the Pattern Language easier
- [Magic Files](/magic) - Custom magic file definitions for the use with libmagic
- [Encodings](/encodings) - Custom encodings in the .tbl format
- [Data Processor Nodes](/nodes) - Custom nodes made for ImHex's Data Processor
- [Themes](/themes) - Custom themes for ImHex
- [Constants](/constants) - Constants definition files
- [Scripts](/scripts) - Various scripts to generate code or automate some tasks
- [Yara](/yara) - Custom Yara rules

## Submissions

Most files in this repository have been submitted by the community. Please feel free to open a PR on your own and add files to it!
Everything will immediately show up in ImHex's Content Store and gets bundled with the next release of ImHex.

## Table of Contents

### Hex Patterns

| Name | MIME | Path | Description |
|------|------|------|-------------|
| 3DS | | [`patterns/3ds.hexpat`](patterns/3ds.hexpat) | Autodesk 3DS Max Model file |
| 7Z | | [`patterns/7z.hexpat`](patterns/7z.hexpat) | 7z File Format |
| ADTFDAT | | [`patterns/adtfdat.hexpat`](patterns/adtfdat.hexpat) | [ADTFDAT files](https://digitalwerk.gitlab.io/solutions/adtf_content/adtf_base/adtf_file_library) |
| ADTS | `audio/x-hx-aac-adts` | [`patterns/adts.hexpat`](patterns/adts.hexpat) | ADTS/AAC audio files |
| AFE2 | | [`patterns/afe2.hexpat`](patterns/afe2.hexpat) | Nintendo Switch Atmosphère CFW Fatal Error log |
| ANI | `application/x-navi-animation` | [`patterns/ani.hexpat`](patterns/ani.hexpat) | Windows Animated Cursor file |
| AR | `application/x-archive` | [`patterns/ar.hexpat`](patterns/ar.hexpat) | Static library archive files |
| ARC | | [`patterns/arc.hexpat`](patterns/arc.hexpat) | Minecraft Legacy Console Edition ARC files |
| ARIA2 | | [`patterns/aria2.hexpat`](patterns/aria2.hexpat) | ARIA2 Download Manager Control files |
| ARM VTOR | | [`patterns/arm_cm_vtor.hexpat`](patterns/arm_cm_vtor.hexpat) | ARM Cortex M Vector Table Layout |
| Bastion | | [`patterns/bastion/*`](https://gitlab.com/EvelynTSMG/imhex-bastion-pats) | Various [Bastion](https://en.wikipedia.org/wiki/Bastion_(video_game)) files |
| BeyondCompare BCSS | | [`patterns/bcss.hexpat`](patterns/bcss.hexpat) | BeyondCompare Snapshot (BCSS) file |
| Bencode | `application/x-bittorrent` | [`patterns/bencode.hexpat`](patterns/bencode.hexpat) | Bencode encoding, used by Torrent files |
| Prusa BGCODE | | [`patterns/bgcode.hexpat`](patterns/bgcode.hexpat) | PrusaSlicer Binary G-Code files |
| BLEND  | | [`patterns/blend.hexpat`](patterns/blend.hexpat) | Blender Project file |
| BMP  | `image/bmp` | [`patterns/bmp.hexpat`](patterns/bmp.hexpat) | OS2/Windows Bitmap files |
| BIN  | | [`patterns/selinux.hexpat`](patterns/selinux.pat) | SE Linux modules |
| BINKA  | | [`patterns/binka.hexpat`](patterns/binka.pat) | RAD Game Tools Bink Audio (BINKA) files |
| BSON | `application/bson` | [`patterns/bson.hexpat`](patterns/bson.hexpat) | BSON (Binary JSON) format |
| bplist | `application/x-bplist` | [`patterns/bplist.hexpat`](patterns/bplist.hexpat) | Apple's binary property list format (bplist) |
| BSP | | [`patterns/bsp_goldsrc.hexpat`](patterns/bsp_goldsrc.hexpat) | GoldSrc engine maps format (used in Half-Life 1) |
| BZIP3 | | [`patterns/bzip3.hexpat`](patterns/bzip3.hexpat) | Parses BZip3 compression (file format) by Kamila Szewczyk |
| CAB | | [`patterns/cab.hexpat`](patterns/cab.hexpat) | Microsoft Cabinet (CAB) Files |
| CCHVA | | [`patterns/cchva.hexpat`](patterns/cchva.hexpat) | Command and Conquer Voxel Animation |
| CCVXL | | [`patterns/ccvxl.hexpat`](patterns/ccvxl.hexpat) | Command and Conquer Voxel Model |
| CCPAL | | [`patterns/ccpal.hexpat`](patterns/ccpal.hexpat) | Command and Conquer Voxel Palette |
| CDA | | [`patterns/cda.hexpat`](patterns/cda.hexpat) | Compact Disc Audio track |
| CHM | `application/vnd.ms-htmlhelp` | [`patterns/chm.hexpat`](patterns/chm.hexpat) | Windows HtmlHelp Data (ITSF / CHM) |
| COFF | `application/x-coff` | [`patterns/coff.hexpat`](patterns/coff.hexpat) | Common Object File Format (COFF) executable |
| CPIO | `application/x-cpio` | [`patterns/cpio.hexpat`](patterns/cpio.hexpat) | Old Binary CPIO Format |
| CrashLvl | | [`patterns/Crashlvl.hexpat`](patterns/Crashlvl.hexpat) | Crash Bandicoot - Back in Time (fan game) User created level format |
| CREDHIST | | [`patterns/credhist.hexpat`](patterns/credhist.hexpat) | CREDHIST Format |
| DDS | `image/vnd-ms.dds` | [`patterns/dds.hexpat`](patterns/dds.hexpat) | DirectDraw Surface |
| DEX | | [`patterns/dex.hexpat`](patterns/dex.hexpat) | Dalvik EXecutable Format |
| DICOM | `application/dicom` | [`patterns/dicom.hexpat`](patterns/dicom.hexpat) | DICOM image format |
| DMG | | [`patterns/dmg.hexpat`](patterns/dmg.hexpat) | Apple Disk Image Trailer (DMG) |
| DMP | | [`patterns/dmp64.hexpat`](patterns/dmp64.hexpat) | Windows Kernel Dump(DMP64) |
| DPAPI_Blob | | [`patterns/dpapblob.hexpat`](patterns/dpapiblob.hexpat) | Data protection API Blob File Format |
| DPAPI_MasterKey | | [`patterns/dpapimasterkey.hexpat`](patterns/dpapimasterkey.hexpat) | Data protection API MasterKey |
| DS_Store | | [`patterns/dsstore.hexpat`](patterns/dsstore.hexpat) | .DS_Store file format |
| DTA | | [`patterns/max_v104.hexpat`](patterns/max_v104.hexpat) | Mechanized Assault and Exploration v1.04 (strategy game) save file format |
| DTED | | [`patterns/dted.hexpat`](patterns/dted.hexpat) | Digital Terrain Elevation Data (DTED) |
| ELF  | `application/x-executable` | [`patterns/elf.hexpat`](patterns/elf.hexpat) | ELF header in elf binaries |
| EVTX | `application/x-ms-evtx` | [`patterns/evtx.hexpat`](patterns/evtx.hexpat) | MS Windows Vista Event Log |
| EXT4 | | [`patterns/ext4.hexpat`](patterns/ext4.hexpat) | Ext4 filesystem |
| FAS | | [`patterns/fas_oskasoftware.hexpat`](patterns/fas_oskasoftware.hexpat) [`patterns/fas_oskasoftware_old.hexpat`](patterns/fas_oskasoftware_old.hexpat) (Old versions of Oska DeskMate) | Oska Software DeskMates FAS (Frames and Sequences) file |
| FBX | | [`patterns/fbx.hexpat`](patterns/fbx.hexpat) | Kaydara FBX Binary |
| FDT | | [`patterns/fdt.hexpat`](patterns/fdt.hexpat) | Flat Linux Device Tree blob |
| FFX | | [`patterns/ffx/*`](https://gitlab.com/EvelynTSMG/imhex-ffx-pats) | Various Final Fantasy X files |
| File System | `application/x-ima` | [`patterns/fs.hexpat`](patterns/fs.hexpat) | Drive File System |
| FLAC | `audio/flac` | [`patterns/flac.hexpat`](patterns/flac.hexpat) | Free Lossless Audio Codec, FLAC Audio Format |
| Flipper Zero Settings | | [`patterns/flipper_settings.hexpat`](patterns/flipper_settings.hexpat) | Flipper Zero Settings Files |
| GB | `application/x-gameboy-rom` | [`patterns/gb.hexpat`](patterns/gb.hexpat) | Game Boy ROM |
| GBA | `application/x-gameboy-advance-rom` | [`patterns/gba.hexpat`](patterns/gba.hexpat) | Game Boy Advance ROM header |
| GGUF | | [`patterns/gguf.hexpat`](patterns/gguf.hexpat) | GGML Inference Models |
| GIF | `image/gif` | [`patterns/gif.hexpat`](patterns/gif.hexpat) | GIF image files |
| GLTF | `model/gltf-binary` | [`patterns/gltf.hexpat`](patterns/gltf.hexpat) | GL Transmission Format binary 3D model file |
| GZIP | `application/gzip` | [`patterns/gzip.hexpat`](patterns/gzip.hexpat) | GZip compressed data format |
| Halo Tag || [`patterns/hinf_tag.hexpat`](patterns/hinf_tag.hexpat) | Halo Infinite Tag Files |
| Halo Module || [`patterns/hinf_module.hexpat`](patterns/hinf_module.hexpat) | Halo Infinite Module Archive Files |
| Halo HavokScript || [`patterns/hinf_luas.hexpat`](patterns/hinf_luas.hexpat) | Halo Infinite HavokScript 5.1 Bytecode |
| HSDT || [`patterns/hsdt.hexpat`](patterns/hsdt.hexpat) | HiSilicon device-tree table images |
| ICO | | [`patterns/ico.hexpat`](patterns/ico.hexpat) | Icon (.ico) or Cursor (.cur) files |
| ID3 | `audio/mpeg` | [`patterns/id3.hexpat`](patterns/id3.hexpat) | ID3 tags in MP3 files |
| IM*H | `audio/mpeg` | [`patterns/imah.hexpat`](patterns/imah.hexpat) | DJI Signed Firmware (IM*H) |
| Intel HEX  | | [`patterns/intel_hex.hexpat`](patterns/intel_hex.hexpat) | [Intel hexadecimal object file format definition]("https://en.wikipedia.org/wiki/Intel_HEX") |
| IP | | [`patterns/ip.hexpat`](patterns/ip.hexpat) | Ethernet II Frames (IP Packets) |
| IPS | | [`patterns/ips.hexpat`](patterns/ips.hexpat) | IPS (International Patching System) files |
| ISO | `application/x-iso9660-image` | [`patterns/iso.hexpat`](patterns/iso.hexpat) | ISO 9660 file system |
| Java Class | `application/x-java-applet` | [`patterns/java_class.hexpat`](patterns/java_class.hexpat) | Java Class files |
| JPEG | `image/jpeg` | [`patterns/jpeg.hexpat`](patterns/jpeg.hexpat) | JPEG Image Format |
| LOC | | [`patterns/loc.hexpat`](patterns/loc.hexpat) | Minecraft Legacy Console Edition Language file |
| Lua 5.1 | | [`patterns/lua51.hexpat`](patterns/lua51.hexpat) | Lua 5.1 bytecode |
| Lua 5.2 | | [`patterns/lua52.hexpat`](patterns/lua52.hexpat) | Lua 5.2 bytecode |
| Lua 5.3 | | [`patterns/lua53.hexpat`](patterns/lua53.hexpat) | Lua 5.3 bytecode |
| Lua 5.4 | | [`patterns/lua54.hexpat`](patterns/lua54.hexpat) | Lua 5.4 bytecode |
| LCE Savefile | | [`patterns/lcesave.hexpat`](patterns/lcesave.hexpat) | Minecraft Legacy Console Edition save file |
| LZNT1 | | [`patterns/lznt1.hexpat`](patterns/lznt1.hexpat) | LZNT1 compressed data format |
| Mach-O | `application/x-mach-binary` | [`patterns/macho.hexpat`](patterns/macho.hexpat) | Mach-O executable |
| MBR & GPT | | [`patterns/partition_table.hexpat`](patterns/partition_table.hexpat) | Partition tables with primary focus on GPT |
| MIDI | `audio/midi` | [`patterns/midi.hexpat`](patterns/midi.hexpat) | MIDI header, event fields provided |
| MiniDump | `application/x-dmp` | [`patterns/minidump.hexpat`](patterns/minidump.hexpat) | Windows MiniDump files |
| mp4 | `video/mp4` | [`patterns/mp4.hexpat`](patterns/mp4.hexpat) | MPEG-4 Part 14 digital multimedia container format |
| msgpack | `application/x-msgpack` | [`patterns/msgpack.hexpat`](patterns/msgpack.hexpat) | MessagePack binary serialization format |
| MSSCMP | | [`patterns/msscmp.hexpat`](patterns/msscmp.hexpat) | Miles Sound System Compressed Archive |
| NACP | | [`patterns/nacp.hexpat`](patterns/nacp.hexpat) | Nintendo Switch NACP files |
| NBT | | [`patterns/nbt.hexpat`](patterns/nbt.hexpat) | Minecraft NBT format |
| NDS | `application/x-nintendo-ds-rom` | [`patterns/nds.hexpat`](patterns/nds.hexpat) | DS Cartridge Header |
| NE | `application/x-ms-ne-executable` | [`patterns/ne.hexpat`](patterns/ne.hexpat) | NE header and Standard NE fields |
| nes | | [`patterns/nes.hexpat`](patterns/nes.hexpat) | .nes file format |
| NotepadCache | | [`patterns/notepad-cache.hexpat`](patterns/notepad-cache.hexpat) | Windows Notepad Cache |
| NotepadWindowState | | [`patterns/notepadwindowstate.hexpat`](patterns/notepadwindowstate.hexpat) | Windows 11 Notepad - Window State .bin file |
| NRO | | [`patterns/nro.hexpat`](patterns/nro.hexpat) | Nintendo Switch NRO files |
| NTAG | | [`patterns/ntag.hexpat`](patterns/ntag.hexpat) | NTAG213/NTAG215/NTAG216, NFC Forum Type 2 Tag compliant IC |
| NTFS | | [`patterns/ntfs.hexpat`](patterns/ntfs.hexpat) | NTFS (NT File System) |
| OGG | `audio/ogg` | [`patterns/ogg.hexpat`](patterns/ogg.hexpat) | OGG Audio format |
| PAK | | [`patterns/xgspak.hexpat`](patterns/xgspak.hexpat) | Exient XGS Engine Pak files |
| PCAP | `application/vnd.tcpdump.pcap` | [`patterns/pcap.hexpat`](patterns/pcap.hexpat) | pcap header and packets |
| PCK | | [`patterns/pck.hexpat`](patterns/pck.hexpat) | Minecraft Legacy Console Edition .pck file |
| PCX | `application/x-pcx` | [`patterns/pcx.hexpat`](patterns/pcx.hexpat) | PCX Image format |
| PE | `application/x-dosexec` `application/x-msdownload` | [`patterns/pe.hexpat`](patterns/pe.hexpat) | PE header, COFF header, Standard COFF fields and Windows Specific fields |
| PEX | | [`patterns/pex.hexpat`](patterns/pex.hexpat) | Bethesda Papyrus executable compiled script file |
| PP | | [`patterns/selinuxpp.hexpat`](patterns/selinuxpp.pat) | SE Linux package |
| PFS0 | | [`patterns/pfs0.hexpat`](patterns/pfs0.hexpat) | Nintendo Switch PFS0 archive (NSP files) |
| PF | | [`patterns/pf.hexpat`](patterns/pf.hexpat) | Microsoft uncompressed prefetch files (.pf) |
| PIF | `image/pif` | [`patterns/pif.hexpat`](patterns/pif.hexpat) | PIF Image Format |
| PKM | | [`patterns/pkm.hexpat`](patterns/pkm.hexpat) | PKM texture format |
| PNG  | `image/png` | [`patterns/png.hexpat`](patterns/png.hexpat) | PNG image files |
| PRODINFO | | [`patterns/prodinfo.hexpat`](patterns/prodinfo.hexpat) | Nintendo Switch PRODINFO |
| Protobuf | | [`patterns/protobuf.hexpat`](patterns/protobuf.hexpat) | Google Protobuf encoding |
| psafe3 | | [`patterns/psafe3.hexpat`](patterns/psafe3.hexpat`) | Password Safe V3 |
| PyInstaller | | [`patterns/pyinstaller.hexpat`](patterns/pyinstaller.hexpat) | PyInstaller binray files |
| PYC | `application/x-bytecode.python` | [`patterns/pyc.hexpat`](patterns/pyc.hexpat) | Python bytecode files |
| QBCL | | [`patterns/qbcl.hexpat`](patterns/qbcl.hexpat) | Qubicle voxel scene project file |
| QOI | `image/qoi` | [`patterns/qoi.hexpat`](patterns/qoi.hexpat) | QOI image files |
| quantized-mesh | | [`patterns/quantized-mesh.hexpat`](patterns/quantized-mesh.hexpat) | Cesium quantized-mesh terrain |
| RAR | `application/x-rar` | [`patterns/rar.hexpat`](patterns/rar.hexpat) | RAR archive file format |
| RAS | `image/x-sun-raster` | [`patterns/ras.hexpat`](patterns/ras.hexpat) | RAS image files |
| ReFS | | [`patterns/refs.hexpat`](patterns/refs.hexpat) | Microsoft Resilient File System |
| RGBDS | | [`patterns/rgbds.hexpat`](patterns/rgbds.hexpat) | [RGBDS](https://rgbds.gbdev.io) object file format |
| RPM | | [`patterns/rpm.hexpat`](patterns/rpm.hexpat) | [RPM](http://ftp.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html) package file format |
| Shell Link | `application/x-ms-shortcut` | [`patterns/lnk.hexpat`](patterns/lnk.hexpat) | Windows Shell Link file format |
| shp | | [`patterns/shp.hexpat`](patterns/shp.hexpat) | ESRI shape file |
| shx | | [`patterns/shx.hexpat`](patterns/shx.hexpat) | ESRI index file |
| sup | | [`patterns/sup.hexpat`](patterns/sup.hexpat) | PGS Subtitle |
| SPIRV | | [`patterns/spirv.hexpat`](patterns/spirv.hexpat) | SPIR-V header and instructions |
| STDF | | [`patterns/stdfv4.hexpat`](patterns/stdfv4.hexpat) | Standard test data format for IC testers |
| STL | `model/stl` | [`patterns/stl.hexpat`](patterns/stl.hexpat) | STL 3D Model format |
| StuffItV5 | `application/x-stuffit` | [`patterns/sit5.hexpat`](patterns/sit5.hexpat) | StuffIt V5 archive |
| SQLite3 | `application/vnd.sqlite3` | [`patterns/sqlite3.hexpat`](patterns/sqlite3.hexpat) | SQLite3 Database |
| SWF | `application/x-shockwave-flash` |[`patterns/swf.hexpat`](patterns/swf.hexpat) | Shockwave Flash file format |
| TAR | `application/x-tar` | [`patterns/tar.hexpat`](patterns/tar.hexpat) | Tar file format |
| TES | | [`patterns/wintec_tes.hexpat`](patterns/wintec_tes.hexpat) | Wintec TES GPS log |
| Thumbcache | | [`patterns/thumbcache.hexpat`](patterns/thumbcache.hexpat) | Windows thumbcache_*.db |
| TIFF | `image/tiff` | [`patterns/tiff.hexpat`](patterns/tiff.hexpat) | Tag Image File Format |
| TGA | `image/tga` | [`patterns/tga.hexpat`](patterns/tga.hexpat) | Truevision TGA/TARGA image |
| TTF | `font/ttf`, `font/otf` | [`patterns/ttf.hexpat`](patterns/ttf.hexpat) | TrueType and OpenType font format |
| Ubiquiti | | [`patterns/ubiquiti.hexpat`](patterns/ubiquiti.hexpat) | Ubiquiti Firmware (update) image |
| UPK | | [`patterns/upk-ue3.hexpat`](patterns/upk-ue3.hexpat) | Unreal Engine 3 UPK file |
| UEFI | | [`patterns/uefi.hexpat`](patterns/uefi.hexpat)` | UEFI structs for parsing efivars |
| UEFI Boot Entry | | [`patterns/uefi_boot_entry.hexpat`](patterns/uefi_boot_entry.hexpat) | UEFI Boot Entry (Load option) |
| UF2 | | [`patterns/uf2.hexpat`](patterns/uf2.hexpat) | [USB Flashing Format](https://github.com/microsoft/uf2) |
| VBMeta | | [`patterns/vbmeta.hexpat`](patterns/vbmeta.hexpat) | Android VBMeta image |
| VDF | | [`patterns/vdf.hexpat`](patterns/vdf.hexpat) | Binary Value Data Format (.vdf) files |
| VEADO | | [`patterns/veado.hexpat`](patterns/veado.hexpat) | veadotube mini avatar file |
| VGM | | [`patterns/vgm.hexpat`](patterns/vgm.hexpat) | VGM (Video Game Music) sound log |
| VHDX | | [`patterns/vhdx.hexpat`](patterns/vhdx.hexpat) | Microsoft Hyper-V Virtual Hard Disk format |
| VOX | | [`patterns/vox.hexpat`](patterns/vox.hexpat) | MagicaVoxel scene description format |
| WAV  | `audio/x-wav`  | [`patterns/wav.hexpat`](patterns/wav.hexpat)  | RIFF header, WAVE header, PCM header |
| WAS | | [`patterns\was_oskasoftware.hexpat`](patterns\was_oskasoftware.hexpat) | Oska Software DeskMates WAS/WA3 (WAVE/MP3 Set) file
| WAD | | [`patterns/wad.hexpat`](patterns/wad.hexpat) | DOOM WAD Archive |
| WebP | `image/webp` | [`patterns/webp.hexpat`](patterns/webp.hexpat) | Google WebP image |
| XBEH | `audio/x-xbox-executable` | [`patterns/xbeh.hexpat`](patterns/xbeh.hexpat) | Xbox executable |
| XCI | | [`patterns/xci.hexpat`](patterns/xci.hexpat) | Nintendo Switch XCI cartridge ROM |
| XGT | | [`patterns/xgt.hexpat`](patterns/xgstexture.hexpat) | Exient XGS Engine Texture |
| Xilinx BIT | | [`patterns/xilinx_bit.hexpat`](patterns/xilinx_bit.hexpat) | Xilinx FPGA Bitstreams |
| Xilinx Bootgen | `application/x-xilinx-boot-zynqmp` | [`patterns/xilinx_bootgen.hexpat`](patterns/xilinx_bootgen.hexpat) | Xilinx ZynqMP Boot Images |
| ZIP  | `application/zip` | [`patterns/zip.hexpat`](patterns/zip.hexpat) | End of Central Directory Header, Central Directory File Headers |
| ZLIB | `application/zlib` | [`patterns/zlib.hexpat`](patterns/zlib.hexpat) | ZLIB compressed data format |
| ZSTD | `application/zstd` | [`patterns/zstd.hexpat`](patterns/zstd.hexpat) | Zstandard compressed data format |

### Scripts

| Name | Path | Description |
|------|------|-------------|
| svd2pat | [`scripts/svd2pat.py`](scripts/svd2pat.py) | Converts a ARM .svd register MMIO definition file into a pattern |
| csv2tbl | [`scripts/csv2tbl.py`](scripts/csv2tbl.py) | Converts a 010 editor CSV encoding file into a table file |

### Pattern Libraries

| Name | Path | Description |
|------|------|-------------|
| libhex | [`includes/hex/*`](includes/hex) | Functions to interact with ImHex |
| libstd | [`includes/std/*`](includes/std) | Pattern Language Standard Library |
| libtype | [`includes/type/*`](includes/type) | Various custom types with special formatters |

### Yara rules

| Name | Path | Description |
|------|------|-------------|
| Official Rules | [`yara/official_rules/*`](yara/official_rules) | Official Yara rules repository |

### Magic files

| Name | Path | Description |
|------|------|-------------|
| Nintendo Switch | [`magic/nintendo_switch_magic`](magic/nintendo_switch_magic) | Identifies common file types used on the Nintendo Switch |
| Portable Executable | [`magic/portable_executable_magic`](magic/portable_executable_magic) | Identifies PE files used on Windows

### Constants files

| Name | Path | Description |
|------|------|-------------|
| CRC-16 | [`constants/crc16.json`](constants/crc16.json) | Constants associated with CRC-16 operations |
| CRC-32 | [`constants/crc32.json`](constants/crc32.json) | Constants associated with CRC-32 operations |
| HTTP-Codes | [`constants/http_status.json`](constants/http_status.json) | HTTP Status code values |
| Linux Error Codes | [`constants/linux_errors.json`](constants/linux_errors.json) | Values of Linux error results |

### Encoding files

| Name | Path | Description |
|------|------|-------------|
| Arabic ISO | [`encodings/arabic_iso.tbl`](encodings/arabic_iso.tbl) | Arabic ISO encoding |
| Arabic Windows | [`encodings/arabic_windows.tbl`](encodings/arabic_windows.tbl) | Arabic Windows encoding |
| ASCII | [`encodings/ascii.tbl`](encodings/ascii.tbl) | Regular ASCII encoding |
| ASCII+ANSI | [`encodings/ascii_ansi.tbl`](encodings/ascii_ansi.tbl) | Extended ASCII encoding |
| ASCII+OEM | [`encodings/ascii_oem.tbl`](encodings/ascii_oem.tbl) | ASCII encoding with Windows OEM characters |
| Baltic ISO | [`encodings/baltic_iso.tbl`](encodings/baltic_iso.tbl) | Baltic ISO encoding |
| Baltic Windows | [`encodings/baltic_windows.tbl`](encodings/baltic_windows.tbl) | Baltic Windows encoding |
| Big5 (Traditional Chinese) | [`encodings/big5.tbl`](encodings/big5.tbl) | Big5 encoding for Traditional Chinese |
| Cyrillic ISO | [`encodings/cyrillic_iso.tbl`](encodings/cyrillic_iso.tbl) | Cyrillic ISO encoding |
| Cyrillic Windows | [`encodings/cyrillic_windows.tbl`](encodings/cyrillic_windows.tbl) | Cyrillic Windows encoding |
| Cyrillic KOI8-R | [`encodings/cyrillic_koi8_r.tbl`](encodings/cyrillic_koi8_r.tbl) | Cyrillic KOI8-R encoding (Russian Characters) |
| Cyrillic KOI8-U | [`encodings/cyrillic_koi8_u.tbl`](encodings/cyrillic_koi8_u.tbl) | Cyrillic KOI8-U encoding (Ukranian Characters) |
| Eastern Europe ISO | [`encodings/eastern_europe_iso.tbl`](encodings/eastern_europe_iso.tbl) | Eastern Europe ISO encoding |
| Eastern Europe Windows | [`encodings/eastern_europe_windows.tbl`](encodings/eastern_europe_windows.tbl) | Eastern Europe Windows encoding |
| EBCDIC | [`encodings/ebcdic.tbl`](encodings/ebcdic.tbl) | Extended Binary Coded Decimal Interchange Code, developed by IBM for their Main Frames |
| EUC-JP | [`encodings/euc_jp.tbl`](encodings/euc_jp.tbl) | EUC-JP encoding with NEC special and IBM extended characters |
| EUC-KR | [`encodings/euc_kr.tbl`](encodings/euc_kr.tbl) | EUC-KR encoding |
| Greek ISO | [`encodings/greek_iso.tbl`](encodings/greek_iso.tbl) | Greek ISO encoding |
| Greek Windows | [`encodings/greek_windows.tbl`](encodings/greek_windows.tbl) | Greek Windows encoding |
| Hebrew ISO | [`encodings/hebrew_iso.tbl`](encodings/hebrew_iso.tbl) | Hebrew ISO encoding |
| Hebrew Windows | [`encodings/hebrew_windows.tbl`](encodings/hebrew_windows.tbl) | Hebrew Windows encoding |
| ISO/IEC 646 | [`encodings/iso_646.tbl`](encodings/iso_646.tbl) | ISO/IEC 646 encoding, an older version of ASCII |
| ISO/IEC 6937 | [`encodings/iso_6937.tbl`](encodings/iso_6937.tbl) | ISO/IEC 6937 encoding, an extension of ASCII containing additional character |
| JIS 0201 | [`encodings/jis_x_0201.tbl`](encodings/jis_x_0201.tbl) | JIS X 0201 encoding in UTF-8 |
| JIS X 0211 | [`encodings/jis_x_0211.tbl`](encodings/jis_x_0211.tbl) | JIS X 0211 encoding in UTF-8 |
| JIS 0213 | [`encodings/jis_x_0213.tbl`](encodings/jis_x_0213.tbl) | JIS X 0213 encoding in UTF-8 |
| Macintosh | [`encodings/macintosh.tbl`](encodings/macintosh.tbl) | Macintosh character encoding used by the Kermit protocol |
| Pokémon (English, Generation 1) | [`encodings/pokegen1_en.tbl`](encodings/pokegen1_en.tbl) | Character encoding used by the English generation 1 Pokémon games  |
| Pokémon (English, Generation 3) | [`encodings/pokegen3_en.tbl`](encodings/pokegen3_en.tbl) | Character encoding used by the English generation 3 Pokémon games  |
| Shift-JIS UTF-8 | [`encodings/shiftjis.tbl`](encodings/shiftjis.tbl) | Shift-JIS encoding in UTF-8 |
| Thai | [`encodings/thai.tbl`](encodings/thai.tbl) | Thai character encoding |
| Turkish ISO | [`encodings/turkish_iso.tbl`](encodings/turkish_iso.tbl) | Turkish ISO encoding |
| Turkish Windows | [`encodings/turkish_windows.tbl`](encodings/turkish_windows.tbl) | Turkish Windows encoding |
| UTF-8 | [`encodings/utf8.tbl`](encodings/utf8.tbl) | UTF-8 encoding |
| Vietnamese | [`encodings/vietnamese.tbl`](encodings/vietnamese.tbl) | Vietnamese character encoding |

### Data Processor Nodes

| Name | Path | Description |
|------|------|-------------|
| Caesar Cipher | [`nodes/caesar.hexnode`](nodes/caesar.hexnode) | Simple adjustable per-byte Caecar Cipher (ROT) |
| XOR Cipher | [`nodes/xor.hexnode`](nodes/xor.hexnode) | XORs a input with a repeating XOR pad |

### Themes

| Name | Path | Description |
|------|------|-------------|
| Visual Studio Dark | [`themes/vs_dark.json`](themes/vs_dark.json) | Theme similar to Visual Studio's Dark theme |
| Solarized Dark | [`themes/solarized_dark.json`](themes/solarized_dark.json) | Solarized Dark Theme |
| Catppuccin Latte | [`themes/catppuccin-latte.json`](themes/catppuccin-latte.json) | Catppuccin Latte Flavor (Light Theme) |
| Catppuccin Frappe | [`themes/catppuccin-frappe.json`](themes/catppuccin-frappe.json) | Catppuccin Frappe Flavor (Dark Theme) |
| Catppuccin Macchiato | [`themes/catppuccin-macchiato.json`](themes/catppuccin-macchiato.json) | Catppuccin Macchiato Flavor (Dark Theme) |
| Catppuccin Mocha | [`themes/catppuccin-mocha.json`](themes/catppuccin-mocha.json) | Catppuccin Mocha Flavor (Dark Theme) |

### Disassemblers

| Name | Path | Description |
|------|------|-------------|
| 8051 | [`disassemblers/8051.json`](disassemblers/8051.json) | Intel 8051 Architecture |
