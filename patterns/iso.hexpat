#pragma description ISO 9660 file system
#pragma MIME application/x-iso9660-image

#pragma endian little

import std.io;
import std.math;
import std.mem;
import std.string;

// The directory tree is walked recursively, its depth is bounded by MaxDirectoryDepth below
#pragma eval_depth 0

// Set from the volume descriptor that is currently being parsed
u32 blockSize = 2048;
bool inJoliet = false;

// Guards for corrupted images: directories already open further up the tree are not
// entered again, nesting depth and the number of directories followed per tree are capped
str openDirectories = "";
u32 directoriesFollowed = 0;
u32 directoryDepth = 0;
const u32 MaxDirectories = 10000;
const u32 MaxDirectoryDepth = 64;

// State of the interleaved file currently being parsed, see InterleavedFileUnit
u64 interleaveRemaining = 0;
u64 interleaveUnitBytes = 0;
u64 interleaveGapBytes = 0;

enum VolumeDescriptorTypes : u8 {
  BootRecord,
  PrimaryVolume,
  SupplementaryVolume,
  VolumePartition,
  Terminator = 0xff,
};

struct di32 {
  s32    leValue;
  be s32 beValue;
} [[static]];

struct di16 {
  s16    leValue;
  be s16 beValue;
} [[static]];

struct PathTablePtr {
  s32    leMainOffset;
  s32    leOptOffset;
  be s32 beMainOffset;
  be s32 beOptOffset;
} [[static]];

struct DateFormat {
  u8 year;
  u8 month;
  u8 day;
  u8 hour;
  u8 minute;
  u8 second;
  u8 gmtOffset;
} [[static]];

fn FormatDate(DateFormat fmt) {
  s16 gmt = (-48 + fmt.gmtOffset) * 15;
  float gmtHour = gmt / 60;
  s16 gmtMinute = gmt % 60;
  str retVal = std::format("{}.{:02}.{:02} {:02}:{:02}:{:02} GMT{:+03}:{:02}",
                           fmt.day, fmt.month, fmt.year + 1900,
                           fmt.hour, fmt.minute, fmt.second,
                           gmtHour, gmtMinute);
  return retVal;
};

struct StrDateFormat {
  char year[4];
  char month[2];
  char day[2];
  char hour[2];
  char minute[2];
  char second[2];
  char secondFrac[2];
  u8   gmtOffset;
} [[static]];

fn FormatStrDate(StrDateFormat fmt) {
  s16 gmt = (-48 + fmt.gmtOffset) * 15;
  float gmtHour = gmt / 60;
  s16 gmtMinute = gmt % 60;
  str retVal = std::format("{}.{}.{} {}:{}:{}.{} GMT{:+03}:{:02}",
                           fmt.day, fmt.month, fmt.year,
                           fmt.hour, fmt.minute, fmt.second, fmt.secondFrac,
                           gmtHour, gmtMinute);
  return retVal;
};

bitfield FileFlags {
  hidden                           : 1;
  directory                        : 1;
  associatedFile                   : 1;
  extendedAttribute                : 1;
  ownerAndGroupInExtendedAttribute : 1;
  padding                          : 2;
  fileRecordNotFinal               : 1;
};

using Directory<auto Address, auto Size>;

// A file recorded in interleaved mode (ECMA-119 7.4.3): file units of `fileUnitSize`
// logical blocks separated by gaps of `interleaveGapSize` blocks. One element per unit, so
// the gaps are skipped as padding instead of being shown as file data.
struct InterleavedFileUnit {
  u64 size = std::math::min(interleaveUnitBytes, interleaveRemaining);
  u8 data[size] [[sealed]];
  interleaveRemaining -= size;
  if (interleaveRemaining > 0)
    padding[interleaveGapBytes];
} [[format("FormatInterleavedFileUnit")]];

fn FormatInterleavedFileUnit(ref InterleavedFileUnit unit) {
  return std::format("{} bytes", unit.size);
};

struct InterleavedFile<auto Size, auto UnitBlocks, auto GapBlocks> {
  interleaveRemaining = Size;
  interleaveUnitBytes = u64(UnitBlocks) * blockSize;
  interleaveGapBytes = u64(GapBlocks) * blockSize;
  InterleavedFileUnit units[while(interleaveRemaining > 0)];
};

// Bytes from the start of an interleaved file's first unit to the end of its last one
fn InterleavedSpan(u64 size, u8 unitBlocks, u8 gapBlocks) {
  u64 unitBytes = u64(unitBlocks) * blockSize;
  u64 units = (size + unitBytes - 1) / unitBytes;
  return (units - 1) * (unitBytes + u64(gapBlocks) * blockSize) + (size - (units - 1) * unitBytes);
};

