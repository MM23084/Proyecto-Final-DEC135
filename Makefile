all: app

app: menu.o entrada_salida.o rectangulo.o triangulo.o
	ld -m elf_i386 -o app menu.o entrada_salida.o rectangulo.o triangulo.o

%.o: %.asm
	nasm -f elf32 -o $@ $<

clean:
	rm -f *.o app