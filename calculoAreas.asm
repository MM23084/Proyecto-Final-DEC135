section .data
    ; Mensajes
    mensaje_bienvenida db "Bienvenido al sistema, por favor ingrese la opcion a realizar:",10,0
    mensaje_bienvenida_len equ $ - mensaje_bienvenida

    msg_largo    db "Ingrese el largo del rectángulo (entero): ", 0
    len_largo    equ $ - msg_largo
    msg_ancho    db "Ingrese el ancho del rectángulo (entero): ", 0
    len_ancho    equ $ - msg_ancho
    msg_result   db "El área del rectángulo es: ", 0
    len_result   equ $ - msg_result
    msg_punto    db ".", 0

    menu_opciones db "1. Calcular area de rectangulo.",10,"2. Calcular area de triangulo.",10,"3. Salir.",10,"Seleccione una opcion: ",0
    menu_opciones_len equ $ - menu_opciones

    msg_error db "Opcion no valida. Intente nuevamente.",10,0
    msg_error_len equ $ - msg_error

    msg_salir db "Programa finalizado, hasta luego!",10,0
    msg_salir_len equ $ - msg_salir

    msg_base     db "Ingrese la base del triangulo (entero): ", 0
    len_base    equ $ - msg_base
    msg_altura   db "Ingrese la altura del triangulo (entero): ", 0
    len_altura  equ $ - msg_altura
    msg_result_tri   db "El área del triángulo es: ", 0
    len_result_tri   equ $ - msg_result_tri

    ; Variables
    buffer       times 16 db 0
    buffer_num   times 16 db 0
    zero db "00", 0
    salto_linea db 10, 0
    salto_linea_len equ $ - salto_linea

section .bss
    base resd 1
    altura resd 1
    area resq 1
    largo resd  1
    ancho resd 1
    opcion resd  2

section .text
    global _start

_start:
menu:
    ; Salto de línea
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, salto_linea_len
    int 0x80

    ; Mensaje de bienvenida
    mov eax, 4
    mov ebx, 1
    mov ecx, mensaje_bienvenida
    mov edx, mensaje_bienvenida_len
    int 0x80

    ; Menu
    mov eax, 4
    mov ebx, 1
    mov ecx, menu_opciones
    mov edx, menu_opciones_len
    int 0x80

    ; Leer opcion
    mov eax, 3
    mov ebx, 0
    mov ecx, opcion
    mov edx, 2
    int 0x80

    ; Evaluar
    cmp byte [opcion], '1'
    je rectangulo
    cmp byte [opcion], '2'
    je triangulo
    cmp byte [opcion], '3'
    je salir

    ; Opcion no válida
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_error
    mov edx, msg_error_len
    int 0x80
    jmp menu

rectangulo:
    ; Largo
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_largo
    mov edx, len_largo
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 15
    int 0x80
    
    call ascii_to_int
    mov [largo], eax

    ; Ancho
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_ancho
    mov edx, len_ancho
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 15
    int 0x80
    
    call ascii_to_int
    mov [ancho], eax

    ; Área
    mov eax, [largo]
    mov ebx, [ancho]
    mul ebx
    mov [area], eax

    ; Imprimir resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_result
    mov edx, len_result
    int 0x80
    
    mov eax, [area]
    call int_to_ascii
    
    ; Punto .00
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_punto
    mov edx, 1
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, zero
    mov edx, 2
    int 0x80
    
    ; Salto de línea
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, 1
    int 0x80
    
    jmp menu

triangulo:
    ; Base
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_base
    mov edx, len_base
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 15
    int 0x80
    
    call ascii_to_int
    mov [base], eax

    ; Altura
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_altura
    mov edx, len_altura
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 15
    int 0x80
    
    call ascii_to_int
    mov [altura], eax

    ; Área triángulo = base * altura / 2
    mov eax, [base]
    mov ebx, [altura]
    mul ebx
    shr eax, 1
    mov [area], eax

    ; Imprimir resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_result_tri
    mov edx, len_result_tri
    int 0x80
    
    mov eax, [area]
    call int_to_ascii
    
    ; Punto .00
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_punto
    mov edx, 1
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, zero
    mov edx, 2
    int 0x80
    
    ; Salto de línea
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, 1
    int 0x80
    
    jmp menu

ascii_to_int:
    mov esi, buffer
    xor eax, eax
    xor ecx, ecx
.convert:
    movzx edx, byte [esi]
    cmp dl, 10
    je .done
    cmp dl, '0'
    jb .invalid
    cmp dl, '9'
    ja .invalid
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .convert
.invalid:
    jmp .done
.done:
    ret

int_to_ascii:
    mov edi, buffer_num + 15
    mov byte [edi], 0
    dec edi
    mov ebx, 10
.next_digit:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .next_digit
    inc edi
    
    ; imprimir
    mov edx, buffer_num + 15
    sub edx, edi

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80
    
    ret

salir:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_salir
    mov edx, msg_salir_len
    int 0x80
    
    mov eax, 1
    xor ebx, ebx
    int 0x80
