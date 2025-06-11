section .data
    msg_base     db "Ingresa la base: ",0
    msg_altura   db "Ingresa la altura: ",0
    msg_result   db "El area es: %.2f",10,0
    formato      db "%d",0

section .bss
    base         resd 1
    altura       resd 1
    area         resq 1    ; Double (8 bytes)

section .text
    extern printf, scanf
    global main

%macro leer_entero 2
    push %2
    push %1
    call printf
    add esp, 8
    push %2
    push formato
    call scanf
    add esp, 8
%endmacro

main:
    ; Leer base
    leer_entero msg_base, base

    ; Leer altura
    leer_entero msg_altura, altura

    ; Convertir a float y calcular area = (base * altura) / 2.0
    fild dword [base]        ; st0 = base (float)
    fild dword [altura]      ; st0 = altura, st1 = base
    fmulp st1, st0           ; st0 = base*altura
    fld1                     ; st0 = 1.0, st1 = base*altura
    fadd st0, st0            ; st0 = 2.0 (ahora sí, divisor)
    fdivp st1, st0           ; st0 = (base*altura)/2.0
    fstp qword [area]        ; Guarda resultado double

    ; Imprimir resultado
    push dword [area+4]      ; parte alta del double
    push dword [area]        ; parte baja del double
    push msg_result
    call printf
    add esp, 12

    ret
