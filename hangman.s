/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

.include "io/utils.s"
.include "io/stdio.s"

/**
 * Counts the number of words in the file.
 *
 * @param R0, The base address of the file's buffer in memory.
 * @param R1, The size of the allocated memory buffer.
 */
.text
countWords:
    PROLOGUE
                        // R4 = the buffer base address.
                        // R5 = the size of the file.

    MOV R6, #0          // R6 = current (working) offset.
    MOV R7, #0          // R7 = word counter.

    countWordsLoop_start:
        // If the end of the file has been reached,
        // jump to the end of the loop.
        CMP R6, R5
        BGT countWordsLoop_end

        // Load the character stored at [base address + offset] in memory,
        // into R1.
        LDRB R1, [R4, R6]
        
        // If the current character is a newline, increment the word count.
        CMP R1, #0x0A
        ADDEQ R7, R7, #1

        // Increment the current offset and continue.
        ADD R6, R6, #1 
        B countWordsLoop_start // return to the start of the loop.
    countWordsLoop_end:

    SUB R7, R7, #1

    MOV R0, R7 // return the word count.
    EPILOGUE

selectRandomWord:
    PROLOGUE

    // Select a random word.
    LDR R0, =wordListCount
    LDR R0, [R0]

    randomNumber R0
    MOV R9, R0

    // Get the base address (R0) and size (R1) of the word.
    LDR R1, =wordListFileBase
    LDR R1, [R1]
    LDR R2, =wordListFileSize
    LDR R2, [R2]
    BL locateWord

    EPILOGUE

locateWord:
    PROLOGUE
    // R4 = word index
    // R5 = the buffer base address
    // R6 = the size of the file.

    MOV R7, #0          // R7 = current (working) offset.
    MOV R8, #0          // R8 = word counter.
    MOV R9, #0          // R9 = start/end of word?

    MOV R0, #0          // R0 = word base address
    MOV R1, #0          // R1 = word size

    // If the word index is 0, set R9 to 1 (looking for end)
    // and set R0 to R5.
    CMP R4, #0
    MOVEQ R0, R5
    MOVEQ R9, #1
    SUBEQ R8, R8, #1

    locateWordLoop_start:
        // If the end of the file has been reached,
        // jump to the end of the loop.
        CMP R7, R6
        MOVEQ R1, R5
        ADDEQ R1, R6, R1
        BEQ locateWordLoop_end

        // Load the character stored at [base address + offset] in memory,
        // into R1.
        LDRB R2, [R5, R7]

        // Keep looking for a word (i.e. until a newline is reached.)
        CMP R2, #0x0A
        BNE locateWordLoop_keepLookingForWord

        // Word was found. Increment the word counter.
        ADDEQ R8, R8, #1

        // Now compare the word counter to the desired word index,
        // if it's equal:
        CMP R8, R4
        SUBEQ R8, R8, #1
        BNE locateWordLoop_keepLookingForWord

        CMP R9, #0
            // if R9 is 0, it's the start of the word,
            // so set R9 to 1, R0 to [base + offset] and continue.
            MOVEQ R9, #1
            MOVEQ R0, R5        // R0 = base
            ADDEQ R0, R0, R7    // R0 += working offset
            ADDEQ R0, R0, #1    // R0 += 1 (first char rather than newline)

            // if R9 is 1, it's the end of the word,
            // so store the end address and exit.
            MOVNE R1, R5        // R1 = base
            ADDNE R1, R1, R7    // R1 += working offset
            BNE locateWordLoop_end

        locateWordLoop_keepLookingForWord:
            // Increment the working offset and continue.
            ADD R7, R7, #1
            B locateWordLoop_start
    
    locateWordLoop_end:
        // Subtract the word end address (stored in R1 at this point), from
        // the word base address and save the value in R1 to leave us with
        // the word's size.
        SUB R1, R1, R0

    EPILOGUE

/**
 * Reads the user's guess from standard input.
 *
 * Valid outputs: Uppercase ASCII character (65-90)
 *                 -or- NULL (0)
 */
readGuess:
    PROLOGUE

    readChar guess

    LDR R5, =guess
    LDRB R4, [R5]

    // if guess >= 97, subtract 32, essentially 'overlapping' uppercase
    // and lowercase letters.
    CMP R4, #97
    SUBGE R4, R4, #32
    STRGE R4, [R5]

    // We should now either have an uppercase ASCII character, or an
    // invalid value.
    BNR R4, #65, #90, readGuess_isInvalid
    B readGuess_isValid

    readGuess_isInvalid:
        // If the value is invalid, set R4 to 0, indicating
        // null byte (hence making the output value considered 'valid' again).
        MOV R4, #0

    readGuess_isValid:
        MOV R0, R4

    EPILOGUE

