; convertir otros tipos a int

; entrada: "323" -> salida 323 -> consola "323"
; entrada: "-323" -> salida -323 -> consola "-323"
; entrada: "hola" -> salida 62949 -> consola "62949"
; entrada: "13.5" -> salida 13.5 -> consola "13.5"
; entrada: "a" -> salida 49 -> consola "49"
; entrada: "true" -> salida 1 -> consola "1"
; entrada: "false" -> salida 0 -> consola "0"

; falta truncar la parte decimal con floats
; aun falta considerar negativos
; se puede mejorar el manejo de strings con letras

data segment
    mensaje_entrada   DB 'Ingrese una cadena de caracteres: $'
    mensaje_invalido  DB 'Solo puede ingresar valores numericos$'
    mensaje_string    DB 0Dh, 0Ah, 'La cadena de caracteres ingresada es: $'
    mensaje_float     DB 0Dh, 0Ah, 'La cadena representa el siguiente valor flotante: $'
    mensaje_bool      DB 0Dh, 0Ah, 'La cadena representa un valor booleano equivalente a: $'
    buffer            DB 10                                                                     ; Tamaño máximo del buffer (5 caracteres + 1 byte para la longitud real)
                      DB 0                                                                      ; Número de caracteres leídos (se llenará automáticamente)
    numero            DB 10 dup(0)                                                              ; Espacio para los caracteres ingresados y el terminador
    numero_convertido DW 0
    resultado_ascii   DB 10 dup('$')                                                            ; Buffer para el número convertido a texto

data endS

pile segment stack 'stack'
         dw 265 dup(?)
pile endS

code segment
                      assume cs:code, ds:data, ss:pile

    main:             
                      mov    ax, pile
                      mov    ss, ax

                      mov    ax, data
                      mov    ds, ax

                      MOV    AH, 09h
                      LEA    DX, mensaje_entrada
                      INT    21h
    
    ; Leer la entrada del usuario
                      MOV    AH, 0Ah
                      LEA    DX, buffer
                      INT    21h

    ; Agregar terminador '$' a la entrada del usuario
                      mov    si, dx
                      add    si, 2
                      xor    bx, bx
                      mov    bl, buffer[1]
                      add    si, bx
                      mov    byte ptr [si], '$'
                      mov    si, dx                       ; retornamos si al inicio del buffer
                      add    si, 2

    ; Sección de identificación de entrada

    ; (1) Caso float. Busca un punto en la entrada **FALTA CONFIRMAR QUE SOLO TENGA NUMEROS**
                      xor    cx, cx
                      mov    di, si

    ciclo:            
                      cmp    cx, bx
                      je     caso_bool
                      inc    di
                      mov    al, [di]
                      cmp    al, '.'
                      je     desplegar_float
                      inc    cx
                      jmp    ciclo

    desplegar_float:  
                      lea    dx, mensaje_float
                      mov    ah, 09h
                      int    21h

                      mov    dx, si
                      mov    ah, 09h
                      int    21h
                      jmp    fin
                      
    caso_bool:        
    ; (2) Caso Bool. Detecta los strings "true" o "false"
    ; Mover el puntero al inicio real del texto ingresado
                      mov    cl, [buffer + 1]             ; CL tiene el número de caracteres ingresados
                      mov    ch, 0

    ; Comparar con "true"
                      cmp    cl, 4
                      jne    verificar_false              ; Si no tiene 4 letras, no es "true"

                      mov    di, offset numero
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
                      lea    dx, mensaje_bool
                      mov    ah, 09h
                      int    21h

                      mov    numero_convertido, 1
                      mov    dx, 1
                      add    dl, '0'                      ;pasa a ASCII
                      lea    di, resultado_ascii
                      mov    [di],dx
                      mov    ah, 09h
                      mov    dx, di
                      int    21h
                      jmp    fin

    verificar_false:  
                      cmp    cl, 5
                      jne    caso_string                  ; Si no tiene 5 letras, no es "false"

                      mov    al, [si]
                      cmp    al, 'f'
                      jne    caso_string
                      mov    al, [si+1]
                      cmp    al, 'a'
                      jne    caso_string
                      mov    al, [si+2]
                      cmp    al, 'l'
                      jne    caso_string
                      mov    al, [si+3]
                      cmp    al, 's'
                      jne    caso_string
                      mov    al, [si+4]
                      cmp    al, 'e'
                      jne    caso_string

    ; Si llegó aquí, es "false"
                      lea    dx, mensaje_bool
                      mov    ah, 09h
                      int    21h

                      mov    numero_convertido, 0
                      mov    dx, 0
                      add    dl, '0'                      ;pasa a ASCII
                      lea    di, resultado_ascii
                      mov    [di],dx
                      mov    ah, 09h
                      mov    dx, di
                      int    21h
                      jmp    fin

    ; En este caso es el mismo procedimiento para convertir str,char
    caso_string:      
                      mov    si, dx
    
    ; convertir string a int

                      xor    ax, ax
                      xor    cx, cx                       ; CX = 0, para usar como contador
                      add    si, 2                        ; movemos si al inicio de la palabra ingresada por el usuaurio
    texto_a_entero:   
                      mov    bl, [si]
                      cmp    bl, '$'                      ; fin de cadena
                      je     mostrar_resultado
                      sub    bl, '0'                      ; convertir de ASCII a dígito

                      mov    bh, 0
                      mov    cx, ax
                      mov    ax, 10
                      mul    cx                           ; AX = AX * 10
                      add    ax, bx                       ; AX = AX + dígito actual
                      inc    si
                      jmp    texto_a_entero

    caso_invalido:    
    ; En caso de error, podrías poner un valor especial
    ; o saltar a un mensaje de error
                      lea    dx, mensaje_invalido
                      mov    ah, 09h
                      int    21h
                      jmp    fin


    mostrar_resultado:
    ; Guardar el número convertido
                      mov    numero_convertido, ax

    ; Mostrar mensaje de salida
                      mov    ah, 09h
                      lea    dx, mensaje_string
                      int    21h

    ; Convertir AX a ASCII
                      xor    bx, bx
                      mov    bl, buffer[1]
                      lea    di, resultado_ascii + bx     ; Comenzamos al final del buffer (para almacenar al revés)
                      mov    cx, 0
                      xor    ax, ax
                      mov    ax, numero_convertido        ; Contador de dígitos

    convertir_decimal:
                      xor    dx, dx
                      mov    bx, 10
                      div    bx                           ; AX / 10, cociente en AX, resto en DX
                      add    dl, '0'                      ; convertir a ASCII
                      dec    di
                      mov    [di], dl                     ; guardar dígito en buffer
                      inc    cx                           ; contar dígitos
                      cmp    ax, 0
                      jne    convertir_decimal

    ; Mostrar el resultado en pantalla
                      mov    ah, 09h
                      mov    dx, di
                      int    21h

    fin:              
                      mov    ax, 4C00h
                      int    21h

code endS
end main