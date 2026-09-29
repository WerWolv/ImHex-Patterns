#pragma description Bitcoin raw transaction (legacy + SegWit + Taproot, BIP141/144/341/342)
#pragma author imHexTxTemplate
#pragma MIME application/x-bitcoin-transaction
#pragma endian little
// Note: a raw transaction has no file signature, so there is no magic/ entry and
// ImHex cannot auto-detect it — load this pattern manually.

// Ordinal / inscription reveals can carry multi-MB payloads in a single witness
// item. Items up to 8 KB are expanded byte-by-byte; larger ones show a 256-byte
// preview + padding (bytes stay fully visible in the hex view) so ImHex never
// has to materialise millions of patterns.
#pragma array_limit    0x20000
#pragma pattern_limit  0x200000

import std.core;
import std.io;
import std.mem;
import std.string;

/*  ────────────────────────────────────────────────────────────────────────────
    BITCOIN TRANSACTION — wire serialization

    Point this pattern at a raw transaction dump: the bytes behind
    `bitcoin-cli getrawtransaction <txid>` / `decoderawtransaction`, or the
    `xxd -r -p` of a hex string. It parses BOTH encodings:

      legacy (pre-SegWit)                SegWit / witness (BIP144)
      ------------------                 -------------------------
      version    : s32  LE               version    : s32  LE
                                         marker     : u8   == 0x00
                                         flag       : u8   != 0x00   (0x01 today)
      in count   : VarInt                in count   : VarInt
      inputs     : TxInput[in count]     inputs     : TxInput[in count]
      out count  : VarInt                out count  : VarInt
      outputs    : TxOutput[out count]   outputs    : TxOutput[out count]
                                         witnesses  : TxInWitness[in count]
      lockTime   : u32  LE               lockTime   : u32  LE

    SegWit is detected the way BIP144 parsers do it: the byte right after
    `version` is 0x00 (a real legacy tx can never have 0 inputs, so its
    input-count VarInt is never 0x00) followed by a non-zero flag.

    All integers are little-endian. Transaction / previous-output hashes are
    stored little-endian and shown reversed here — that reversed form is the
    txid you see in block explorers.

    References: legacy tx format; BIP141 / BIP144 (SegWit, marker/flag,
    witness), BIP143 (v0 sighash), BIP68 / BIP112 (relative timelock, CSV),
    BIP125 (opt-in RBF), BIP113 (locktime = median-time-past),
    BIP340 / BIP341 / BIP342 (Schnorr / Taproot / Tapscript).
    ──────────────────────────────────────────────────────────────────────────── */


// ── low-level helpers ──────────────────────────────────────────────────────

fn byte_at(u128 base, u128 i) {
    return std::mem::read_unsigned(base + i, 1);
};

// CompactSize / "VarInt": 1, 3, 5 or 9 bytes on the wire.
fn varint_size(u128 off) {
    u8 p = std::mem::read_unsigned(off, 1);
    if (p < 0xFD)  return 1;
    if (p == 0xFD) return 3;
    if (p == 0xFE) return 5;
    return 9;
};

// Decode a CompactSize straight from memory (explicit little-endian).
fn varint_value(u128 off) {
    u8 p = std::mem::read_unsigned(off, 1);
    if (p < 0xFD)
        return u64(p);

    u8 n = 2;
    if (p == 0xFE) n = 4;
    if (p == 0xFF) n = 8;

    u64 v = 0;
    for (u8 i = 0, i < n, i = i + 1)
        v = v | (u64(std::mem::read_unsigned(off + 1 + i, 1)) << (8 * i));
    return v;
};

// Value of an already-parsed VarInt pattern.
fn vi(ref auto v) {
    if (v.prefix < 0xFD)
        return u64(v.prefix);
    return u64(v.ext);
};


// ── Script opcode names ───────────────────────────────────────────────────

