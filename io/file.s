/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

// C-style include guard to ensure file is only included once.
.ifndef libSJM_fileio_inc
.set libSJM_fileio_inc, 1

.text
getFileSize:
    PROLOGUE
    // R0 = file name

    LDR R1, =stat_result // The space in memory for the stat response.
    SYSCALL $sys_stat

    // Load R1 + (offset = 20) into the output register.
    LDR R0, [R1, #20]

    EPILOGUE

.bss
.align 4
/*
From: /usr/include/arm-linux-gnueabihf/asm/stat.h
**
struct __old_kernel_stat {
        unsigned short st_dev;
        unsigned short st_ino;
        unsigned short st_mode;
        unsigned short st_nlink;
        unsigned short st_uid;
        unsigned short st_gid;
        unsigned short st_rdev;
        unsigned long  st_size;
        unsigned long  st_atime;
        unsigned long  st_mtime;
        unsigned long  st_ctime;
};
*/
stat_result:               .space 64 // the size of the stat structure is 64 bytes.

.text
.endif
