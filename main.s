/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */
 .text
.include "utils.s"
.include "stdio.s"
.include "random.s"

.include "hangman.s"

.extern malloc
.extern free

.text
.global main
main:
    // Initialize registers.
    MOV R0, #0

    // Stat the word list so we can obtain the file size.
    MOV R7, #106    // system call:     stat
    LDR R0, =wordListFileName
    LDR R1, =wordListFileStat
    SYSCALL

    // Extract the word list file size from the struct and, if it's valid,
    // save it into wordListFileSize.
    LDR R1, [R1, #20]       // size is a word (long), so load the next word at position 20 relative to the start of the stat struct.
    MOV R0, #134217728
    
    CMP R1, R0
    BGT end_ERR_WLSZ_MAX    // prevent the file from exceeding 128 MiB
    
    MOV R0, #0
    CMP R1, R0
    BEQ end_ERR_WLSZ_EMPT   // however, ensure the file is not missing or empty.

    LDR R0, =wordListFileSize
    STR R1, [R0]

    // Call malloc to allocate memory for the word list.
    LDR R0, [R0]            // Load the size of the file (from the memory address R0 is pointing to, which will be wordListFileSize)
    BL malloc               // Call malloc to allocate memory for that file.
    LDR R6, =wordListFileBase
    STR R0, [R6]
    MOV R6, R0              // Copy the address of the allocated memory to R6.

    // Call open to get a file descriptor for the words file.
    MOV R7, #5              // system call: open
    LDR R0, =wordListFileName
    MOV R1, #0
    MOV R2, #0
    SYSCALL
    MOV R5, R0              // Copy the file descriptor to R5.

    // Read the file into the allocated memory.
    MOV R7, #3              // system call: read
    MOV R0, R5
    MOV R1, R6
    LDR R2, =wordListFileSize
    LDR R2, [R2]
    SYSCALL

    // Now count the number of words in the file.
    //                      // R2 = size of file (from before).
    MOV R3, #0              // R3 = offset
    MOV R4, #0              // R4 = word counter

    wordCounter_start:
    CMP R3, R2
    BGE wordCounter_end

    LDRB R1, [R3, R6]
    CMP R1, #0x0A
    BEQ wordCounter_addWord
    B wordCounter_afterAddWord

    wordCounter_addWord:
    ADD R4, R4, #1
    
    wordCounter_afterAddWord:
    ADD R3, R3, #1
    B wordCounter_start
    wordCounter_end:

    // We now have the number of words entered into words.txt in R4.
    // It's time to select a random number.
    randomNumber #10
    // Our random number is now stored in R0.

    // NOTE: R5, R6 still off limits
    // R0 still contains the random word.

    // Select the word and determine its length.
    LDR R2, =wordListFileSize
    LDR R2, [R2]
    MOV R3, #0              // R3 = offset
    MOV R4, #0
    LDR R6, =wordListFileBase
    LDR R6, [R6]
    MOV R8, #0              // R8 = start of word
    MOV R9, #0              // R9 = end of word

    wordCounter2_start:
    CMP R4, R0
    BNE wordCounter2_noSetStart
    ADD R3, R3, #1
    MOV R8, R3
    ADD R8, R6, R8
    wordCounter2_noSetStart:

    CMP R3, R2
    BGT end_ERR_OVERFLOW

    LDRB R1, [R3, R6]
    CMP R1, #0x0A
    BEQ wordCounter2_addWord
    B wordCounter2_afterAddWord

    wordCounter2_addWord:
    CMP R4, R0
    BNE wordCounter2_noSetEnd
    MOV R9, R3
    ADD R9, R6, R9
    B wordCounter2_end
    wordCounter2_noSetEnd:
    ADD R4, R4, #1
    
    wordCounter2_afterAddWord:
    ADD R3, R3, #1
    B wordCounter2_start
    wordCounter2_end:

    // Allocate memory for the new word and save the size.

    

    // Now that we've selected and copied our word, we can free the
    // file descriptor and the allocated memory for the file.
    MOV R7, #6              // system call: close
    MOV R0, R5
    SYSCALL

    MOV R0, R6
    BL free                 // free the memory

    // Print the welcome message.
    print           welcome_str, welcome_str_size

    // Read the user's next guess.
    print           prompt_str, prompt_str_size
    readGuess       guess

    ifMemCharEqual  memChar=guess, char=#0x30, jmpIfEqual=end

    print           guess, #1

end:
    // Set exit code to 0 (normal exit.)
    MOV R7, #1  // system call:     set exit code
    MOV R0, #0  // exit code:       0
    SYSCALL
    JMP =.end

end_ERR_WLSZ_EMPT:
    printErr        wordListMissingEmpty_str, wordListMissingEmpty_str_size

    // Set exit code to 1 (error: ERR_WLSZ_EMPT - word list size empty or missing)
    MOV R7, #1  // system call:     set exit code
    MOV R0, #1  // exit code:       1
    SYSCALL
    JMP =.end

end_ERR_WLSZ_MAX:
    printErr        wordListSizeExceedMax_str, wordListSizeExceedMax_str_size

    // Set exit code to 2 (error: ERR_WLSZ_MAX - word list size exceed max)
    MOV R7, #1  // system call:     set exit code
    MOV R0, #2  // exit code:       2
    SYSCALL
    JMP =.end

end_ERR_OVERFLOW:
    printErr        overflowError_str, overflowError_str_size

    // Set exit code to 3 (error: ERR_OVERFLOW - overflow or safety error)
    MOV R7, #1  // system call:     set exit code
    MOV R0, #3  // exit code:       3
    SYSCALL
    JMP =.end

.bss
// A single byte reserved for the user's guess.
guess:                          .space 1

// Space in memory reserved for the size and address
// of the random word.
randomWordSize:                 .word 0
randomWordAddr:                 .word 0

.data
// Files
wordListFileName:               .string "words.txt"
wordListFileStat:               .space 64 // the size of a linux assembly stat is 64 bits (/arch/arm/include/uapi/asm/stat.h).
wordListFileSize:               .word 0
wordListFileBase:               .word 0 // base of the loaded file in memory.

// Strings
welcome_str:                    .string "Welcome to Hangman!\nDeveloped by Sam Jakob Mearns\n\nFollow the on-screen prompts to play the game or type 0 at any of the prompts to exit the game.\nGood luck!\n\n"
welcome_str_end:                .set welcome_str_size, welcome_str_end - welcome_str

prompt_str:                     .string "Enter next character (A-Z) or 0 (zero) to exit: "
prompt_str_end:                 .set prompt_str_size, prompt_str_end - prompt_str

// Errors
wordListSizeExceedMax_str:      .string "(!) ERROR: The word list is too big. It may not exceed 128 MiB.\n"
wordListSizeExceedMax_str_end:  .set wordListSizeExceedMax_str_size, wordListSizeExceedMax_str_end - wordListSizeExceedMax_str

wordListMissingEmpty_str:       .string "(!) ERROR: The word list file is missing or empty. Please create words.txt and add some words.\n"
wordListMissingEmpty_str_end:   .set wordListMissingEmpty_str_size, wordListMissingEmpty_str_end - wordListMissingEmpty_str

overflowError_str:              .string "(!) ERROR: A problem occurred in the program which forced it to exit.\n"
overflowError_str_end:          .set overflowError_str_size, overflowError_str_end - overflowError_str

// Debug
debug_str:                      .string "Hello world!\n"
debug_str_end:                  .set debug_str_size, debug_str_end - debug_str

.end
