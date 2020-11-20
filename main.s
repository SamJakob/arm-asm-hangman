/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

.text
.include "function/function.s"
.include "function/syscall.s"

.include "io/utils.s"
.include "io/stdio.s"
.include "io/file.s"

.include "math/random.s"

.include "utils.s"
.include "hangman.s"

.extern sprintf
.extern malloc
.extern free

.text
.global main
main:
    /* SETUP */

    // Initialize registers.
    MOV R0, #0
    MOV R1, #0
    MOV R2, #0
    MOV R3, #0

    // Print loading message.
    print loading_str, loading_str_size

    // Seed the random number generator.
    seedRNG

    initialize:
        // 1. Determine the size of the word file.
            // Stat the word list so we can obtain the file size.
            LDR R0, =wordListFileName
            BL getFileSize

            // Extract the word list file size from the struct and, if it's valid,
            // save it into wordListFileSize.
            
                // -> Ensure the file does not exceed 128 MiB.
                MOV R1, #134217728
                CMP R0, R1
                BGT end_ERR_WLSZ_MAX
            
                // -> Ensure the file is not missing or empty.
                MOV R1, #0
                CMP R0, R1
                BEQ end_ERR_WLSZ_EMPT

            // Now, save R0 in wordListFileSize for later use.
            LDR R1, =wordListFileSize
            STR R0, [R1]

        // 2. Load the word list into memory.
            // Call malloc to allocate memory for the word list.
            // (required size of memory block is in R0)
            BL malloc               // Call malloc to allocate memory for that file.
            LDR R6, =wordListFileBase
            STR R0, [R6]
            MOV R6, R0              // Copy the address of the allocated memory to R6.

            // Call open to get a file descriptor for the words file.
            LDR R0, =wordListFileName
            MOV R1, #0
            MOV R2, #0
            SYSCALL $sys_open
            MOV R5, R0              // Copy the file descriptor to R5.

            // Read the file into the allocated memory.
            // R0                           = file descriptor
            MOV R1, R6                  //  = memory address
            LDR R2, =wordListFileSize
            LDR R2, [R2]                //  = amount of bytes to read.
            SYSCALL $sys_read

        // 3. Count the number of words in the file.
            LDR R0, =wordListFileBase
            LDR R0, [R0]
            MOV R1, R2
            BL countWords
        
        // 4. Save the number of words in the word list.
            LDR R1, =wordListCount
            STR R0, [R1]
        
        // 5. Clean up.
            // We're done with the file on disk, so we can close the file descriptor.
            // The file in memory is retained for the next word selection.
            MOV R0, R5
            SYSCALL $sys_close

    /* GAME */
    game:
        // Reload the app state. (R6)
        LDR R6, =appState
        LDR R6, [R6]

        // Reset number of remaining moves. (R5)
        BL resetInitGallows
        MOV R5, #6

        // Select the word to use.
        LDR R7, =randomWordBase
        LDR R8, =randomWordSize
        BL selectRandomWord
        STR R0, [R7]
        STR R1, [R8]

        // Check the 'welcome message shown' bit in the app state...
        AND R1, R6, #1
        CMP R1, #1
        BEQ game_ready      // If it's equal to 1, skip the welcome message.

        game_showWelcomeMessage:
            // Show the welcome message.
            print welcome_str, welcome_str_size

            // Set the welcome message shown bit to 1.
            ORR R6, R6, #1
            LDR R0, =appState
            STR R6, [R0]

        game_ready:

            // Start the user's turn loop.
            game_turn:
                print ansi_SAVE, ansi_SAVE_size

                // Check whether the user has moves left or if they've won the game.
                // Additionally print the gallows, misses and word.
                game_checkShowState:
                    // Print the game state underlay.
                    MOV R0, R5                  // number of moves left
                    LDR R1, =randomWordBase     // selected word base address
                    LDR R1, [R1]
                    LDR R2, =randomWordSize     
                    LDR R2, [R2]                // selected word size
                    LDR R3, =guessedLetters     // guessed letters
                    BL printUnderlay

                    // Now restore and print the gallows. (the first parameter is the number of moves left)
                    print ansi_RESTORE, ansi_RESTORE_size
                    MOV R0, R5
                    BL printGallows

                    print ansi_CLEARLN, ansi_CLEARLN_size

                    CMP R5, #0
                    BEQ game_end_loss

                // Read the user's next guess.
                print           prompt_str, prompt_str_size
                BL readGuess

                // Check if the user guessed 0.
                // If so, we end the game.
                print ansi_RESTORE, ansi_RESTORE_size
                ifMemCharEqual memChar=guess, char=#0x30, jmpIfEqual=end

                // Otherwise we'll update the game start accordingly.
                SUB R5, R5, #1

                B game_turn
            
            // The end of the game.
            // R0 - endgame status (#0=fail, #1=success)
            game_end:
                CMP R0, #0
                BNE game_end_success

                game_end_loss:
                    print loss_str, loss_str_size
                    B play_again_prompt

                game_end_success:
                    print win_str, win_str_size
                    B play_again_prompt
                
            play_again_prompt:
                print           play_again_str, play_again_str_size
                
                // Check if the user wants to play again.
                BL readGuess
                ifMemCharEqual memChar=guess, char=#89, jmpIfEqual=restartGame

                // If not, simply end.
                print ansi_RESTORE, ansi_RESTORE_size
                print newlines, #3

end:
    // Free the memory for our file.
    LDR R0, =wordListFileBase
    LDR R0, [R0]
    BL free

    // Print thank you message
    print thanks_for_playing_str, thanks_for_playing_str_size

    // Set exit code to 0 (normal exit.)
    MOV R0, #0  // exit code:       0
    SYSCALL $sys_exit

