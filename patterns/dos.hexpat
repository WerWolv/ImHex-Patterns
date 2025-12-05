#pragma author Stephen Hewitt
#pragma description MSDOS executable file

#pragma MIME application/x-dosexec
#pragma MIME application/x-msdownload
#pragma MIME application/x-dosexecapplication/zip
#pragma MIME application/vnd.microsoft.portable-executable

import type.magic;
import std.io;
import std.mem;
import std.math;
import std.string;

/*
 * A DOS EXE file, at a high level, consists of three regions:
 *
 * Header
 *  As it's name suggests. Contains info the loader uses.
 *
 * Load module
 *  Contains the program data that is loaded into memory.
 *
 * Extra data
 *  Data appended to the file that isn't loaded into memory.
 *
 * We'll call the combined header and load module the
 * "program image". It's what the DOS loader cares about.
 */

 /*
 * Wikipedia: The New Executable (NE or NewEXE) is a 16-bit executable
 * file format, a successor to the DOS MZ executable format. It was used
 * in Windows 1.0–3.x, Windows 9x, multitasking MS-DOS 4.0,[1] OS/2 1.x,
 * and the OS/2 subset of Windows NT up to version 5.0 (Windows 2000).
 *
 * Since it was used in DOS we'll support it.
 *
 * We'll make it optional since some programs increased
 * 'headerSizeInParagraphs' and stashed all kind of stuff there.
 */
bool EnableNEHeaderExt in;

/*
 * DOS file offsets/sizes. DOS uses INT 21h for file I/O. File positions and
 * lengths are tracked using 32-bit signed integers. DOS INT 21h functions
 * treat the offset as signed, so the highest positive offset is 0x7FFFFFFF.
 * Attempting to seek beyond that or read/write beyond that will fail.
 * We'll use a u32.
 */
u32 g_loadModule;
u32 g_loadModuleSize;
u32 g_programImageSize;

fn formatNumber(u32 num, str msg="") {
    if (std::string::length(msg)==0)
        return std::format("0x{:x} ({})", num, num);
    else
        return std::format("{} 0x{:x} ({})", msg, num, num);
};

fn inLoadModule(u32 off, u32 sz) {
    return off>=g_loadModule && off+sz<=g_loadModule+g_loadModuleSize;
};

struct Relocation {
    u16 offset [[color("9AE630")]];
    u16 segment [[color("FE9A37")]];
};

struct RelocationAnnotated : Relocation {
    u32 fileOffset = g_loadModule+offset+segment*16;
    if (inLoadModule(fileOffset, 2)) {
        u16 __goto__target @ fileOffset [[highlight_hidden]];
     }
     else {
        str __goto__target = formatNumber(fileOffset, "Not in load module") [[export, highlight_hidden]];
     }
};

struct Relocations {
    if (parent.dosHeader.relocations>0) {
        Relocation __goto__firstReloc @ $ [[highlight_hidden]];
        Relocation __goto__lastReloc  @ $+(parent.dosHeader.relocations-1)*sizeof(Relocation) [[highlight_hidden]];
    }
    RelocationAnnotated data[parent.dosHeader.relocations] [[inline]];
};

struct DOSHeader {
    type::Magic<"MZ"> signature [[hex::spec_name("e_magic")]];
    u16 extraPageSize [[hex::spec_name("e_cblp")]];
    u16 numberOfPages [[hex::spec_name("e_cp")]];
    g_programImageSize =  (extraPageSize==0) ?
        (numberOfPages*512) :
        (numberOfPages-1)*512 + extraPageSize;
    str __programImageSize = formatNumber(g_programImageSize) [[export, highlight_hidden]];
    u8 __goto__lastByteInProgramImage @ g_programImageSize-1 [[highlight_hidden]];
    u16 relocations [[name("stubRelocations"), hex::spec_name("e_crlc")]];
    u16 headerSizeInParagraphs [[hex::spec_name("e_cparhdr")]];
    u32 headerSize = headerSizeInParagraphs*16;
    g_loadModule = headerSizeInParagraphs*16;
    g_loadModuleSize = g_programImageSize - headerSize;
    str __headerSize = formatNumber(headerSize) [[export, highlight_hidden]];
    u8 __goto__lastByteInHeader @ headerSize-1 [[highlight_hidden]];
    u16 minimumAllocatedParagraphs [[hex::spec_name("e_minalloc")]];
    u16 maximumAllocatedParagraphs [[hex::spec_name("e_maxalloc")]];
    u16 initialSSValue [[hex::spec_name("e_ss")]];
    u16 initialRelativeSPValue [[hex::spec_name("e_sp")]];
    u16 checksum [[name("stubChecksum"), hex::spec_name("e_csum")]];
    u16 initialRelativeIPValue [[hex::spec_name("e_ip")]];
    u16 initialCSValue [[hex::spec_name("e_cs")]];

    u32 csAddrFirst = initialCSValue<<4;
    u32 csAddrLast = (csAddrFirst+0xffff) & ((1<<20)-1);

