/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

// C-style include guard to ensure file is only included once.
.ifndef libSJM_stdio_inc
.set libSJM_stdio_inc, 1

//// @PRIVATE                   *** not expected to be used externally.
.bss
_stdio_flushInput_buf:        .space 1

.text
.macro _stdio_read data, dataSize
    PUSH {R0, R1, R2, R7}
    MOV R0, #0          // read from:   standard input
    LDR R1, =\data      // arg1 (%r1):  char* buf
    LDR R2, =\dataSize  // arg2 (%r2):  size_t count
    SYSCALL $sys_read
    POP {R0, R1, R2, R7}
.endm

/**
 * A function to flush the input buffer by reading characters until a newline is reached.
 * This is used if the user enters more characters than expected, to ensure that the standard
 * input stream is clear for the next time a call is made.
 */
_stdio_flushInput:
    PROLOGUE

    _stdio_flushInput_start:
        _stdio_read _stdio_flushInput_buf, #1
        ifMemCharEqual _stdio_flushInput_buf, 0x0A, _stdio_flushInput_complete
        B _stdio_flushInput_start
    _stdio_flushInput_complete:

    EPILOGUE

//// @PUBLIC                    *** the public API that this file exposes.

/**
 * Prints (strSize) bytes from memory starting at (str) to standard output
 * using the Linux write syscall.
 *
 * @param [size_t] str          *** The starting memory address from which to begin writing.
 * @param [size_t] strSize      *** The number of bytes to write to standard output.
 */
.macro print str, strSize
    PUSH {R0, R1, R2, R7}
    MOV R0, #1          // write to:    standard output
    LDR R1, =\str       // arg1 (%r1):  const char* buf
    LDR R2, =\strSize   // arg2 (%r2):  size_t count
    SYSCALL $sys_write
    POP {R0, R1, R2, R7}
.endm

/**
 * Identical to print, however prints to standard error instead of standard output.
 *
 * @see print
 */
.macro printErr str, strSize
    PUSH {R0, R1, R2, R7}
    MOV R0, #2          // write to:    standard error
    LDR R1, =\str       // arg1 (%r1):  const char* buf
    LDR R2, =\strSize   // arg2 (%r2):  size_t count
    SYSCALL $sys_write
    POP {R0, R1, R2, R7}
.endm

/**
 * Reads (dataSize) bytes from standard input, and places it in to the memory
 * buffer starting at (data).
 *
 * @param [size_t] data         *** The starting memory address to begin writing to.
 * @param [size_t] dataSize     *** The number of bytes to read from standard input.
 */
.macro read data, dataSize
    _stdio_read \data, \dataSize
.endm

.macro readChar data
    // Read a single byte from standard input into the response.
    read \data, #1

    PUSH {R1}
    // Check if (data) contains a newline, if so we exit immediately.
    LDR R1, =\data
    LDRB R1, [R1]
    CMP R1, #0x0A
    POP {R1}
    BEQ inputFlushed\@

    // Now flush standard input.
    BL _stdio_flushInput

    inputFlushed\@:
.endm

.endif