fn IsSelfOrParent(u128 nameAddress, u8 nameLength) {
  return nameLength == 1 && std::mem::read_unsigned(nameAddress, 1) <= 0x01;
};

struct DirectoryRecord {
  u8 recordSize;
  u8 extendedRecordSize;
  di32 extentOffset;
  di32 dataSize;
  DateFormat recordDate[[format("FormatDate")]];
  FileFlags fileFlags;
  u8 fileUnitSize;
  u8 interleaveGapSize;
  di16 volumeSequenceNumber;
  u8 fileNameLen;
  // Joliet names are UCS-2 big endian, except for the one byte "." and ".." identifiers
  if (inJoliet && fileNameLen > 1)
    be char16 fileName[fileNameLen / 2];
  else
    char fileName[fileNameLen];
  padding[$ % 2];
  u8 remainingSize = $ - addressof(this);
  if (recordSize > remainingSize) {
    u8 systemUse[recordSize - remainingSize];
  }

  // Follow the record to its contents. "." and ".." are skipped, they point back up the tree.
  // An extended attribute record of `extendedRecordSize` logical blocks comes first in the
  // extent, or fills the first file unit of an interleaved file (ECMA-119 7.4.3.4, 7.4.4).
  u128 extentAddress = u128(extentOffset.leValue) * blockSize;
  u128 extentSize = u32(dataSize.leValue);
  bool interleaved = fileUnitSize != 0;
  if (interleaved && fileFlags.directory) {
    std::warning(std::format("Directory \"{}\" claims to be interleaved, which ECMA-119 does not allow; reading it as contiguous", fileName));
    interleaved = false;
  }
  u128 dataAddress = extentAddress;
  if (extendedRecordSize != 0)
    dataAddress += interleaved ? u128(fileUnitSize + interleaveGapSize) * blockSize : u128(extendedRecordSize) * blockSize;
  u128 dataSpan = interleaved && extentSize > 0 ? InterleavedSpan(extentSize, fileUnitSize, interleaveGapSize) : extentSize;

  if (!IsSelfOrParent(addressof(fileName), fileNameLen) && (extentSize > 0 || extendedRecordSize != 0)) {
    if (dataAddress + dataSpan > std::mem::size()) {
      std::warning(std::format("Extent of \"{}\" lies outside of the image", fileName));
    } else {
      if (extendedRecordSize != 0)
        u8 extendedAttributeRecord[u128(extendedRecordSize) * blockSize] @ extentAddress [[sealed]];

      if (extentSize == 0) {
        // Only an extended attribute record
      } else if (fileFlags.directory) {
        // Keyed by where the records start, after any extended attribute record
        str key = std::format("|{}|", dataAddress / blockSize);
        if (std::string::contains(openDirectories, key)) {
          std::warning(std::format("\"{}\" loops back to a parent directory, not following it", fileName));
        } else if (directoriesFollowed >= MaxDirectories) {
          std::warning(std::format("More than {} directories, not following \"{}\"", MaxDirectories, fileName));
        } else if (directoryDepth >= MaxDirectoryDepth) {
          std::warning(std::format("Directories nested deeper than {} levels, not following \"{}\"", MaxDirectoryDepth, fileName));
        } else {
          u32 openLength = std::string::length(openDirectories);
          openDirectories += key;
          directoriesFollowed += 1;
          directoryDepth += 1;
          Directory<dataAddress, extentSize> contents @ dataAddress;
          directoryDepth -= 1;
          openDirectories = std::string::substr(openDirectories, 0, openLength);
        }
      } else if (interleaved) {
        InterleavedFile<extentSize, fileUnitSize, interleaveGapSize> data @ dataAddress;
      } else {
        std::mem::Bytes<extentSize> data @ dataAddress;
      }
    }
  }
} [[format("FormatDirectoryRecord")]];

fn FormatDirectoryRecord(ref DirectoryRecord record) {
  if (IsSelfOrParent(addressof(record.fileName), record.fileNameLen))
    return std::mem::read_unsigned(addressof(record.fileName), 1) == 0x00 ? "." : "..";
  if (record.fileFlags.directory)
    return std::format("<DIR> {}", record.fileName);
  return std::format("{} ({} bytes)", record.fileName, u32(record.dataSize.leValue));
};

// Records never cross a sector boundary, the rest of a sector after the last record is zero
fn NextRecordAddress(u128 address, u128 end) {
  while (address < end && std::mem::read_unsigned(address, 1) == 0x00)
    address = address + blockSize - (address % blockSize);
  return address;
};

