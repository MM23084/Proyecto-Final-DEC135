section .data
    ; Mensaje de bienvenida
    mensaje_bienvenida db "Bienvenido al sistema, por favor ingrese la opcion a realizar:",10,0
    mensaje_bienvenida_end:

    ; Opciones del menú
    menu_opciones db "1. Calcular area de rectangulo.",10
                   db "2. Calcular area de triangulo.",10
                   db "3. Salir.",10
                   db "Seleccione una opcion: ",0
    menu_opciones_end:

    ; Mensajes de éxito
    msg_exito_rect db "Calculo realizado con exito (Rectangulo).",10,0
    msg_exito_rect_end:

    msg_exito_tri db "Calculo realizado con exito (Triangulo).",10,0
    msg_exito_tri_end:

    ; Mensaje de salida
    msg_salir db "Programa finalizado, hasta luego!",10,0
    msg_salir_end:

    ; Mensaje de error
    msg_error db "Opcion no valida. Intente nuevamente.",10,0
    msg_error_end:

    ; Espacio en blanco entre iteraciones del menú
    salto_linea db 10,0
    salto_linea_end:

    ; Longitudes
    mensaje_bienvenida_len equ mensaje_bienvenida_end - mensaje_bienvenida
    menu_opciones_len      equ menu_opciones_end - menu_opciones
    msg_exito_rect_len     equ msg_exito_rect_end - msg_exito_rect
    msg_exito_tri_len      equ msg_exito_tri_end - msg_exito_tri
    msg_salir_len          equ msg_salir_end - msg_salir
    msg_error_len          equ msg_error_end - msg_error
    salto_linea_len        equ salto_linea_end - salto_linea

section .bss
    opcion resb 2    ; 1 byte para la opción + 1 byte para Enter

section .text
    global _start

_start:
menu:
    ; Salto de línea para separar ejecuciones anteriores
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, salto_linea_len
    int 0x80

    ; Mostrar mensaje de bienvenida
    mov eax, 4
    mov ebx, 1
    mov ecx, mensaje_bienvenida
    mov edx, mensaje_bienvenida_len
    int 0x80

    ; Mostrar opciones del menú
    mov eax, 4
    mov ebx, 1
    mov ecx, menu_opciones
    mov edx, menu_opciones_len
    int 0x80

    ; Leer la opción del usuario
    mov eax, 3
    mov ebx, 0
    mov ecx, opcion
    mov edx, 2
    int 0x80

    ; Verificar la opción ingresada
    cmp byte [opcion], '1'
    je rectangulo

    cmp byte [opcion], '2'
    je triangulo

    cmp byte [opcion], '3'
    je salir

    ; Si no es válida, mostrar mensaje de error
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_error
    mov edx, msg_error_len
    int 0x80

    jmp menu

rectangulo:
    ; Mostrar mensaje de éxito
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_exito_rect
    mov edx, msg_exito_rect_len
    int 0x80
    jmp menu

triangulo:
    ; Mostrar mensaje de éxito
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_exito_tri
    mov edx, msg_exito_tri_len
    int 0x80
    jmp menu

salir:
    ; Mostrar mensaje de salida
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_salir
    mov edx, msg_salir_len
    int 0x80

    ; Terminar programa
    mov eax, 1
    xor ebx, ebx
    int 0x80