fn opcode_name(u8 op) {
    if (op == 0x00) return "OP_0";
    if (op >= 0x01 && op <= 0x4b) return std::format("OP_PUSHBYTES_{}", op);
    if (op == 0x4c) return "OP_PUSHDATA1";
    if (op == 0x4d) return "OP_PUSHDATA2";
    if (op == 0x4e) return "OP_PUSHDATA4";
    if (op == 0x4f) return "OP_1NEGATE";
    if (op == 0x50) return "OP_RESERVED";
    if (op >= 0x51 && op <= 0x60) return std::format("OP_{}", op - 0x50);   // OP_1 .. OP_16

    if (op == 0x61) return "OP_NOP";
    if (op == 0x62) return "OP_VER";
    if (op == 0x63) return "OP_IF";
    if (op == 0x64) return "OP_NOTIF";
    if (op == 0x65) return "OP_VERIF";
    if (op == 0x66) return "OP_VERNOTIF";
    if (op == 0x67) return "OP_ELSE";
    if (op == 0x68) return "OP_ENDIF";
    if (op == 0x69) return "OP_VERIFY";
    if (op == 0x6a) return "OP_RETURN";
    if (op == 0x6b) return "OP_TOALTSTACK";
    if (op == 0x6c) return "OP_FROMALTSTACK";
    if (op == 0x6d) return "OP_2DROP";
    if (op == 0x6e) return "OP_2DUP";
    if (op == 0x6f) return "OP_3DUP";
    if (op == 0x70) return "OP_2OVER";
    if (op == 0x71) return "OP_2ROT";
    if (op == 0x72) return "OP_2SWAP";
    if (op == 0x73) return "OP_IFDUP";
    if (op == 0x74) return "OP_DEPTH";
    if (op == 0x75) return "OP_DROP";
    if (op == 0x76) return "OP_DUP";
    if (op == 0x77) return "OP_NIP";
    if (op == 0x78) return "OP_OVER";
    if (op == 0x79) return "OP_PICK";
    if (op == 0x7a) return "OP_ROLL";
    if (op == 0x7b) return "OP_ROT";
    if (op == 0x7c) return "OP_SWAP";
    if (op == 0x7d) return "OP_TUCK";
    if (op == 0x7e) return "OP_CAT (disabled)";
    if (op == 0x7f) return "OP_SUBSTR (disabled)";
    if (op == 0x80) return "OP_LEFT (disabled)";
    if (op == 0x81) return "OP_RIGHT (disabled)";
    if (op == 0x82) return "OP_SIZE";
    if (op == 0x83) return "OP_INVERT (disabled)";
    if (op == 0x84) return "OP_AND (disabled)";
    if (op == 0x85) return "OP_OR (disabled)";
    if (op == 0x86) return "OP_XOR (disabled)";
    if (op == 0x87) return "OP_EQUAL";
    if (op == 0x88) return "OP_EQUALVERIFY";
    if (op == 0x89) return "OP_RESERVED1";
    if (op == 0x8a) return "OP_RESERVED2";
    if (op == 0x8b) return "OP_1ADD";
    if (op == 0x8c) return "OP_1SUB";
    if (op == 0x8d) return "OP_2MUL (disabled)";
    if (op == 0x8e) return "OP_2DIV (disabled)";
    if (op == 0x8f) return "OP_NEGATE";
    if (op == 0x90) return "OP_ABS";
    if (op == 0x91) return "OP_NOT";
    if (op == 0x92) return "OP_0NOTEQUAL";
    if (op == 0x93) return "OP_ADD";
    if (op == 0x94) return "OP_SUB";
    if (op == 0x95) return "OP_MUL (disabled)";
    if (op == 0x96) return "OP_DIV (disabled)";
    if (op == 0x97) return "OP_MOD (disabled)";
    if (op == 0x98) return "OP_LSHIFT (disabled)";
    if (op == 0x99) return "OP_RSHIFT (disabled)";
    if (op == 0x9a) return "OP_BOOLAND";
    if (op == 0x9b) return "OP_BOOLOR";
    if (op == 0x9c) return "OP_NUMEQUAL";
    if (op == 0x9d) return "OP_NUMEQUALVERIFY";
    if (op == 0x9e) return "OP_NUMNOTEQUAL";
    if (op == 0x9f) return "OP_LESSTHAN";
    if (op == 0xa0) return "OP_GREATERTHAN";
    if (op == 0xa1) return "OP_LESSTHANOREQUAL";
    if (op == 0xa2) return "OP_GREATERTHANOREQUAL";
    if (op == 0xa3) return "OP_MIN";
    if (op == 0xa4) return "OP_MAX";
    if (op == 0xa5) return "OP_WITHIN";
    if (op == 0xa6) return "OP_RIPEMD160";
    if (op == 0xa7) return "OP_SHA1";
    if (op == 0xa8) return "OP_SHA256";
    if (op == 0xa9) return "OP_HASH160";
    if (op == 0xaa) return "OP_HASH256";
    if (op == 0xab) return "OP_CODESEPARATOR";
    if (op == 0xac) return "OP_CHECKSIG";
    if (op == 0xad) return "OP_CHECKSIGVERIFY";
    if (op == 0xae) return "OP_CHECKMULTISIG";
    if (op == 0xaf) return "OP_CHECKMULTISIGVERIFY";
    if (op == 0xb0) return "OP_NOP1";
    if (op == 0xb1) return "OP_CHECKLOCKTIMEVERIFY";   // OP_NOP2, BIP65
    if (op == 0xb2) return "OP_CHECKSEQUENCEVERIFY";   // OP_NOP3, BIP112
    if (op == 0xb3) return "OP_NOP4";
    if (op == 0xb4) return "OP_NOP5";
    if (op == 0xb5) return "OP_NOP6";
    if (op == 0xb6) return "OP_NOP7";
    if (op == 0xb7) return "OP_NOP8";
    if (op == 0xb8) return "OP_NOP9";
    if (op == 0xb9) return "OP_NOP10";
    if (op == 0xba) return "OP_CHECKSIGADD";           // Tapscript, BIP342
    if (op == 0xff) return "OP_INVALIDOPCODE";

    return std::format("OP_UNKNOWN_0x{:02x} (OP_SUCCESSx under Tapscript)", op);
};


