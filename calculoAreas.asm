section .data
    ; =============================================
    ; SECCIÓN DE DATOS: Mensajes y cadenas constantes
    ; =============================================
    
    ; Mensaje de bienvenida inicial
    mensaje_bienvenida db "Bienvenido al sistema, por favor ingrese la opcion a realizar:",10,0
    mensaje_bienvenida_len equ $ - mensaje_bienvenida  ; Calcula longitud automáticamente

    ; Mensajes para cálculo de rectángulo
    msg_largo    db "Ingrese el largo del rectángulo (entero): ", 0
    len_largo    equ $ - msg_largo
    msg_ancho    db "Ingrese el ancho del rectángulo (entero): ", 0
    len_ancho    equ $ - msg_ancho
    msg_result   db "El área del rectángulo es: ", 0
    len_result   equ $ - msg_result

    ; Mensajes para menú de opciones
    menu_opciones db "1. Calcular area de rectangulo.",10,"2. Calcular area de triangulo.",10,"3. Salir.",10,"Seleccione una opcion: ",0
    menu_opciones_len equ $ - menu_opciones

    ; Mensajes de error y salida
    msg_error db "Opcion no valida. Intente nuevamente.",10,0
    msg_error_len equ $ - msg_error
    msg_salir db "Programa finalizado, hasta luego!",10,0
    msg_salir_len equ $ - msg_salir

    ; Mensajes para cálculo de triángulo
    msg_base     db "Ingrese la base del triangulo (entero): ", 0
    len_base    equ $ - msg_base
    msg_altura   db "Ingrese la altura del triangulo (entero): ", 0
    len_altura  equ $ - msg_altura
    msg_result_tri   db "El área del triángulo es: ", 0
    len_result_tri   equ $ - msg_result_tri

    ; Caracteres especiales y formatos
    msg_punto    db ".", 0            ; Para mostrar el punto decimal
    zero db "00", 0                   ; Decimales fijos (.00)
    salto_linea db 10, 0              ; Carácter de nueva línea
    salto_linea_len equ $ - salto_linea

    ; Buffer para entrada de usuario
    buffer       times 16 db 0         ; Almacena entrada del teclado
    buffer_num   times 16 db 0         ; Buffer para conversión numérica

section .bss
    ; =============================================
    ; SECCIÓN BSS: Variables no inicializadas
    ; =============================================
    
    base resd 1       ; Almacena base del triángulo (4 bytes)
    altura resd 1     ; Almacena altura del triángulo (4 bytes)
    area resq 1       ; Almacena resultado del área (8 bytes)
    largo resd 1      ; Almacena largo del rectángulo (4 bytes)
    ancho resd 1      ; Almacena ancho del rectángulo (4 bytes)
    opcion resd 2     ; Almacena opción del menú (2 bytes)

section .text
    global _start

_start:
menu:
    ; =============================================
    ; MENÚ PRINCIPAL
    ; =============================================
    
    ; Imprimir salto de línea para mejor formato
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, salto_linea      ; dirección del mensaje
    mov edx, salto_linea_len  ; longitud
    int 0x80                  ; llamada al sistema

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
    mov eax, 3                ; sys_read
    mov ebx, 0                ; stdin
    mov ecx, opcion           ; buffer para almacenar
    mov edx, 2                ; leer 2 bytes (1 char + enter)
    int 0x80

    ; Evaluar opción seleccionada
    cmp byte [opcion], '1'
    je rectangulo             ; Saltar si opción es '1'
    cmp byte [opcion], '2'
    je triangulo              ; Saltar si opción es '2'
    cmp byte [opcion], '3'
    je salir                  ; Saltar si opción es '3'

    ; Opción no válida - mostrar error
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_error
    mov edx, msg_error_len
    int 0x80
    jmp menu                  ; Volver al menú

