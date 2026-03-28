
global my_printf

section .text
my_printf:

        WRITING:
        movzx r10, word [rel INDEX]
        mov al, [rdi + r10]
        cmp al, 0
        je STOP

        cmp al, '%'
        jne case_default

        movzx rbx, byte [rdi + r10 + 1]

        cmp rbx, byte 'b'
        jb case_default
        cmp rbx, byte 'x'
        jg case_default

        jmp GET_CURRENT_VALUE
        GO_BACK:

        lea r11, [rel jmp_table]
        jmp [r11 + (rbx-'b')*8]

        jmp STOP
        

        case_b:

        case_c:

        lea r11, [rel buff_to_wr]
        movzx r10, word [rel LEN]
        mov [r11 + r10], byte al
        add word [rel COUNTER], 1
        add word [rel INDEX], 2
        add word [rel LEN], 1

        jmp WRITING

        case_d:
        push rdi
        push r8 
        push r9
        lea r11, [rel buff_to_wr]
        movzx r10, word [rel LEN]
        dec r10
        lea rdi, [rel convert_value]
        mov r9, 10
        xor r8, r8
        CONVERT_D:
        xor rdx, rdx
        div r9
        jmp SAFE        
        jmp CONVERT_D

        SAFE:
        add dl, '0'
        mov byte [rdi + r8], dl
        cmp rax, 0
        je WRITE 
        inc r8    
        jmp CONVERT_D  

        WRITE:
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

        pop r9 
        pop r8
        pop rdi
        jmp WRITING

        case_o:

        case_s:

        case_x:
        push rcx
        push r8
        push rdi

        lea r11, [rel buff_to_wr]
        movzx r10, word [rel LEN]

        mov rcx, 16
        xor r8, r8
	CONVERT_H:							
	rol rax, 4	
	mov dl, al                                                      ;denuvo
	and dl, 0Fh							;everything but the lowest byte in dl is 0
	
        cmp r8, 1 
        je CONTINUE
        cmp dl, 0
        je SKIP

        CONTINUE:

	cmp dl, 9
	jbe DIGIT

	add dl,	'A' - '9' - 1
		
	DIGIT:
	add dl, '0'							
	

	mov [r11 + r10], dl
        mov r8, 1

	add r10, 1
        add word [rel LEN], 1

        SKIP:

	loop CONVERT_H

        add word [rel INDEX], 2

        pop rdi
        pop r8
        pop rcx
        jmp WRITING

        case_default:
        lea r11, [rel buff_to_wr]
        movzx r10, word [rel LEN]
        mov [r11 + r10], byte al
        add  word [rel INDEX], 1
        add  word [rel LEN], 1
        jmp WRITING



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
        LEN dw 0
        INDEX dw 0
        COUNTER dw 0

        buff_to_wr:
        times (256) db 0


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

        jmp_table_reg:
        dq case_rsi
        dq case_rdx
        dq case_rcx
        dq case_r8
        dq case_r9
        times (250) dq case_stack

        convert_value:
        times (8) db 0
section .note.GNU-stack noalloc noexec nowrite progbits
