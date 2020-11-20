/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

// C-style include guard to ensure file is only included once.
.ifndef libSJM_syscall_inc
.set libSJM_syscall_inc, 1

// Using values from: https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm-32_bit_EABI
.set sys_exit, 1
.set sys_read, 3
.set sys_write, 4
.set sys_open, 5
.set sys_close, 6
.set sys_getpid, 39
.set sys_stat, 106

.macro SYSCALL syscallNumber:req
MOV R7, \syscallNumber
SVC #0
.endm

.endif
