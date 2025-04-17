data segment
    msg     DB 'Ingresa un caracter: $'
    msg_out DB 'Caracter ingresado: $'
    newline DB 13,10,'$'
    char    DB ?
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

         MOV    DX, OFFSET msg
         MOV    AH, 09h
         INT    21h

         MOV    AH, 01h
         INT    21h
         PUSH   AX                           ; enviamos AL al stack ya que AL contiene el caracter ingresado por el usuario.

         MOV    DX, OFFSET newline
         MOV    AH, 09h
         INT    21h

         MOV    DX, OFFSET msg_out
         MOV    AH, 09h
         INT    21h

         POP    AX                           ; se obtiene el caracter desde la pila y se carga en AL
         MOV    DL, AL
         MOV    AH, 02h
         INT    21h

         mov    ax, 4C00h
         INT    21h

code endS

end main