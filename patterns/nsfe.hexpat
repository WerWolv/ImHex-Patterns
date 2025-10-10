#pragma author gmestanley
#pragma description NSFe file format

#include <./nsfmetadata.hexpat>

char signature[4] @ 0x00;
Chunk chunks[while($<std::mem::size())] @ 0x04;