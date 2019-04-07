.section .data
	hash: .string "#"
	plus: .string "+"
	line: .string "-"
	str1: .string "%d \n"
	bn: .string "\n"
    brk_init: .quad 0x0
    brk_atual: .quad 0x0
    lista_livres: .quad 0x0
    lista_usados: .quad 0x0
    .equ PAGINA, 0x1000
    .equ BRK_CALL, 0xC

.section .text
.globl iniciaAlocador
.globl finalizaAlocador
.globl imprimeMapa
.globl alocaMem
.globl liberaMem

criaBloco:
    pushq %rbp
    movq %rsp, %rbp

    # rdi, rsi, rdx, rcx, r8

	movq %rsi, (%rdi)
    movq %rdx, 0x8(%rdi)
    movb %al, 0x10(%rdi)
    movq %r8, 0x11(%rdi)
    addq %r8, %rdi
    movq %r8, 0x19(%rdi)

    popq %rbp
    ret

# Função
iniciaAlocador:
    pushq %rbp
	movq %rsp, %rbp

    # Pega BRK
    movq $BRK_CALL, %rax
    movq $0x0, %rdi
    syscall

    movq %rax, brk_init
    movq %rax, brk_atual
    movq %rax, lista_livres

    addq $PAGINA, brk_atual

    movq $BRK_CALL, %rax
    movq brk_atual, %rdi
    syscall

    # rdi, rsi, rdx, rcx, r8
    movq lista_livres, %rdi
    movq $0x0, %rsi
    movq $0x0, %rdx
    movb $0x1, %al
    movq $PAGINA, %r8
    subq $0x21, %r8
    call criaBloco

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # Muda BRK
    movq $BRK_CALL, %rax
    movq brk_init, %rdi
    syscall

    popq %rbp
    ret

insere:
    pushq %rbp
    movq %rsp, %rbp

	pushq %rax

    # rdi, rsi
	movq (%rdi), %rax
    cmpq $0x0, %rax
	je vazio
	movq %rsi, (%rax)
    vazio:
    movq %rsi, (%rdi)

	popq %rax

    popq %rbp
    ret

deleta:
    pushq %rbp
    movq %rsp, %rbp

	pushq %rax
	pushq %rbx
	pushq %rcx
	pushq %rdx

	# rax = prox
	# rcx = anterior

	# rbx = temp
	movq 8(%rsi), %rax
    cmpq $0x0, %rax
    je fim_if_delet
    movq (%rsi), %rcx
    movq %rcx, (%rax)
    fim_if_delet:
    movq (%rsi), %rcx
    cmpq $0x0, %rcx
    je else
	movq 8(%rsi), %rbx
    movq %rbx, 8(%rcx)
    jmp fim_if_delet_II
    else:
    movq 8(%rsi), %rbx
    movq %rbx, (%rdi)
    fim_if_delet_II:

	popq %rdx
	popq %rcx
	popq %rbx
	popq %rax

	popq %rbp
    ret

imprimeMapa:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi
	pushq %rbx
	pushq %r12
	pushq %r13

	# r12 = aux
	# rbx = i
	# r13 = aux->tam
	movq brk_init, %r12
	while:

	cmpq brk_atual, %r12
	jge fim_while

	movq $0x0, %rbx
	for1:
	cmp $0x19, %rbx
	jge fim_for1

	pushq %rdi
	pushq %rsi
	pushq %rax
	pushq %rdx

	movq $0x1, %rax
	movq $0x1, %rdi
	movq $hash, %rsi
	movq $0x1, %rdx
	syscall

	popq %rdx
	popq %rax
	popq %rsi
	popq %rdi

	addq $0x1, %rbx
	jmp for1
	fim_for1:

	movq $0x0, %rbx
	movq 0x11(%r12), %r13
	for2:

	# r13 <- tamanho
	# rbx = i
	cmp %r13, %rbx
	jge fim_for2

	movb 0x10(%r12), %al
	cmpb $0x0, %al
	je ocupado
	movq $line, %rsi
	jmp fim_if_1
	ocupado:
	movq $plus, %rsi
	fim_if_1:
	pushq %rdi
	pushq %rsi
	pushq %rax
	pushq %rdx

	movq $0x1, %rax
	movq $0x1, %rdi
	movq $0x1, %rdx
	syscall

	popq %rdx
	popq %rax
	popq %rsi
	popq %rdi


	addq $0x1, %rbx
	jmp for2
	fim_for2:

	movq $0x0, %rbx
	for3:
	cmp $0x8, %rbx
	jge fim_for3

	pushq %rdi
	pushq %rsi
	pushq %rax
	pushq %rdx

	movq $0x1, %rax
	movq $0x1, %rdi
	movq $hash, %rsi
	movq $0x1, %rdx
	syscall

	popq %rdx
	popq %rax
	popq %rsi
	popq %rdi

	addq $0x1, %rbx
	jmp for3
	fim_for3:

	pushq %rdi
	pushq %rsi
	pushq %rax
	pushq %rdx

	movq $0x1, %rax
	movq $0x1, %rdi
	movq $bn, %rsi
	movq $0x1, %rdx
	syscall

	popq %rdx
	popq %rax
	popq %rsi
	popq %rdi

	addq 0x11(%r12), %r12
	addq $0x21, %r12
	jmp while
	fim_while:

	pushq %rdi
	pushq %rsi
	pushq %rax
	pushq %rdx

	movq $0x1, %rax
	movq $0x1, %rdi
	movq $bn, %rsi
	movq $0x1, %rdx
	syscall

	popq %rdx
	popq %rax
	popq %rsi
	popq %rdi

	popq %r13
	popq %r12
	popq %rbx
	popq %rdi

	popq %rbp
	ret

