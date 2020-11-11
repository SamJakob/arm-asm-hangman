# Hangman
# Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved

OUTPUT_DIR	= ./build
TARGET		= $(OUTPUT_DIR)/main

run: all
	$(TARGET)

all: main.o
	gcc -o $(TARGET) $(OUTPUT_DIR)/$<

main.o: main.s
	as -o $(OUTPUT_DIR)/$@ $<

.PHONY: clean
clean:
	-rm $(OUTPUT_DIR)
	mkdir $(OUTPUT_DIR)
