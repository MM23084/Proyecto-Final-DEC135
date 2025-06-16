section .data
    ; =============================================
    ; SECCIÓN DE DATOS: Mensajes y cadenas constantes
    ; =============================================

    ; Mensaje de bienvenida inicial
    mensaje_bienvenida db "Bienvenido al sistema, por favor ingrese la opcion a realizar:",10,0
    mensaje_bienvenida_len equ $ - mensaje_bienvenida ; Calcula longitud automáticamente

    ; Mensajes para cálculo de rectángulo
    msg_largo      db "Ingrese el largo del rectangulo (entero): ", 0
    len_largo      equ $ - msg_largo
    msg_ancho      db "Ingrese el ancho del rectangulo (entero): ", 0
    len_ancho      equ $ - msg_ancho
    msg_result     db "El area del rectangulo es: ", 0
    len_result     equ $ - msg_result

    ; Mensajes para menú de opciones
    menu_opciones db "1. Calcular area de rectangulo.",10,"2. Calcular area de triangulo.",10,"3. Salir.",10,"Seleccione una opcion: ",0
    menu_opciones_len equ $ - menu_opciones

    ; Mensajes de error y salida
    msg_error db "Opcion no valida. Intente nuevamente.",10,0
    msg_error_len equ $ - msg_error
    msg_salir db "Programa finalizado, hasta luego!",10,0
    msg_salir_len equ $ - msg_salir

    ; Mensajes para cálculo de triángulo
    msg_base       db "Ingrese la base del triangulo (entero): ", 0
    len_base       equ $ - msg_base
    msg_altura     db "Ingrese la altura del triangulo (entero): ", 0
    len_altura     equ $ - msg_altura
    msg_result_tri db "El area del triangulo es: ", 0
    len_result_tri equ $ - msg_result_tri

    ; Mensajes de validación de entrada
    msg_input_error db "Entrada no valida. Por favor, ingrese solo numeros enteros positivos.",10,0
    len_input_error equ $ - msg_input_error
    msg_no_decimal db "No se permiten decimales. Por favor, ingrese un numero entero.",10,0
    len_no_decimal equ $ - msg_no_decimal

    ; Caracteres especiales y formatos
    msg_punto      db ".", 0             ; Para mostrar el punto decimal
    salto_linea db 10, 0                  ; Carácter de nueva línea
    salto_linea_len equ $ - salto_linea

    ; Buffer para entrada de usuario
    buffer         times 16 db 0         ; Almacena entrada del teclado
    buffer_num     times 16 db 0         ; Buffer para conversión numérica
    decimal_part_buffer times 3 db 0     ; Buffer para la parte decimal (e.g., "00", "50")

section .bss
    ; =============================================
    ; SECCIÓN BSS: Variables no inicializadas
    ; =============================================

    base resd 1             ; Almacena base del triángulo (4 bytes)
    altura resd 1           ; Almacena altura del triángulo (4 bytes)
    area_entero resd 1      ; Almacena parte entera del área
    area_decimal resd 1     ; Almacena parte decimal del área (0-99)
    largo resd 1            ; Almacena largo del rectángulo (4 bytes)
    ancho resd 1            ; Almacena ancho del rectángulo (4 bytes)
    opcion resd 2           ; Almacena opción del menú (2 bytes)
    input_len resd 1        ; Almacena la longitud de la entrada leída
    temp_remainder resd 1   ; Para almacenar el residuo de la división en triangulo

section .text
    global _start

_start:
menu:
    ; =============================================
    ; MENÚ PRINCIPAL
    ; =============================================

    ; Imprimir salto de línea para mejor formato
    mov eax, 4                  ; sys_write
    mov ebx, 1                  ; stdout
    mov ecx, salto_linea        ; dirección del mensaje
    mov edx, salto_linea_len    ; longitud
    int 0x80                    ; llamada al sistema

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

    ; Leer opción del usuario
    mov eax, 3                  ; sys_read
    mov ebx, 0                  ; stdin
    mov ecx, opcion             ; buffer para almacenar
    mov edx, 2                  ; leer 2 bytes (1 char + enter)
    int 0x80
    mov [input_len], eax        ; Guardar la longitud real de lectura

    ; Evaluar opción seleccionada
    cmp byte [opcion], '1'
    je rectangulo               ; Saltar si opción es '1'
    cmp byte [opcion], '2'
    je triangulo                ; Saltar si opción es '2'
    cmp byte [opcion], '3'
    je salir                    ; Saltar si opción es '3'

    ; Opción no válida - mostrar error
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_error
    mov edx, msg_error_len
    int 0x80
    jmp menu                    ; Volver al menú

rectangulo:
    ; =============================================
    ; CÁLCULO DE ÁREA DE RECTÁNGULO
    ; =============================================
