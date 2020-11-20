/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
*/

// C-style include guard to ensure file is only included once.
.ifndef libSJM_math_div_inc
.set libSJM_math_div_inc, 1
.text

/**
 * Performs division given a numerator (R0) and denominator (R1).
 * The quotient is returned in R0 and the remainder in R1.
 */
divide:
    PROLOGUE
    // R4 = N (numerator)
    // R5 = D (denominator)
    
    MOV R6, #0              // Q = 0

    div_start:
        CMP R4, R5
        BLT div_complete
        ADD R6, R6, #1      // Q + Q + 1
        SUB R4, R4, R5      // N = N - D
        B div_start

    div_complete:
        MOV R0, R6          // R0 contains Q (quotient) from R6
        MOV R1, R4          // R1 contains R (remainder) from R4

    EPILOGUE

// An alias to call the divide function.
.macro divide numerator:req, denominator:req
    MOV R0, \numerator
    MOV R1, \denominator
    BL divide
.endm

// An alias for divide, however it moves the remainder into
// R0 for semantic 'correctness'.
.macro modulo numerator:req, denominator:req
    divide \numerator, \denominator
    MOV R0, R1
.endm

.endif
