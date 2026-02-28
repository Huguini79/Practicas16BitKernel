; Gestor de arranque que entra en modo protegido
; Creado por Huguini79

ORG 0x7c00
BITS 16

SELECTOR_DE_CODIGO		EQU		0x08
SELECTOR_DE_DATOS		EQU		0x10

PE_BIT					EQU		1

start:
	; Deshabilitar interrupciones
	CLI
	
	; Inicializar los segmentos
	MOV AX, 0
	MOV DS, AX
	MOV ES, AX

	; Inicializar la pila
	MOV SS, AX
	MOV SP, 0x7c00

	; Cargar el software necesario para la inicialización del modo protegido (32 bits)
	CALL CargarGdt
	
	; Habilitar el modo protegido
	CALL HabilitarModoProtegido
	
HabilitarModoProtegido:
	MOV EBX, CR0						; Mover CR0 a EBX
	OR EBX, PE_BIT						; Activar el PE_BIT en EBX
	MOV CR0, EBX						; Mover el resultado de la operación lógica a CR0
	JMP SELECTOR_DE_CODIGO:Inicio32		; Hacer un far jump al código de 32 bits


CargarGdt:
	; Cargamos la GDT en el procesador
	; En sí, cargamos Gdtr, que gdtr contiene el límite e inicio de nuestro descriptor gdt, y a su vez en el descriptor gdt tenemos los segmentos (nulo (NULL), código (CS), datos (DS, FS, GS, ES, SS)
	LGDT [Gdtr]
	RET


; Descriptor Gdt
DescriptorGdtInicio:


; Segmento nulo (NULL) (Offset: 0x00000000)
GdtNulo:
	DD 0
	DD 0

; Segmento de código (Offset: 0x08)
GdtCodigo:
	DW 0xFFFF	; Límite (16 bits)
	DW 0		; Base primeros 16 bits (0-15 bits)
	DB 0		; Base 8 bits (16-23 bits)
	DB 0x9A		; Byte de acceso (8 bits)
	DB 0xCF 	; 11001111H		|		FLAGS
	DB 0		; Base 8 bits (24-31 bits)

; Segmento de datos (Offset: 0x10)
GdtDatos:
	DW 0xFFFF	; Límite (16 bits)
	DW 0		; Base primeros 16 bits (0-15 bits)
	DB 0		; Base 8 bits (16-23 bits)
	DB 0x92		; Byte de acceso (8 bits)
	DB 0xCF		; 11001111h		|		FLAGS
	DB 0		; Base 8 bits (24-31 bits)


; Final del descriptor GDT
DescriptorGdtFinal:

; Tabla Gdt (Registro Gdt -> Gdtr)
Gdtr:
	; Gdtr contiene el descriptor GDT
	DW DescriptorGdtFinal - DescriptorGdtInicio - 1	; Límite (16 bits)
	DD DescriptorGdtInicio							; Base (32 bits)

[BITS 32]

RestaurarRegistrosDeSegmento:
	MOV AX, SELECTOR_DE_DATOS	; Offset 0x10
	
	MOV DS, AX
	MOV SS, AX
	MOV ES, AX
	MOV FS, AX
	MOV GS, AX
	
	RET

LimpiarPantalla:
	MOV EDI, 0xB8000
	MOV ECX, 80 * 25	; El registro ECX según el manual de intel, se usa para bucles		|		VGA MODO TEXTO (RESOLUCIÓN 80x25)
	MOV AX, 0x0720

.bucle_de_limpieza:
	MOV [EDI], AX
	ADD EDI, 2
	loop .bucle_de_limpieza
	
	RET

Inicio32:
	; Restaurar los registros de segmento para que apunten al selector de datos
	CALL RestaurarRegistrosDeSegmento
	
	CALL LimpiarPantalla
	
	MOV EDI, 0xB8000
	MOV AH, 0x0F
	
	MOV AL, 'H'		; Un carácter son 8 bits (1 byte)
	MOV [EDI], AX	; Meter en EDI el carácter
	ADD edi, 2		; Pasar posición
	
.hang:
	jmp .hang

TIMES 510 - ($ - $$) DB 0
DW 0xAA55
