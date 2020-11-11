/**
    stdio.s - a part of Hangman by Sam Jakob Mearns.
    
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved

    **

    Depends on:
    - utils.s
    - stdio.s
 */

.macro readGuess guess
    PUSH {R0, R1}
    readChar \guess

    LDR R1, =\guess
    LDRB R1, [R1]

    // if (!(guess >= 97 && guess <= 122)) then jmp: capitalOrInvalid
    CMP R1, #97
    BLT capitalOrInvalid\@
    CMP R1, #122
    BGT capitalOrInvalid\@

    // else subtract 32 to get uppercase ASCII:
    SUB R1, R1, #32

    // and write back into guess.
    LDR R0, =\guess
    STR R1, [R0]

    capitalOrInvalid\@:
    POP {R0, R1}
.endm