    u32 csEndGap = 0;
    if (csAddrFirst <= csAddrLast) {
        u32 csOffsetFirst = headerSize+csAddrFirst;
        u32 csOffsetLast  = csOffsetFirst+std::math::min(0x10000, g_loadModuleSize)-1;
    }
    else {
        u32 csOffsetFirst = headerSize;
        csEndGap = (1<<20)-csAddrFirst;
        u32 csOffsetLast  = headerSize+(0x10000-csEndGap-1);

        std::warning("EXE has 'initialCSValue' set such that 20-bit address wraps.");
        std::warning(" My guess would be to get the PSP into the CS.");
    }


    /*
     * Adding `csEndGap` to the `initialIP` calculation below is required because the
     * program is started by transferring execution to CS:IP. If `csEndGap` is non-zero
     * CS and the start of the load-module value do not align; there’s some extra data
     * the CPU can see before the data in the EXE. What confused me for a bit was why
     * it’s not required in the relocation target locations I make. The reason, I think,
     * is that when the loader loads the load-module into memory and then proceeds to
     * apply the relocations, the offsets are relative to the segment the code is loaded
     * in and not the execution environment (the CS register from `initialCSValue`).
     */
    u32 initialIP = csOffsetFirst+initialRelativeIPValue-csEndGap;

    if (inLoadModule(initialIP, 1))
        u8 __goto__initiaIP @ initialIP [[highlight_hidden]];
    else
        str __goto__initiaIP = formatNumber(initialIP, "Not in load module!") [[export, highlight_hidden]];

    u32 csSize = csOffsetLast-csOffsetFirst+1;
    if (inLoadModule(csOffsetFirst, csSize)) {
        std::mem::Bytes<csSize> __select__InitialCS @ csOffsetFirst [[highlight_hidden]];
        u8 __goto__InitialCS_first @ csOffsetFirst [[highlight_hidden]];
        u8 __goto__InitialCS_last  @ csOffsetFirst+csSize-1 [[highlight_hidden]];
    }
    else {
        str __select__CS = formatNumber(csOffsetFirst, "Not in image!") [[export, highlight_hidden]];
    }

    u16 relocationsTablePointer [[hex::spec_name("e_lfarlc")]];
    u32 sizeofRelocations = relocations*sizeof(Relocation);
    if (relocations>0 && relocationsTablePointer+sizeofRelocations<g_programImageSize) {
        std::mem::Bytes<sizeofRelocations> __select__relocationsTable
            @ relocationsTablePointer [[highlight_hidden]];
    }
     else {
        str __select__relocationsTable =
            "Not in image or zero length" [[export, highlight_hidden]];
     }
    u16 overlayNumber [[hex::spec_name("e_ovno")]];
};

struct NEDOSHeaderExt {
    u16 reservedWords[4] [[hex::spec_name("e_res")]];
    u16 oemIdentifier [[hex::spec_name("e_oemid")]];
    u16 oemInformation [[hex::spec_name("e_oeminfo")]];
    u16 otherReservedWords[10] [[hex::spec_name("e_res2")]];
    u32 newHeaderPointer [[hex::spec_name("e_lfanew")]];
};

struct NEDOSHeaderExtAnnotated : NEDOSHeaderExt {
    if (newHeaderPointer < std::mem::size())
        u8 __goto__newHeader @ newHeaderPointer [[highlight_hidden]];
    else
        str __goto__newHeader
            = formatNumber(newHeaderPointer, "Not in image!") [[export, highlight_hidden]];
};

/*
 * The header of a DOS EXE file consists of three regions.
 *
 * DOSHeader
 *  Present in all DOS EXEs. Used by the loader.
 *
 * NEDOSHeaderExt
 *  An extension to the header. Optional.
 *
 * Relocations
 *  An array of segment relocations to the apply to the load module. Optional.
 *
 * The header is followed by the load module. There can be gaps between
 * DOSHeader (or NEDOSHeaderExt if present) and Relocations, and between the
 * Relocations and the load module. It is not uncommon for EXEs to stash candy
 * in these gaps.
 */

struct Header {
    DOSHeader dosHeader;

    if (EnableNEHeaderExt) {
        if (dosHeader.relocationsTablePointer < $+sizeof(NEDOSHeaderExt)) {
            std::warning("NEHeaderExt and Relocations overlap. Disabling NEHeaderExt.");
        }
        else {
            NEDOSHeaderExtAnnotated extHeader;
        }
    }

    if (dosHeader.relocations > 0) {
        if (dosHeader.relocationsTablePointer < $) {
            std::warning("Relocation table overlaps previous header members");
        }
        if (dosHeader.relocationsTablePointer+dosHeader.relocations*sizeof(Relocation) > g_loadModule) {
            std::warning("Relocation table ends past header.");
        }
    }

    if (dosHeader.relocationsTablePointer > $) {
        u8 header_reloc_gap[dosHeader.relocationsTablePointer-$] [[highlight_hidden]];
    }
    Relocations relocations;
    if (g_loadModule > $) {
        u8 reloc_loadModule_gap[g_loadModule-$] [[highlight_hidden]];
    }
};

struct LoadModule {
    u8 __goto__first @ $ [[highlight_hidden]];
    u8 __goto__last  @ $+g_loadModuleSize-1 [[highlight_hidden]];
    u8 data[g_loadModuleSize];
} [[color("7393B3")]];

Header header @0;
LoadModule loadModule @g_loadModule;;