section .data
    buffer_out times 16 db 0 ; Buffer para la conversión de entero a ASCII
    punto db ".", 0           ; Carácter para el formato ".00"
    cero db "00", 0           ; Cadena "00" para el formato ".00"
    salto db 10, 0            ; Carácter de nueva línea (Line Feed)

section .bss
    resultado resd 1          ; Variable global donde las funciones de cálculo almacenan el resultado para imprimir

section .text
    ; Funciones globales que serán llamadas desde otros archivos
    global leer_entero
    global mostrar_resultado
    global imprimir_cadena
    global imprimir_nueva_linea
    global leer_entrada
    global resultado          ; Hacer la variable 'resultado' global para que otros módulos puedan escribir en ella

; Función para imprimir una cadena en stdout
; Recibe: ecx = dirección de la cadena (argumento 1 en la pila)
; NO LIMPIA LA PILA. El llamador es responsable.
imprimir_cadena:
    push ebp         ; Guardar EBP (buena práctica para funciones)
    mov ebp, esp     ; Establecer EBP como base para acceder a argumentos
    push ebx         ; Guardar EBX
    push edx         ; Guardar EDX

    mov ecx, [ebp+8] ; Obtiene la dirección de la cadena desde la pila (EBP + 4 para RET, +4 para EBP guardado = +8)

    ; Calcula la longitud de la cadena (asume que está terminada en 0)
    xor edx, edx
.loop_len:
    cmp byte [ecx+edx], 0
    je .len_done
    inc edx
    jmp .loop_len
.len_done:

    mov eax, 4       ; Syscall para sys_write
    mov ebx, 1       ; File descriptor para stdout
    ; ecx ya tiene la dirección de la cadena
    ; edx ya tiene la longitud
    int 0x80         ; Ejecuta la syscall

    pop edx          ; Restaurar EDX
    pop ebx          ; Restaurar EBX
    pop ebp          ; Restaurar EBP
    ret              ; Retorna. El llamador limpia la pila.

; Función para imprimir una nueva línea
imprimir_nueva_linea:
    push salto       ; Pasa la dirección del carácter de salto de línea
    call imprimir_cadena ; Reutiliza imprimir_cadena
    add esp, 4       ; Limpia el argumento (salto) de la pila (4 bytes)
    ret

; Función para leer una cadena desde stdin
; Recibe: ecx = dirección del buffer (argumento 1), edx = longitud máxima (argumento 2)
; Deja: el número de bytes leídos en EAX. El buffer se llena con la entrada.
; NO LIMPIA LA PILA. El llamador es responsable.
leer_entrada:
    push ebp         ; Guardar EBP
    mov ebp, esp     ; Establecer EBP
    push ebx         ; Guardar EBX
    push edi         ; Guardar EDI

    mov ecx, [ebp+12] ; Obtiene la dirección del buffer (EBP + 4 para RET, +4 para EBP, +4 para EBX/EDI = +12)
    mov edx, [ebp+8]  ; Obtiene la longitud máxima a leer

    mov eax, 3          ; Syscall para sys_read
    mov ebx, 0          ; File descriptor para stdin
    ; ecx ya tiene el buffer
    ; edx ya tiene la longitud
    int 0x80            ; Ejecuta la syscall

    ; Opcional: Reemplazar el salto de línea al final por un terminador nulo para que sea un string C
    ; Se asume que EAX contiene el número de bytes leídos por sys_read.
    cmp eax, 0
    jle .done_read       ; Si no se leyó nada o hubo error, salta
    ; Verifica si el último carácter es un salto de línea y lo reemplaza por un nulo
    mov edi, ecx         ; EDI apunta al inicio del buffer
    add edi, eax         ; Mueve EDI al final de los bytes leídos
    dec edi              ; Apunta al último carácter leído
    cmp byte [edi], 10   ; Es un Line Feed?
    jne .check_cr        ; Si no es LF, chequea CR
    mov byte [edi], 0    ; Reemplaza LF con NUL
    jmp .done_read
.check_cr:
    cmp byte [edi], 13   ; Es un Carriage Return?
    jne .done_read
    mov byte [edi], 0    ; Reemplaza CR con NUL

.done_read:
    pop edi          ; Restaurar EDI
    pop ebx          ; Restaurar EBX
    pop ebp          ; Restaurar EBP
    ret              ; Retorna. El llamador limpia la pila.

; Función para leer un entero desde stdin
; Asume que la cadena ya ha sido leída en un buffer (por ejemplo, con leer_entrada)
; Recibe: ecx = dirección del buffer (argumento 1)
; Deja: el valor entero convertido en EAX
; NO LIMPIA LA PILA. El llamador es responsable.
leer_entero:
    push ebp         ; Guardar EBP
    mov ebp, esp     ; Establecer EBP
    push esi         ; Guardar ESI (porque ascii_to_int usa ESI)

    mov ecx, [ebp+8] ; Obtiene la dirección del buffer desde la pila

    call ascii_to_int   ; Llama a la función de conversión. Resultado en EAX.

    pop esi          ; Restaurar ESI
    pop ebp          ; Restaurar EBP
    ret              ; Retorna. El llamador limpia la pila.

