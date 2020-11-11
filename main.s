/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

.include "utils.s"
.include "stdio.s"

.include "hangman.s"

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
    LDR R1, [R1, #20] // size is a word, so load the next word at position 20 relative to the start of the stat struct.
    MOV R0, #134217728  // prevent the file from exceeding 128 MiB
    CMP R1, R0
    BGT end_ERR_WLSZ_MAX
    
    LDR R0, =wordListFileSize
    STR R1, [R0]

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

end_ERR_WLSZ_MAX:
    printErr        wordListSizeExceedMax_str, wordListSizeExceedMax_str_size

    // Set exit code to 1 (error: ERR_WLSZ_MAX - word list size exceed max)
    MOV R7, #1  // system call:     set exit code
    MOV R0, #1  // exit code:       1
    SYSCALL
    JMP =.end

.bss
// A single byte reserved for the user's guess.
guess:                          .space 1

.data
// Files
wordListFileName:               .string "words.txt"
wordListFileStat:               .space 64 // the size of a linux assembly stat is 64 bits (/arch/arm/include/uapi/asm/stat.h).
wordListFileSize:               .word 0

// Strings
welcome_str:                    .string "Welcome to Hangman!\nDeveloped by Sam Jakob Mearns\n\nFollow the on-screen prompts to play the game or type 0 at any of the prompts to exit the game.\nGood luck!\n\n"
welcome_str_end:                .set welcome_str_size, welcome_str_end - welcome_str

prompt_str:                     .string "Enter next character (A-Z) or 0 (zero) to exit: "
prompt_str_end:                 .set prompt_str_size, prompt_str_end - prompt_str

// Errors
wordListSizeExceedMax_str:      .string "ERROR: The word list is too big. It may not exceed 128 MiB.\n"
wordListSizeExceedMax_str_end:  .set wordListSizeExceedMax_str_size, wordListSizeExceedMax_str_end - wordListSizeExceedMax_str

// Debug
debug_str:                      .string "Hello world!\n"
debug_str_end:                  .set debug_str_size, debug_str_end - debug_str

.end
