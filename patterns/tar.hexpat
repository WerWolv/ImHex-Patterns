#pragma description Tar file format

#pragma MIME application/tar
#pragma MIME application/x-tar

#pragma endian little

import std.string;
import std.time;
import std.mem;
import std.sys;


#define GNU_HEADER "ustar "
#define PAX_HEADER "ustar\x00"
#define NULL "\x00"

fn octal_to_decimal(str value) {
    return std::string::parse_int(value, 8);
};

fn get_time(str time) {
    std::time::EpochTime epochtime = octal_to_decimal(time);
    std::time::Time localtime = std::time::to_local(epochtime);
    return std::time::format(localtime, "%c");
};

enum typeflagenum : char {
    regular = '0',
    also_regular = '\x00',
    link_to_another_file_already_archived = '1',
    symbolic_link = '2',
    character_special_device = '3',
    block_special_device = '4',
    directory = '5',
    fifo_special_file = '6',
    reserved = '7'
};

struct posix_header {
  char name[100] [[name("file name")]];
  char mode[8] [[name("file mode")]];
  char uid[8] [[name("user id of the file")]];
  char gid[8] [[name("group id of the file")]];
  char size[12] [[name("size of the file in octal")]];
  char mtime[12] [[name("modified time of file in epoch time")]];
  char chksum[8] [[name("checksum")]];
  typeflagenum typeflag [[name("type of file")]];
  char linkname[100] [[name("name of link")]];
  char magic[6] [[name("magic bytes that identifies the 'file version'")]];
  char version[2] [[name("version (also used with magic bytes)")]];
  char uname[32] [[name("username of the owner of the file")]];
  char gname[32] [[name("group name of the owner of the file")]];
  char devmajor[8] [[name("major device numbers")]];
  char devminor[8] [[name("minor device numbers")]];
  char prefix[155] [[name("filename prefix")]];
  char reserved[12] [[name("reserved")]];
};


struct tar {
    posix_header header_raw;
    char file[octal_to_decimal(header_raw.size)];
    
    std::print("-" * 50);
    std::print("File Name: {}", header_raw.name);
    std::print("File Permissions: {}" , header_raw.mode);
    std::print("UID: {}", header_raw.uid);
    std::print("GUID: {}", header_raw.gid);
    std::print("Size: {} bytes", octal_to_decimal(header_raw.size));
    std::print("Modified Time: {}", get_time(header_raw.mtime));
    std::print("Checksum: {}", header_raw.chksum);
    std::print("Type of File: {}", header_raw.typeflag);
    std::print("Magic Bytes: {}", header_raw.magic);
    std::print("Version: {}", header_raw.version);
    std::print("uname: {}", header_raw.uname);
    std::print("gname: {}", header_raw.gname);
    std::print("devmajor: {}", header_raw.devmajor);
    std::print("devminor: {}", header_raw.devminor);
    std::print("prefix: {}", header_raw.prefix);
    
    char empty[while (std::mem::read_string($, 1) == NULL && !std::mem::eof())];
    if (std::mem::eof()) {
        break;
    }
};

char magic[6] @ 0x00000101 [[hidden]];
std::assert(magic == PAX_HEADER || magic == GNU_HEADER, "Magic bytes are not correct! Perhaps wrong file?");

tar tar[while(!std::mem::eof())] @ 0x000;