get_largo:
    ; Solicitar y leer largo
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_largo
    mov edx, len_largo
    int 0x80

    mov eax, 3                  ; sys_read
    mov ebx, 0                  ; stdin
    mov ecx, buffer             ; buffer para entrada
    mov edx, 15                 ; máximo 15 caracteres
    int 0x80
    mov [input_len], eax        ; Save actual length read

    call validate_and_convert_int ; Convertir y validar
    cmp eax, -1                 ; Comprobar el valor de error de la conversión
    je .largo_error
    mov [largo], eax            ; Guardar valor en variable
    jmp get_ancho

.largo_error:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input_error
    mov edx, len_input_error
    int 0x80
    jmp get_largo               ; Repetir entrada

get_ancho:
    ; Solicitar y leer ancho (similar a largo)
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
    mov [input_len], eax

    call validate_and_convert_int
    cmp eax, -1
    je .ancho_error
    mov [ancho], eax
    jmp calculate_rect_area

.ancho_error:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input_error
    mov edx, len_input_error
    int 0x80
    jmp get_ancho

calculate_rect_area:
    ; Calcular área (largo * ancho)
    mov eax, [largo]            ; Cargar largo en EAX
    mov ebx, [ancho]            ; Cargar ancho en EBX
    mul ebx                     ; Multiplicar EAX * EBX (resultado en EAX)
    mov [area_entero], eax      ; Guardar resultado entero
    mov dword [area_decimal], 0 ; Los rectángulos siempre tienen .00 si las entradas son números enteros

    ; Mostrar mensaje de resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_result
    mov edx, len_result
    int 0x80

    ; Convertir y mostrar el número entero
    mov eax, [area_entero]
    call int_to_ascii_print

    ; Mostrar parte decimal
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_punto
    mov edx, 1
    int 0x80

    ; Dado que forzamos .00 para rectángulos con entradas enteras
    mov byte [decimal_part_buffer], '0'
    mov byte [decimal_part_buffer + 1], '0'
    mov eax, 4
    mov ebx, 1
    mov ecx, decimal_part_buffer
    mov edx, 2
    int 0x80

    ; Salto de línea final
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, 1
    int 0x80

    jmp menu                    ; Volver al menú principal

triangulo:
    ; =============================================
    ; CÁLCULO DE ÁREA DE TRIÁNGULO
    ; =============================================
get_base:
    ; Solicitar y leer base
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
    mov [input_len], eax

    call validate_and_convert_int
    cmp eax, -1
    je .base_error
    mov [base], eax
    jmp get_altura

.base_error:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input_error
    mov edx, len_input_error
    int 0x80
    jmp get_base

get_altura:
    ; Solicitar y leer altura
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
    mov [input_len], eax

    call validate_and_convert_int
    cmp eax, -1
    je .altura_error
    mov [altura], eax
    jmp calculate_tri_area

.altura_error:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input_error
    mov edx, len_input_error
    int 0x80
    jmp get_altura

calculate_tri_area:
    ; Calcular área del triángulo (base * altura / 2)
    mov eax, [base]             ; Cargar base
    mov ebx, [altura]           ; Cargar altura
    mul ebx                     ; Multiplicar (Resultado en EAX:EDX, pero solo esperamos 32 bits, por lo que EAX está bien)

    ; Ahora tenemos base * altura en EAX. Necesitamos dividir entre 2 y gestionar decimales.
    ; Primero multiplica por 100 para mantener dos decimales.
    mov ebx, 100
    mul ebx                     ; EAX = (base * altura) * 100 (resultado en EAX:EDX)

    mov ebx, 2                  ; El divisor es 2
    xor edx, edx                ; Borrar EDX para la división
    div ebx                     ; EAX = (base * altura * 100) / 2, EDX = resto

    ; EAX ahora tiene el área total escalada por 100
    ; Necesitamos separar las partes enteras y decimales.
    mov ebx, 100
    xor edx, edx
    div ebx                     ; EAX = parte entera, EDX = parte decimal (0-99)

    mov [area_entero], eax
    mov [area_decimal], edx

    ; Mostrar mensaje de resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_result_tri
    mov edx, len_result_tri
    int 0x80

    ; Convertir y mostrar el número entero
    mov eax, [area_entero]
    call int_to_ascii_print

    ; Mostrar parte decimal
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_punto
    mov edx, 1
    int 0x80

    ; Convertir e imprimir la parte decimal
    mov eax, [area_decimal]
    call print_decimal_part

    ; Salto de línea final
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, 1
    int 0x80

    jmp menu                    ; Volver al menú principal

validate_and_convert_int:
    ; =============================================
    ; FUNCIÓN: Validar y Convertir cadena ASCII a entero
    ; Entrada: buffer con la cadena, [input_len] con la longitud real
    ; Salida: EAX = valor numérico (o -1 si hay error)
    ;         CUIDADO: EBX, ECX, EDX, ESI modificados
    ; =============================================

    push ebx                    ; Guardar registros
    push ecx
    push edx
    push esi

    mov esi, buffer             ; Puntero al inicio del buffer
    xor eax, eax                ; Limpiar EAX (acumulador)
    xor ecx, ecx                ; Limpiar ECX (index/counter for length)
    mov ebx, [input_len]        ; Obtener la longitud de la entrada de lectura
    dec ebx                     ; Decrementar para excluir el carácter de nueva línea (si está presente)

    ; Manejar entrada vacía o solo nueva línea
    cmp ebx, 0
    jle .invalid_input_val