end_ERR_WLSZ_EMPT:
    printErr        wordListMissingEmpty_str, wordListMissingEmpty_str_size

    // Set exit code to 1 (error: ERR_WLSZ_EMPT - word list size empty or missing)
    MOV R0, #1  // exit code:       1
    SYSCALL $sys_exit

end_ERR_WLSZ_MAX:
    printErr        wordListSizeExceedMax_str, wordListSizeExceedMax_str_size

    // Set exit code to 2 (error: ERR_WLSZ_MAX - word list size exceed max)
    MOV R0, #2  // exit code:       2
    SYSCALL $sys_exit

restartGame:
    print ansi_RESTORE, ansi_RESTORE_size
    print ansi_CLEAR, ansi_CLEAR_size
    B game

end_ERR_OVERFLOW:
    // Free the memory for the words list (but only if it's loaded).
    LDR R0, =wordListFileBase
    LDR R0, [R0]
    CMP R0, #0
    BLEQ free

    printErr        overflowError_str, overflowError_str_size

    // Set exit code to 3 (error: ERR_OVERFLOW - overflow or safety error)
    MOV R0, #3  // exit code:       3
    SYSCALL $sys_exit

.bss
.align 4
// A single byte reserved for the user's guess.
guess:                          .space 1
// An array of the user's already guessed letters.
guessedLetters:                 .space 26

.align 4
// Space in memory reserved for the size and address
// of the random word.
randomWordSize:                 .word 0
randomWordBase:                 .word 0

.data
.align 4
// State
/*
    appState: [00000000_00000000_00000000_0000000, 0]
                                                   ^
                                                   |- Whether or not the welcome message has been displayed.
*/
appState:                      .word 0

// Files
wordListFileName:               .string "dictionary.txt"
.align 4
wordListFileSize:               .word 0
wordListFileBase:               .word 0 // memory address of the base of the loaded words list.
wordListCount:                  .word 0 // the number of words in the words list.

// Strings
newlines:                        .string "\n\n\n\n\n\n\n\n\n\n"

loading_str:                    .string "Loading...\r"
loading_str_size=               .-loading_str

welcome_str:
.ascii "\033[2J                                                  \n"
.ascii "                                                  \n"
.ascii "     /\\  /\\__ _ _ __   __ _ _ __ ___   __ _ _ __  \n"
.ascii "    / /_/ / _` | '_ \\ / _` | '_ ` _ \\ / _` | '_ \\ \n"
.ascii "   / __  / (_| | | | | (_| | | | | | | (_| | | | |\n"
.ascii "   \\/ /_/ \\__,_|_| |_|\\__, |_| |_| |_|\\__,_|_| |_|\n"
.ascii "                      |___/                       \n"
.ascii "\n"
.ascii "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\n"
.ascii "\n"
.ascii "Welcome to Hangman!\n"
.ascii "Developed by Sam Jakob Mearns\n"
.ascii "\n"
.ascii "• Follow the on-screen prompts to play the game or type 0 (zero)\n"
.ascii "  at any of the prompts to exit the game.\n"
.ascii "\n"
.ascii "• Good luck!\n"
.ascii "\n"
.ascii "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\n"
.asciz "\n"
welcome_str_size=               .-welcome_str

prompt_str:                     .string "Enter next character (A-Z) or 0 (zero) to exit ⇾ "
prompt_str_size=                .-prompt_str

loss_str:                       .string "You lost :(\nYou ran out of moves!"
loss_str_size=                  .-loss_str

win_str:                        .string "You win! :)\nCongratulations!"
win_str_size=                   .-win_str

play_again_str:                 .string "\n\nWould you like to play again? (y/N) ⇾ "
play_again_str_size=            .-play_again_str

thanks_for_playing_str:
.ascii "\n\n\n\n\n\n\n\n\n\n\n"
.ascii "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\n"
.ascii "\n"
.ascii "Hangman\n"
.ascii "Developed by Sam Jakob Mearns\n"
.ascii "\n"
.asciz "\nThank you for playing :)\n"
thanks_for_playing_str_size=    .-thanks_for_playing_str

// ANSI Commands
ansi_SAVE:                      .string "\033[s"    // ANSI command to save cursor pos.
ansi_SAVE_size=                 .-ansi_SAVE

ansi_RESTORE:                   .string "\033[u"    // ANSI command to restore cursor pos.
ansi_RESTORE_size=              .-ansi_RESTORE

ansi_CLEARLN:                   .string "\033[K"  // ANSI command to clear current line.
ansi_CLEARLN_size=              .-ansi_CLEARLN

ansi_CLEAR:                     .string "\033[2J"  // ANSI command to clear current line.
ansi_CLEAR_size=                .-ansi_CLEAR

// Errors
wordListSizeExceedMax_str:      .string "\033[1;31m\033[1m(!) ERROR: The word list file (dictionary.txt) is too big. It may not exceed 128 MiB.\033[0m\n"
wordListSizeExceedMax_str_size= .-wordListSizeExceedMax_str

wordListMissingEmpty_str:       .string "\033[1;31m\033[1m(!) ERROR: The words list file (dictionary.txt) is missing or empty. Please create words.txt and add some words.\033[0m\n"
wordListMissingEmpty_str_size=  .-wordListMissingEmpty_str

overflowError_str:              .string "\033[1;31m\033[1m(!) ERROR: A problem occurred in the program which forced it to exit.\033[0m\n"
overflowError_str_size=         .-overflowError_str

// Debug
debug_str:                      .string "Hello world!\n"
debug_str_size=                 .-debug_str

.end