alocaMem:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi
	pushq %rsi
	# pushq %rax
	pushq %rbx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	pushq %r12

	# rdi = tam
	# rax = bloco
	# rbx = pos
	# rcx = tamEncontrado
	movq lista_livres, %rax

	cmpq brk_init, %rax
	jne continua

	continua:
	movq $0x0, %rbx
	cmpq $0x0, %rax
	je pula_else
	movq 0x11(%rax), %rcx
	addq $0x1, %rcx
	jmp pula_fim_if
	pula_else:
	movq $0x0, %rcx

	pula_fim_if:
	while_am:
	cmp $0x0, %rax
	je fim_while_am
	cmp  %rdi, 0x11(%rax)
	jl nao_cabe
	cmp 0x11(%rax), %rcx
	jle nao_best_fit
	movq %rax, %rbx
	movq 0x11(%rax), %rcx
	nao_best_fit:
	nao_cabe:
	movq 0x8(%rax), %rax


	jmp while_am
	fim_while_am:

	cmp $0x0, %rbx
	jne else_am
	movq %rdi, %r8
	addq $0x21, %r8
	movq $PAGINA, %r9
	# movq $0x1, %r10
	cabedor:
	cmp %r8, %r9
	jge cabe
	addq $PAGINA, %r9
	# addq $0x1, %r10
	jmp cabedor
	cabe:
	# r9 = alloc_size
	# sal $0xC, %r10
	movq brk_atual, %rbx
	addq %r9, brk_atual

	pushq %rax
	pushq %rdi
	movq $BRK_CALL, %rax
    movq brk_atual, %rdi
    syscall

	popq %rdi
	popq %rax

	movq %r9, %rcx

	# r11 = tam+infoGer
	movq $0x21, %r11
	addq %rdi, %r11

	cmp %r9, %r11
	jge fim_if_am_2
	movq %rdi, %rcx

	# r12 = alloc_size - (tam+2*infoGer)
	movq %r9, %r12
	subq %r11, %r12
	subq $0x21, %r12

	# r11 = tam+infoGer+pos
	addq %rbx, %r11

	# criaBloco(rdi, rsi, rdx, rcx, r8)
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8

	movq %r11, %rdi
	movq $0x0, %rsi
	movq lista_livres, %rdx
	movb $0x1, %al
	movq %r12, %r8

	call criaBloco

	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi


	pushq %rsi
	pushq %rdi

	movq %r11, %rsi
	movq $lista_livres, %rdi

	call insere

	popq %rdi
	popq %rsi

	fim_if_am_2:
	jmp fim_if_am
	else_am:
	pushq %rsi
	pushq %rdi

	movq %rbx, %rsi
	movq $lista_livres, %rdi

	call deleta

	popq %rdi
	popq %rsi

	# r8 = tam+infoGer
	movq %rdi, %r8
	addq $0x21, %r8
	cmp %rcx, %r8
	jge fim_if_am_3


	# r13 = pos+tam+infoGer
	movq %rbx, %r13
	addq %r8, %r13

	# r14 = tamEncontrado-tam-infoGer
	movq %rcx, %r14
	subq %r8, %r14

	# criaBloco(rdi, rsi, rdx, rcx, r8)
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8

	movq %r13, %rdi
	movq $0x0, %rsi
	movq lista_livres, %rdx
	movb $0x1, %al
	movq %r14, %r8

	call criaBloco

	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi

	pushq %rdi
	pushq %rsi

	movq $lista_livres, %rdi
	movq %r13, %rsi

	call insere

	popq %rsi
	popq %rdi

	# tamEncontrado <= tam
	movq %rdi, %rcx
	fim_if_am_3:

	fim_if_am:

	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	# criaBloco(rdi, rsi, rdx, rcx, r8)
	movq %rbx, %rdi
	movq $0x0, %rsi
	movq lista_usados, %rdx
	movb $0x0, %al
	movq %rcx, %r8

	call criaBloco

	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi

	pushq %rdi
	pushq %rsi

	movq $lista_usados, %rdi
	movq %rbx, %rsi

	call insere

	popq %rsi
	popq %rdi

	# return bloco+infoGer
	movq %rbx, %rax
	addq $0x19, %rax

	popq %r12
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rbx
	# popq %rax
	popq %rsi
	popq %rdi

	popq %rbp
	ret

