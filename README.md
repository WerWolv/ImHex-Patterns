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
| $I | | [`patterns/ifile.hexpat`](patterns/ifile.hexpat) | Windows Recycling Bin $I file |
| 3DS | | [`patterns/3ds.hexpat`](patterns/3ds.hexpat) | Autodesk 3DS Max Model file |
| 7Z | | [`patterns/7z.hexpat`](patterns/7z.hexpat) | 7z File Format |
| ADTFDAT | | [`patterns/adtfdat.hexpat`](patterns/adtfdat.hexpat) | [ADTFDAT files](https://digitalwerk.gitlab.io/solutions/adtf_content/adtf_base/adtf_file_library) |
| ADTS | `audio/x-hx-aac-adts` | [`patterns/adts.hexpat`](patterns/adts.hexpat) | ADTS/AAC audio files |
| AFE2 | | [`patterns/afe2.hexpat`](patterns/afe2.hexpat) | Nintendo Switch Atmosphère CFW Fatal Error log |
| AMD Ucode Container | | [`patterns/amd_ucode_container.hexpat`](patterns/amd_ucode_container.hexpat) | AMD Linux Kernel microcode container |
| AMD Ucode Patch | | [`patterns/amd_ucode_patch.hexpat`](patterns/amd_ucode_patch.hexpat) | AMD microcode patch |
| ANI | `application/x-navi-animation` | [`patterns/ani.hexpat`](patterns/ani.hexpat) | Windows Animated Cursor file |
| APFS | | [`patterns/fs/apfs.hexpat`](patterns/fs/apfs.hexpat) | Apple File Ssytem (APFS) |
| AppleSingle | `application/applefile` | [`patterns/apple_single_double.hexpat`](patterns/apple_single_double.hexpat) | AppleSingle Dual Fork file |
| AppleDouble | `multipart/appledouble` | [`patterns/apple_single_double.hexpat`](patterns/apple_single_double.hexpat) | AppleDouble Resource Fork/Finder Metadata file |
| AR | `application/x-archive` | [`patterns/ar.hexpat`](patterns/ar.hexpat) | Static library archive files |
| ARC | | [`patterns/arc.hexpat`](patterns/arc.hexpat) | Minecraft Legacy Console Edition ARC files |
| ARIA2 | | [`patterns/aria2.hexpat`](patterns/aria2.hexpat) | ARIA2 Download Manager Control files |
| ARM VTOR | | [`patterns/arm_cm_vtor.hexpat`](patterns/arm_cm_vtor.hexpat) | ARM Cortex M Vector Table Layout |
| Arma 3 config | `application/x.a3-rap` | [`patterns/a3/a3_rap.hexpat`](patterns/a3/a3_rap.hexpat) | Arma 3 binary/rapified config |
| Arma 3 P3D (MLOD) | `model/x.a3-p3d-mlod` | [`patterns/a3/a3_p3d_mlod.hexpat`](patterns/a3/a3_p3d_mlod.hexpat) | Arma 3 P3D model file (MLOD) |
| Arma 3 PAA | `image/x.a3-paa` | [`patterns/a3/a3_paa.hexpat`](patterns/a3/a3_paa.hexpat) | Arma 3 PAA texture file |
| Arma 3 RTM | `application/x.a3-rtm` | [`patterns/a3/a3_rtm.hexpat`](patterns/a3/a3_rtm.hexpat) | Arma 3 RTM animation file (plain) |
| Arma 3 RTM (binarized) | `application/x.a3-bmtr` | [`patterns/a3/a3_bmtr.hexpat`](patterns/a3/a3_bmtr.hexpat) | Arma 3 RTM animation file (binarized) |
| Arma 3 texHeaders.bin | `application/x.a3-texheaders` | [`patterns/a3/a3_texheaders.hexpat`](patterns/a3/a3_texheaders.hexpat) | Arma 3 texture index file |
| Assassin's Creed: Unity | | [`patterns/AC Unity`](patterns/Assassin's Creed: Unity) | Assassin's Creed: Unity archive files -- .forge & .data (compressed and decompressed) -- |
| Bastion | | [`patterns/bastion/*`](https://gitlab.com/EvelynTSMG/imhex-bastion-pats) | Various [Bastion](https://en.wikipedia.org/wiki/Bastion_(video_game)) files |
| BeyondCompare BCSS | | [`patterns/bcss.hexpat`](patterns/bcss.hexpat) | BeyondCompare Snapshot (BCSS) file |
| Bencode | `application/x-bittorrent` | [`patterns/bencode.hexpat`](patterns/bencode.hexpat) | Bencode encoding, used by Torrent files |
| Prusa BGCODE | | [`patterns/bgcode.hexpat`](patterns/bgcode.hexpat) | PrusaSlicer Binary G-Code files |
| BLEND  | | [`patterns/blend.hexpat`](patterns/blend.hexpat) | Blender Project file |
| BLF | | [`patterns/blf.hexpat`](patterns/blf.hexpat) | Vector BLF Frame Logging Files |
| Bloodborne | | [`patterns/bloodborne_save.hexpat`](patterns/bloodborne_save.hexpat) | Bloodborne character files (userdata0000 to userdata0009) |
| BMP  | `image/bmp` | [`patterns/bmp.hexpat`](patterns/bmp.hexpat) | OS2/Windows Bitmap files |
| BIN  | | [`patterns/selinux.hexpat`](patterns/selinux.pat) | SE Linux modules |
| BINK Container | `video/vnd.radgamettools.bink` | [`patterns/bink_container.hexpat`](patterns/bink_container.hexpat) | [RAD Game Tools Bink Video Container files](https://en.wikipedia.org/wiki/Bink_Video) |
| BINKA  | | [`patterns/binka.hexpat`](patterns/binka.pat) | RAD Game Tools Bink Audio (BINKA) files |
| BroEngine .anim | | [`patterns/BroEngine/anim.hexpat`](patterns/BroEngine/anim.hexpat) | Bro Engine (World of Tanks: HEAT) Animation |
| BroEngine .dds | | [`patterns/BroEngine/dds.hexpat`](patterns/BroEngine/dds.hexpat) | Bro Engine (World of Tanks: HEAT) Texture |
| BroEngine .mesh | | [`patterns/BroEngine/mesh.hexpat`](patterns/BroEngine/mesh.hexpat) | Bro Engine (World of Tanks: HEAT) Mesh |
| BroEngine .morph | | [`patterns/BroEngine/morph.hexpat`](patterns/BroEngine/morph.hexpat) | Bro Engine (World of Tanks: HEAT) Morph |
| BroEngine .skel | | [`patterns/BroEngine/skel.hexpat`](patterns/BroEngine/skel.hexpat) | Bro Engine (World of Tanks: HEAT) Skeleton |
| BSON | `application/bson` | [`patterns/bson.hexpat`](patterns/bson.hexpat) | BSON (Binary JSON) format |
| BTRFS Send Stream | | [`patterns/btrfs_send_stream.hexpat`](patterns/btrfs_send_stream.hexpat) | BTRFS Send Stream format |
| bplist | `application/x-bplist` | [`patterns/bplist.hexpat`](patterns/bplist.hexpat) | Apple's binary property list format (bplist) |
| BSP | | [`patterns/bsp_goldsrc.hexpat`](patterns/bsp_goldsrc.hexpat) | GoldSrc engine maps format (used in Half-Life 1) |
| BZIP3 | | [`patterns/bzip3.hexpat`](patterns/bzip3.hexpat) | Parses BZip3 compression (file format) by Kamila Szewczyk |
| CAB | | [`patterns/cab.hexpat`](patterns/cab.hexpat) | Microsoft Cabinet (CAB) Files |
| CCHVA | | [`patterns/cchva.hexpat`](patterns/cchva.hexpat) | Command and Conquer Voxel Animation |
| CCVXL | | [`patterns/ccvxl.hexpat`](patterns/ccvxl.hexpat) | Command and Conquer Voxel Model |
| CCPAL | | [`patterns/ccpal.hexpat`](patterns/ccpal.hexpat) | Command and Conquer Voxel Palette |
| CGX | | [`patterns/CGX.hexpat`](patterns/CGX.hexpat) | PlayStation Mobile Shader |
| CDA | | [`patterns/cda.hexpat`](patterns/cda.hexpat) | Compact Disc Audio track |
| CHD | | [`patterns/chd.hexpat`](patterns/chd.hexpat) | MAME Compressed Hunks of Data file |
| CHM | `application/vnd.ms-htmlhelp` | [`patterns/chm.hexpat`](patterns/chm.hexpat) | Windows HtmlHelp Data (ITSF / CHM) |
| Chromium Pak | | [`patterns/chromium_pak.hexpat`](patterns/chromium_pak.hexpat) | Chromium pak file |
| COFF | `application/x-coff` | [`patterns/coff.hexpat`](patterns/coff.hexpat) | Common Object File Format (COFF) executable |
| CPIO | `application/x-cpio` | [`patterns/cpio.hexpat`](patterns/cpio.hexpat) | Old Binary CPIO Format |
| CPIO | | [`patterns/cpio_portable_ascii.hexpat`](patterns/cpio_portable_ascii.hexpat) | Portable ASCII CPIO Format |
| CPIO | | [`patterns/cpio_new_ascii.hexpat`](patterns/cpio_new_ascii.hexpat) | "New" ASCII CPIO Format |
| CrashLvl | | [`patterns/Crashlvl.hexpat`](patterns/Crashlvl.hexpat) | Crash Bandicoot - Back in Time (fan game) User created level format |
| CREDHIST | | [`patterns/credhist.hexpat`](patterns/credhist.hexpat) | CREDHIST Format |
| DDS | `image/vnd-ms.dds` | [`patterns/dds.hexpat`](patterns/dds.hexpat) | DirectDraw Surface |
| DEM | |[`patterns/hldem.hexpat`](patterns/hldem.hexpat) | GoldSRC Demo file |
| DEX | | [`patterns/dex.hexpat`](patterns/dex.hexpat) | Dalvik EXecutable Format |
| Devil May Cry HD Collection | | [`patterns/Devil May Cry HD Collection`](patterns/Devil May Cry HD Collection) | 3D Model files used in Devil May Cry 3 HD Collection |
| DICOM | `application/dicom` | [`patterns/dicom.hexpat`](patterns/dicom.hexpat) | DICOM image format |
| Dig or Die Save | | [`patterns/dod-save.hexpat`](patterns/dod-save.hexpat) | Dig or Die uncompressed save file |
| DISK_PARSER (DFIR) | `application/x-ima` | [`patterns/DFIR/DISK_PARSER.hexpat`](patterns/DFIR/DISK_PARSER.hexpat) | Recursive Disk/Volume/Filesystem parsing |
| DMG | | [`patterns/dmg.hexpat`](patterns/dmg.hexpat) | Apple Disk Image Trailer (DMG) |
| DMP | | [`patterns/dmp64.hexpat`](patterns/dmp64.hexpat) | Windows Kernel Dump(DMP64) |
| DOS | `application/x-dosexec` |  [`patterns/dos.hexpat`](patterns/dos.hexpat) | 16-bit real mode DOS EXE files |
| DOTNET_BinaryFormatter | | [`patterns/dotnet_binaryformatter.hexpat`](patterns/dotnet_binaryformatter.hexpat) | .NET BinaryFormatter |
| DPAPI_Blob | | [`patterns/dpapblob.hexpat`](patterns/dpapiblob.hexpat) | Data protection API Blob File Format |
| DPAPI_MasterKey | | [`patterns/dpapimasterkey.hexpat`](patterns/dpapimasterkey.hexpat) | Data protection API MasterKey |
| DS_Store | | [`patterns/dsstore.hexpat`](patterns/dsstore.hexpat) | .DS_Store file format |
| DTA | | [`patterns/max_v104.hexpat`](patterns/max_v104.hexpat) | Mechanized Assault and Exploration v1.04 (strategy game) save file format |
| DTED | | [`patterns/dted.hexpat`](patterns/dted.hexpat) | Digital Terrain Elevation Data (DTED) |
| EBU STL | `application/x-ebu-stl` | [`patterns/ebu_stl.hexpat`](patterns/ebu_stl.hexpat) | EBU STL broadcast subtitle format |
| ELF  | `application/x-executable` | [`patterns/elf.hexpat`](patterns/elf.hexpat) | ELF header in elf binaries |
| ESP32 Image | | [`patterns/esp32_image.hexpat`](patterns/esp32_image.hexpat) | Firmware image format for the ESP32 chip family |
| ESP8266 Image | | [`patterns/esp8266.hexpat`](patterns/esp8266.hexpat) | ESP8266 Firmware Image v1 |
| EVTX | `application/x-ms-evtx` | [`patterns/evtx.hexpat`](patterns/evtx.hexpat) | MS Windows Vista Event Log |
| EXFAT | | [`patterns/fs/exfat.hexpat`](patterns/fs/exfat.hexpat) | Extensible File Allocation Table (exFAT) |
| EXFAT (DFIR) | | [`patterns/DFIR/exFAT.hexpat`](patterns/DFIR/exFAT.hexpat) | Imported by DISK_PARSER.hexpat |
| EXT4 | | [`patterns/fs/ext4.hexpat`](patterns/fs/ext4.hexpat) | Ext4 File System |
| FAS | | [`patterns/fas_oskasoftware.hexpat`](patterns/fas_oskasoftware.hexpat) [`patterns/fas_oskasoftware_old.hexpat`](patterns/fas_oskasoftware_old.hexpat) (Old versions of Oska DeskMate) | Oska Software DeskMates FAS (Frames and Sequences) file |
| FAT32 | | [`patterns/fs/fat32.hexpat`](patterns/fs/fat32.hexpat) | FAT32 File System |
| FAT32 (DFIR) | | [`patterns/DFIR/FAT32.hexpat`](patterns/DFIR/FAT32.hexpat) | Imported by DISK_PARSER.hexpat |
| FBX | | [`patterns/fbx.hexpat`](patterns/fbx.hexpat) | Kaydara FBX Binary |
| FDT | | [`patterns/fdt.hexpat`](patterns/fdt.hexpat) | Flat Linux Device Tree blob |
| FEZ Save File | | [`patterns/fez.hexpat`](patterns/fez.hexpat) | Game Save File format for FEZ |
| FFX | | [`patterns/ffx/*`](https://gitlab.com/EvelynTSMG/imhex-ffx-pats) | Various Final Fantasy X files |
| File System | `application/x-ima` | [`patterns/fs/pattern.hexpat`](patterns/fs/pattern.hexpat) | Drive File System |
| FLAC | `audio/flac` | [`patterns/flac.hexpat`](patterns/flac.hexpat) | Free Lossless Audio Codec, FLAC Audio Format |
| FLC/FLIC | | [`patterns/flc.hexpat`](patterns/flc.hexpat) | FLC/FLIC animation file |
| FLP | `application/x-fruityloops` | [`patterns/flp.hexpat`](patterns/fl.hexpat) | FL Studio project file |
| FLV | | [`patterns/flv.hexpat`](patterns/flv.hexpat) | FLv animation file |
| Flipper Zero Settings | | [`patterns/flipper_settings.hexpat`](patterns/flipper_settings.hexpat) | Flipper Zero Settings Files |
| GB | `application/x-gameboy-rom` | [`patterns/gb.hexpat`](patterns/gb.hexpat) | Game Boy ROM |
| GBA | `application/x-gameboy-advance-rom` | [`patterns/gba.hexpat`](patterns/gba.hexpat) | Game Boy Advance ROM header |
| GBX | | [`patterns/gbx.hexpat`](patterns/gbx.hexpat) | GameBoy ROM file GBX footer |
| Gen | | [`patterns/gen.hexpat`](patterns/gen.hexpat) | Sega Genesis/MegaDrive ROM |
| GGUF | | [`patterns/gguf.hexpat`](patterns/gguf.hexpat) | GGML Inference Models |
| GIF | `image/gif` | [`patterns/gif.hexpat`](patterns/gif.hexpat) | GIF image files |
| GLTF | `model/gltf-binary` | [`patterns/gltf.hexpat`](patterns/gltf.hexpat) | GL Transmission Format binary 3D model file |
| Gold Box Games: Character | | [`patterns/GoldBox/GB_CHR.hexpat`](patterns/GoldBox/GB_CHR.hexpat) | Gold Box Game Character/Monster files |
| Gold Box Games: Executable | | [`patterns/GoldBox/GB_EXE.hexpat`](patterns/GoldBox/GB_EXE.hexpat) | Gold Box Game Executables |
| Gold Box Games: Item Base | | [`patterns/GoldBox/GB_ITM-Base.hexpat`](patterns/GoldBox/GB_ITM-Base.hexpat) | Gold Box Game Item Base files |
| Gold Box Games: Item Record | | [`patterns/GoldBox/GB_ITM-Record.hexpat`](patterns/GoldBox/GB_ITM-Record.hexpat) | Gold Box Game Item Record files |
| Gold Box Games: Map | | [`patterns/GoldBox/GB_GEO.hexpat`](patterns/GoldBox/GB_GEO.hexpat) | Gold Box Game Map files |
| Gold Box Games: Unlimited Adventures Script | | [`patterns/GoldBox/GB_UA_SCRIPT.hexpat`](patterns/GoldBox/GB_UA_SCRIPT.hexpat) | Gold Box Unlimited Adventures SCRIPT file |
| Gold Box Games: Vault | | [`patterns/GoldBox/GB_VLT.hexpat`](patterns/GoldBox/GB_VLT.hexpat) | Gold Box Game Vault files |
| GTA:SA *.b | | [`patterns/gtasa_save.hexpat`](patterns/gtasa_save.hexpat) | GTA San Andreas Save Game File |
| GVAS | | [`patterns/gvas.hexpat`](patterns/gvas.hexpat) | Unreal Engine 4+ Save Game file |
| GZIP | `application/gzip` | [`patterns/gzip.hexpat`](patterns/gzip.hexpat) | GZip compressed data format |
| Halo Tag || [`patterns/hinf_tag.hexpat`](patterns/hinf_tag.hexpat) | Halo Infinite Tag Files |
| Halo Module || [`patterns/hinf_module.hexpat`](patterns/hinf_module.hexpat) | Halo Infinite Module Archive Files |
| Halo HavokScript || [`patterns/hinf_luas.hexpat`](patterns/hinf_luas.hexpat) | Halo Infinite HavokScript 5.1 Bytecode |
| HPROF || [`patterns/hprof.hexpat`](patterns/hprof.hexpat) | Java HPROF Profiler Data Format |
| HSDT || [`patterns/hsdt.hexpat`](patterns/hsdt.hexpat) | HiSilicon device-tree table images |
| ICO | | [`patterns/ico.hexpat`](patterns/ico.hexpat) | Icon (.ico) or Cursor (.cur) files |
| ID3 | `audio/mpeg` | [`patterns/id3.hexpat`](patterns/id3.hexpat) | ID3 tags in MP3 files |
| IM*H || [`patterns/imah.hexpat`](patterns/imah.hexpat) | DJI Signed Firmware (IM*H) |
| Intel HEX  | | [`patterns/intel_hex.hexpat`](patterns/intel_hex.hexpat) | [Intel hexadecimal object file format definition]("https://en.wikipedia.org/wiki/Intel_HEX") |
| IP | | [`patterns/ip.hexpat`](patterns/ip.hexpat) | Ethernet II Frames (IP Packets) |
| IPS | | [`patterns/ips.hexpat`](patterns/ips.hexpat) | IPS (International Patching System) files |
| ISO | `application/x-iso9660-image` | [`patterns/iso.hexpat`](patterns/iso.hexpat) | ISO 9660 file system |
| Java Class | `application/x-java-applet` | [`patterns/java_class.hexpat`](patterns/java_class.hexpat) | Java Class files |
| Job File   |  | [`patterns/job.hexpat`](patterns/job.hexpat) | TaskScheduler v1.0 Job File | 
| JPEG | `image/jpeg` | [`patterns/jpeg.hexpat`](patterns/jpeg.hexpat) | JPEG Image Format |
| keytab | | [`patterns/keytab.hexpat`](patterns/keytab.hexpat) | MIT Kerberos 5 keytab file |
| Kindle Update | | [`patterns/kindle_update.hexpat`](patterns/kindle_update.hexpat) | Kindle Update Package |
| KTX | `image/ktx` | [`patterns/ktx.hexpat`](patterns/ktx.hexpat) | Khronos TeXture 1.0 |
| LOC | | [`patterns/loc.hexpat`](patterns/loc.hexpat) | Minecraft Legacy Console Edition Language file |
| Lua 4.0 | | [`patterns/lua40.hexpat`](patterns/lua40.hexpat) | Lua 4.0 bytecode |
| LUC | | [`patterns/popcap_luc.hexpat`](patterns/popcap_luc.hexpat) | PopCap's proprietary Lua bytecode |
| Lua 5.0 | | [`patterns/lua50.hexpat`](patterns/lua50.hexpat) | Lua 5.0 bytecode |
| Lua 5.1 | | [`patterns/lua51.hexpat`](patterns/lua51.hexpat) | Lua 5.1 bytecode |
| Lua 5.2 | | [`patterns/lua52.hexpat`](patterns/lua52.hexpat) | Lua 5.2 bytecode |
| Lua 5.3 | | [`patterns/lua53.hexpat`](patterns/lua53.hexpat) | Lua 5.3 bytecode |
| Lua 5.4 | | [`patterns/lua54.hexpat`](patterns/lua54.hexpat) | Lua 5.4 bytecode |
| LCE Savefile | | [`patterns/lcesave.hexpat`](patterns/lcesave.hexpat) | Minecraft Legacy Console Edition save file |
| LZ4 | `application/x-lz4` | [`patterns/lz4.hexpat`](patterns/lz4.hexpat) | LZ4 Frame Format |
| LZNT1 | | [`patterns/lznt1.hexpat`](patterns/lznt1.hexpat) | LZNT1 compressed data format |
| Mach-O | `application/x-mach-binary` | [`patterns/macho.hexpat`](patterns/macho.hexpat) | Mach-O executable |
| Magic | `application/x-file` | [`patterns/magic.hexpat`](patterns/magic.hexpat) | file / libmagic Magic database |
| MIDI | `audio/midi` | [`patterns/midi.hexpat`](patterns/midi.hexpat) | MIDI header, event fields provided |
| MIFARE Classic 1K | `application/x-mifare-classic` | [`patterns/mifare/mifare-1k.hexpat`](patterns/mifare/mifare-1k.hexpat) | MIFARE Classic EV1 1K (MF1S50yyX/V1) |
| MIFARE Classic 4K | `application/x-mifare-classic` | [`patterns/mifare/mifare-4k.hexpat`](patterns/mifare/mifare-4k.hexpat) | MIFARE Classic EV1 4K (MF1S70yyX/V1) |
| MiniDump | `application/x-dmp` | [`patterns/minidump.hexpat`](patterns/minidump.hexpat) | Windows MiniDump files |
| MO | | [`patterns/mo.hexpat`](patterns/mo.hexpat) | GNU Machine Object (MO) files containing translations for gettext |
| ModuleAnalysisCache | | [`patterns/moduleanalysiscache.hexpat`](patterns/moduleanalysiscache.hexpat) | PSModuleCacheFile (ModuleAnalysisCache) |
| mp4 | `video/mp4` | [`patterns/mp4.hexpat`](patterns/mp4.hexpat) | MPEG-4 Part 14 digital multimedia container format |
| msgpack | `application/x-msgpack` | [`patterns/msgpack.hexpat`](patterns/msgpack.hexpat) | MessagePack binary serialization format |
| MSSCMP | | [`patterns/msscmp.hexpat`](patterns/msscmp.hexpat) | Miles Sound System Compressed Archive |
| NACP | | [`patterns/nacp.hexpat`](patterns/nacp.hexpat) | Nintendo Switch NACP files |
| NBT | | [`patterns/nbt.hexpat`](patterns/nbt.hexpat) | Minecraft NBT format |
| N64 | | [`patterns/n64.hexpat`](patterns/n64.hexpat) | Nintendo 64 ROM header |
| NDS | `application/x-nintendo-ds-rom` | [`patterns/nds.hexpat`](patterns/nds.hexpat) | DS Cartridge Header |
| NE | `application/x-ms-ne-executable` | [`patterns/ne.hexpat`](patterns/ne.hexpat) | NE header and Standard NE fields |
| nes | | [`patterns/nes.hexpat`](patterns/nes.hexpat) | Nintendo Entertainment System ROM |
| NSF | | [`patterns/nsf.hexpat`](patterns/nsf.hexpat) | NES Sound Format |
| NSFe | | [`patterns/nsfe.hexpat`](patterns/nsfe.hexpat) | NES Sound Format extended |
| NotepadCache | | [`patterns/notepad-cache.hexpat`](patterns/notepad-cache.hexpat) | Windows Notepad Cache |
| NotepadStateFile | | [`patterns/notepad-state.hexpat`](patterns/notepad-state.hexpat) | Windows Notepad .bin State files |
| NotepadWindowState | | [`patterns/notepadwindowstate.hexpat`](patterns/notepadwindowstate.hexpat) | Windows 11 Notepad - Window State .bin file |
| NRO | | [`patterns/nro.hexpat`](patterns/nro.hexpat) | Nintendo Switch NRO files |
| NSO | | [`patterns/nso.hexpat`](patterns/nso.hexpat) | Nintendo Switch NSO files |
| NTAG | | [`patterns/ntag.hexpat`](patterns/ntag.hexpat) | NTAG213/NTAG215/NTAG216, NFC Forum Type 2 Tag compliant IC |
| NTFS | | [`patterns/fs/ntfs.hexpat`](patterns/fs/ntfs.hexpat) | NTFS (NT File System) |
| NTFS (DFIR) | | [`patterns/DFIR/NTFS.hexpat`](patterns/DFIR/NTFS.hexpat) | Imported by DISK_PARSER.hexpat |
| OGG | `audio/ogg` | [`patterns/ogg.hexpat`](patterns/ogg.hexpat) | OGG Audio format |
| ORP / ORS | | [`patterns/orp.hexpat`](patterns/orp.hexpat) | OpenRGB profile format |
| PACK | | [`patterns/roblox_pack.hexpat`](patterns/roblox_pack.hexpat) | Roblox shader archive format |
| PAK | | [`patterns/xgspak.hexpat`](patterns/xgspak.hexpat) | Exient XGS Engine Pak files |
| PCAP | `application/vnd.tcpdump.pcap` | [`patterns/pcap.hexpat`](patterns/pcap.hexpat) | pcap header and packets |
| PcapNG | `application/vnd.tcpdump.pcap` | [`patterns/pcapng.hexpat`](patterns/pcapng.hexpat) | pcapng header and packets |
| PCK | | [`patterns/pck.hexpat`](patterns/pck.hexpat) | Minecraft Legacy Console Edition .pck file |
| PCX | `application/x-pcx` | [`patterns/pcx.hexpat`](patterns/pcx.hexpat) | PCX Image format |
| PE | `application/x-dosexec` `application/x-msdownload` | [`patterns/pe.hexpat`](patterns/pe.hexpat) | PE header, COFF header, Standard COFF fields and Windows Specific fields |
| PEF | | [`patterns/pef.hexpat`](patterns/pef.hexpat) | Preffered Executable Format executable (for Mac OS 7.1.2 - Mac OS 10.4 / BeOS) |
| PEX | | [`patterns/pex.hexpat`](patterns/pex.hexpat) | Bethesda Papyrus executable compiled script file |
| PP | | [`patterns/selinuxpp.hexpat`](patterns/selinuxpp.pat) | SE Linux package |
| PFS0 | | [`patterns/pfs0.hexpat`](patterns/pfs0.hexpat) | Nintendo Switch PFS0 archive (NSP files) |
| PF | | [`patterns/pf.hexpat`](patterns/pf.hexpat) | Microsoft uncompressed prefetch files (.pf) |
| Pickle | | [`patterns/pickle.hexpat`](patterns/pickle.hexpat) | Python Pickle Protocol |
| PIF | `image/pif` | [`patterns/pif.hexpat`](patterns/pif.hexpat) | PIF Image Format |
| PKM | | [`patterns/pkm.hexpat`](patterns/pkm.hexpat) | PKM texture format |
| PNG  | `image/png` | [`patterns/png.hexpat`](patterns/png.hexpat) | PNG image files |
| PRODINFO | | [`patterns/prodinfo.hexpat`](patterns/prodinfo.hexpat) | Nintendo Switch PRODINFO |
| Protobuf | | [`patterns/protobuf.hexpat`](patterns/protobuf.hexpat) | Google Protobuf encoding |
| PSP SELF | | [`patterns/psp_self.hexpat`](patterns/psp_self.hexpat) | PlayStation Portable SELF |
| psafe3 | | [`patterns/psafe3.hexpat`](patterns/psafe3.hexpat`) | Password Safe V3 |
| PyInstaller | | [`patterns/pyinstaller.hexpat`](patterns/pyinstaller.hexpat) | PyInstaller binray files |
| PYC | `application/x-bytecode.python` | [`patterns/pyc.hexpat`](patterns/pyc.hexpat) | Python bytecode files |
| QBCL | | [`patterns/qbcl.hexpat`](patterns/qbcl.hexpat) | Qubicle voxel scene project file |
| QOI | `image/qoi` | [`patterns/qoi.hexpat`](patterns/qoi.hexpat) | QOI image files |
| Quake 3 engine demo | | [`patterns/q3demo.hexpat`](patterns/q3demo.hexpat) | Demos/replays of most Quake 3 engine games |
| quantized-mesh | | [`patterns/quantized-mesh.hexpat`](patterns/quantized-mesh.hexpat) | Cesium quantized-mesh terrain |
| RAR | `application/x-rar` | [`patterns/rar.hexpat`](patterns/rar.hexpat) | RAR archive file format |
| RAS | `image/x-sun-raster` | [`patterns/ras.hexpat`](patterns/ras.hexpat) | RAS image files |
| RCF 1.2 | | [`patterns/rcf_v1_2.hexpat`](patterns/rcf_v1_2.hexpat) | Radcore Cement Library 1.2 file header |
| ReFS | | [`patterns/refs.hexpat`](patterns/fs/refs.hexpat) | Microsoft Resilient File System |
| RGBDS | | [`patterns/rgbds.hexpat`](patterns/rgbds.hexpat) | [RGBDS](https://rgbds.gbdev.io) object file format |
| RKVD | | [`patterns/rkvd.hexpat`](patterns/rkvd.hexpat) | Rockchip Vendor Storage |
| RPM | | [`patterns/rpm.hexpat`](patterns/rpm.hexpat) | [RPM](http://ftp.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html) package file format |
| RSC | | [`patterns/rsc.hexpat`](patterns/rsc.hexpat) | BYOND Resource Cache file |
| SDB | | [`patterns/sdb.hexpat`](patterns/sdb.hexpat) | [Shim DataBase](https://learn.microsoft.com/en-us/windows/win32/devnotes/application-compatibility-database) file format |
| SFO | | [`patterns/sfo.hexpat`](patterns/sfo.hexpat) | PlayStation Param File |
| Shell Link | `application/x-ms-shortcut` | [`patterns/lnk.hexpat`](patterns/lnk.hexpat) | Windows Shell Link file format |
| shp | | [`patterns/shp.hexpat`](patterns/shp.hexpat) | ESRI shape file |
| SHR | | [`patterns/SHR.hexpat`](patterns/SHR.hexpat) | Apple IIgs Super Hi-Res (SHR) + PaintWorks Animation (ANI) |
| shx | | [`patterns/shx.hexpat`](patterns/shx.hexpat) | ESRI index file |
| smk | | [`patterns/smk.hexpat`](patterns/smk.hexpat) | Smacker video file |
| SNES | | [`patterns/snes.hexpat`](patterns/snes.hexpat) | Super Nintendo Entertainment System ROM header |
| sup | | [`patterns/sup.hexpat`](patterns/sup.hexpat) | PGS Subtitle |
| SPC | | [`patterns/spc.hexpat`](patterns/spc.hexpat) | Super Nintendo Entertainment System SPC-700 dump file |
| SPIRV | | [`patterns/spirv.hexpat`](patterns/spirv.hexpat) | SPIR-V header and instructions |
| Spore EAPd Resource | | [`patterns/Spore/spore-pdr.hexpat`](patterns/Spore/spore-pdr.hexpat) | Spore EAPd Resource (Binary Patch) |
| STDF | | [`patterns/stdfv4.hexpat`](patterns/stdfv4.hexpat) | Standard test data format for IC testers |
| STL | `model/stl` | [`patterns/stl.hexpat`](patterns/stl.hexpat) | STL 3D Model format |
| StuffItV5 | `application/x-stuffit` | [`patterns/sit5.hexpat`](patterns/sit5.hexpat) | StuffIt V5 archive |
| SQLite3 | `application/vnd.sqlite3` | [`patterns/sqlite3.hexpat`](patterns/sqlite3.hexpat) | SQLite3 Database |
| SWF | `application/x-shockwave-flash` |[`patterns/swf.hexpat`](patterns/swf.hexpat) | Shockwave Flash file format |
| TA | | [`patterns/optee_ta.hexpat`](patterns/optee_ta.hexpat) | OPTEE Trusted Application Executable |
| TAR | `application/x-tar` | [`patterns/tar.hexpat`](patterns/tar.hexpat) | Tar file format |
| TARC | | [`patterns/tarc.hexpat`](patterns/tarc.hexpat) | KEX Engine TARC file format |
| TES | | [`patterns/wintec_tes.hexpat`](patterns/wintec_tes.hexpat) | Wintec TES GPS log |
| Thumbcache | | [`patterns/thumbcache.hexpat`](patterns/thumbcache.hexpat) | Windows thumbcache_*.db |
| TIFF | `image/tiff` | [`patterns/tiff.hexpat`](patterns/tiff.hexpat) | Tag Image File Format |
| TGA | `image/tga` | [`patterns/tga.hexpat`](patterns/tga.hexpat) | Truevision TGA/TARGA image |
| TMD | | [`patterns/tmd.hexpat`](patterns/tmd.hexpat) | Nintendo TMD |
| TTF | `font/ttf`, `font/otf` | [`patterns/ttf.hexpat`](patterns/ttf.hexpat) | TrueType and OpenType font format |
| Ubiquiti | | [`patterns/ubiquiti.hexpat`](patterns/ubiquiti.hexpat) | Ubiquiti Firmware (update) image |
| UPK | | [`patterns/upk-ue3.hexpat`](patterns/upk-ue3.hexpat) | Unreal Engine 3 UPK file |
| UEFI | | [`patterns/uefi.hexpat`](patterns/uefi.hexpat) | UEFI structs for parsing efivars |
| UEFI Boot Entry | | [`patterns/uefi_boot_entry.hexpat`](patterns/uefi_boot_entry.hexpat) | UEFI Boot Entry (Load option) |
| UEFI Variable Store | | [`patterns/uefi_fv_varstore.hexpat`](patterns/uefi_fv_varstore.hexpat) | UEFI Firmware Volume Variable Store |
| UF2 | | [`patterns/uf2.hexpat`](patterns/uf2.hexpat) | [USB Flashing Format](https://github.com/microsoft/uf2) |
| Unity Asset Bundle | | [`patterns/unity-asset-bundle.hexpat`](patterns/unity-asset-bundle.hexpat) | Unity Asset Bundle |
| Unity Web Data 1.0 | | [`patterns/unity_web_data.hexpat`](patterns/unity_web_data.hexpat) | Unity Web Data 1.0 |
| Valve VPK | | [`patterns/valve_vpk.hexpat`](valve_vpk.hexpat) | Valve Package File |
| VBMeta | | [`patterns/vbmeta.hexpat`](patterns/vbmeta.hexpat) | Android VBMeta image |
| VDF | | [`patterns/vdf.hexpat`](patterns/vdf.hexpat) | Binary Value Data Format (.vdf) files |
| VEADO | | [`patterns/veado.hexpat`](patterns/veado.hexpat) | veadotube mini avatar file |
| VGM | | [`patterns/vgm.hexpat`](patterns/vgm.hexpat) | VGM (Video Game Music) sound log |
| VHD | `application/x-vhd` | [`patterns/vhd.hexpat`](patterns/vhd.hexpat) | [Connectix Virtual Hard Disk format](https://en.wikipedia.org/wiki/VHD_(file_format)) |
| VHDX | | [`patterns/vhdx.hexpat`](patterns/vhdx.hexpat) | Microsoft Hyper-V Virtual Hard Disk format |
| VOX | | [`patterns/vox.hexpat`](patterns/vox.hexpat) | MagicaVoxel scene description format |
| WAV  | `audio/x-wav`  | [`patterns/wav.hexpat`](patterns/wav.hexpat)  | RIFF header, WAVE header, PCM header |
| WAS | | [`patterns/was_oskasoftware.hexpat`](patterns/was_oskasoftware.hexpat) | Oska Software DeskMates WAS/WA3 (WAVE/MP3 Set) file
| WAD | | [`patterns/wad.hexpat`](patterns/wad.hexpat) | DOOM WAD Archive |
| WebP | `image/webp` | [`patterns/webp.hexpat`](patterns/webp.hexpat) | Google WebP image |
| XBEH | `audio/x-xbox-executable` | [`patterns/xbeh.hexpat`](patterns/xbeh.hexpat) | Xbox executable |
| XCI | | [`patterns/xci.hexpat`](patterns/xci.hexpat) | Nintendo Switch XCI cartridge ROM |
| XGT | | [`patterns/xgt.hexpat`](patterns/xgstexture.hexpat) | Exient XGS Engine Texture |
| Xilinx BIT | | [`patterns/xilinx_bit.hexpat`](patterns/xilinx_bit.hexpat) | Xilinx FPGA Bitstreams |
| Xilinx Bootgen | `application/x-xilinx-boot-zynqmp` | [`patterns/xilinx_bootgen.hexpat`](patterns/xilinx_bootgen.hexpat) | Xilinx ZynqMP Boot Images |
| ZIM  | | [`patterns/zim.hexpat`](patterns/zim.hexpat) | [ZIM](https://openzim.org) file format |
| ZIP  | `application/zip` | [`patterns/zip.hexpat`](patterns/zip.hexpat) | End of Central Directory Header, Central Directory File Headers |
| ZLIB | `application/zlib` | [`patterns/zlib.hexpat`](patterns/zlib.hexpat) | ZLIB compressed data format |
| Zone | | [`patterns/zone.hexpat`](patterns/zone.hexpat) | Minecraft Infdev 20100624 Zone file |
| ZSTD | `application/zstd` | [`patterns/zstd.hexpat`](patterns/zstd.hexpat) | Zstandard compressed data format |
| MOD | `3d-model/mod` | [`patterns/DMC3HD-Mod.hexpat`](patterns/dmc3_hd_mod.hexpat) | 3D Model files used in Devil May Cry 3 HD Collection |
| CBM BASIC | | [`commodore_basic.hexpat`](patterns/commodore_basic.hexpat) | Commodore BASIC |
| Atari XEX | | [`xex.hexpat`](patterns/xex.hexpat) | Atari 8-bit binary format |
| Terminfo | `application/x-terminfo` and `application/x-terminfo2` | [`patterns/terminfo.hexpat`](patterns/terminfo.hexpat) | Compiled *(legacy and extended)* term info entry |
| CSNAP | [`csnap.hexpat`](patterns/csnap.hexpat) | ClipboardEdit Clipboard Snapshot format |


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
| Arma 3 | [`magic/arma3_magic`](magic/arma3_magic) | Identifies Arma 3 binary formats |
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

Most `.tbl` files below are generated by
[`scripts/generate_encodings.py`](scripts/generate_encodings.py) from
Python's stdlib `codecs`. Run it to regenerate them, or with `--check` to
verify without writing.

Generated files start with a `# Generated by ...` comment. A `.tbl` file
without that comment is left alone, so you can add a hand-authored encoding
anywhere under `encodings/` without touching the script.

Every name listed below becomes `encodings/<name>.tbl`, lowercased and
otherwise unchanged, so `#pragma encoding <name>` works for anything in the
Aliases column below. Spellings that differ only in their separators, like
`iso8859-1` and `iso_8859_1`, are separate files rather than one file under
some canonical spelling. Encodings with identical entries share them via an
`-include` line instead of repeating them (every ASCII-transparent encoding
includes `ascii`, for example), and the files for alternate names hold a
single `-alias` line.

#### Generated file encodings

Codepages: one byte per character. Usable as: file, string, or custom encoding.

<!-- generate_encodings.py: start of File encodings table -->
| Name | Path | Description | Entries | Aliases |
|------|------|-------------|---------|---------|
| ASCII | [`encodings/ascii.tbl`](encodings/ascii.tbl) | Basic 7-bit encoding for English text | 128 | `ansi_x3.4_1968`, `ansi_x3.4_1986`, `ansi_x3_4_1968`, `cp367`, `ibm367`, `iso646_us`, `iso_646.irv_1991`, `iso_ir_6`, `us`, `us_ascii` |
| IBM 037 | [`encodings/cp037.tbl`](encodings/cp037.tbl) | Extended Binary Coded Decimal Interchange Code | 256 | `ebcdic_cp_ca`, `ebcdic_cp_nl`, `ebcdic_cp_us`, `ebcdic_cp_wt`, `ibm037`, `ibm039` |
| IBM 437 | [`encodings/cp437.tbl`](encodings/cp437.tbl) | Original IBM PC encoding, with box-drawing and symbol characters | 256 | `ibm437` |
| IBM 775 | [`encodings/cp775.tbl`](encodings/cp775.tbl) | DOS encoding for Baltic languages (Estonian, Latvian, Lithuanian) | 256 | `ibm775` |
| IBM 850 | [`encodings/cp850.tbl`](encodings/cp850.tbl) | DOS encoding for Western European languages (English, French, German, and others) | 256 | `ibm850` |
| IBM 852 | [`encodings/cp852.tbl`](encodings/cp852.tbl) | DOS encoding for Central European languages (Polish, Czech, Hungarian, and others) | 256 | `ibm852` |
| IBM 855 | [`encodings/cp855.tbl`](encodings/cp855.tbl) | DOS encoding for Cyrillic languages (Russian, Bulgarian, Serbian, and others) | 256 | `ibm855` |
| IBM 857 | [`encodings/cp857.tbl`](encodings/cp857.tbl) | DOS encoding for the Turkish language | 253 | `ibm857` |
| IBM 860 | [`encodings/cp860.tbl`](encodings/cp860.tbl) | DOS encoding for the Portuguese language | 256 | `ibm860` |
| IBM 861 | [`encodings/cp861.tbl`](encodings/cp861.tbl) | DOS encoding for the Icelandic language | 256 | `cp_is`, `ibm861` |
| IBM 862 | [`encodings/cp862.tbl`](encodings/cp862.tbl) | DOS encoding for the Hebrew language | 256 | `ibm862` |
| IBM 863 | [`encodings/cp863.tbl`](encodings/cp863.tbl) | DOS encoding for the Canadian French language | 256 | `ibm863` |
| IBM 864 | [`encodings/cp864.tbl`](encodings/cp864.tbl) | DOS encoding for the Arabic language | 250 | `ibm864` |
| IBM 865 | [`encodings/cp865.tbl`](encodings/cp865.tbl) | DOS encoding for Nordic languages (Danish, Norwegian, and others) | 256 | `ibm865` |
| IBM 866 | [`encodings/cp866.tbl`](encodings/cp866.tbl) | DOS encoding for Cyrillic languages (Russian and others) | 256 | `ibm866` |
| IBM 869 | [`encodings/cp869.tbl`](encodings/cp869.tbl) | DOS encoding for the Greek language | 247 | `cp_gr`, `ibm869` |
| ISO 8859-1 | [`encodings/iso8859-1.tbl`](encodings/iso8859-1.tbl) | ISO encoding for Western European languages (English, French, German, and others) | 256 | `cp819`, `ibm819`, `iso8859`, `iso8859_1`, `iso_8859_1`, `iso_8859_1_1987`, `iso_ir_100`, `latin`, `latin1`, `latin_1` |
| ISO 8859-2 | [`encodings/iso8859-2.tbl`](encodings/iso8859-2.tbl) | ISO encoding for Central European languages (Polish, Czech, Hungarian, and others) | 256 | `iso8859_2`, `iso_8859_2`, `iso_8859_2_1987`, `iso_ir_101`, `latin2` |
| ISO 8859-3 | [`encodings/iso8859-3.tbl`](encodings/iso8859-3.tbl) | ISO encoding for South European languages (Turkish, Maltese, Esperanto) | 249 | `iso8859_3`, `iso_8859_3`, `iso_8859_3_1988`, `iso_ir_109`, `latin3` |
| ISO 8859-4 | [`encodings/iso8859-4.tbl`](encodings/iso8859-4.tbl) | ISO encoding for North European languages (Estonian, Latvian, Lithuanian, Greenlandic, Sami) | 256 | `iso8859_4`, `iso_8859_4`, `iso_8859_4_1988`, `iso_ir_110`, `latin4` |
| ISO 8859-5 | [`encodings/iso8859-5.tbl`](encodings/iso8859-5.tbl) | ISO encoding for Cyrillic languages (Russian, Bulgarian, Serbian, and others) | 256 | `cyrillic`, `iso8859_5`, `iso_8859_5`, `iso_8859_5_1988`, `iso_ir_144` |
| ISO 8859-6 | [`encodings/iso8859-6.tbl`](encodings/iso8859-6.tbl) | ISO encoding for the Arabic language | 211 | `arabic`, `asmo_708`, `ecma_114`, `iso8859_6`, `iso_8859_6`, `iso_8859_6_1987`, `iso_ir_127` |
| ISO 8859-7 | [`encodings/iso8859-7.tbl`](encodings/iso8859-7.tbl) | ISO encoding for the Greek language | 253 | `ecma_118`, `elot_928`, `greek`, `greek8`, `iso8859_7`, `iso_8859_7`, `iso_8859_7_1987`, `iso_ir_126` |
| ISO 8859-8 | [`encodings/iso8859-8.tbl`](encodings/iso8859-8.tbl) | ISO encoding for the Hebrew language | 220 | `hebrew`, `iso8859_8`, `iso_8859_8`, `iso_8859_8_1988`, `iso_ir_138` |
| ISO 8859-9 | [`encodings/iso8859-9.tbl`](encodings/iso8859-9.tbl) | ISO encoding for the Turkish language | 256 | `iso8859_9`, `iso_8859_9`, `iso_8859_9_1989`, `iso_ir_148`, `latin5` |
| ISO 8859-10 | [`encodings/iso8859-10.tbl`](encodings/iso8859-10.tbl) | ISO encoding for Nordic languages (Icelandic, Sami, and others) | 256 | `iso8859_10`, `iso_8859_10`, `iso_8859_10_1992`, `iso_ir_157`, `latin6` |
| ISO 8859-11 | [`encodings/iso8859-11.tbl`](encodings/iso8859-11.tbl) | ISO encoding for the Thai language | 248 | `iso8859_11`, `iso_8859_11`, `iso_8859_11_2001`, `thai` |
| ISO 8859-13 | [`encodings/iso8859-13.tbl`](encodings/iso8859-13.tbl) | ISO encoding for Baltic languages (Estonian, Latvian, Lithuanian) | 256 | `iso8859_13`, `iso_8859_13`, `latin7` |
| ISO 8859-14 | [`encodings/iso8859-14.tbl`](encodings/iso8859-14.tbl) | ISO encoding for Celtic languages (Irish Gaelic, Scottish Gaelic, Welsh, Breton) | 256 | `iso8859_14`, `iso_8859_14`, `iso_8859_14_1998`, `iso_celtic`, `iso_ir_199`, `latin8` |
| ISO 8859-15 | [`encodings/iso8859-15.tbl`](encodings/iso8859-15.tbl) | ISO encoding for Western European languages, a revision of ISO-8859-1 adding the Euro sign | 256 | `iso8859_15`, `iso_8859_15`, `latin9` |
| ISO 8859-16 | [`encodings/iso8859-16.tbl`](encodings/iso8859-16.tbl) | ISO encoding for South-Eastern European languages (Romanian, and others), includes the Euro sign | 256 | `iso8859_16`, `iso_8859_16`, `iso_8859_16_2001`, `iso_ir_226`, `latin10` |
| JIS X 0201 | [`encodings/jis_x0201.tbl`](encodings/jis_x0201.tbl) | JIS X 0201 encoding (half-width katakana and Roman set) | 191 | `x0201` |
| KOI8-R | [`encodings/koi8-r.tbl`](encodings/koi8-r.tbl) | Cyrillic KOI8-R encoding (Russian characters) | 256 | `koi8_r` |
| KOI8-U | [`encodings/koi8-u.tbl`](encodings/koi8-u.tbl) | Cyrillic KOI8-U encoding (Ukrainian characters) | 256 | `koi8_u` |
| Mac OS Arabic | [`encodings/mac-arabic.tbl`](encodings/mac-arabic.tbl) | Classic Mac OS encoding for the Arabic language | 256 | `mac_arabic` |
| Mac OS Central European | [`encodings/mac-latin2.tbl`](encodings/mac-latin2.tbl) | Classic Mac OS encoding for Central European languages (Czech, Slovak, Hungarian, Polish, and others) | 256 | `mac_centeuro`, `mac_latin2`, `maccentraleurope`, `maclatin2` |
| Mac OS Croatian | [`encodings/mac-croatian.tbl`](encodings/mac-croatian.tbl) | Classic Mac OS encoding for the Croatian language | 256 | `mac_croatian` |
| Mac OS Cyrillic | [`encodings/mac-cyrillic.tbl`](encodings/mac-cyrillic.tbl) | Classic Mac OS encoding for Cyrillic languages (Russian, Bulgarian, Serbian, and others) | 256 | `mac_cyrillic`, `maccyrillic` |
| Mac OS Farsi | [`encodings/mac-farsi.tbl`](encodings/mac-farsi.tbl) | Classic Mac OS encoding for the Persian (Farsi) language | 256 | `mac_farsi` |
| Mac OS Greek | [`encodings/mac-greek.tbl`](encodings/mac-greek.tbl) | Classic Mac OS encoding for the Greek language | 256 | `mac_greek`, `macgreek` |
| Mac OS Icelandic | [`encodings/mac-iceland.tbl`](encodings/mac-iceland.tbl) | Classic Mac OS encoding for the Icelandic language | 256 | `mac_iceland`, `maciceland` |
| Mac OS Roman | [`encodings/mac-roman.tbl`](encodings/mac-roman.tbl) | Classic Mac OS encoding for Western European languages | 256 | `mac_roman`, `macintosh`, `macroman` |
| Mac OS Romanian | [`encodings/mac-romanian.tbl`](encodings/mac-romanian.tbl) | Classic Mac OS encoding for the Romanian language | 256 | `mac_romanian` |
| Mac OS Turkish | [`encodings/mac-turkish.tbl`](encodings/mac-turkish.tbl) | Classic Mac OS encoding for the Turkish language | 256 | `mac_turkish`, `macturkish` |
| TIS-620 | [`encodings/tis-620.tbl`](encodings/tis-620.tbl) | Thai national standard character encoding | 247 | `iso_ir_166`, `tis620`, `tis_620`, `tis_620_0`, `tis_620_2529_0`, `tis_620_2529_1` |
| Windows 874 | [`encodings/cp874.tbl`](encodings/cp874.tbl) | Windows encoding for the Thai language | 225 | (none) |
| Windows 1250 | [`encodings/cp1250.tbl`](encodings/cp1250.tbl) | Windows encoding for Central European languages (Polish, Czech, Hungarian, and others) | 251 | `windows_1250` |
| Windows 1251 | [`encodings/cp1251.tbl`](encodings/cp1251.tbl) | Windows encoding for Cyrillic languages (Russian, Bulgarian, Serbian, and others) | 255 | `windows_1251` |
| Windows 1252 | [`encodings/cp1252.tbl`](encodings/cp1252.tbl) | Windows encoding for Western European languages (English, French, German, and others) | 251 | `windows_1252` |
| Windows 1253 | [`encodings/cp1253.tbl`](encodings/cp1253.tbl) | Windows encoding for the Greek language | 239 | `windows_1253` |
| Windows 1254 | [`encodings/cp1254.tbl`](encodings/cp1254.tbl) | Windows encoding for the Turkish language | 249 | `windows_1254` |
| Windows 1255 | [`encodings/cp1255.tbl`](encodings/cp1255.tbl) | Windows encoding for the Hebrew language | 233 | `windows_1255` |
| Windows 1256 | [`encodings/cp1256.tbl`](encodings/cp1256.tbl) | Windows encoding for the Arabic language | 256 | `windows_1256` |
| Windows 1257 | [`encodings/cp1257.tbl`](encodings/cp1257.tbl) | Windows encoding for Baltic languages (Estonian, Latvian, Lithuanian) | 244 | `windows_1257` |
| Windows 1258 | [`encodings/cp1258.tbl`](encodings/cp1258.tbl) | Windows encoding for the Vietnamese language | 247 | `windows_1258` |
<!-- generate_encodings.py: end of File encodings table -->

#### Generated string encodings

Generated from Python's stdlib `codecs`, but not codepages. Usable as: string or custom encoding.

<!-- generate_encodings.py: start of Generated encodings table -->
| Name | Path | Description | Entries | Aliases |
|------|------|-------------|---------|---------|
| Big5 | [`encodings/big5.tbl`](encodings/big5.tbl) | Encoding for Traditional Chinese text | 13838 | `big5_tw`, `x_mac_trad_chinese` |
| Big5-HKSCS | [`encodings/big5hkscs.tbl`](encodings/big5hkscs.tbl) | Extended Big5 encoding with the Hong Kong Supplementary Character Set | 18530 | `big5_hkscs`, `hkscs` |
| EUC-JP | [`encodings/euc_jp.tbl`](encodings/euc_jp.tbl) | Extended Unix Code encoding for the Japanese language | 13137 | `eucjp`, `u_jis`, `ujis` |
| EUC-KR | [`encodings/euc_kr.tbl`](encodings/euc_kr.tbl) | Extended Unix Code encoding for the Korean language | 8353 | `euckr`, `korean`, `ks_c_5601`, `ks_c_5601_1987`, `ks_x_1001`, `ksc5601`, `ksx1001`, `x_mac_korean` |
| GB2312 | [`encodings/gb2312.tbl`](encodings/gb2312.tbl) | Older encoding for Simplified Chinese text | 7573 | `chinese`, `euc_cn`, `euccn`, `eucgb2312_cn`, `gb2312_1980`, `gb2312_80`, `iso_ir_58`, `x_mac_simp_chinese` |
| GB18030 | [`encodings/gb18030.tbl`](encodings/gb18030.tbl) | Encoding for Simplified Chinese text, the mandatory national standard and a superset of GBK | 24068 | `gb18030_2000` |
| GBK | [`encodings/gbk.tbl`](encodings/gbk.tbl) | Encoding for Simplified Chinese text | 21919 | `cp936`, `ms936`, `windows-936` |
| Shift_JIS | [`encodings/shift_jis.tbl`](encodings/shift_jis.tbl) | Encoding for Japanese text | 7070 | `s_jis`, `shiftjis`, `sjis`, `x_mac_japanese` |
| Windows 31J | [`encodings/cp932.tbl`](encodings/cp932.tbl) | Shift-JIS with Microsoft/NEC/IBM extensions (aka MS932/CP932) | 9800 | `ms932`, `ms_kanji`, `mskanji` |
<!-- generate_encodings.py: end of Generated encodings table -->

#### Custom encodings

No codec covers these, so `generate_encodings.py` never touches them.
Usable as: string or custom encoding.

<!-- generate_encodings.py: start of Custom encodings table -->
| Name | Path | Description | Entries | Aliases |
|------|------|-------------|---------|---------|
| Pokémon (English, Generation 1) | [`encodings/pokegen1_en.tbl`](encodings/pokegen1_en.tbl) | Character encoding used by the English generation 1 Pokémon games | 143 | (none) |
| Pokémon (English, Generation 3) | [`encodings/pokegen3_en.tbl`](encodings/pokegen3_en.tbl) | Character encoding used by the English generation 3 Pokémon games | 144 | (none) |
<!-- generate_encodings.py: end of Custom encodings table -->

#### Algorithmic encodings

Built into ImHex, with no `.tbl` file here. Usable as: string encoding.
The `UTF-*` family is an example; see the ImHex documentation for the full list.

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
| Theme Lion | [`themes/theme_lion.json`](themes/theme_lion.json) | Semantic CLion inspired theme (Dark Theme) |
| Retina Dark | [`themes/retina_dark.json`](themes/retina_dark.json) | Semantic theme based on Dark Theme |
| OLED | [`themes/oled.json`](themes/oled.json) | OLED theme based on Dark Theme |

### Disassemblers

| Name | Path | Description |
|------|------|-------------|
| 8051 | [`disassemblers/8051.json`](disassemblers/8051.json) | Intel 8051 Architecture |
| CHIP-8 | [`disassemblers/chip-8.json`](disassemblers/chip-8.json) | CHIP-8 virtual machine |
| Z80 | [`disassemblers/z80.json`](disassemblers/z80.json) | Zelog Z80 Architecture |
