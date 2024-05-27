
;[BEGIN]
;//MODULE: VIDEO
;//CREATE: 19-05-1998	AUTHOR:	Denis Parinov
;//UPDATE: 24-10-1999	DNS	Restore	module
;---------------------------------------------------------------
;Rev	Date	   Name	Description
;---------------------------------------------------------------
;R01	07-11-2002 DNS	FIX BUG WITH SCROLLUP FN. (A=0)
;R02	07-11-2002 DNS	CORRECT FN. WINCOPY & WINREST, ADD "DI+EI"
;---------------------------------------------------------------

; CLEAR TEXT WINDOW
;=====================
; D - Y
; E - X
; H - HEIGHT
; L - WIDTH
; B - COLOR
; A - ATTR

CLEAR	LD	C,#8D
	RST	#08
	AND	A
	RET 
;

; PRINT NULL-TERMINATED CHARS STRING
;======================================
; HL - STRING POINTER

PCHARS
	LD	A,(HL)
	INC	HL
	OR	A
	RET	Z
	CALL	PUTCHAR
	JR	PCHARS

; PRINT CHAR
;==============
; A - CHAR

PUTCHAR
    LD         B,A
    LD         C,0x8e
    RST        0x08
    LD         A,B
    CP         0xd
    JR         Z,CR_
    CP         0xa
    JR         Z,LF_
    CP         0x9
    JR         Z,TB_
    CP         0x8
    JR         Z,BK_
    PUSH       HL
    LD         BC,0x182
    RST        0x08
    PUSH       AF
    LD         A,E
    CP         0x4f
    JP         NZ,NLFF
    LD         A,D
    CP         0x1f
    JP         NZ,NLFF
    LD         E,0x0
    LD         C,0x84
    RST        0x08
    CALL       LFF
NLFF
    POP        AF
    POP        HL
    RET

BK_ 
    LD         C,0x8e       ;GET CURSOR
    RST        0x08
    XOR        A
    CP         E
    JP         Z,LOCATE
    DEC        E
    JP         LOCATE    

TB_
    LD         C,0x8e
    RST        0x08
    LD         A,E
    ADD        A,0x8
    AND        0x78
    LD         E,A
    JP         LOCATE

CR_
    LD         C,0x8e
    RST        0x08
    LD         E,0x0
    JP         LOCATE

LF_
    LD         C,0x8e
    RST        0x08
    LD         A,D
    CP         0x1f
    JR         NC,LFF
    INC        D
    CALL       LOCATE
    JR         CR_

LFF
    PUSH       HL
    LD         BC,0x18a
    LD         DE,0x20
    EI
    HALT
    DI
    RST        0x08
    LD         DE,0x1f00
    PUSH       DE
    CALL       LOCATE
    LD         A,0x20
    LD         BC,0x5082
    RST        0x08
    EI
    POP        DE
    CALL       LOCATE
    POP        HL
    RET


; SET CURRENT CURSOR POSITION
;===============================
; D = Y
; E = X

LOCATE
	LD	C,#84
	RST	#08
	RET 

; GET CURRENT CURSOR POSITION
;===============================
;

CURSOR
	LD	C,#8E
	RST	#08
	RET 
; D - Y
; E - X

; READ CHAR & ATTR FROM THE SCREEN
;=============================
; D - Y
; E - X

RDCHAR
	XOR	A
	LD	C,#B4
	RST	#08
	LD	A,L
	LD	B,H
	AND	A
	RET 
; A - CHAR
; B - ATTR

; WRITE CHAR & ATTR TO THE SCREEN
;===================================
; D - Y
; E - X
; A - CHAR
; B - ATTR

WRCHAR	LD	C,A
	PUSH	BC
	PUSH	DE
	LD	C,#B4
	XOR	A
	RST	#08
	POP	DE
	POP	HL
	LD	C,#B5
	XOR	A
	RST	#08
	AND	A
	RET 

; COPY WINDOW FROM THE SCREEN
;===============================
; D - Y
; E - X
; H - HEIGHT
; L - WIDTH
; IX - ADDRESS
; B - PAGE, IF IX > 0C000H

WINCOPY
	LD	A,R	;R02
	PUSH	AF	;R02
	XOR	A
	DI		;R02
	LD	C,#B2
	RST	#08
	POP	AF	;R02
	SCF		;R02
	CCF		;R02
	RET	PO	;R02
	EI		;R02
	RET 

; RESTORE WINDOW TO THE SCREEN
;================================
; D - Y
; E - X
; H - HEIGHT
; L - WIDTH
; IX - ADDRESS
; B - PAGE, IF IX > 0C000H

WINREST
	LD	A,R	;R02
	PUSH	AF	;R02
	XOR	A
	DI		;R02
	LD	C,#B3
	RST	#08
	POP	AF	;R02
	SCF		;R02
	CCF		;R02
	RET	PO	;R02
	EI		;R02
	RET 

