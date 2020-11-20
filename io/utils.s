/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

// C-style include guard to ensure file is only included once.
.ifndef libSJM_ioutils_inc
.set libSJM_ioutils_inc, 1

/**
 * Compares guess and char and jumps to jmpIfEqual if they are equal.
 *
 * @param [size_t] memChar          *** The memory location of the character to check.
 * @param [uint8_t] char            *** The character to check.
 * @param [size_t] jmpIfEqual       *** The address (or label) to jump to if the characters are equal.
 */
.macro ifMemCharEqual memChar:req, char:req, jmpIfEqual:req
PUSH {R1, R2}
// Load the first byte of the buffer into R1.
LDR R1, =\memChar
LDRB R1, [R1]
// Load (char) into R2.
LDR R2, =\char
// Compare them and branch if they're equal, otherwise
// continue execution.
CMP R1, R2
POP {R1, R2}
BEQ \jmpIfEqual
.endm

.endif