; Función para mostrar un entero con el formato ".00"
; Asume que el entero a mostrar está en la variable global 'resultado'
mostrar_resultado:
    push ebp         ; Guardar EBP
    mov ebp, esp     ; Establecer EBP
    push eax         ; Guardar EAX (porque int_to_ascii lo usa para el número)
    push ebx         ; Guardar EBX
    push ecx         ; Guardar ECX
    push edx         ; Guardar EDX
    push edi         ; Guardar EDI

    mov eax, [resultado] ; Carga el valor desde la variable global 'resultado'
    call int_to_ascii    ; Convierte el entero a ASCII y lo imprime

    ; Imprime el punto y los dos ceros
    mov eax, 4
    mov ebx, 1
    mov ecx, punto
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, cero
    mov edx, 2
    int 0x80

    ; Imprime un salto de línea final
    mov eax, 4
    mov ebx, 1
    mov ecx, salto
    mov edx, 1
    int 0x80

    pop edi          ; Restaurar EDI
    pop edx          ; Restaurar EDX
    pop ecx          ; Restaurar ECX
    pop ebx          ; Restaurar EBX
    pop eax          ; Restaurar EAX
    pop ebp          ; Restaurar EBP
    ret              ; Retorna

; Subrutina: Convierte una cadena ASCII a un entero binario
; Recibe: ECX = dirección de la cadena ASCII (buffer)
; Deja: EAX = el valor entero binario
ascii_to_int:
    ; Esta función usa ESI, pero no es de las que deben preservar ESI/EDI por convención (caller-saved)
    ; De todas formas, la hemos guardado en leer_entero, que es quien la llama.
    mov esi, ecx    ; ESI apunta al inicio de la cadena
    xor eax, eax    ; EAX = 0 (acumulador del número)
    xor ecx, ecx    ; ECX = 0 (no se usa como contador aquí)

.next_char:
    movzx edx, byte [esi]   ; Carga un byte (carácter) y lo extiende a 32 bits en EDX
    cmp dl, 10              ; Comprueba si es Line Feed (salto de línea)
    je .done
    cmp dl, 13              ; Comprueba si es Carriage Return (retorno de carro)
    je .done
    cmp dl, 0               ; Comprueba si es Nulo (fin de cadena)
    je .done
    cmp dl, '0'             ; Comprueba si es menor que '0'
    jb .skip                ; Si no es un dígito, saltar
    cmp dl, '9'             ; Comprueba si es mayor que '9'
    ja .skip                ; Si no es un dígito, saltar

    sub dl, '0'             ; Convierte el carácter ASCII a su valor numérico (ej. '5' -> 5)
    imul eax, 10            ; Multiplica el acumulador actual por 10 (ej. 12 -> 120)
    add eax, edx            ; Suma el nuevo dígito (ej. 120 + 3 -> 123)
.skip:
    inc esi                 ; Avanza al siguiente carácter
    jmp .next_char
.done:
    ret                     ; Retorna; el número convertido está en EAX

; Subrutina: Convierte un entero binario a su representación en cadena ASCII y la imprime
; Recibe: EAX = el número entero a convertir (pasado por mostrar_resultado)
; Imprime: la cadena ASCII del número en stdout
int_to_ascii:
    ; Esta función usa EDI, pero no es de las que deben preservar EDI por convención (caller-saved)
    ; De todas formas, la hemos guardado en mostrar_resultado, que es quien la llama.
    mov edi, buffer_out + 15 ; EDI apunta al final del buffer_out (posición 15 de 0-15)
    mov byte [edi], 0       ; Coloca un terminador nulo al final (buffer_out[15] = 0)
    dec edi                 ; Mueve EDI a la posición anterior para empezar a escribir dígitos

    mov ebx, 10             ; Divisor para la conversión a base 10
.next:
    xor edx, edx            ; Limpia EDX para la división
    div ebx                 ; Divide EAX por EBX (10). Cociente en EAX, residuo en EDX
    add dl, '0'             ; Convierte el residuo (dígito) a su carácter ASCII (ej. 5 -> '5')
    mov [edi], dl           ; Almacena el carácter ASCII en el buffer_out
    dec edi                 ; Mueve EDI a la siguiente posición a la izquierda
    test eax, eax           ; Comprueba si EAX es cero (todos los dígitos procesados)
    jnz .next               ; Si no es cero, continúa el bucle

    inc edi                 ; EDI ahora apunta al inicio de la cadena de dígitos válidos

    ; Imprime la cadena de dígitos generada
    mov eax, 4              ; Syscall para sys_write
    mov ebx, 1              ; File descriptor para stdout
    mov ecx, edi            ; Dirección de la cadena a imprimir
    mov edx, buffer_out + 15 ; Dirección del final del buffer
    sub edx, edi            ; Calcula la longitud de la cadena
    int 0x80                ; Ejecuta la syscall
    ret