// ── output-script classification (heuristic, standard templates) ──────────

fn classify_script(u128 off, u128 len) {
    if (len == 0) return "empty";

    u8 b0 = byte_at(off, 0);

    if (b0 == 0x6a)
        return "OP_RETURN — data carrier (provably unspendable)";

    if (len == 25 && b0 == 0x76 && byte_at(off, 1) == 0xa9 && byte_at(off, 2) == 0x14
                  && byte_at(off, 23) == 0x88 && byte_at(off, 24) == 0xac)
        return "P2PKH — pay to pubkey hash";

    if (len == 23 && b0 == 0xa9 && byte_at(off, 1) == 0x14 && byte_at(off, 22) == 0x87)
        return "P2SH — pay to script hash";

    if (len == 22 && b0 == 0x00 && byte_at(off, 1) == 0x14)
        return "P2WPKH — native SegWit v0 pubkey hash";

    if (len == 34 && b0 == 0x00 && byte_at(off, 1) == 0x20)
        return "P2WSH — native SegWit v0 script hash";

    if (len == 34 && b0 == 0x51 && byte_at(off, 1) == 0x20)
        return "P2TR — Taproot (SegWit v1, BIP341)";

    // any other witness program: OP_0 / OP_1..OP_16 then a 2..40 byte push
    if ((b0 == 0x00 || (b0 >= 0x51 && b0 <= 0x60)) && len >= 4 && len <= 42
         && byte_at(off, 1) == (len - 2)) {
        u8 ver = 0;
        if (b0 != 0x00) ver = b0 - 0x50;
        return std::format("witness v{} program ({}-byte program)", u64(ver), u64(len - 2));
    }

    if (len == 35 && b0 == 0x21 && byte_at(off, 34) == 0xac)
        return "P2PK — pay to (compressed) pubkey";
    if (len == 67 && b0 == 0x41 && byte_at(off, 66) == 0xac)
        return "P2PK — pay to (uncompressed) pubkey";

    if (len >= 37 && byte_at(off, len - 1) == 0xae
                  && b0 >= 0x51 && b0 <= 0x60
                  && byte_at(off, len - 2) >= 0x51 && byte_at(off, len - 2) <= 0x60)
        return std::format("bare multisig {}-of-{}",
                           u64(b0 - 0x50), u64(byte_at(off, len - 2) - 0x50));

    return "non-standard / custom";
};


// ── witness spend-type classification (BIP341 key-path / script-path / annex) ─