.convert_val:
    cmp ecx, ebx                ; 
    jge .done_val               ; 

    movzx edx, byte [esi + ecx] ; Leer siguiente byte
    cmp dl, '0'                 ; Validar que sea dígito (>= '0')
    jb .invalid_input_val
    cmp dl, '9'                 ; Validar que sea dígito (<= '9')
    ja .invalid_input_val

    sub dl, '0'                 ; Convertir ASCII a valor numérico
    imul eax, 10                ; Multiplicar acumulador por 10
    add eax, edx                ; Sumar nuevo dígito
    inc ecx                     ; Mover al siguiente carácter
    jmp .convert_val            ; Repetir

.invalid_input_val:
    mov eax, -1                 ; Establecer código de error
    jmp .end_val

.done_val:
    ; Comprueba si se analizaron dígitos. Si EAX sigue siendo 0 y no se procesaron dígitos,
    cmp ecx, 0                  ; 
    je .invalid_input_val       ; Tratar como inválido

.end_val:
    pop esi                     ; Restaurar registros
    pop edx
    pop ecx
    pop ebx
    ret

int_to_ascii_print:
    ; =============================================
    ; FUNCIÓN: Convertir entero a cadena ASCII e imprimir
    ; Entrada: EAX = número a convertir
    ; Salida: Imprime el número en stdout
    ; CUIDADO: EBX, ECX, EDX, EDI modificados
    ; =============================================

    push eax                    ; Guarde EAX para compararlo más tarde si el número es 0
    push ebx
    push ecx
    push edx
    push edi

    mov edi, buffer_num + 15    ; Puntero al final del buffer
    mov byte [edi], 0           ; Terminador nulo
    dec edi                     ; Retroceder una posición

    mov ebx, 10                 ; Divisor para obtener dígitos

    cmp dword [esp + 20], 0     ; Verifique el valor EAX original (insertado)
    je .print_zero              ; Si es 0, simplemente imprime '0'

.next_digit_print:
    xor edx, edx                ; Limpiar EDX para división
    div ebx                     ; Dividir EAX por 10 (EAX = cociente, EDX = residuo)
    add dl, '0'                 ; Convertir residuo a ASCII
    mov [edi], dl               ; Almacenar dígito
    dec edi                     ; Retroceder en el buffer
    test eax, eax               ; Verificar si cociente es cero
    jnz .next_digit_print       ; Si no es cero, continuar

    inc edi                     ; Ajustar puntero al primer dígito

    ; Calcular longitud del número
    mov edx, buffer_num + 15    ; Final del buffer
    sub edx, edi                ; EDX = longitud

    ; Imprimir el número
    mov eax, 4                  ; sys_write
    mov ebx, 1                  ; stdout
    mov ecx, edi                ; dirección del número
    ; EDX ya tiene la longitud
    int 0x80

    jmp .end_print

.print_zero:
    mov byte [buffer_num], '0'
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer_num
    mov edx, 1
    int 0x80

.end_print:
    pop edi                     ; Restaurar registros
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_decimal_part:
    ; =============================================
    ; FUNCIÓN: Convertir y imprimir la parte decimal (0-99)
    ; Entrada: EAX = número decimal (0-99)
    ; Salida: Imprime la parte decimal con dos dígitos (e.g., "05", "50")
    ; CUIDADO: EBX, ECX, EDX, EDI modificados
    ; =============================================

    push ebx
    push ecx
    push edx
    push edi

    mov edi, decimal_part_buffer + 1 ; Apunta al segundo byte
    mov byte [edi], 0                ; Terminador nulo

    mov ebx, 10                      ; Divisor para decenas y unidades

    xor edx, edx
    div ebx                          ; EAX = dígito de las decenas, EDX = dígito de las unidades

    add dl, '0'                      ; Convertir unidades a ASCII
    mov [edi], dl
    dec edi                          ; Mover al primer byte

    mov dl, al                       ; Obtener el dígito de las decenas (de EAX)
    add dl, '0'                      ; Convertir decenas a ASCII
    mov [edi], dl

    ; Imprima los dos dígitos decimales
    mov eax, 4                       ; sys_write
    mov ebx, 1                       ; stdout
    mov ecx, decimal_part_buffer
    mov edx, 2                       ; Siempre 2 dígitos
    int 0x80

    pop edi
    pop edx
    pop ecx
    pop ebx
    ret

salir:
    ; =============================================
    ; FINALIZACIÓN DEL PROGRAMA
    ; =============================================

    ; Mostrar mensaje de despedida
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_salir
    mov edx, msg_salir_len
    int 0x80

    ; Terminar programa
    mov eax, 1                  ; sys_exit
    xor ebx, ebx                ; código de salida 0 (éxito)
    int 0x80