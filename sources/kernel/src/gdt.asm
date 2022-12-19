section .text

gdtr dw 0 ; For storing the limit parameter 
     dd 0 ; For storing the base parameter

LOAD_GDT:
    mov ax, [esp + 4] ; get the limit parameter from the stack
    mov [gdtr], ax    ; store limit parameter 
    mov eax, [esp + 8]; get the base parameter from the stack
    mov [gdtr + 2], eax ; store the base parameter
    lgdt [gdtr]
    ret 

