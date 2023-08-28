#pragma description ISO 9660 file system

#pragma endian little

#include <std/io.pat>

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
  char fileName[fileNameLen];
  padding[$ % 2];
};

struct VolumeDescriptor {
  VolumeDescriptorTypes type;
  char id[5];
  u8 version;

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
    padding[0x200 + 0x28E];
  }
};

VolumeDescriptor data @ 0x8000;