rectangulo:
    ; =============================================
    ; CÁLCULO DE ÁREA DE RECTÁNGULO
    ; =============================================
    
    ; Solicitar y leer largo
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_largo
    mov edx, len_largo
    int 0x80
    
    mov eax, 3                ; sys_read
    mov ebx, 0                ; stdin
    mov ecx, buffer           ; buffer para entrada
    mov edx, 15               ; máximo 15 caracteres
    int 0x80
    
    call ascii_to_int         ; Convertir entrada a número
    mov [largo], eax          ; Guardar valor en variable

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
    
    call ascii_to_int
    mov [ancho], eax

    ; Calcular área (largo * ancho)
    mov eax, [largo]          ; Cargar largo en EAX
    mov ebx, [ancho]          ; Cargar ancho en EBX
    mul ebx                   ; Multiplicar EAX * EBX (resultado en EAX)
    mov [area], eax           ; Guardar resultado

    ; Mostrar mensaje de resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_result
    mov edx, len_result
    int 0x80
    
    ; Convertir y mostrar el número
    mov eax, [area]
    call int_to_ascii
    
    ; Mostrar parte decimal fija (.00)
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
    
    ; Salto de línea final
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, 1
    int 0x80
    
    jmp menu                  ; Volver al menú principal

triangulo:
    ; =============================================
    ; CÁLCULO DE ÁREA DE TRIÁNGULO
    ; =============================================
    
    ; Solicitar y leer base (similar a rectángulo)
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
    
    call ascii_to_int
    mov [altura], eax

    ; Calcular área del triángulo (base * altura / 2)
    mov eax, [base]           ; Cargar base
    mov ebx, [altura]         ; Cargar altura
    mul ebx                   ; Multiplicar (resultado en EAX)
    shr eax, 1                ; Dividir entre 2 (shift right 1 bit)
    mov [area], eax           ; Guardar resultado

    ; Mostrar mensaje de resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_result_tri
    mov edx, len_result_tri
    int 0x80
    
    ; Convertir y mostrar el número
    mov eax, [area]
    call int_to_ascii
    
    ; Mostrar parte decimal fija (.00)
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
    
    ; Salto de línea final
    mov eax, 4
    mov ebx, 1
    mov ecx, salto_linea
    mov edx, 1
    int 0x80
    
    jmp menu                  ; Volver al menú principal

ascii_to_int:
    ; =============================================
    ; FUNCIÓN: Convertir cadena ASCII a entero
    ; Entrada: buffer con la cadena
    ; Salida: EAX = valor numérico
    ; =============================================
    
    mov esi, buffer           ; Puntero al inicio del buffer
    xor eax, eax              ; Limpiar EAX (acumulador)
    xor ecx, ecx              ; Limpiar ECX (contador)
    
.convert:
    movzx edx, byte [esi]     ; Leer siguiente byte (con extensión a cero)
    cmp dl, 10                ; Comparar con fin de línea (Enter)
    je .done                  ; Si es fin de línea, terminar
    cmp dl, '0'               ; Validar que sea dígito (>= '0')
    jb .invalid
    cmp dl, '9'               ; Validar que sea dígito (<= '9')
    ja .invalid
    sub dl, '0'               ; Convertir ASCII a valor numérico
    imul eax, 10              ; Multiplicar acumulador por 10
    add eax, edx              ; Sumar nuevo dígito
    inc esi                   ; Mover al siguiente carácter
    jmp .convert              ; Repetir
    
.invalid:
    ; Podría manejarse mejor el error, aquí simplemente termina
    jmp .done
    
.done:
    ret                       ; Retornar con resultado en EAX

int_to_ascii:
    ; =============================================
    ; FUNCIÓN: Convertir entero a cadena ASCII
    ; Entrada: EAX = número a convertir
    ; Salida: Imprime el número en stdout
    ; =============================================
    
    mov edi, buffer_num + 15  ; Puntero al final del buffer
    mov byte [edi], 0         ; Terminador nulo
    dec edi                   ; Retroceder una posición
    
    mov ebx, 10               ; Divisor para obtener dígitos
    
.next_digit:
    xor edx, edx              ; Limpiar EDX para división
    div ebx                   ; Dividir EAX por 10 (EAX = cociente, EDX = residuo)
    add dl, '0'               ; Convertir residuo a ASCII
    mov [edi], dl             ; Almacenar dígito
    dec edi                   ; Retroceder en el buffer
    test eax, eax             ; Verificar si cociente es cero
    jnz .next_digit           ; Si no es cero, continuar
    
    inc edi                   ; Ajustar puntero al primer dígito
    
    ; Calcular longitud del número
    mov edx, buffer_num + 15  ; Final del buffer
    sub edx, edi              ; EDX = longitud
    
    ; Imprimir el número
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    mov ecx, edi              ; dirección del número
    ; EDX ya tiene la longitud
    int 0x80
    
    ret                       ; Retornar

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
    mov eax, 1                ; sys_exit
    xor ebx, ebx              ; código de salida 0 (éxito)
    int 0x80