fn classify_witness(u128 struct_off, u64 count) {
    if (count == 0)
        return "empty — non-witness input inside a SegWit tx";

    u128 off = struct_off + varint_size(struct_off);   // skip the stack-item-count VarInt

    u128 first_len  = 0;
    u128 prev_len   = 0; u128 prev_start = 0;
    u128 last_len   = 0; u128 last_start = 0;
    u128 l = 0; u128 hs = 0; u128 ds = 0;

    for (u64 i = 0, i < count, i = i + 1) {
        l  = varint_value(off);
        hs = varint_size(off);
        ds = off + hs;
        if (i == 0) { first_len = l; }
        prev_len = last_len; prev_start = last_start;
        last_len = l;        last_start = ds;
        off = ds + l;
    }

    bool has_annex = false;
    str  annex_note = "";
    if (count >= 2 && std::mem::read_unsigned(last_start, 1) == 0x50) {
        has_annex  = true;
        annex_note = "  [+ annex]";
    }

    u64  eff      = count;
    u128 cb_len   = last_len;
    u128 cb_start = last_start;
    if (has_annex) {
        eff      = count - 1;
        cb_len   = prev_len;
        cb_start = prev_start;
    }

    if (eff == 1) {
        if (first_len == 64) return std::format("Taproot key-path spend (64B Schnorr sig, SIGHASH_DEFAULT){}", annex_note);
        if (first_len == 65) return std::format("Taproot key-path spend (65B: 64B sig + explicit sighash){}", annex_note);
        return std::format("single stack item, {} bytes{}", u64(first_len), annex_note);
    }

    if (eff == 2 && first_len >= 70 && first_len <= 73 && (last_len == 33 || last_len == 65))
        return std::format("P2WPKH spend — DER signature + pubkey{}", annex_note);

    u8 c0   = std::mem::read_unsigned(cb_start, 1);
    u8 leaf = c0 & 0xfe;
    if (eff >= 2 && cb_len >= 33 && ((cb_len - 33) % 32) == 0 && leaf == 0xc0) {
        u64 m = u64((cb_len - 33) / 32);
        return std::format("Taproot script-path spend — leaf 0x{:02x}, {}-node Merkle path, {} script input(s){}",
                           leaf, m, u64(eff - 2), annex_note);
    }

    return std::format("{} stack items — P2WSH / multisig / custom{}", u64(eff), annex_note);
};

// For a Taproot script-path spend, locate the tapscript (the witness item just
// before the control block, skipping an annex). `field`: 0 -> offset, 1 -> length.
// Returns 0 when this is not a disassemblable script-path spend (wrong shape, or
// the tapscript is huge — e.g. an inscription).
fn tapscript_span(u128 struct_off, u64 count, u8 field) {
    if (count < 2)
        return 0;

    u128 off = struct_off + varint_size(struct_off);
    u128 a_len = 0; u128 a_start = 0;   // item i-2
    u128 b_len = 0; u128 b_start = 0;   // item i-1
    u128 c_len = 0; u128 c_start = 0;   // item i   (== last after the loop)
    u128 l = 0; u128 hs = 0; u128 ds = 0;

    for (u64 i = 0, i < count, i = i + 1) {
        l  = varint_value(off);
        hs = varint_size(off);
        ds = off + hs;
        a_len = b_len; a_start = b_start;
        b_len = c_len; b_start = c_start;
        c_len = l;     c_start = ds;
        off = ds + l;
    }

    bool annex = (std::mem::read_unsigned(c_start, 1) == 0x50);
    if (annex && count < 3)
        return 0;

    u128 ts_len = b_len; u128 ts_start = b_start;
    u128 cb_len = c_len; u128 cb_start = c_start;
    if (annex) {
        ts_len = a_len; ts_start = a_start;
        cb_len = b_len; cb_start = b_start;
    }

    // control block must be 33 + 32*m with a tapleaf version byte; tapscript
    // must be present and small enough to disassemble
    if (cb_len < 33 || ((cb_len - 33) % 32) != 0)
        return 0;
    if ((std::mem::read_unsigned(cb_start, 1) & 0xfe) != 0xc0)
        return 0;
    if (ts_len == 0 || ts_len > 0x2000)
        return 0;

    if (field == 0)
        return ts_start;
    return ts_len;
};


// ── display formatters ────────────────────────────────────────────────────

fn format_varint(ref auto v) {
    return vi(v);
};

fn format_value(u64 sats) {
    return std::format("{} sat  ({}.{:08} BTC)", sats, sats / 100000000, sats % 100000000);
};

