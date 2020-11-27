# Hangman in ARM Assembly
A COM1031 Coursework assignment.

## Source Tree
```bash
┌ main.s            # Main program label and data.
├ hangman.s         # Contains hangman-related methods used to make 'main.s' more concise.
└ utils.s           # Contains additional util methods and macros not specific to Hangman.

├ function/
  ├ function.s      # Contains macros used to define functions.
  └ syscall.s       # Contains macros and symbols for system calls.
├ io/
  ├ file.s          # Used to get information from the OS about files.
  ├ stdio.s         # Used to read/write standard input.
  └ utils.s         # A collection of various helpful utilities.
├ math/
  ├ division.s      # Implementation of division on ARM using subtraction method.
  └ random.s        # Used for generating random numbers.

├ dictionary.txt    # Contains the wordlist for the game.

├ Makefile          # Contains the make directives to build the program.
└ build/            # Compiled build output.
  ├ *.o                 # ...compiled object files.
  └ *                   # ...compiled executable binaries.
```

## Build Setup
```bash
# Set up directory structure.
$ make clean

# Run a build.
$ make

# Run a (debug) build and inspect it with GDB.
$ make debug
```

## Dictionary
- Maximum size of the dictionary file is 128MiB.
- Minimum number of words is 1.
- Words may be any length, however words of length greater than 30 are untested (and will most likely not show up correctly, graphically speaking).