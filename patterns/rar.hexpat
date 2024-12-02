#pragma author targodan
#pragma description RAR archive file format
#pragma MIME application/x-rar

import type.magic;
import type.byte;
import std.mem;
import std.math;
import std.string;
import std.time;

// Source: https://www.rarlab.com/technote.htm

#define RARv5_MAGIC "Rar!\x1a\x07\x01\x00"

using FILETIME = u64 [[format("format_windows_time")]];
using time_t = std::time::EpochTime [[format("format_unix_time")]];
using nanotime_t = u64 [[format("format_unix_time")]];

fn format_unix_time(time_t t) {
    return std::time::format(std::time::to_local(t), "%c");
};

fn format_windows_time(FILETIME t) {
    return format_unix_time(std::time::filetime_to_unix(t));
};

struct vint {
    u8 data[while(std::mem::read_unsigned($, 1) & 0x80 != 0)];
    u8 last;
} [[sealed, transform("vint_value"), format("vint_value")]];

fn vint_value(vint vi) {
    u64 value = 0;
    u8 i = 0;
    for(i = 0, i < sizeof(vi.data), i = i + 1) {
        value |= (vi.data[i] & 0x7F) << (i * 7);
    }
    value |= vi.last << (i * 7);
    return value;
};

bitfield LocatorRecordFlags {
    bool quickOpenRecordOffsetIsPresent : 1;
    bool recoveryRecordOffsetIsPresent : 1;
};

struct LocatorRecord {
    LocatorRecordFlags flags;  // should be vint but not compatible with bitfield
    if (flags.quickOpenRecordOffsetIsPresent) {
        vint quickOpenRecordOffset;
    }
    if (flags.recoveryRecordOffsetIsPresent) {
        vint recoveryRecordOffset;
    }
};

bitfield MetadataRecordFlags {
    bool archiveNameIsPresent : 1;
    bool archiveOriginalCreationTimeIsPresent : 1;
    bool timeIsUnixTime : 1;
    bool unixTimeIsNanosecondPrecision : 1;
};

struct MetadataRecord {
    MetadataRecordFlags flags;  // should be vint but not compatible with bitfield
    if (flags.archiveNameIsPresent) {
        vint nameLength;
        char name[nameLength];
    }
    if (flags.archiveOriginalCreationTimeIsPresent) {
        match (flags.timeIsUnixTime, flags.unixTimeIsNanosecondPrecision) {
            (true, true): nanotime_t originalCreationTime;
            (true, false): time_t originalCreationTime;
            (false, _): FILETIME originalCreationTime;
        }
    }
};

enum MainHeaderExtraRecordType : vint {
    Locator = 1,
    Metadata = 2
};

struct MainHeaderExtraRecord {
    vint size;
    MainHeaderExtraRecordType type;
    match(type) {
        (MainHeaderExtraRecordType::Locator): LocatorRecord record [[inline]];
        (MainHeaderExtraRecordType::Metadata): MetadataRecord record [[inline]];
    }
};

bitfield HeaderFlags {
    bool extraAreaIsPresent : 1;
    bool dataAreaIsPresent : 1;
};

bitfield ArchiveFlags {
    bool archiveIsPartOfMultiVolumeSet : 1;
    bool volumeNumberFieldIsPresent : 1;
    bool isSolidArchive : 1;
    bool recoveryRecordIsPresent : 1;
    bool isLockedArchive : 1;
};

enum HeaderType : vint {
    MainHeader = 1,
    FileHeader,
    ServiceHeader,
    EncryptionHeader,
    EndOfArchive
};

struct MainArchiveHeader {
    HeaderFlags flags;  // should be vint but not compatible with bitfield
    if (flags.extraAreaIsPresent) {
        vint extraAreaSize;
    }
    ArchiveFlags archiveFlags;  // should be vint but not compatible with bitfield
    if (archiveFlags.volumeNumberFieldIsPresent) {
        vint volumeNumber;
    }
    if (flags.extraAreaIsPresent) {
        u64 extraEnd = $ + extraAreaSize;
        MainHeaderExtraRecord extraArea[while($ < extraEnd)];
    }
};