; SCROLL WINDOWS
;==================
; D - Y
; E - X
; H - HEIGHT
; L - WIDTH
; B - SCROLL DIRECTION
; B = 1 - SCROLL UP
; B = 2 - SCROLL DOWN
; A = 0 - CLEAR LINE
SCROLL
    DJNZ       SCR_DW
    LD         B,A
    LD         C,H
    PUSH       BC
    PUSH       DE
    PUSH       HL
    LD	XH,D
    LD	XL,E
    INC        D
    DEC        H
    XOR        A
    LD         C,0xb7
    DI
    RST        0x8
    EI
    POP        HL
    POP        DE
    POP        BC
    XOR        A
    CP         B
    RET        NZ
    LD         A,D
    ADD        A,H
    DEC        A
    LD         D,A

SCR1
    PUSH       DE
    CALL       LOCATE
    LD         A,0x20
    LD         B,L
    LD         C,0x82
    RST        0x8
    POP        DE
    CALL       LOCATE
    AND        A
    RET


SCR_DW
    DJNZ       SCR_ERR
    LD         B,A
    LD         C,L
    PUSH       DE
    PUSH       BC
    LD         XH,D
    LD         XL,E
    INC        XH
    DEC        H
    XOR        A
    LD         C,0xb7
    DI
    RST        0x8
    EI
    POP        HL
    POP        DE
    XOR        A
    CP         B
    JR         Z,SCR1
    RET

SCR_ERR
	LD	A,1
	SCF 
	RET 

; SELECT SCREEN PAGE
;======================
; B - SCREEN PAGE

SELPAGE
	PUSH	BC
	LD	A,(VMODE)
	BIT	7,A
	JR	NZ,SEL2
	LD	C,A
	CALL	TEXT_M
