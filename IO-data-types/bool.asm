data segment
    mensaje_entrada DB 'Ingrese un valor booleano (true/false): $'
    mensaje_valido  DB 0Dh, 0Ah, 'Valor booleano ingresado: $'
    mensaje_error   DB 0Dh, 0Ah, 'Entrada invalida.$'
    buffer          DB 6                                              ; Max 5 letras + byte de longitud
                    DB 0                                              ; Aquí se guardará la cantidad de caracteres leídos
    entrada         DB 6 dup(?)                                       ; Buffer para los caracteres
data ends

pile segment stack 'stack'
         dw 265 dup(?)
pile ends

code segment
                    assume cs:code, ds:data, ss:pile

    main:           
                    mov    ax, pile
                    mov    ss, ax

                    mov    ax, data
                    mov    ds, ax

    ; Mostrar mensaje
                    lea    dx, mensaje_entrada
                    mov    ah, 09h
                    int    21h

    ; Leer la cadena
                    lea    dx, buffer
                    mov    ah, 0Ah
                    int    21h
                    mov    bl, buffer[1]                ; cantidad de caracteres leídos
                    mov    bh, 0
                    mov    si, offset buffer + 2
                    add    si, bx                       ; SI ahora apunta al final de la cadena ingresada
                    mov    byte ptr [si], '$'           ; Agregar el terminador '$'

    ; Mover el puntero al inicio real del texto ingresado
                    lea    si, buffer + 2               ; SI apunta a los caracteres ingresados
                    mov    cl, [buffer + 1]             ; CL tiene el número de caracteres ingresados
                    mov    ch, 0

    ; Comparar con "true"
                    cmp    cl, 4
                    jne    verificar_false              ; Si no tiene 4 letras, no es "true"

                    mov    di, offset entrada
                    mov    al, [si]                     ; primer carácter
                    cmp    al, 't'
                    jne    verificar_false
                    mov    al, [si+1]
                    cmp    al, 'r'
                    jne    verificar_false
                    mov    al, [si+2]
                    cmp    al, 'u'
                    jne    verificar_false
                    mov    al, [si+3]
                    cmp    al, 'e'
                    jne    verificar_false

    ; Si llegó aquí, es "true"
                    lea    dx, mensaje_valido
                    mov    ah, 09h
                    int    21h

                    mov    ah, 09h
                    mov    dx, si
                    int    21h
                    jmp    terminar

    verificar_false:
                    cmp    cl, 5
                    jne    error                        ; Si no tiene 5 letras, no es "false"

                    mov    al, [si]
                    cmp    al, 'f'
                    jne    error
                    mov    al, [si+1]
                    cmp    al, 'a'
                    jne    error
                    mov    al, [si+2]
                    cmp    al, 'l'
                    jne    error
                    mov    al, [si+3]
                    cmp    al, 's'
                    jne    error
                    mov    al, [si+4]
                    cmp    al, 'e'
                    jne    error

    ; Si llegó aquí, es "false"
                    lea    dx, mensaje_valido
                    mov    ah, 09h
                    int    21h

                    mov    ah, 09h
                    mov    dx, si
                    int    21h
                    jmp    terminar

    error:          
                    lea    dx, mensaje_error
                    mov    ah, 09h
                    int    21h

    terminar:       
                    mov    ax, 4C00h
                    int    21h

code ends
end main