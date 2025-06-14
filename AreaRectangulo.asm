section .data
    ; Mensajes completos
    msg_largo    db  "Ingrese el largo del rectángulo (entero): ", 0
    len_largo    equ $ - msg_largo
    msg_ancho    db  "Ingrese el ancho del rectángulo (entero): ", 0
    len_ancho    equ $ - msg_ancho
    msg_result   db  "El área del rectángulo es: ", 0
    len_result   equ $ - msg_result
    msg_punto    db  ".", 0
    newline      db  10, 0
    
    ; Variables
    largo        dd  0
    ancho        dd  0
    area         dd  0
    buffer       times 16 db 0
    buffer_num   times 16 db 0

section .text
    global _start

_start:
    ; Solicitar y leer largo
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

    ; Solicitar y leer ancho
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

    ; Calcular área
    mov eax, [largo]
    mov ebx, [ancho]
    mul ebx
    mov [area], eax

    ; Mostrar resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_result
    mov edx, len_result
    int 0x80
    
    mov eax, [area]
    call int_to_ascii
    
    ; Mostrar .00 (para cumplir con el formato de 2 decimales)
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
    
    ; Nueva línea
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Salir
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Convertir ASCII a entero
ascii_to_int:
    mov esi, buffer
    xor eax, eax
    xor ecx, ecx
.convert:
    movzx edx, byte [esi]
    cmp dl, 10      ; Fin de línea
    je .done
    cmp dl, '0'     ; Validar dígito
    jb .invalid
    cmp dl, '9'
    ja .invalid
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .convert
.invalid:
    ; Manejar entrada inválida (opcional)
    jmp .convert
.done:
    ret

; Convertir entero a ASCII
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
    
    ; Calcular longitud
    mov ecx, buffer_num + 15
    sub ecx, edi
    mov edx, ecx
    
    ; Imprimir
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80
    ret

section .data
    zero db "00", 0