bitfield EncryptionHeaderFlags {
    bool passwordCheckDataIsPresent : 1;
};

struct EncryptionHeader {
    HeaderFlags flags;  // should be vint but not compatible with bitfield
    vint encryptionVersion; // only 0 (AES-256) is supported
    EncryptionHeaderFlags encryptionFlags;
    u8 kdfCount;
    u8 salt[16];
    if (encryptionFlags.passwordCheckDataIsPresent) {
        u8 checkValue[12];
    }
    
    u8 iv[16];
    // if this header is present, all following headers are encrypted => gobble up all data
    u8 encryptedHeaders[while(!std::mem::eof())];
    // With a bit of guess work, I figured out the exact crypto:
    // key = PBKDF2(password, salt, keysize=256, iterations=2^kdfCount, hash=sha256)
    // plainHeaders = AES256Decrypt(key, iv, mode=CBC)
};

bitfield FileAndServiceHeaderFlags {
    bool isDirectory : 1;
    bool timeFieldIsPresent : 1;
    bool crc32FieldIsPresent : 1;
    bool unpackedSizeIsUnknown : 1;
};

enum HostOS : vint {
    Windows = 0,
    Unix = 1
};

bitfield FileEncryptionFlags {
    bool passwordCheckDataIsPresent : 1;
    bool useTweakedChecksums : 1;
};

struct FileEncryptionRecord {
    vint encryptionVersion; // only 0 (AES-256) is supported
    FileEncryptionFlags flags;  // should be vint but not compatible with bitfield
    u8 kdfCount;
    u8 salt[16];
    u8 iv[16];
    u8 checkValue[12];
};

struct FileHashRecord {
    vint hashType; // only 0 (BLAKE2sp) hash is documented
    u8 hashData[32]; // depends on hashType, but only one type is supported
};

bitfield FileTimeFlags {
    bool timeIsStoredInUnixTime : 1;
    bool mtimeIsPresent : 1;
    bool ctimeIsPresent : 1;
    bool atimeIsPresent : 1;
    bool unixTimeIsNanosecondPrecision : 1;
};

struct FileTimeRecord {
    FileTimeFlags flags;  // should be vint but not compatible with bitfield
    if (flags.mtimeIsPresent) {
        match (flags.timeIsStoredInUnixTime, flags.unixTimeIsNanosecondPrecision) {
            (true, true): nanotime_t mtime;
            (true, false): time_t mtime;
            (false, _): FILETIME mtime;
        }
    }
    if (flags.ctimeIsPresent) {
        match (flags.timeIsStoredInUnixTime, flags.unixTimeIsNanosecondPrecision) {
            (true, true): nanotime_t ctime;
            (true, false): time_t ctime;
            (false, _): FILETIME ctime;
        }
    }
    if (flags.atimeIsPresent) {
        match (flags.timeIsStoredInUnixTime, flags.unixTimeIsNanosecondPrecision) {
            (true, true): nanotime_t atime;
            (true, false): time_t atime;
            (false, _): FILETIME atime;
        }
    }
};

struct FileVersionRecord {
    vint flags;
    vint versionNumber;
};

enum RedirectionType : vint {
    unixSymlink = 1,
    windowsSymlink,
    windowsJunktion,
    hardLink,
    fileCopy
};

struct RedirectionRecord {
    RedirectionType type;
    vint flags;
    vint targetLength;
    char target[targetLength];
};

bitfield UnixOwnerFlags {
    bool userNameStringIsPresent : 1;
    bool groupNameStringIsPresent : 1;
    bool numericUserIDIsPresent : 1;
    bool numericGroupIDIsPresent : 1;
};

