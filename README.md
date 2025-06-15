# Cálculo de Áreas en Ensamblador (NASM)

Este es un pequeño **programa en ensamblador (NASM)** destinado a ejecutar en **arquitectura de 32 bits (x86)** en Linux.  
El procedimiento proporciona un **menú** en la terminal para que el usuario elija:

- Calcular el área de un rectángulo.
- Calcular el área de un triángulo.
- Salir del programa.

## Requisitos

- **NASM** instalado.
- Un **sistema Linux de 32 bits o multilib habilitado en 64 bits**.
- **ld** (el Linker de GNU).

## Compilado y ejecución

Ensambla el código:

```bash
nasm -f elf32 calculoAreas.asm
```

Enlaza el objeto:

```bash
gcc -m32 -no-pie -nostartfiles calculoAreas.o -o calculoAreas -lc
```

Finalmente, ejecutar:

```bash
./calculoAreas
```