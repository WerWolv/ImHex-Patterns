#pragma author kenkit
#pragma description Agilent/Rigol Waveform
#pragma file_extension bin
#pragma magic [ 41 47, 52 47 ] @ 0x00 // Matches "AG" or "RG" at offset 0


#include <std/mem.pat>

// Helper: Convert ASCII version string to integer
fn version_to_int(u32 addr) {
    u8 tens = u8(std::mem::read_unsigned(addr, 1)) - 48;
    u8 ones = u8(std::mem::read_unsigned(addr + 1, 1)) - 48;
    return (tens * 10) + ones;
};

struct FileHeader {
    char magic[2];
    char version_string[2];
    u16 v_val = version_to_int(addressof(version_string));

    if (v_val == 1 || v_val == 10) {
        u32 file_size;
        u32 num_waveforms;
    } else if (v_val == 3) {
        u64 file_size;
        u32 num_waveforms;
    }
} [[static]];

FileHeader header @ 0x00;

struct WaveformHeader {
    u8 length; 
    s32 wave_type;
    s32 buffers;
    s32 points;
    s32 average;
    float x_d_range;
    double x_d_origin;
    double x_increment;
    double x_origin;
    s32 x_units;
    s32 y_units;
    char date[16];
    char time[16];
    char frame[24];
    char label[16];
    double time_tags;
    u32 segment;
} [[static]];

struct DataHeader {
    u8 length;
    s16 data_type; 
    s16 bits_per_pixel;
    
    if (header.v_val == 3) {
        u64 buffer_length;
    } else {
        u32 buffer_length;
    }
} [[static]];

struct Waveform {
    WaveformHeader wave_header;
    DataHeader data_header;
    
    // Calculate sample count
    u32 sample_count = (data_header.data_type == 6) ? 
                        data_header.buffer_length : 
                        (data_header.buffer_length / 4);

    // This block parses the actual voltage/digital values
    if (data_header.data_type == 6) {
        u8 samples[sample_count] [[name("Digital Samples"), color("00FF00")]];
    } else {
        float samples[sample_count] [[name("Analog Samples"), color("00FFFF")]];
    }
} [[static]];

// Placement of the waveform array
Waveform waveforms[header.num_waveforms] @ $;