struct UnixOwnerRecord {
    UnixOwnerFlags flags;  // should be vint but not compatible with bitfield
    if (flags.userNameStringIsPresent) {
        vint userNameLength;
        char userName[usernameLength];
    }
    if (flags.groupNameStringIsPresent) {
        vint groupNameLength;
        char groupName[groupNameLength];
    }
    if (flags.numericUserIDIsPresent) {
        vint uid;
    }
    if (flags.numericGroupIDIsPresent) {
        vint gid;
    }
};

enum FSHeaderExtraRecordType : vint {
    FileEncryption = 1,
    FileHash,
    FileTime,
    FileVersion,
    Redirection,
    UnixOwner,
    ServiceData
};

struct FSHeaderExtraRecord {
    vint size;
    FSHeaderExtraRecordType type;
    match(type) {
        (FSHeaderExtraRecordType::FileEncryption): FileEncryptionRecord record [[inline]];
        (FSHeaderExtraRecordType::FileHash): FileHashRecord record [[inline]];
        (FSHeaderExtraRecordType::FileTime): FileTimeRecord record [[inline]];
        (FSHeaderExtraRecordType::FileVersion): FileVersionRecord record [[inline]];
        (FSHeaderExtraRecordType::Redirection): RedirectionRecord record [[inline]];
        (FSHeaderExtraRecordType::UnixOwner): UnixOwnerRecord record [[inline]];
        (FSHeaderExtraRecordType::ServiceData): u8 data[size - sizeof(type)]; // couldn't find any info on these records
    }
};

bitfield _CompressionInformation {
    version : 6;
    bool isSolid : 1;
    method : 3;
    minDictionarySizeExponent : 5; // min dict size is `128 KB * 2^minDictionarySizeExponent`
    additionalDictionarySize : 5;
    bool compressionAlgorithmIsZeroButSizeIsV1 : 1;
};

struct CompressionInformation {
    vint value; // TODO: I'd like to somehow cast the resulting value to _CompressionInformation
};

struct FileOrServiceHeader {
    HeaderFlags flags;  // should be vint but not compatible with bitfield
    if (flags.extraAreaIsPresent) {
        vint extraAreaSize;
    }
    if (flags.dataAreaIsPresent) {
        vint dataAreaSize;
    }
    FileAndServiceHeaderFlags fileOrServiceFlags;  // should be vint but not compatible with bitfield
    vint unpackedSize;
    vint fileAttributes;
    if (fileOrServiceFlags.timeFieldIsPresent) {
        u32 fileModificationUnixTime;
    }
    if (fileOrServiceFlags.crc32FieldIsPresent) {
        u32 unpackedCrc32;
    }
    CompressionInformation compressionInformation;
    try {
        HostOS hostOS;
        vint nameLength;
        char name[nameLength];
        if (flags.extraAreaIsPresent) {
            u64 extraEnd = $ + extraAreaSize;
            FSHeaderExtraRecord extraArea[while($ < extraEnd)];
        }
        if (flags.dataAreaIsPresent) {
            u8 data[dataAreaSize] [[sealed]];
        }
    } catch {}
};

bitfield EOAHeaderFlags {
    bool archiveIsVolumeAndNotLastInVolumeSet : 1;
};

struct EndOfArchiveHeader {
    HeaderFlags flags;
    EOAHeaderFlags eoaFlags;
};

struct Header {
    u32 crc32;
    vint headerSize;
    HeaderType type;
    match (type) {
        (HeaderType::EncryptionHeader): EncryptionHeader [[inline]];
        (HeaderType::MainHeader): MainArchiveHeader [[inline]];
        (HeaderType::FileHeader): FileOrServiceHeader [[inline]];
        (HeaderType::ServiceHeader): FileOrServiceHeader [[inline]];
        (HeaderType::EndOfArchive): EndOfArchiveHeader [[inline]];
    }
    if (type == HeaderType::EndOfArchive) {
        break;
    }
};

struct RARv5 {
    type::Magic<RARv5_MAGIC> magic;
    Header headers[while(!std::mem::eof())]; // TODO: would be better to read until EOAHeader
};

RARv5 archive @ std::mem::find_string(0, RARv5_MAGIC);

