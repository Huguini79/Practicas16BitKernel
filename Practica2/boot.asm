ORG 0x7c00
BITS 16

PE_BIT				EQU		1

; (Sección de código - Inicio de la GDT)
SEGMENTO_DE_CODIGO		EQU		GdtCodigo - GdtInicio

; (Sección de datos - Inicio de la GDT)
SEGMENTO_DE_DATOS		EQU		GdtDatos - GdtInicio

start:
	CLI
	
	; Inicializar los segmentos
	XOR		AX, AX
	MOV		DS, AX
	MOV		ES, AX
	
	; Inicializar la pila
	MOV		SS,  AX
	MOV		SP, 0x7c00
	
	CALL 	CargarGdt
	CALL 	HabilitarModoProtegido


CargarGdt:
	LGDT 	[DescriptorGdt]	; Cargamos en el procesador el descriptor gdt que contiene nuestra sección de código y de datos (Código: CS | Datos:  DS, GS, FS, ES, SS)
	RET

GdtInicio:
GdtNulo:
	DD	0x00
	DD	0x00

; (0-15 bits <- 16 bits offset) | (16-23 bits <- 8 bits offset) | (24-31 bits <- 8 bits offset)

GdtCodigo:
	DW	0xFFFF		; Límite
	DW	0x00		; Base (primeros 0-15 bits)	|	AQUÍ HEMOS DEFINIDO UN WORD (16 BITS), PORQUE ENTRE 0 Y 15, HAY 16 BITS DE DIFERENCIA
	DB	0x00		; Base (16-23 bits)		|	AQUÍ HEMOS DEFINIDO UN BYTE (QUE SON 8 BITS), POR ESO SON ENTRE 16 Y 23, Y HAY 8 BITS DE DIFERENCIA
	DB	0x9A		; Byte de acceso (es de 8 bits)
	DB	11001111b	; 4 Bits altos y 4 bits bajos (8 bits en total)
	DB	0x00		; Base (24-31 bits)

GdtDatos:
	DW	0xFFFF
	DW	0x00
	DB	0x00
	DB	0x92
	DB	11001111b
	DB	0x00

GdtFinal:

DescriptorGdt:
	; (Final de la Gdt - Inicio de la Gdt - 1)
	DW		GdtFinal - GdtInicio - 1
	DD		GdtInicio

HabilitarModoProtegido:
	MOV		EBX, CR0	; Mover a ebx el registro cr0
	OR		EBX, PE_BIT	; Perforar el PE_BIT (1)
	MOV		CR0, EBX	; Mover el resultado de ebx a la perforación del bit
	JMP DWORD	SEGMENTO_DE_CODIGO:Entrada32	; Hacer un far jump (salto largo) | Para saltar al código de 32 bits


; A partir de ahora, solo se ejecutará código de 32 bits en modo protegido
BITS 32

RestaurarSegmentos:
	MOV	AX, SEGMENTO_DE_DATOS
	MOV	DS, AX
	MOV	ES, AX
	MOV	SS, AX
	MOV	FS, AX
	RET


ImprimirCadena:
	MOV		EDI, 0xB8000
	MOV		AH, 0x0F
	
.relleno:
	MOV		AL, [ESI]
	CMP		AL, 0
	je .listo

	MOV		[EDI], AX
	ADD		EDI, 2
	inc esi
	
	jmp .relleno
	
.listo:
	ret
	
Entrada32:
	CALL	RestaurarSegmentos

	mov esi, mensaje
	
	call ImprimirCadena

	jmp .hang
	
.hang:
	jmp .hang

mensaje: db 'HOLA', 0

TIMES	510 - ($-$$) db 0
DW	0xAA55
