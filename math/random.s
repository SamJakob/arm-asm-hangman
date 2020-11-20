/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
*/

.include "function/syscall.s"
.include "math/division.s"

.extern random
.extern srand
.extern time

// Called once to seed the program's random number generator.
.macro seedRNG
    MOV R0, #0
    
    BL time
    MOV R1, R0              // get the current time and move it into R1 for future use.
    SYSCALL $sys_getpid     // now get the current process ID and load it into R0 for added entropy.
    MUL R0, R1, R0          // seed = <time> * <pid>

    BL srand
.endm

// An alias to call the randomNumber function.
.macro randomNumber max:req
    PUSH {R4}
    MOV R4, \max

    BL rand
    modulo R0, R4
    POP {R4}
.endm
