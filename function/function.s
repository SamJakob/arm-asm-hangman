/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

// C-style include guard to ensure file is only included once.
.ifndef libSJM_func_inc
.set libSJM_func_inc, 1

/*
    Macros to execute function prologue and epilogue based on the
    ARM calling convention.

    https://developer.arm.com/documentation/dui0040/d/using-the-procedure-call-standards/using-the-arm-procedure-call-standard/apcs-register-names-and-usage?lang=en
 */

.macro PROLOGUE
    PUSH {R4-R11, LR}   // Push the register state from before the function call.

    MOV R4, R0          // Copy passed arguments (R0-R3) into scratch registers.
    MOV R5, R1
    MOV R6, R2
    MOV R7, R3
.endm

.macro EPILOGUE
    POP {R4-R11, LR}    // Restore the original registers.
    BX LR               // Return to caller.
.endm

.endif
