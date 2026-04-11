CC = gcc
ASM = nasm
FLAGS_C = -g -no-pie
FLAGS_NASM = -f elf64 -g -F dwarf

TARGET = exe/test
OBJ = build/cprog.o build/my_printf.o

$(TARGET): $(OBJ)
	$(CC) $(FLAGS_C) $(OBJ) -o $(TARGET)

build/my_printf.o: src/my_printf.nasm
	$(ASM)  $(FLAGS_NASM) src/my_printf.nasm -o build/my_printf.o

build/cprog.o: src/cprog.c
	$(CC) -c src/cprog.c -o build/cprog.o

clean:
	rm -f $(OBJ) $(TARGET)