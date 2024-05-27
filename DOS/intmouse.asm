
;[BEGIN]
;//MODULE: INTMOUSE
;//CREATE: 19-05-1998	AUTHOR:	Denis Parinov
;//UPDATE: 24-10-1999	DNS	Restore	module

CMOUSE	EQU	#1B
DMOUSE	EQU	#1A
Y_PORT	EQU	#89
VPAGE	EQU	#C9

; MOUSE	SOFTWARE SPECIFICATION
;---------------------------------------------
; COMMAND 00h (INITIALIZATION)
;
;  RETURN: NC -	MOUSE PRESENT
;	    C -	MOUSE ABSENT
;---------------------------------------------
; COMMAND 01h (SHOW MOUSE CURSOR)
;
;  RETURN: NC -	DONE
;	    C -	MOUSE ON SCREEN
;---------------------------------------------
; COMMAND 02h (HIDE MOUSE CURSOR)
;
;  RETURN: NC -	DONE
;	    C -	NONE MOUSE
;---------------------------------------------
; COMMAND 03h (READ MOUSE STATE)
;
;  RETURN: HL -	X COORD
;	   DE -	Y COORD
;	    A -	BUTTONS	D2-D0 (MIDDLE,RIGHT,LEFT)
;---------------------------------------------
; COMMAND 04h (GOTO MOUSE CURSOR)
;
;   INPUT: HL -	X COORD
;	   DE -	Y COORD
;---------------------------------------------
; COMMAND 05h (RESERVED)
;---------------------------------------------
; COMMAND 06h (RESERVED)
;---------------------------------------------
; COMMAND 07h (SET VERT. BOUNDS)
;
;   INPUT: HL -	Y MIN
;	   DE -	Y MAX
;---------------------------------------------
; COMMAND 08h (SET HORZ. BOUNDS)
;
;   INPUT: HL -	X MIN
;	   DE -	X MAX
;---------------------------------------------
; COMMAND 09h (LOAD CURSOR)
;
;   INPUT: IX -	CURSOR IMAGE
;	    H -	HEIGHT CURSOR
;	    L -	WIDTH CURSOR
;	    D -	Y HOT SPOT
;	    E -	X HOT SPOT
;	    B =	0
;---------------------------------------------
; COMMAND 0Ah (SET CURSOR IN TEXT MODES)
;
;   INPUT: H - AND SIMBOL MASK
;	   L - XOR SIMBOL MASK
;	   D - AND ATTRIBUT MASK
;	   E - XOR ATTRIBUT MASK
;	   B = 0
;---------------------------------------------
; COMMAND 0Bh (RETURN CURSOR)
;
;   INPUT: IX -	CURSOR IMAGE BUFFER
;  OUTPUT:  H -	HEIGHT CURSOR
;	    L -	WIDTH CURSOR
;	    D -	Y HOT SPOT
;	    E -	X HOT SPOT
;---------------------------------------------
; COMMAND 0Ch (RESERVED)
;---------------------------------------------
; COMMAND 0Dh (RESERVED)
;---------------------------------------------
; COMMAND 0Eh (GET SENSETIVE)
;  OUTPUT: H - VERTICAL	SENSETIVE
;	   L - HORIZONTAL SENSETIVE
;---------------------------------------------
; COMMAND 0Fh (SET SENSETIVE)
;   INPUT: H - VERTICAL	SENSETIVE
;	   L - HORIZONTAL SENSETIVE
;---------------------------------------------
; COMMAND 80h (MOUSE HARDWARE INTERRUPT)
;---------------------------------------------
; COMMAND 81h (CHANGE VIDEO MODE)
;   INPUT: A - MODE
;---------------------------------------------
; COMMAND 82h (RESERVED)
;---------------------------------------------
; COMMAND 83h (MOUSE REFRESH)
;---------------------------------------------
; ERRORS:  0 - NO ERROR
;	   1 - COMMAND NOT PRESENT
;	   2 - DEVICE ABSENT
;	   3 - CURSOR ON (UZHE)
;	   4 - CURSOR OFF (UZHE)
;	   5 - CURSOR IMAGE VERY BIG

