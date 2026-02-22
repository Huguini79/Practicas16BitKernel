; Gestor de arranque creado por Huguini79, de 16 bits para la arquitectura x86
; Programando tranquilito y sin obsesionarme

; Documentación creada por Huguini79

; [PUERTAS LÓGICAS]

; Básicamente, las puertas lógicas activan un bit o lo desactivan, ponen de manera diferente, 0 o 1, en un bit específico
; Cuando a la funciones de puertas lógicas de ensamblador (and, or, not, xor ...), las llamamos, lo que hacen es iterar sobre cada bit que le pasemos y por ejemplo, en el caso de and, si en el destino y en el origen, en un bit específico, está los dos activados (1 y 1), devuelve positivo

; AND (CASI SIEMPRE ES 0, SALVO SI ES 1 | 1)
;	-> 0 | 0	->	0
;	-> 0 | 1	->	0
;	-> 1 | 0	->	0
;	-> 1 | 1	->	1

; OR (CASI SIEMPRE ES 1, SALVO SI ES 0 | 0)
;	-> 0 | 0	->	0
;	-> 0 | 1	->	1
;	-> 1 | 0	->	1
;	-> 1 | 1	->	1

; NOT (LO CONTRARIO)
;	-> 1		->	0
;	-> 0		->	1

; XOR (EN ALGUNOS CASOS ES 1, SALVO CUANDO LOS DOS BITS SON IGUALES)
;	-> 0 | 0	-> 0
;	-> 0 | 1	-> 1
;	-> 1 | 0	-> 1
;	-> 1 | 1	-> 0

[org 0x7c00]

; FUNCIÓN PRINCIPAL
start:
	; Deshabilitar interrupciones (Clear Interrupts)
	cli
	; Limpiar el registro ax (por si hay basura) <- básicamente, que ax sea 0
	xor ax, ax

	; Inicializar la pila
	mov ss, ax	; Stack Segment | Tenemos que poner el valor de ax (0) directamente en el segmento de la pila, porque directamente ensamblador no nos deja poner un 0
	mov sp, 0x7c00	; Stack Pointer | Ponemos en el puntero de la pila (esp en 32 bits) la dirección de carga de nuestro gestor de arranque (0x7c00)

	; Inicializar los segmentos
	mov ds, ax	; Data Segment | Poner el Segmento de Datos (DS) a 0
	mov es, ax	; Extra Segment | Poner el Segmento Adicional (ES) a 0 <- POR CIERTO, (ES) SE PARECE A LA ABREVIATURA DE ESPAÑA | VIVA ESPAÑAAAAAAAAAAAAAAAAAAA

	; Habilitar las interrupciones de nuevo (Set Interrupts)
	sti
	
	jmp main
	
main:
	; Mensaje de bienvenida
	mov si, bienvenida_msg		; Cargar el mensaje de bienvenida
	call PrintString

	; PCI
	
	call PciReadConfigurationWord
	
	; Entrar en un bucle infinito
	jmp $
	
PrintString:
	mov ah, 0x0E
	xor bh, bh	; Limpiar el atributo de página para que no haya basura
	mov bl, 15	; Color Blanco sobre fondo Negro

.loop:
	mov al, [si]	; Cargar el carácter al registro SI
	cmp al, 0		; Es el último carácter?
	je .done		; Finalizar el proceso
	
	int 0x10		; Imprimir el carácter
	inc si			; Mover hasta el siguiente carácter
	jmp .loop
	
.done:
	mov al, 0x0d
	int 0x10
	mov al, 0x0a
	int 0x10
	ret
	
PciReadConfigurationWord:

	; Ejemplo para leer 16 bits del espacio de configuración de un dispositivo PCI

	mov ah, PCI_FUNCTION_ID
	mov al, READ_CONFIG_WORD	; Leer 16 bits del espacio de configuración del dispositivo
	mov bh, 56			; Por ejemplo, dentro del rango de 256 buses, selecciono el bus 56
	mov bl, 5
	mov di, 2			; Register number

	int 0x1A			; Llamar a la syscall de la BIOS para llamar al servicio PCI para que lea los registros y nos de una respuesta (1Ah)
	
	cmp ah, BAD_REGISTER_NUMBER
	je bad_register_number

	cmp ah, SUCCESSFULL
	je successfull
	
	ret
	
successfull:
	mov si, pci_config_word_success_msg
	call PrintString
	ret
	
bad_register_number:
	mov si, pci_config_word_bad_msg
	call PrintString
	ret
	
; PCI MACROS

PCI_FUNCTION_ID			EQU		0xB1 ; (B1h)
READ_CONFIG_WORD		EQU		0x09 ; (09h)
SUCCESSFULL				EQU		0x00 ; (0)
BAD_VENDOR_ID			EQU		0x83 ; (83h)
FUNC_NOT_SUPPORTED		EQU		0x81 ; (81h)
DEVICE_NOT_FOUND		EQU		0x86 ; (86h)
BAD_REGISTER_NUMBER		EQU		0x87 ; (87h)
SET_FAILED				EQU		0x88 ; (88h)
BUFFER_TOO_SMALL		EQU		0x89 ; (89h)

pci_config_word_success_msg: db 'PciConfigReadWord: EXITO', 0
pci_config_word_bad_msg:	 db 'PciConfigReadWord: FALLO', 0

bienvenida_msg:		db	'WordOS ARRANCANDO CON EXITO', 0x0a, 0x0d, 0

times 510 - ($ - $$) db 0 ; Dejamos 2 bytes de espacio para la firma de arranque (0xAA55)
dw 0xAA55