SEL2	POP	BC
	LD	A,B
	AND	#01
	OUT	(#C9),A
	RET 

; GET CURRENT VIDEO MODE
;==========================
;
GETVMOD
	IN	A,(#C9)
	LD	B,A
	LD	A,(VMODE)
	AND	A
	RET 
; A - MODE
; B - PAGE

; SET CURRENT VIDEO MODE
;==========================
; A - MODE
; B - PAGE

SETVMOD
	BIT	7,A
	LD	C,A
	JR	NZ,GRAPH

TEXT_M
	LD	IX,BACKTXT
	PUSH	IX
	EX	AF,AF'
	LD	A,(VMODE)
	LD	(VVMODE),A
	EX	AF,AF'
	INC	A
	DEC	A
	JR	Z,NOMODE
	DEC	A
	JR	Z,NOMODE
	DEC	A
	JR	Z,T_40_32
	DEC	A
	JR	Z,T_80_32
NOMODE
	POP	IX
	LD	A,#30
	SCF 
	RET 

GRAPH
	CALL	SAVETXT
	AND	#7F
	JP	Z,G320_16
	DEC	A
	JP	Z,G320_56
	DEC	A
	JP	Z,G640_16
	DEC	A
	JP	Z,G640_56
	LD	A,#30
	SCF 
	RET 

T_40_32
	PUSH	BC
	LD	HL,TAB2
	LD	A,B
	RLCA 
	RLCA 
	RLCA 
	RLCA 
	OR	B
	AND	#11
	XOR	#10
	LD	E,A
	CALL	SETMODE
	POP	BC
	LD	A,C
	LD	(VMODE),A
	LD	A,B
	AND	#01
	OUT	(#C9),A
	LD	A,(VMODE)
	LD	C,#81
	RST	#30
	LD	A,#C0
	OUT	(Y_PORT),A
	XOR	A
	RET 

T_80_32
	PUSH	BC
	LD	HL,TAB1
	LD	A,B
	RLCA 
	RLCA 
	RLCA 
	RLCA 
	OR	B
	AND	#11
	XOR	#10
	LD	E,A
	CALL	SETMODE
	POP	BC
	LD	A,C
	LD	(VMODE),A
	LD	A,B
	AND	#01
	OUT	(#C9),A
	LD	A,(VMODE)
	LD	C,#81
	RST	#30
	LD	A,#C0
	OUT	(Y_PORT),A
	XOR	A
	RET 

G320_16
	LD	A,#30
	SCF 
	RET 

G320_56
	PUSH	BC
	LD	HL,TAB4
	LD	E,#11
	CALL	SETMODE
	LD	HL,TAB8
	LD	E,#00
	CALL	SETMODE
	POP	BC
	LD	A,C
	LD	(VMODE),A
	LD	A,B
	AND	#01
	OUT	(#C9),A
	LD	A,(VMODE)
	LD	C,#81
	RST	#30
	LD	A,#C0
	OUT	(Y_PORT),A
	XOR	A
	RET 

G640_16	PUSH	BC
	LD	HL,TAB3
	LD	E,#11
	CALL	SETMODE
	LD	HL,TAB7
	LD	E,#00
	CALL	SETMODE
	POP	BC
	LD	A,C
	LD	(VMODE),A
	LD	A,B
	AND	#01
	OUT	(#C9),A
	LD	A,(VMODE)
	LD	C,#81
	RST	#30
	LD	A,#C0
	OUT	(Y_PORT),A
	XOR	A
	RET 

G640_56	LD	A,#30
	SCF 
	RET 

VMODE	DB	#03

;02h - TEXT 40 x 32 (16	colors)
;03h - TEXT 80 x 32 (16	colors)
;80h - GRAF 320	x 256 (16 colors)
;81h - GRAF 320	x 256 (256 colors)
;82h - GRAF 640	x 256 (16 colors)
;83h - GRAF 640	x 256 (256 colors) UNUSED

SETMODE
	PUSH	DE
	LD	DE,0xFEE0
	LD	BC,0x0020
	CALL	MOVBIOS
	POP	DE
	LD	IX,0xFEE0
	LD	C,0xB0
	RST	0x08
	LD	A,0xC0
	OUT	(Y_PORT),A
	XOR	A
	RET 

MOVBIOS	LD	A,R
	IN	A,(PAGE3)
	EX	AF,AF'
	LD	A,#FE
	OUT	(PAGE3),A
	LDIR 
	EX	AF,AF'
	OUT	(PAGE3),A
	RET	PO
	EI 
	RET 

;IX+0	;HORIZONTAL
;IX+1	;VERTICAL
;IX+2	;X - COORD
;IX+3	;Y - COORD
;IX+4	;MODE
;IX+5	;EXT MODE
;IX+6	;VIDEO RAM X OFFSET (SIGNPLACES)
;IX+7	;VIDEO RAM Y OFFSET (SIGNPLACES)

;80x32
TAB1	DB	#28,#20,#00,#00,#1B,#00,#00,#00
;40x32
TAB2	DB	#28,#20,#00,#00,#3B,#00,#00,#00
;640x256 PAGE 0
TAB3	DB	#28,#20,#00,#00,#00,#00,#00,#00
;320x256 PAGE 0
TAB4	DB	#28,#20,#00,#00,#20,#00,#00,#00
;640x256 PAGE 1
TAB7	DB	#28,#20,#00,#00,#40,#00,#28,#00
;320x256 PAGE 1
TAB8	DB	#28,#20,#00,#00,#60,#00,#28,#00

SAVETXT
	PUSH	AF
	LD	A,(VMODE)
	BIT	0x7,A
	JR	NZ,NOSAVET
	SUB	0x2
	JR	C,NOSAVET
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	AF
	LD	C,0x8e
	RST	0x08

	LD	(TCURS),DE
	POP	AF
	LD	IX,0xc000
	LD	DE,0x0
	LD	HL,0x2050
	OR	A
	JR	NZ,SVTEXT1
	LD	L,0x28
SVTEXT1
	LD	(SVHL1),HL
	LD	A,(BANKTBL+TXTPAGE)		;(BANKTBL_2) 
	LD	B,A
	XOR	A
	LD	C,0xb2
	DI
	RST	0x08
	EI
	POP	IX
	POP	HL
	POP	DE
	POP	BC
NOSAVET
	POP	AF
	RET


BACKTXT
    PUSH    AF
VVMODE	EQU	$+1
    LD         A,0x0
    RLCA
    JR         NC,NOBACKT
    PUSH       BC
    PUSH       DE
    PUSH       HL
    PUSH       IX
    LD         IX,0xc000
    LD         DE,0x0
SVHL1	EQU	$+1
    LD         HL,0x2050
    LD         A,(BANKTBL+TXTPAGE)
    LD         B,A
    XOR        A
    LD         C,0xb3
    DI
    RST        0x8
    EI
TCURS	EQU	$+1
    LD         DE,0x0
    LD         C,0x84
    RST        0x8
    POP        IX
    POP        HL
    POP        DE
    POP        BC
NOBACKT
    POP        AF
    RET
    
; SEND A SYMBOL TO THE PRINTER
;==============================
; A - SYMBOL
;
LPT_A	EQU	#1B
LPT_B	EQU	#1C

PRINT
	LD	B,A
	LD	A,R
	LD	A,B
	DI 
	PUSH	AF
	XOR	A
	OUT	(LPT_A),A
	LD	A,#10
	OUT	(LPT_A),A
	XOR	A
	OUT	(LPT_A),A
	IN	A,(LPT_A)
    LD C,A
	; IN (1Bh): bit 5 - busy, Bit 3 - Ack
    ; IN (19h): bit 5 - Paper Enable, Bit 3 - Select

	BIT	5,A
	JR	NZ,LPTBUSY
    AND	0xd8
    JR	Z,LPTBUSY
    LD	A,B
    OUT	(LPT_B),A
    POP	AF
    SCF
    CCF
    RET	PO
    EI
    RET

LPTBUSY
	POP	AF
    LD A,C
	SCF 
	RET	PO
	EI 
	RET 

; B - SYMBOL
; CF = 1 - PRINTER BUSY

PRINT_INIT
	DI
	LD	A,#CF ; port 1F только чеpез LD BC,1F: Out (BC),reg !!!
	LD	BC,#001F
	OUT	(C),A
	LD	A,#63
	OUT	(C),A
	LD	A,#C0 ; Bit 7 - Select (1), Bit 6 - Auto_Line_Feed (1)
	OUT	(#1E),A
	LD	A,#0F ; Init printer port for Out
	OUT	(#1D),A
	RET


;//MODULE: VIDEO
;[END]