liberaMem:
	pushq %rbp
	movq %rsp, %rbp

	# rbx = blocoant
	# rcx = blocoprox
	# rdi = bloco

	subq $0x19, %rdi

	movq %rdi, %rbx

	cmpq %rdi, brk_init
	je pula_lm
	subq -0x8(%rdi), %rbx
	subq $0x21, %rbx
	pula_lm:
	movq %rdi, %rcx
	addq 0x11(%rdi), %rcx
	addq $0x21, %rcx
	cmpq %rcx, brk_atual
	jg tem_prox
	movq %rdi, %rcx
	tem_prox:

	pushq %rsi
	pushq %rdi

	movq %rdi, %rsi
	movq $lista_usados, %rdi

	call deleta

	popq %rdi
	popq %rsi

	# criaBloco(rdi, rsi, rdx, rcx, r8)
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8

	movq %rdi, %rdi
	movq $0x0, %rsi
	movq lista_livres, %rdx
	movb $0x1, %al
	movq 0x11(%rdi), %r8

	call criaBloco

	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi

	pushq %rsi
	pushq %rdi

	movq %rdi, %rsi
	movq $lista_livres, %rdi

	call insere

	popq %rdi
	popq %rsi

	cmpb $0, 0x10(%rbx)
	je fim_if_lm_1
	cmpq %rdi, %rbx
	je fim_if_lm_1
	pushq %rsi
	pushq %rdi

	movq %rdi, %rsi
	movq $lista_livres, %rdi

	call deleta

	popq %rdi
	popq %rsi

	# r11 = canario
	# r12 = auxiliar

	movq 0x11(%rdi), %r12
	addq %r12, 0x11(%rbx)
	addq $0x21, 0x11(%rbx)

	movq %rdi, %r11
	addq $0x19, %r11
	addq 0x11(%rdi), %r11
	movq 0x11(%rbx), %r12
	movq %r12, (%r11)

	movq %rbx, %rdi

	fim_if_lm_1:

	cmpb $0x0, 0x10(%rcx)
	je fim_if_lm_2
	cmpq %rdi, %rcx
	je fim_if_lm_2
	pushq %rsi
	pushq %rdi

	movq %rdi, %rsi
	movq $lista_livres, %rdi

	call deleta

	popq %rdi
	popq %rsi

	pushq %rsi
	pushq %rdi

	movq %rcx, %rsi
	movq $lista_livres, %rdi

	call deleta

	popq %rdi
	popq %rsi

	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r12
	pushq %rax

	movq $0x21, %r8
	addq 0x11(%rdi), %r8
	addq 0x11(%rcx), %r8
	movq %r8, %r12

	movq %rdi, %rdi
	movq $0x0, %rsi
	movq lista_livres, %rdx
	movb $0x1, %al
	movq %r12, %r8

	call criaBloco

	popq %rax
	popq %r12
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi

	pushq %rsi
	pushq %rdi

	movq %rdi, %rsi
	movq $lista_livres, %rdi

	call insere

	popq %rdi
	popq %rsi

	fim_if_lm_2:

	popq %rbp
	ret
