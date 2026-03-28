 
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

        case_b:
;---------------------------------------------------------------------------;
;It just writes a symbol in buff_to_wr and changes INDEX, COUNTER, LEN      ;
;---------------------------------------------------------------------------;

        case_c:

        lea r11, [rel buff_to_wr]               ;char case - it puts the symbol in r11:[r10] 
        movzx r10, word [rel LEN]
        mov [r11 + r10], byte al
        add word [rel COUNTER], 1               ;COUNTER is needed to control, form where should we get the informanion according to cdecl
        add word [rel INDEX], 2                 ;2 is added so that %c is skipped, the next symbol can be read
        add word [rel LEN], 1                   ;the real len of the symbols that will be written is incremented

        jmp WRITING                             

;---------------------------------------------------------------------------;
;the algoritm is based in division. Until the quotient (stored in rax) is'nt;
; 0, the value of remainder (stored in rdx) is being stored in buffer:      ;
;convert_value(it's needed,because the symbols are written from             ;
; the lowest to the greatest). Then it copies symbols from convert_value    ;
; to buff_to_wr                                                             ;
;---------------------------------------------------------------------------;

        case_d:
        push rdi                                ;save regs
        push rdx
        push r8 
        push r9
        push rcx 

        lea r11, [rel buff_to_wr]               ;symbols will be written in r11:[r10]
        movzx r10, word [rel LEN]               
        lea rdi, [rel convert_value]
        mov r9, 10                              ;rax will be divided by 10
        xor r8, r8
CONVERT_D:
        xor rdx, rdx
        div r9                                  ;the remainder is in rdx, 

SAFE:
        add dl, '0'                             ;convert a digit to ASSCI
        mov byte [rdi + r8], dl                 ;put it in the array convert_value
        cmp rax, 0                              ;the sign of the end
        je WRITE 
        inc r8                                  ;r8 here serves as an index
        jmp CONVERT_D  

WRITE:                                          ;here is a loop, that rewrites symbols from convert_value to buff_to_wr from the greatest
        inc r8 
        mov rcx , r8 

COPY:
        dec r8
        movzx r10, word [rel LEN]               
        mov al, byte [rdi + r8]
        mov [r11 + r10], al
        add word [rel LEN], 1
loop COPY
        add word [rel COUNTER], 1
        add word [rel INDEX], 2

        pop rcx
        pop r9 
        pop r8
        pop rdx
        pop rdi
        jmp WRITING
;---------------------------------------------------------------------------;

        case_o:
;---------------------------------------------------------------------------;

        case_s:
;---------------------------------------------------------------------------;
;the algorithm is based on cyclic permutation(it's useful to separate bytes);
;from each other. r8 is a flag if 00, null bytes are being skipped          ;
;---------------------------------------------------------------------------;

        case_x:
        push rcx
        push r8
        push rdx

        lea r11, [rel buff_to_wr]
        movzx r10, word [rel LEN]       ;bytes are being written in r11:r10

        mov rcx, 16                     ;all 8 bytes are to be converted
        xor r8, r8
	CONVERT_H:							
	rol rax, 4	                ;cyclic permutation to the left 1234 -> 4231
	mov dl, al                      ;denuvo
	and dl, 0Fh			;everything but the lowest byte in dl is 0
	
        cmp r8, 1                       ;until the first not null symbol was written - it skips zeroes
        je CONTINUE
        cmp dl, 0
        je SKIP

        CONTINUE:

	cmp dl, 9                       ;if the value is bellow - digit
	jbe DIGIT

	add dl,	'A' - '9' - 1           ;if not - letter
		
	DIGIT:
	add dl, '0'							
	

	mov [r11 + r10], dl
        mov r8, 1

	add r10, 1
        add word [rel LEN], 1

        SKIP:

	loop CONVERT_H

        add word [rel INDEX], 2
        add word [rel COUNTER], 1

        pop rdx
        pop r8
        pop rcx
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
        mov rax, rsi
        jmp GO_BACK
        case_rdx:
        mov rax, rdx
        jmp GO_BACK
        case_rcx:
        mov rax, rcx
        jmp GO_BACK
        case_r8:
        mov rax, r8
        jmp GO_BACK
        case_r9:
        mov rax, r9
        jmp GO_BACK
        case_stack:

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
        times (8) db 0
;---------------------------------------------------------------------------;

section .note.GNU-stack noalloc noexec nowrite progbits
