section .data
    mensaje_bienvenida db "Bienvenido al sistema para el cálculo de áreas de forma geométricas:", 10, 0
    opciones_menu db "1. Area Rectangulo", 10, "2. Area Triangulo", 10, "3. Salir", 10, "Seleccione una opcion: ", 0
    msg_error db "Opcion no valida.", 10, 0

section .bss
    opcion resb 2 ; Buffer para leer la opción del usuario (1 caracter + '\n' o '\0')

section .text
    global _start
    extern calcular_rectangulo, calcular_triangulo
    extern leer_entrada, imprimir_cadena, imprimir_nueva_linea

_start:
menu:
    push mensaje_bienvenida
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)

    push opciones_menu
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)

    push opcion      ; Argumento 1: Dirección del buffer
    push byte 2      ; Argumento 2: Longitud
    call leer_entrada
    add esp, 8       ; Limpia 8 bytes (2 argumentos)

    cmp byte [opcion], '1'
    je rectangulo
    cmp byte [opcion], '2'
    je triangulo
    cmp byte [opcion], '3'
    je salir

    push msg_error
    call imprimir_cadena
    add esp, 4       ; Limpia 4 bytes (1 argumento)
    call imprimir_nueva_linea ; Esta función ya limpia sus propios argumentos si tiene (en este caso no tiene pushes directos)
                              ; La he ajustado para que imprima una nueva línea con una llamada interna a imprimir_cadena que si limpia.
    jmp menu

rectangulo:
    call calcular_rectangulo
    jmp menu

triangulo:
    call calcular_triangulo
    jmp menu

salir:
    mov eax, 1
    xor ebx, ebx
    int 0x80