INTMOUS
	BIT	7,C
	JR	NZ,EMOUSE
	INC	C
	DEC	C
	JR	Z,MS_INIT
	DEC	C
	JP	Z,MS_SHOW
	DEC	C
	JP	Z,MS_HIDD
	DEC	C
	JP	Z,MS_READ
	DEC	C
	JP	Z,MS_GOTO
	DEC	C
	JP	Z,MS_RESR           ; TODO: JR?
	DEC	C
	JR	Z,MS_RESR
	DEC	C
	JP	Z,MS_VERT
	DEC	C
	JP	Z,MS_HORZ
	DEC	C
	JP	Z,MS_CURS
	DEC	C
	JP	Z,MS_MASK
	DEC	C
	JP	Z,MS_BCUR
	DEC	C
	JR	Z,MS_RESR
	DEC	C
	JR	Z,MS_RESR
	DEC	C
	JP	Z,MS_GSEN
	DEC	C
	JP	Z,MS_SENT

MS_RESR
    LD	A,1
	SCF 
	RET 

EMOUSE
	RES	7,C
	INC	C
	DEC	C
	JP	Z,M_INT
	DEC	C
	JP	Z,M_MODE
	DEC	C
	JR	Z,M_RESR
	DEC	C
	JP	Z,M_REFR
M_RESR
	LD	A,1
	SCF 
	RET 

