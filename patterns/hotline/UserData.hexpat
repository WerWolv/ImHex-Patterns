#pragma author Scott Anderson
#pragma descrption
#pragma endian big
#pragma encoding mac

import std.io;
import std.file;

import type.magic;

struct PascalString<auto W> {
    u16 script;
    u16 size;
    char data[size];
    padding[W - size];
} [[sealed, format("format_pascal_string")]];
fn format_pascal_string(auto s) {
    return std::format("\"{}\"", type::escape_bytes(s.data));
};

using PascalString_xor_ff<auto W> = PascalString<W> [[format("format_pascal_string_xor_ff")]];
fn format_pascal_string_xor_ff(auto s) {
    str deobfuscated = s.data;
    auto i = 0;
    while (i < s.size) {
        deobfuscated[i] = deobfuscated[i] ^ 0xff;
        i += 1;
    }
    return std::format("\"{}\"", type::escape_bytes(deobfuscated));
};

//using SMyUserAccess = u64;
bitfield SMyUserAccess {
    DeleteFile        : 1;
    UploadFile        : 1;
    DownloadFile      : 1;
    RenameFile        : 1;
    MoveFile          : 1;
    CreateFolder      : 1;
    DeleteFolder      : 1;
    RenameFolder      : 1;
    MoveFolder        : 1;
    ReadChat          : 1;
    SendChat          : 1;
    CreateChat        : 1;
    CloseChat         : 1;
    ShowInList        : 1;
    CreateUser        : 1;
    DeleteUser        : 1;
    OpenUser          : 1;
    ModifyUser        : 1;
    ChangeOwnPass     : 1;
    SendPrivMsg       : 1;
    NewsReadArt       : 1;
    NewsPostArt       : 1;
    DisconUser        : 1;
    CannotBeDiscon    : 1;
    GetClientInfo     : 1;
    UploadAnywhere    : 1;
    AnyName           : 1;
    NoAgreement       : 1;
    SetFileComment    : 1;
    SetFolderComment  : 1;
    ViewDropBoxes     : 1;
    MakeAlias         : 1;
    Broadcast         : 1;
    NewsDeleteArt     : 1;
    NewsCreateCat     : 1;
    NewsDeleteCat     : 1;
    NewsCreateFldr    : 1;
    NewsDeleteFldr    : 1;
    UploadFolder      : 1;
    DownloadFolder    : 1;
    SendMessage       : 1;
    RESERVED          : 23;
};

struct SMyUserDataFile {
    u16 version;
    s16 iconID;
    SMyUserAccess access;
    u16 maxSimulDownloads;
    padding[512];
    PascalString<64> name;
    PascalString<64> alias;
    PascalString<32> login;
    PascalString_xor_ff<32> passowrd;
};
SMyUserDataFile file @ 0x00 [[inline]];