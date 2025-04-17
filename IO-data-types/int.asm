data segment
    mensaje_entrada DB 'Ingrese un numero entero: $'
    mensaje_salida  DB 0Dh, 0Ah, 'El numero ingresado es: $'
    buffer          DB 6                                        ; Tamaño máximo del buffer (5 caracteres + 1 byte para la longitud real)
                    DB 0                                        ; Número de caracteres leídos (se llenará automáticamente)
    numero          DB 6 dup(0)                                 ; Espacio para los caracteres ingresados y el terminador
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
    
    ; Mostrar mensaje de salida
                   MOV    AH, 09h
                   LEA    DX, mensaje_salida
                   INT    21h
    
    ; Mostrar el número ingresado
                   LEA    DI, buffer + 2
                   MOV    BL, [buffer + 1]             ;cargamos la cantidad de caracteres leidos en BL
                   MOV    BH, 0
                   MOV    CL, BL                       ;cargamos BL en CL (ahora CL se repite tantas veces como caracteres leidos)
                   MOV    CH, 0
                   ADD    DI,CX
                   DEC    DI

    APILAR_NUMERO: 
                   CMP    CX, 0
                   JE     MOSTRAR_NUMERO
                   MOV    DL, [DI]                     ; Obtener el carácter
                   MOV    AL, DL
                   PUSH   AX
                   DEC    DI                           ; Avanzar al siguiente carácter
                   DEC    CX
                   JMP    APILAR_NUMERO

    MOSTRAR_NUMERO:
                   MOV    CL, BL                       ; Nuevamente cargamos la cantidad de caracteres por leer. Aunque tal vez se puede trabajar con la pila
                   MOV    CH, 0
                   MOV    AH, 02h                      ; Función para mostrar caracteres
    MOSTRAR_CICLO: 
                   CMP    CX, 0
                   JE     TERMINAR
                   POP    DX                           ; Obtener el carácter
                   MOV    AH, 02h                      ; Función para mostrar un carácter
                   INT    21h
                   INC    DI                           ; Avanzar al siguiente carácter
                   DEC    CX
                   JMP    MOSTRAR_CICLO                ; Repetir hasta mostrar todos los caracteres
    TERMINAR:      
                   mov    ax, 4C00h
                   INT    21h

code endS

end main