fn format_locktime(u32 lt) {
    if (lt == 0)        return "0  (inactive)";
    if (lt < 500000000) return std::format("{}  (block height)", lt);
    return std::format("{}  (unix time; enforced against BIP113 median-time-past)", lt);
};

fn format_sequence(u32 seq) {
    if (seq == 0xffffffff)
        return "0xffffffff  final — no RBF, no relative timelock";

    str rbf = "RBF not signalled";
    if (seq <= 0xfffffffd) rbf = "BIP125 RBF: opt-in";

    if (seq & (1 << 31))
        return std::format("0x{:08x}  {};  BIP68 relative timelock: disabled", seq, rbf);

    u32 val = seq & 0xffff;
    if (seq & (1 << 22))
        return std::format("0x{:08x}  {};  BIP68 (tx v>=2): +{} x 512 s", seq, rbf, val);
    return std::format("0x{:08x}  {};  BIP68 (tx v>=2): +{} blocks", seq, rbf, val);
};

fn format_txid(ref auto bytes) {
    // display (reversed) byte order
    str s = "";
    for (s32 i = 31, i >= 0, i = i - 1)
        s = s + std::format("{:02x}", bytes[i]);
    return s;
};

fn format_scriptop(ref auto o) {
    str name = opcode_name(o.opcode);
    if (o.opcode < 0x01 || o.opcode > 0x4e)
        return name;

    u128 n = o.opcode;
    if (o.opcode == 0x4c || o.opcode == 0x4d || o.opcode == 0x4e)
        n = o.pushLen;

    u128 shown = n;
    if (shown > 20) shown = 20;

    str hex = "";
    for (u128 i = 0, i < shown, i = i + 1)
        hex = hex + std::format("{:02x}", o.data[i]);
    if (n > shown) hex = hex + "...";

    str hint = "";
    if (n == 33 || n == 65)      hint = "  <- pubkey";
    else if (n >= 70 && n <= 73) hint = "  <- DER signature";
    else if (n == 64)            hint = "  <- Schnorr signature";
    else if (n == 20)            hint = "  <- 20-byte hash (hash160)";
    else if (n == 32)            hint = "  <- 32-byte value (sha256 / x-only pubkey)";

    return std::format("{}  {}  ({} bytes){}", name, hex, u64(n), hint);
};

fn format_wititem(ref auto w) {
    u128 n = vi(w.length);
    if (n == 0) return "<empty>";

    u128 shown = n;
    if (shown > 20) shown = 20;

    str hex = "";
    for (u128 i = 0, i < shown, i = i + 1)
        hex = hex + std::format("{:02x}", std::mem::read_unsigned(w._dataStart + i, 1));
    if (n > shown) hex = hex + "...";

    str note = "";
    if (n > 0x2000) note = "  [large — full payload in hex view]";
    return std::format("{}  ({} bytes){}", hex, u64(n), note);
};

fn format_witness(ref auto tw) {
    return classify_witness(tw._start, vi(tw.stackItemCount));
};

fn format_txout(ref auto o) {
    return std::format("{}   |   {}",
        classify_script(o._spkStart, o._spkLen),
        format_value(o.value));
};

fn format_tx(ref auto t) {
    str kind = "legacy";
    if (t.segwit) kind = "segwit";
    return std::format("Bitcoin tx  v{}  ({})  {} in / {} out  locktime {}",
        t.version, kind, u64(vi(t.inputCount)), u64(vi(t.outputCount)), t.lockTime);
};


// ── structures ───────────────────────────────────────────────────────────

struct VarInt {
    u8 prefix [[hidden]];
    if (prefix == 0xFD)      u16 ext [[hidden]];
    else if (prefix == 0xFE) u32 ext [[hidden]];
    else if (prefix == 0xFF) u64 ext [[hidden]];
} [[sealed, format("format_varint")]];