MS_INIT
	DI 
	LD	A,85
	OUT	(#10),A
	LD	A,45
	OUT	(#10),A
	LD	A,0
	OUT	(CMOUSE),A
	LD	A,1
	OUT	(CMOUSE),A
	LD	A,0
	OUT	(CMOUSE),A
	LD	A,3
	OUT	(CMOUSE),A
	LD	A,#41
	OUT	(CMOUSE),A
	LD	A,4
	OUT	(CMOUSE),A
	LD	A,#47
	OUT	(CMOUSE),A
	LD	A,5
	OUT	(CMOUSE),A
	LD	A,#E0
	OUT	(CMOUSE),A
	EI 
	XOR	A
	RET 

MS_SHOW
	PUSH	IX
	PUSH	HL
	PUSH	DE
	EX	AF,AF'
	PUSH	AF
	LD	HL,(PIX_X)
	LD	DE,(PIX_Y)
	DI 
	CALL	MOUSE
	LD  A,1
	LD	(REFRESH+1),A
	EI 
	POP	AF
	EX	AF,AF'
	POP	DE
	POP	HL
	POP	IX
	XOR	A
	RET 

MS_HIDD
	PUSH	IX
	PUSH	HL
	PUSH	DE
	EX	AF,AF'
	PUSH	AF
	DI 
	XOR A
	LD	(REFRESH+1),A
	CALL	RESTORE
	EI 
	POP	AF
	EX	AF,AF'
	POP	DE
	POP	HL
	POP	IX
	XOR	A
	RET 

MS_READ
	LD	HL,(PIX_X)
	LD	DE,(PIX_Y)
	LD	A,(MB)
	AND	A
	RET 

MS_GOTO
	PUSH	IX
	PUSH	HL
	PUSH	DE
	LD	(PIX_X),HL
	LD	(PIX_Y),DE
	EX	AF,AF'
	PUSH	AF
	DI 
	CALL	REFRESH
	EI 
	POP	AF
	EX	AF,AF'
	POP	DE
	POP	HL
	POP	IX
	XOR	A
	RET 

MS_CURS
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	LD	A,L
	LD	(M_XSIZE),A
	LD	A,H
	LD	(M_YSIZE),A
	LD	C,E
	LD	B,0
	LD	(XHOT_SP),BC
	LD	C,D
	LD	(YHOT_SP),BC
	EXX 
	LD	A,(M_XSIZE)
	LD	C,A
	LD	B,0
	LD	A,(M_YSIZE)
	LD	L,B
    LD  H,B

MSCURS1
	ADD	HL,BC
	DEC	A
	JR	NZ,MSCURS1
	PUSH	HL
	LD	BC,MAXSIZM+1
	AND	A
	SBC	HL,BC
	CCF 
	EXX 
	POP	BC
	POP	HL
	LD	A,5
	JR	C,NOLOADM
	LD	DE,M_IMAGE
	DI 
	LDIR 
	XOR	A
NOLOADM
	POP	HL
	POP	DE
	POP	BC
	EI 
	RET 

MS_BCUR
	PUSH	IX
	EXX 
	LD	A,(M_XSIZE)
	LD	C,A
	LD	B,0
	LD	A,(M_YSIZE)
	LD	L,B
    LD  H,B

MSBCUR1
	ADD	HL,BC
	DEC	A
	JR	NZ,MSBCUR1
	PUSH	HL
	LD	BC,MAXSIZM+1
	AND	A
	SBC	HL,BC
	CCF 
	EXX 
	POP	BC
	POP	HL
	LD	A,5
	JR	C,NOSAVEM
	LD	DE,M_IMAGE
	EX	DE,HL
	DI 
	LDIR 
	LD	HL,(M_XSIZE)
	LD	BC,(XHOT_SP)
	LD	E,C
	LD	BC,(YHOT_SP)
	LD	D,C
    XOR A
	LD  C,A
    LD  B,A

NOSAVEM
	EI 
	RET 

MS_HORZ
	LD	(MIN_X),HL
	LD	(MAX_X),DE
	XOR	A
	RET 

MS_VERT
	LD	(MIN_Y),HL
	LD	(MAX_Y),DE
	XOR	A
	RET 

MS_MASK
	LD	(ANDXORS),HL
	LD	(ANDXORA),DE
	XOR	A
	RET 

; H - VERTICAL SENSETIVE
; L - HORIZONTAL SENSETIVE

MS_SENT
	LD	(SENSEXY),HL
	XOR	A
	RET 

MS_GSEN
	LD	HL,(SENSEXY)
	XOR	A
	RET 

MOUSET
	LD	(REST_XT+1),HL
	LD	(REST_YT+1),DE
;Y
	SRL	D
	RR	E
	SRL	D
	RR	E
	SRL	D
	RR	E
	LD	D,E
;X
	SRL	H
	RR	L
	SRL	H
	RR	L
	SRL	H
	RR	L
	LD	E,L

	IN	A,(Y_PORT)
	LD	XH,A
	IN	A,(PAGE1)
	LD	XL,A
;
	DI 
;
	LD	A,#54
	OUT	(PAGE1),A
;
	LD	A,D
	ADD	A,A
	ADD	A,A	;Y * 4
	LD	L,A
	LD	H,#43	;+ #4300
;
	IN	A,(VPAGE)
	RRCA 
	AND	#80
	OR	#01
	ADD	A,E
	OUT	(Y_PORT),A
	INC	L
	LD	A,(HL)	;SIMBOL
	LD	BC,(ANDXORS)
	AND	B
	XOR	C
	LD	(HL),A
	INC	L
	LD	A,(HL)	;ATTRIBUT
	LD	BC,(ANDXORA)
	AND	B
	XOR	C
	LD	(HL),A
;
	LD	A,XL
	OUT	(PAGE1),A
	LD	A,XH
	OUT	(Y_PORT),A
	RET 

RESTORT
REST_XT	
    LD	HL,#0000
REST_YT	
    LD	DE,#0000
;Y
	SRL	D
	RR	E
	SRL	D
	RR	E
	SRL	D
	RR	E
	LD	D,E
;X
	SRL	H
	RR	L
	SRL	H
	RR	L
	SRL	H
	RR	L
	LD	E,L

	IN	A,(Y_PORT)
	LD	XH,A
	IN	A,(PAGE1)
	LD	XL,A
;
	DI 
;
	LD	A,#50
	OUT	(PAGE1),A
;
	LD	A,D
	ADD	A,A
	ADD	A,A	;Y * 4
	LD	L,A
	LD	H,#43	;+ #4300
;
	IN	A,(VPAGE)
	RRCA 
	AND	#80
	OR	#01
	ADD	A,E
	OUT	(Y_PORT),A
	INC	L
	LD	A,(HL)	;SIMBOL
	LD	(HL),A
	INC	L
	LD	A,(HL)	;ATTRIBUT
	LD	(HL),A
;
	LD	A,XL
	OUT	(PAGE1),A
	LD	A,XH
	OUT	(Y_PORT),A
	RET 

RESTORE
	LD	A,#00
	BIT	7,A
	JR	Z,RESTORT
RESTORG
	IN	A,(PAGE3)
	LD	B,A
	IN	A,(Y_PORT)
	LD	C,A
	PUSH	BC
	LD	A,#50
	OUT	(PAGE3),A
REST_X	LD	HL,0
REST_Y	LD	DE,0
	LD	A,E
	EX	AF,AF'
REST_V	LD	A,#00
	AND	1
	LD	DE,#C000	;PAGE 0
	JR	Z,AA2
	LD	DE,#C000+320	;PAGE 1
AA2	ADD	HL,DE
REST_A	LD	A,0
	LD	XH,A
	EX	AF,AF'
REST_H
RS002	LD	BC,10
	OUT	(Y_PORT),A
	EX	AF,AF'
;	PUSH	HL
	LD	(PUSH_HL+1),HL
	LD	D,H
	LD	E,L
	LDIR 
PUSH_HL	LD	HL,#0000
;	POP	HL
	EX	AF,AF'
	INC	A
	JR	Z,RS003
	DEC	XH
	JR	NZ,RS002
RS003	POP	BC
	LD	A,B
	OUT	(PAGE3),A
	LD	A,C
	OUT	(Y_PORT),A
	XOR	A
	RET 

;HL/DE - X/Y

MOUSE
	LD	A,(MODE)
	LD	(RESTORE+1),A
	BIT	7,A
	JP	Z,MOUSET
MOUSEG
	CP	#82	;640x256x16
	JR	NZ,NOFX
	SRL	H
	RR	L
NOFX
	LD	IX,M_IMAGE
	LD	A,(M_XSIZE)
	LD	C,A
	LD	B,0
	LD	(REALXS),BC
	LD	(REST_H+1),BC
	LD	C,B
	LD	(SKIPXF),BC
	LD	A,(M_YSIZE)
	LD	(REST_A+1),A
	LD	C,A
	LD	B,0
	LD	(REALYS),BC
	LD	BC,(YHOT_SP)
	LD	A,E
	SUB	C
	LD	E,A
	JR	NC,GOODY
	NEG 
	LD	E,A
	LD	A,(M_XSIZE)
	LD	C,A
	LD	B,0
	LD	A,(M_YSIZE)
	SUB	E
SKIPMY
	ADD	IX,BC
	DEC	E
	JR	NZ,SKIPMY
	LD	C,A
	LD	(REALYS),BC
GOODY
	LD	BC,(XHOT_SP)
	AND	A
	SBC	HL,BC
	JR	NC,GOODX
	LD	B,H
	LD	C,L
	LD	HL,0
	AND	A
	SBC	HL,BC
	LD	(SKIPXF),HL
	LD	A,(M_XSIZE)
	SUB	L
	LD	L,A
	LD	(REALXS),HL
	LD	HL,0
GOODX
	LD	(REST_X+1),HL
	LD	(REST_Y+1),DE

	PUSH	HL
	IN	A,(PAGE3)
	LD	H,A
	IN	A,(Y_PORT)
	LD	L,A
	EX	(SP),HL
	LD	A,#5C
	OUT	(PAGE3),A
	LD	A,E
	EX	AF,AF'
	IN	A,(VPAGE)
	LD	(REST_V+1),A
	AND	1
	LD	DE,#C000	;PAGE 0
	JR	Z,AA1
	LD	DE,#C000+320	;PAGE 1
AA1	ADD	HL,DE
	LD	D,XH
	LD	E,XL
	EX	DE,HL	;HL - BITMAP
	LD	BC,(REALYS)
	LD	XH,C
	EX	AF,AF'
MS002	LD	BC,(SKIPXF)
	ADD	HL,BC
	LD	BC,(REALXS)
	OUT	(Y_PORT),A
	EX	AF,AF'
	;USH	DE
	LD	(PUSH_DE+1),DE
	LDIR 
PUSH_DE	LD	DE,#0000
;	POP	DE
	EX	AF,AF'
	INC	A
	JR	Z,MS003
	DEC	XH
	JR	NZ,MS002
MS003	POP	BC
	LD	A,B
	OUT	(PAGE3),A
	LD	A,C
	OUT	(Y_PORT),A
	XOR	A
	RET 

READ_M
	LD	A,(M_VAR_Y)
    LD  E,A
    LD  BC, 0xFFDF
    IN  A,(C)
    LD (M_VAR_Y), A
    LD (M_VAR_Y2), A
    SUB E
    NEG
    LD	D,A
    LD	A,(M_VAR_X)
    LD	E,A
    LD	B,0xfb
    IN	A,(C)
    LD	(M_VAR_X),A
    LD	(M_VAR_Y2),A
    SUB	E
    LD	E,A
    LD	B,0xfa
    IN	A,(C)
    CPL
    AND	0x7
    LD	(MB),A
    LD	A,(M_VAR_Y2)
    OR	A
    RET	Z
    CALL	SENSE
    LD	(MX),DE
    XOR	A
    LD	(M_VAR_Y2),A
    SCF
    RET

M_VAR_Y2    DB  0x00

MCORECT
	LD	HL,(PIX_X)
	LD	DE,(MX)
	LD	D,0
	BIT	7,E
	JR	NZ,DECX
	ADD	HL,DE
	LD	(PIX_X),HL
	EX	DE,HL
	LD	HL,(MAX_X)
	AND	A
	SBC	HL,DE
	JR	NC,YCOO
	LD	HL,(MAX_X)
	LD	(PIX_X),HL
	JR	YCOO

DECX
	LD	A,E
	NEG 
	LD	E,A
	AND	A
	SBC	HL,DE
	LD	(PIX_X),HL
	JR	C,YCOO2
	LD	DE,(MIN_X)
	SBC	HL,DE
	JR	NC,YCOO
YCOO2
	LD	HL,(MIN_X)
	LD	(PIX_X),HL

YCOO
	LD	HL,(PIX_Y)
	LD	DE,(MY)
	LD	D,0
	BIT	7,E
	JR	NZ,DECY
	ADD	HL,DE
	LD	(PIX_Y),HL
	EX	DE,HL

	LD	HL,(MAX_Y)
	AND	A
	SBC	HL,DE
	RET	NC
	LD	HL,(MAX_Y)
	LD	(PIX_Y),HL
	RET 

DECY
	LD	A,E
	NEG 
	LD	E,A
	AND	A
	SBC	HL,DE
	LD	(PIX_Y),HL
	JR	C,XCOO
	LD	DE,(MIN_Y)
	SBC	HL,DE
	RET	NC
XCOO
	LD	HL,(MIN_Y)
	LD	(PIX_Y),HL
	RET 

SENSE
	LD	HL,(SENSEXY)
	LD	A,L
	OR	L
	RET	Z
	DEC	A
	RET	Z
	LD	A,E
	BIT	7,A
	LD	B,#FF
	JR	Z,SEN1
	LD	B,#7F
	NEG 
SEN1	INC	B
	SUB	L
	JR	NC,SEN1
	BIT	7,B
	JR	Z,SEN2
	LD	A,B
	RES	7,A
	NEG 
	LD	B,A
SEN2	LD	E,B
	LD	A,D
	BIT	7,A
	LD	B,#FF
	JR	Z,SEN3
	LD	B,#7F
	NEG 
SEN3	INC	B
	SUB	H
	JR	NC,SEN3
	BIT	7,B
	JR	Z,SEN4
	LD	A,B
	RES	7,A
	NEG 
	LD	B,A
SEN4	LD	D,B
	RET 

M_MODE
	LD	(MODE),A
	OR	A
	JR	Z,UNKMODE
	CP	1
	JR	Z,UNKMODE
	CP	2
	JR	Z,S320256
	CP	3
	JR	Z,S640256
	BIT	7,A
	JR	Z,UNKMODE
	CP	0x81
	JR	Z,S320256
	CP	0x82
	JR	Z,S640256

UNKMODE
    XOR	A
	SCF 
	RET 

S320256                                        
    LD         DE,319
SET_HV
    LD         HL,0x0
    CALL       MS_HORZ
    LD         DE,0xff
    JP         MS_VERT

S640256            
    LD         DE,639
    JR         SET_HV


;Mouse Interrupt
M_INT	IN	A,(PAGE3)
	LD	B,A
	IN	A,(Y_PORT)
	LD	C,A
	PUSH	BC
	CALL	REFRESH	;Refresh mouse
	CALL	CONTROL
	POP	BC
	LD	A,B
	OUT	(PAGE3),A
	LD	A,C
	OUT	(Y_PORT),A
	RET 

M_REFR	CALL	CONTROL
	AND	A
	RET 

CONTROL	CALL	READ_M
	RET	NC
	CALL	MCORECT
	LD	A,#00
	LD	(REDY+1),A
	RET 

REFRESH	
    LD	A,#00
	OR	A
	RET	Z

REDY
	LD	A,#00
	CALL	RESTORE
	LD	HL,(PIX_X)
	LD	DE,(PIX_Y)
	CALL	MOUSE
	LD	A,#FF
	LD	(REDY+1),A
	RET 

MODE	DB	#03

PIX_X	DW	160
PIX_Y	DW	128

MX	    DB	#00
MY	    DB	#00
MB	    DB	#00
MB_OLD	DB	#00

M_VAR_X DB 0
M_VAR_Y DB 0

MIN_X	DW	0
MAX_X	DW	319
MIN_Y	DW	0
MAX_Y	DW	255
SENSEXY
SENSE_X	DB	0
SENSE_Y	DB	0

XHOT_SP	DW	0
YHOT_SP	DW	0

ANDXORS	DW	#FF00
ANDXORA	DW	#FF77

M_XSIZE	DB	10
M_YSIZE	DB	14
SKIPXF	DW	0
REALXS	DW	0
REALYS	DW	0

X	EQU	#00
W	EQU	#FE
N	EQU	#FF

M_IMAGE
MS_BMP	DB	X,X,N,N,N,N,N,N,N,N
	DB	X,W,X,N,N,N,N,N,N,N
	DB	X,W,W,X,N,N,N,N,N,N
	DB	X,W,W,W,X,N,N,N,N,N
	DB	X,W,W,W,W,X,N,N,N,N
	DB	X,W,W,W,W,W,X,N,N,N
	DB	X,W,W,W,W,W,W,X,N,N
	DB	X,W,W,W,W,X,X,X,X,N
	DB	X,W,W,X,W,X,N,N,N,N
	DB	X,W,X,X,W,W,X,N,N,N
	DB	X,X,N,N,X,W,X,N,N,N
	DB	X,N,N,N,X,W,W,X,N,N
	DB	N,N,N,N,N,X,X,N,N,N
	DB	N,N,N,N,N,N,N,N,N,N
	DS	116
MAXSIZM	EQU	$-M_IMAGE

;//MODULE: INTMOUSE
;[END]

