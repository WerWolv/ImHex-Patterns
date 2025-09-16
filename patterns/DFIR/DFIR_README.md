ImHex Pattern Files - Digital Forensics:
  - [ImHex-DFIR-Patterns](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns)

Enhanced features of the stock Disk/Filesystem pattern files for forensic review of disk content.
  - [ImHex](https://github.com/WerWolv/ImHex)
  - [ImHex Patterns](https://github.com/WerWolv/ImHex-Patterns)

Install:
  - Create a new folder called "DFIR"
  - Add these updated pattern files to "DFIR"
[Folder_Structure (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/1-Folder_Structure.png)

Use:
  - Open a physical disk via Raw Provider (read-only)
      - EXAMPLE: /dev/disk6
  - Import Pattern File
      - EXAMPLE: DISK_PARSER.hexpat
  - [Pattern_Selection (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/2-DISK_PARSER-Pattern.png)

  - DISK_PARSER.hexpat
      - Recognize MBR/GPT Disks and parse MPT/GPT
        - Including Logical Volumes in an Extended Partition (container) 
      - Auto load file system patterns for FAT32, exFAT, NTFS formatted volumes
      - Optional Disk Report

  - [DISK > MBR/GPT (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/3-DISK-HYBRID.png)
  - [DISK > MBR > MPT > 3 Primaries | 2 Logicals in an Extended (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/3a-DISK-MBR.png)
    
  - FAT32.hexpat
      - Auto loaded by DISK_PARSER.hexpat
      - Parse VBR, FAT1, FAT2, Root Dir, and 1 level of SubDirs
      - FAT1/FAT2 Cluster chaining with SFN resolution
      - LFN/SFN Alias grouping in Root Dir
      - Recognize deleted entries (xE5)
      - File Content pointer
      - D/T Conversions
      - Optional FAT32 Volume Report

  - [VOLUME > FAT32 > FAT1 (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/4-FAT32-1_SMALL_TXT.png)
  - [VOLUME > FAT32 > Root Dir (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/5-FAT32_ROOT_DIR.png)
  - [VOLUME > FAT32 > Data Pointer (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/6-FAT32_SFN_POINTER.png)

  - exFAT.hexpat
      - Auto loaded by DISK_PARSER.hexpat
      - Parse VBR/Boot Sector/Extended Sectors, FAT1, Root Dir
      - Recognize active directory entries (x85, xC0, xC1)
      - Recognize inactive directory entries (x05, x40, x41)
      - xC0/x40 File Content pointer
      - D/T Conversions
      - Optional exFAT Volume Report

  - [VOLUME > exFAT (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/7-exFAT-1.png)
  - [VOLUME > exFAT > Root Dir > xC0 (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/8-exFAT_xC0.png)
  - [VOLUME > exFAT > Data Pointer (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/9-exFAT-Data_Pointer.png)
  
   - NTFS.hexpat
      - Auto loaded by DISK_PARSER.hexpat
      - Parse VBR (Boot Sector), $MFT, Root Dir, and Indexes
      - Recursively parse the $Metadata files, $Attributes, and user files/dirs
          - Added file record | parent [MFT#] [SEQ#] indicators
      - Parse x80/xB0 Data Runs
      - File Content pointer
      - D/T Conversions
      - Optional NTFS Volume Report

  - [VOLUME > NTFS > $MFT > D/T Conversion (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/10-NTFS-DT.png)
  - [VOLUME > NTFS > $MFT > x80 Run List (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/11-NTFS-DATA_RUN.png)
  - [VOLUME > NTFS > Data Pointer (screenshot)](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/screenshots/12-NTFS-DATA_POINTER.png)

  - Optional Reports
    - Simply copy the console output to a file...

    - To enable/disable the reports:
      - Open each DFIR related .hexpat
      - Find the report constant (near the top)
        - "true" = enabled
        - "false" = disabled

  Example Report: GPT > FAT32|exFAT
  - [exFAT_Report](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/reports/exFAT_Report.txt)
  
  Example Report: MBR > 5 Logical Volumes (2 in an Extended) > All FAT32 Volumes
  - [MBR_5_VOLs](https://github.com/Xtreme-Liberty/ImHex-DFIR-Patterns/blob/main/reports/MBR_5_VOLs.txt)


