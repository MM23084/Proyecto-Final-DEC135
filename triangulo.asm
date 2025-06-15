section .data
    msg_base db "Ingrese la base: ",0
    msg_altura db "Ingrese la altura: ",0
    msg_resultado db "El área del triangulo es: ",0

section .bss
    buffer resb 16 ; Buffer para leer la cadena ASCII de entrada
    base resd 1
    altura resd 1

section .text
    global calcular_triangulo
    extern leer_entrada, leer_entero, imprimir_cadena, mostrar_resultado
    extern resultado ; Variable global definida en entrada_salida.asm

calcular_triangulo:
    ; Leer base
    push msg_base
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)

    ; 1. Leer la cadena ASCII para la base
    push buffer
    push byte 16 ; Cantidad máxima de bytes a leer
    call leer_entrada
    add esp, 8       ; Limpia 8 bytes (2 argumentos)

    ; 2. Convertir la cadena del buffer a un entero
    push buffer
    call leer_entero
    add esp, 4       ; Limpia 4 bytes (1 argumento)
    mov [base], eax

    ; Leer altura
    push msg_altura
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)

    ; 1. Leer la cadena ASCII para la altura
    push buffer
    push byte 16
    call leer_entrada
    add esp, 8       ; Limpia 8 bytes (2 argumentos)

    ; 2. Convertir la cadena del buffer a un entero
    push buffer
    call leer_entero
    add esp, 4       ; Limpia 4 bytes (1 argumento)
    mov [altura], eax

    ; Calcular (base * altura) / 2
    mov eax, [base]
    imul eax, [altura]
    mov ebx, 2
    xor edx, edx
    div ebx

    ; Guardar el resultado en la variable global 'resultado' para que mostrar_resultado la imprima
    mov [resultado], eax

    ; Mostrar el mensaje "El área del triangulo es: "
    push msg_resultado
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)

    ; Mostrar el resultado
    call mostrar_resultado ; Esta función ya maneja su propia pila interna si es necesario.

    ret
