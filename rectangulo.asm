section .data
    msg_largo db "Ingrese largo: ", 0
    msg_ancho db "Ingrese ancho: ", 0
    msg_resultado db "El área del rectángulo es: ",0
    buffer times 16 db 0 ; Buffer para leer la cadena ASCII de entrada

section .bss
    largo resd 1
    ancho resd 1

section .text
    global calcular_rectangulo
    extern imprimir_cadena, leer_entrada, leer_entero, mostrar_resultado
    extern resultado ; Variable global definida en entrada_salida.asm

calcular_rectangulo:
    push msg_largo
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)

    ; 1. Leer la cadena ASCII para el largo
    push buffer
    push byte 16 ; Cantidad máxima de bytes a leer (tamaño del buffer)
    call leer_entrada
    add esp, 8       ; Limpia 8 bytes (2 argumentos)

    ; 2. Convertir la cadena del buffer a un entero
    push buffer
    call leer_entero
    add esp, 4       ; Limpia 4 bytes (1 argumento)
    mov [largo], eax

    push msg_ancho
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)

    ; 1. Leer la cadena ASCII para el ancho
    push buffer
    push byte 16
    call leer_entrada
    add esp, 8       ; Limpia 8 bytes (2 argumentos)

    ; 2. Convertir la cadena del buffer a un entero
    push buffer
    call leer_entero
    add esp, 4       ; Limpia 4 bytes (1 argumento)
    mov [ancho], eax

    ; Calcular (largo * ancho)
    mov eax, [largo]
    mov ebx, [ancho]
    mul ebx

    ; Guardar el resultado en la variable global 'resultado' para que mostrar_resultado lo imprima
    mov [resultado], eax

    ; Mostrar el mensaje " El área del rectángulo es: "
    push msg_resultado
    call imprimir_cadena
    add esp, 4         ;LImpia 4bytes (1 argumento)

    ; Mostrar resultado
    call mostrar_resultado ; Esta función ya maneja su propia pila interna si es necesario.

    ret
