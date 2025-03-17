#pragma once

import hex.impl.imhex_check;

/*!
    Types to work with machine code
*/

namespace auto hex::type {

    /**
        A machine code instruction which will get disassembled
        @tparam DisassemblerSetting A string containing the config for the disassembler in the form of "architecture; setting1, setting2, no-setting3"
        @tparam SyntaxType Syntax used in the disassembly. Possible values are "intel", "at&t", "masm" and "motorola"
        @tparam ImageBaseAddress Start address of the instruction region in the data
        @tparam ImageLoadAddress Address where the instructions will be loaded into memory

        Possible Values for DisassemblerSetting:
        - Architecture, all may be suffixed with le or be to specify endianess (e.g armbe or mipsle)
            - arm
            - thumb
            - aarch64
            - arm64
            - mips
            - x86
            - x86_64
            - x64
            - ppc
            - powerpc
            - sparc
            - sysz
            - xcore
            - m68k
            - m680x
            - tms320c64x
            - evm
            - wasm
            - riscv
            - mos65xx
            - bpf
            - sh
            - tricore

        - Settings, not all settings make sense for each architecture. Prefixing settings with no- will remove them instead
            - 16bit
            - 32bit
            - 64bit
            - cortex-m
            - armv8
            - micromips
            - mips2
            - mips3
            - mips32r6
            - sparcv9
            - qpx
            - spe
            - ps
            - 68000
            - 68010
            - 68020
            - 68030
            - 68040
            - 68060
            - 6301
            - 6309
            - 6800
            - 6801
            - 6805
            - 6808
            - 6809
            - 6811
            - cpu12
            - hcs08
            - bpfe
            - rv32g
            - rv64g
            - riscvc
            - 6502
            - 65c02
            - w65c02
            - 65816
            - long-m
            - long-x
            - sh2
            - sh2a
            - sh3
            - sh4
            - sh4a
            - shfpu
            - shdsp
            - 1.1
            - 1.2
            - 1.3
            - 1.3.1
            - 1.6
            - 1.6.1
            - 1.6.2
    */
    struct Instruction<auto DisassemblerSetting, auto SyntaxType, auto ImageBaseAddress, auto ImageLoadAddress> {
        builtin::hex::dec::Instruction<DisassemblerSetting, SyntaxType, ImageBaseAddress, ImageLoadAddress> instruction;
    } [[sealed, format("hex::type::impl::format_instruction")]];

    /**
        A machine code instruction which will get disassembled using Intel syntax
        @tparam DisassemblerSetting A string containing the config for the disassembler in the form of "architecture; setting1, setting2, no-setting3"
        @tparam ImageBaseAddress Start address of the instruction region in the data
        @tparam ImageLoadAddress Address where the instructions will be loaded into memory
    */
    using InstructionIntel<auto DisassemblerSetting, auto ImageBaseAddress, auto ImageLoadAddress> = Instruction<DisassemblerSetting, "intel", ImageBaseAddress, ImageLoadAddress>;
    
    /**
        A machine code instruction which will get disassembled using AT&T syntax
        @tparam DisassemblerSetting A string containing the config for the disassembler in the form of "architecture; setting1, setting2, no-setting3"
        @tparam ImageBaseAddress Start address of the instruction region in the data
        @tparam ImageLoadAddress Address where the instructions will be loaded into memory
    */
    using InstructionATNT<auto DisassemblerSetting, auto ImageBaseAddress, auto ImageLoadAddress> = Instruction<DisassemblerSetting, "at&t", ImageBaseAddress, ImageLoadAddress>;
    
    /**
        A machine code instruction which will get disassembled using MASM syntax
        @tparam DisassemblerSetting A string containing the config for the disassembler in the form of "architecture; setting1, setting2, no-setting3"
        @tparam ImageBaseAddress Start address of the instruction region in the data
        @tparam ImageLoadAddress Address where the instructions will be loaded into memory
    */    
    using InstructionMASM<auto DisassemblerSetting, auto ImageBaseAddress, auto ImageLoadAddress> = Instruction<DisassemblerSetting, "masm", ImageBaseAddress, ImageLoadAddress>;
    
    /**
        A machine code instruction which will get disassembled using Motorola syntax
        @tparam DisassemblerSetting A string containing the config for the disassembler in the form of "architecture; setting1, setting2, no-setting3"
        @tparam ImageBaseAddress Start address of the instruction region in the data
        @tparam ImageLoadAddress Address where the instructions will be loaded into memory
    */
    using InstructionMotorola<auto DisassemblerSetting, auto ImageBaseAddress, auto ImageLoadAddress> = Instruction<DisassemblerSetting, "motorola", ImageBaseAddress, ImageLoadAddress>;

    namespace impl {

        fn format_instruction(ref auto instruction) {
            return instruction.instruction;
        };
    }

}