struct ScriptOp {
    u8 opcode [[color("D8DEE9")]];
    if (opcode >= 0x01 && opcode <= 0x4b) {
        u8 data[opcode]   [[color("9CCFD8"), comment("pushed data")]];
    } else if (opcode == 0x4c) {
        u8  pushLen       [[color("EA9D34")]];
        u8  data[pushLen] [[color("9CCFD8"), comment("pushed data")]];
    } else if (opcode == 0x4d) {
        u16 pushLen       [[color("EA9D34")]];
        u8  data[pushLen] [[color("9CCFD8"), comment("pushed data")]];
    } else if (opcode == 0x4e) {
        u32 pushLen       [[color("EA9D34")]];
        u8  data[pushLen] [[color("9CCFD8"), comment("pushed data")]];
    }
} [[format("format_scriptop")]];

// A run of Script bytes of known length `Len`, disassembled into opcodes.
struct Script<auto Len> {
    ScriptOp ops[while(!std::mem::reached(addressof(this) + Len))];
};

struct OutPoint {
    u8  txid[32] [[color("A8DAB5"), format("format_txid"),
                   comment("hash of the funding tx (stored LE; shown reversed = explorer txid)")]];
    u32 index    [[color("A8DAB5"), comment("index of the output being spent (0xffffffff on a coinbase)")]];
};

struct TxInput {
    OutPoint previousOutput;
    VarInt   scriptSigLength [[color("A8DAB5")]];
    Script<vi(scriptSigLength)> scriptSig [[color("A8DAB5"),
             comment("unlocking script — empty for native SegWit inputs")]];
    u32      sequence [[color("A8DAB5"), format("format_sequence")]];
};

struct TxOutput {
    u64    value [[color("F6C177"), format("format_value")]];
    VarInt scriptPubKeyLength [[color("F6C177")]];
    u128   _spkLen   = vi(scriptPubKeyLength) [[hidden]];
    u128   _spkStart = $ [[hidden]];
    Script<vi(scriptPubKeyLength)> scriptPubKey [[color("F6C177"), comment("locking script")]];
} [[format("format_txout")]];

struct WitnessItem {
    VarInt length [[color("EB6F92")]];
    u128   _n = vi(length) [[hidden]];
    u128   _dataStart = $ [[hidden]];
    if (_n > 0 && _n <= 0x2000) {
        u8 data[_n] [[color("EB6F92"), comment("witness stack item — a raw byte push, not a script")]];
    } else if (_n > 0x2000) {
        u8 dataPreview[256] [[color("EB6F92"), comment("first 256 bytes — large item (e.g. an inscription); scroll the hex view for the rest")]];
        padding[_n - 256];
    }
} [[format("format_wititem")]];

struct TxInWitness {
    u128        _start = $ [[hidden]];
    VarInt      stackItemCount [[color("EB6F92"), comment("number of witness stack items for this input")]];
    u128        _c = vi(stackItemCount) [[hidden]];
    if (_c > 0) {
        WitnessItem stack[_c];
    }

    // Overlay: disassemble the tapscript of a Taproot script-path spend
    // (leaf script before the control block). 0 length => not applicable.
    u128 _tsLen   = tapscript_span(_start, _c, 1) [[hidden]];
    u128 _tsStart = tapscript_span(_start, _c, 0) [[hidden]];
    if (_tsLen > 0) {
        Script<_tsLen> tapScript @ _tsStart [[color("F2CDCD"),
                comment("BIP342 tapscript, disassembled (multi_a(k,...) => OP_CHECKSIG + OP_CHECKSIGADD chain)")]];
    }
} [[format("format_witness")]];

struct BitcoinTransaction {
    s32 version [[color("C4A7E7"),
                  comment("transaction version — >= 2 enables BIP68 relative timelocks")]];

    bool segwit = (std::mem::read_unsigned($, 1) == 0x00)
               && (std::mem::read_unsigned($ + 1, 1) != 0x00) [[hidden]];

    if (segwit) {
        u8 marker [[color("6E6A86"), comment("SegWit marker — must be 0x00 (BIP144)")]];
        u8 flag   [[color("6E6A86"), comment("SegWit flag — must be non-zero; 0x01 today")]];
    }

    VarInt  inputCount [[color("A8DAB5")]];
    TxInput inputs[vi(inputCount)];

    VarInt   outputCount [[color("F6C177")]];
    TxOutput outputs[vi(outputCount)];

    if (segwit) {
        TxInWitness witnesses[vi(inputCount)];
    }

    u32 lockTime [[color("C4A7E7"), format("format_locktime")]];
} [[format("format_tx")]];

BitcoinTransaction transaction @ 0x00;