struct DirectoryEntry<auto End> {
  padding[NextRecordAddress($, End) - $];
  DirectoryRecord record [[inline]];
} [[inline]];

struct Directory<auto Address, auto Size> {
  DirectoryEntry<Address + Size> records[while(NextRecordAddress($, Address + Size) < Address + Size)] [[inline]];
};

fn GetSupplementaryEncoding() {
  const u128 escapeSequencesOffset = 89 - 8;

  str encoding = std::mem::read_string($ + escapeSequencesOffset, 0x20);
  return encoding == "%/@\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
      || encoding == "%/C\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
      || encoding == "%/E\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";
};

struct VolumeDescriptor {
  VolumeDescriptorTypes type;
  char id[5];
  u8 version;
  bool isJoliet = type == VolumeDescriptorTypes::SupplementaryVolume && GetSupplementaryEncoding();

  if (type == VolumeDescriptorTypes::PrimaryVolume) {
    padding[1];
    char systemId[0x20];
    char volumeId[0x20];
    padding[8];
    di32 spaceSize;
    padding[0x20];
    di16 setSize;
    di16 sequenceNumber;
    di16 logicalBlockSize;
    blockSize = logicalBlockSize.leValue;
    inJoliet = false;
    di32 pathTableSize;
    PathTablePtr pathTableOffset;
    DirectoryRecord rootDir;
    char setId[0x80];
    char publisherId[0x80];
    char preparerId[0x80];
    char applicationId[0x80];
    char copyrightFileId[0x25];
    char abstractFileId[0x25];
    char bibliographicFileId[0x25];
    StrDateFormat creationTime[[format("FormatStrDate")]];
    StrDateFormat modificationTime[[format("FormatStrDate")]];
    StrDateFormat expirationTime[[format("FormatStrDate")]];
    StrDateFormat effectiveTime[[format("FormatStrDate")]];
    u8 fileStructVersion;
  } else if (isJoliet) {
    u8 flags;
    be char16 systemId[0x10];
    be char16 volumeId[0x10];
    padding[8];
    di32 spaceSize;
    u8 escapeSequences[0x20];
    di16 setSize;
    di16 sequenceNumber;
    di16 logicalBlockSize;
    blockSize = logicalBlockSize.leValue;
    inJoliet = true;
    di32 pathTableSize;
    PathTablePtr pathTableOffset;
    DirectoryRecord rootDir;
    be char16 setId[0x40];
    be char16 publisherId[0x40];
    be char16 preparerId[0x40];
    be char16 applicationId[0x40];
    be char16 copyrightFileId[0x12];
    padding[1];
    be char16 abstractFileId[0x12];
    padding[1];
    be char16 bibliographicFileId[0x12];
    padding[1];
    StrDateFormat creationTime[[format("FormatStrDate")]];
    StrDateFormat modificationTime[[format("FormatStrDate")]];
    StrDateFormat expirationTime[[format("FormatStrDate")]];
    StrDateFormat effectiveTime[[format("FormatStrDate")]];
    u8 fileStructVersion;
  }

  // The whole directory tree, starting at the root directory's extent
  if (type == VolumeDescriptorTypes::PrimaryVolume || isJoliet) {
    u128 rootAddress = (u128(rootDir.extentOffset.leValue) + rootDir.extendedRecordSize) * blockSize;
    u128 rootSize = u32(rootDir.dataSize.leValue);
    if (blockSize > 0 && rootSize > 0 && rootAddress + rootSize <= std::mem::size()) {
      openDirectories = std::format("|{}|", rootAddress / blockSize);
      directoriesFollowed = 0;
      directoryDepth = 0;
      Directory<rootAddress, rootSize> rootDirectory @ rootAddress;
      openDirectories = "";
    }
    inJoliet = false;
  }

  padding[0x800 - $ % 0x800];
};

// Volume descriptors start after the 32 KiB system area; a cut off image shows the
// descriptors it still holds completely and the rest as bytes
fn DescriptorFits(u128 address) {
  return address + 0x800 <= std::mem::size();
};

struct ISOImage {
  if (std::mem::size() <= 0x8000) {
    u8 systemArea[std::mem::size()];
  } else {
    padding[0x8000];
    VolumeDescriptor descriptors[while(DescriptorFits($) && std::mem::read_unsigned($, 1) != 0xFF)];
    if (DescriptorFits($))
      VolumeDescriptor terminator;
    else if ($ < std::mem::size())
      u8 truncatedDescriptor[std::mem::size() - $];
  }
} [[inline]];

ISOImage image @ 0x00;