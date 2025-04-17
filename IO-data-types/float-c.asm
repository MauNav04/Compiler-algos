data segment
    mensaje_pedir    db 'Ingrese un numero tipo float: $'
    mensaje_valido   db 0Dh,0Ah, 'El tipo de dato flotante es: $'
    mensaje_invalido db 0Dh,0Ah, 'Entrada invalida: no es un numero flotante.$'
    buffer           db 10                                                         ; tamaño máximo
                     db ?                                                          ; longitud real ingresada
    entrada          db 10 dup(0)                                                  ; contenido de entrada
data ends

pile segment stack 'stack'
         dw 265 dup(?)
pile ends

code segment
                  assume cs:code, ds:data, ss:pile

    main:         
    ; Inicializar segmentos
                  mov    ax, data
                  mov    ds, ax
                  mov    ax, pile
                  mov    ss, ax

    ; Mostrar mensaje
                  lea    dx, mensaje_pedir
                  mov    ah, 09h
                  int    21h

    ; Leer entrada
                  mov    ah, 0Ah
                  lea    dx, buffer
                  int    21h

    ; Obtener cantidad de caracteres
                  mov    bl, buffer[1]                ; cantidad de caracteres ingresados
                  xor    bh, bh                       ; limpiar bh para usar bx
                  lea    si, buffer + 2               ; si apunta al comienzo de la cadena

    ; Agregar '$' al final para impresión (sin modificar si original)
                  mov    di, si
                  add    di, bx
                  mov    byte ptr [di], '$'

    ; Buscar el punto '.'
                  xor    cx, cx                       ; contador
    buscar:       
                  cmp    cx, bx
                  je     caso_invalido                ; si ya revisamos todo y no lo encontramos

                  mov    di, si
                  add    di, cx
                  mov    al, [di]
                  cmp    al, '.'
                  je     caso_valido

                  inc    cx
                  jmp    buscar

    caso_valido:  
                  lea    dx, mensaje_valido
                  mov    ah, 09h
                  int    21h

                  mov    dx, si                       ; Mostrar lo que el usuario ingresó
                  mov    ah, 09h
                  int    21h
                  jmp    salir

    caso_invalido:
                  lea    dx, mensaje_invalido
                  mov    ah, 09h
                  int    21h
                  jmp    salir

    salir:        
                  mov    ax, 4C00h
                  int    21h

code ends
end main