/**
 * To be called at the start of each game to reset the working
 * gallows buffer.
 */
resetInitGallows:
    PROLOGUE

    MOV R4, #0
    LDR R5, =gallows_str
    LDR R6, =gallows_working_buffer

    resetInitGallows_doCopy:
        LDR R4, [R5], #1
        STR R4, [R6], #1

        CMP R4, #0
        BNE resetInitGallows_doCopy

    EPILOGUE

printGallows:
    PROLOGUE
    // R4 = number of moves remaining

    .macro drawMoveStart moveNo:req
        CMP R4, #\moveNo
        BGT printGallows_drawMove\moveNo\()Skip
    .endm
    .macro drawMoveEnd moveNo:req
        printGallows_drawMove\moveNo\()Skip:
    .endm

    drawMoveStart 5
        MOV R5, #'0'
        LDR R6, =gallows_working_buffer
        STRB R5, [R6, #33]
    drawMoveEnd 5

    drawMoveStart 4
        MOV R5, #124
        LDR R6, =gallows_working_buffer
        STRB R5, [R6, #49]
        STRB R5, [R6, #65]
    drawMoveEnd 4

    drawMoveStart 3
        MOV R5, #'\\'
        LDR R6, =gallows_working_buffer
        STRB R5, [R6, #48]
    drawMoveEnd 3

    drawMoveStart 2
        MOV R5, #'/'
        LDR R6, =gallows_working_buffer
        STRB R5, [R6, #50]
    drawMoveEnd 2

    drawMoveStart 1
        MOV R5, #'/'
        LDR R6, =gallows_working_buffer
        STRB R5, [R6, #80]
    drawMoveEnd 1

    drawMoveStart 0
        MOV R5, #'\\'
        LDR R6, =gallows_working_buffer
        STRB R5, [R6, #82]
    drawMoveEnd 0

    readyForOutput:
        MOV R0, #1
        LDR R1, =gallows_working_buffer
        LDR R2, =gallows_str_size
        SYSCALL #sys_write

    EPILOGUE

printUnderlay:
    PROLOGUE
    // R4 = number of moves remaining
    // R5 = selected word base
    // R6 = selected word size
    // R7 = guessed letters

    MOV R10, #6 // = misses
    SUB R10, R10, R4

    print underlay_1, underlay_1_size

    LDR R0, =wordCountStr
    LDR R1, =intFormat
    MOV R2, R6
    BL sprintf
    print wordCountStr, #10

    print underlay_1_1, underlay_1_1_size

    // TODO: print word
    MOV R3, #0
    LDR R8, =underlay_blank

    printUnderlay_wordLoopStart:
        CMP R3, R6
        BGE printUnderlay_wordLoopEnd
        
        print underlay_blank, #2
        ADD R3, R3, #1

        B printUnderlay_wordLoopStart
    printUnderlay_wordLoopEnd:

    print underlay_2, underlay_2_size

    LDR R0, =missesCountStr
    LDR R1, =intFormat
    MOV R2, R10
    BL sprintf
    print missesCountStr, #10

    print underlay_2_1, underlay_2_1_size

    // TODO: print misses

    print underlay_3, underlay_3_size

    EPILOGUE

/**
 * Steps through the guessedLetters array until it reaches a null byte,
 * and adds the guess at that point.
 */
addGuess:
    PROLOGUE
    // R4 = guess char


    EPILOGUE

.data
.align 4
gallows_str:
.ascii "       ┌────┐\n"
.ascii "            │\n"
.ascii "            │\n"
.ascii "            │\n"
.ascii "            │\n"
.ascii "            │\n"
.ascii "            │\n"
.ascii "    ────────┘\n"
.asciz "\n"
gallows_str_size= .-gallows_str

.align 4
underlay_blank:         .ascii "_ "

.align 4
underlay_1:
.ascii "\n"
.ascii "\n"
.asciz "                    WORD ("
underlay_1_size= .-underlay_1

underlay_1_1:
.asciz "): "
underlay_1_1_size= .-underlay_1_1

underlay_2:
.ascii "\n"
.ascii "\n"
.asciz "                    MISSES ("
underlay_2_size = .-underlay_2

underlay_2_1:
.asciz "): "
underlay_2_1_size= .-underlay_2_1

underlay_3:
.ascii "\n"
.ascii "\n"
.ascii "\n"
.ascii "\n"
.asciz "\n"
underlay_3_size = .-underlay_3

intFormat: .string "%d"

wordCountStr: .space 10
missesCountStr: .space 10

.align 4
gallows_working_buffer: .space gallows_str_size
