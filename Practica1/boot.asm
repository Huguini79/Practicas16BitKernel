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

	mov ah, 0x0E
	mov al, 'A'
	int 0x10

	; Entrar en un bucle infinito
	jmp $

times 510 - ($ - $$) db 0 ; Dejamos 2 bytes de espacio para la firma de arranque (0xAA55)
dw 0xAA55
