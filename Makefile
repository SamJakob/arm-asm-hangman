# Hangman
# Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved

OUTPUT_DIR	= ./build
TARGET		= $(OUTPUT_DIR)/main

run: all
	$(TARGET)

all: main.o
	gcc -s -o $(TARGET) $(OUTPUT_DIR)/$<

debug: main.o
	gcc -g -o $(TARGET) $(OUTPUT_DIR)/$<
	gdb $(TARGET)

main.o: main.s
	as -g -o $(OUTPUT_DIR)/$@ $<

.PHONY: clean
clean:
	-rm $(OUTPUT_DIR)
	mkdir $(OUTPUT_DIR)
