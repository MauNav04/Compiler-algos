data segment
    mensaje_pedir    db 'Ingrese un numero tipo float: $'
    mensaje_valido   db 0Dh,0Ah, 'El tipo de dato flotante es: $'
    mensaje_invalido db 0Dh,0Ah, 'Entrada invalida: no es un numero flotante.$'
    buffer           db 10                                                         ; tamaño máximo: 9 caracteres
                     db ?                                                          ; cantidad real de caracteres ingresados
    entrada          db 10 dup(0)                                                  ; espacio para almacenar la entrada
data endS

pile segment stack 'stack'
         dw 265 dup(?)
pile endS

code segment
    main:         
    ; Mostrar mensaje
    ; Leer con INT 21h, AH = 0Ah
    ; Buscar el punto en entrada ('.')
    ; Mostrar mensaje dependiendo del caso
                  assume cs:code, ds:data, ss:pile

                  mov    ax, pile
                  mov    ss, ax

                  mov    ax, data
                  mov    ds, ax

                  lea    dx, mensaje_pedir
                  mov    ah, 09h
                  int    21h

    ; Leer la entrada del usuario
                  MOV    AH, 0Ah
                  LEA    DX, buffer
                  INT    21h

                  mov    bl, buffer[1]
                  mov    bh,0
                  MOV    SI, OFFSET buffer + 2
                  ADD    SI, bx
                  mov    byte ptr [si], '$'

    ; Buscar el punto en la entrada
                  xor    cx, cx
                  MOV    SI, OFFSET buffer + 2
                  mov    di, si

    ciclo:        
                  cmp    cx, bx
                  je     caso_invalido
                  inc    di
                  mov    al, [di]
                  cmp    al, '.'
                  je     caso_valido
                  inc    cx
                  jmp    ciclo

    caso_valido:  
                  lea    dx, mensaje_valido
                  mov    ah, 09h
                  int    21h

                  mov    dx, si
                  mov    ah, 09h
                  int    21h

                  jmp    exit

    caso_invalido:
                  lea    dx, mensaje_invalido
                  mov    ah, 09h
                  int    21h
                  jmp    exit

    exit:         
                  mov    ax, 4C00h
                  int    21h

code endS
end main