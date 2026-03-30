 
global my_printf

section .text

;---------------------------------------------------------------------------;
;The function works with given string, whic is stored in rdi. The purpose   ;
;of it is to correctly interpretate given bytes, according to specificators.;
;The specificators are :%b, %c, %d, %o, %s, %x. It's a try to write printf. ;
;---------------------------------------------------------------------------;

my_printf:
;---------------------------------------------------------------------------;
;here starts the main loop. It reads every symbol from rdi and works with it;
;---------------------------------------------------------------------------;

        WRITING:
        cmp word [rel LEN], 256                 ;here and from then on , if 256 symbols were written - the buffer is filled
        jae STOP
        movzx r10, word [rel INDEX]             ;Index - the number of the symbol that we are to read from rdi
        mov al, [rdi + r10]                                    
        cmp al, 0                               ;if the NULL byte is given, we've read everything, so terminate              
        je STOP

        mov [rel SYMBOL], al                    ;inital value should be saved to use in case default
        cmp al, '%'                             ;the specificators are separated with %
        jne case_default                        ;if not % - just put the symbol in buf_to_wr

        movzx rbx, byte [rdi + r10 + 1]          

        cmp rbx, byte 'b'                       ;if % - check if the next symbol after it is within our range
        jb case_default
        cmp rbx, byte 'x'
        jg case_default

        jmp GET_CURRENT_VALUE                   ;if it's within the range - get the value from register, according to cdecl
GO_BACK:                                        ;the value is stored in rax

        lea r11, [rel jmp_table]                ;for choosing case, a jmp_table is used, according to the letter , it jumps
        jmp [r11 + (rbx-'b')*8]                 ;to the right address

;---------------------------------------------------------------------------;
;the algoritm is based in division. Until the quotient (stored in rax) is'nt;
; 0, the value of remainder (stored in rdx) is being stored in buffer:      ;
;convert_value(it's needed,because the symbols are written from             ;
; the lowest to the greatest). Then it copies symbols from convert_value    ;
; to buff_to_wr                                                             ;
;---------------------------------------------------------------------------;
        CONVERT:        

        push rdi                                ;save regs
        push rdx
        push r8 
        push rcx 

        lea r11, [rel buff_to_wr]               ;symbols will be written in r11:[r10]
        movzx r10, word [rel LEN]               
        lea rdi, [rel convert_value]
        xor r8, r8


.CONVERT_LOOP:
        xor rdx, rdx
        div r9                                  ;the remainder is in rdx, 

.SAFE:
        
        cmp dl, 9                               ;if the value is bellow - digit
	jbe .DIGIT

	add dl,	'A' - '9' - 1                   ;if not - letter
		
.DIGIT:
        add dl, '0'                             ;convert a digit to ASSCI
        mov byte [rdi + r8], dl                 ;put it in the array convert_value
        cmp rax, 0                              ;the sign of the end
        je .WRITE 
        inc r8                                  ;r8 here serves as an index
        jmp .CONVERT_LOOP 

.WRITE:                                          ;here is a loop, that rewrites symbols from convert_value to buff_to_wr from the greatest
        inc r8 
        mov rcx , r8 

.COPY:
        cmp word [rel LEN], 256
        jae .END
        dec r8
        movzx r10, word [rel LEN]               
        mov al, byte [rdi + r8]                 ;the symbols from convert_value are being written in buff_t_wr
        mov [r11 + r10], al
        add word [rel LEN], 1
loop .COPY
        add word [rel COUNTER], 1
        add word [rel INDEX], 2
.END:
        pop rcx
        pop r8
        pop rdx
        pop rdi
        ret
;---------------------------------------------------------------------------;
;the bytes are being written in the binary way with (1/0)                   ;
;---------------------------------------------------------------------------;
        case_b:
        cmp word [rel LEN], 256
        jae STOP

        push r9

        mov r9, 2                               ;rax will be divided by 2

        call CONVERT
        pop r9

        jmp WRITING

        

;---------------------------------------------------------------------------;
;It just writes a symbol in buff_to_wr and changes INDEX, COUNTER, LEN      ;
;---------------------------------------------------------------------------;

        case_c:
        cmp word [rel LEN], 256
        jae STOP
        lea r11, [rel buff_to_wr]               ;char case - it puts the symbol in r11:[r10] 
        movzx r10, word [rel LEN]
        mov [r11 + r10], byte al
        add word [rel COUNTER], 1               ;COUNTER is needed to control, form where should we get the informanion according to cdecl
        add word [rel INDEX], 2                 ;2 is added so that %c is skipped, the next symbol can be read
        add word [rel LEN], 1                   ;the real len of the symbols that will be written is incremented

        jmp WRITING                             

;--------------------------------------------------------------------------;
;the bytes are being written in the binary way with (0,...,9)             ;
;--------------------------------------------------------------------------;

        case_d:
        cmp word [rel LEN], 256
        jae STOP
        push r9
        mov r9, 10                               ;rax will be divided by 10

        call CONVERT

        pop r9
        jmp WRITING
;--------------------------------------------------------------------------;
;the bytes are being written in the binary way with (0,...,7)              ;
;--------------------------------------------------------------------------;
        case_o:

        cmp word [rel LEN], 256
        jae STOP
        push r9
        mov r9, 8                               ;rax will be divided by 8

        call CONVERT
        pop r9

        jmp WRITING
;---------------------------------------------------------------------------;
;this case is about printing a string, that is stored in rax. In a loop it  ;
;stores symbols in buff_to_wr, until the symbol is not '\0' or the buffer is;
;filled.                                                                     ;
;---------------------------------------------------------------------------;
        case_s:
        push rcx
        push r9
        lea r11, [rel buff_to_wr]               ;symbols will be written in r11:[r10]
        movzx r10, word [rel LEN] 
        xor rcx, rcx         
        mov ecx, 256   
        sub ecx, r10d                           ;the maximum amout of symbols, that can be written is
        xor r9, r9                              ;256 - current LEN.
.COPY:
        cmp word [rel LEN], 256
        jae .END
        cmp byte [rax + r9], 0
        je .END
        mov bl , [rax + r9]
        mov [r11 + r10], bl
        inc r9
        inc r10
        add word [rel LEN], 1
loop .COPY
.END:
        add word [rel INDEX], 2
        add word [rel COUNTER], 1
        pop r9
        pop rcx
        jmp WRITING

;--------------------------------------------------------------------------;
;the bytes are being written in the binary way with (0,...,9,A,..,F )      ;
;--------------------------------------------------------------------------;
        case_x:
        cmp word [rel LEN], 256
        jae STOP
        push r9
        mov r9, 16                               ;rax will be divided by 16

        call CONVERT
        pop r9
        jmp WRITING
;---------------------------------------------------------------------------;
;when we are not working with specificator - just print symbol              ;
;---------------------------------------------------------------------------;

        case_default:
        lea r11, [rel buff_to_wr]
        movzx r10, word [rel LEN]
        mov al, [rel SYMBOL]                    ;the initial value was stored in 'SYMBOL'
        mov [r11 + r10], byte al
        add  word [rel INDEX], 1
        add  word [rel LEN], 1
        jmp WRITING
;---------------------------------------------------------------------------;



        STOP:
        mov rdi, 1
        lea rsi, [rel buff_to_wr] 
        movzx rdx, word [rel LEN]
        mov rax, 1
        syscall
        ret

        GET_CURRENT_VALUE:
        lea r11, [rel jmp_table_reg]
        movzx r10, word [rel COUNTER]
        jmp [r11 + r10*8]
        


        case_rsi:                       
        mov rax, rsi                    ;the second argument is in rsi
        jmp GO_BACK     
        case_rdx:
        mov rax, rdx                    ;the third is in rdx
        jmp GO_BACK
        case_rcx:
        mov rax, rcx                    ;the forth is in rcx
        jmp GO_BACK
        case_r8:
        mov rax, r8                     ;the fifth is in r8
        jmp GO_BACK
        case_r9:
        mov rax, r9                     ;the sixth is in r9
        jmp GO_BACK
        case_stack:
        sub r10, 4                      ;after 6th argument , n-th is being stored in [rsp + 8*(n-6)]
        mov rax, [rsp + 8*r10]          ;according to the meaning of COUNTER, n-th is being stored in
        jmp GO_BACK                     ;[rsp+8*[COUNTER-4]]

section .data
;---------------------------------------------------------------------------;

        SYMBOL db 0
        LEN dw 0
        INDEX dw 0
        COUNTER dw 0
;---------------------------------------------------------------------------;

        buff_to_wr:
        times (256) db 0

;---------------------------------------------------------------------------;

        jmp_table:
        dq case_b
        dq case_c
        dq case_d
        times('o'-'d' - 1) dq case_default

        dq case_o

        times('s'-'o' - 1) dq case_default

        dq case_s

        times('x'-'s' - 1) dq case_default

        dq case_x
;---------------------------------------------------------------------------;

        jmp_table_reg:
        dq case_rsi
        dq case_rdx
        dq case_rcx
        dq case_r8
        dq case_r9
        times (250) dq case_stack
;---------------------------------------------------------------------------;

        convert_value:
        times (64) db 0
;---------------------------------------------------------------------------;

section .note.GNU-stack noalloc noexec nowrite progbits
