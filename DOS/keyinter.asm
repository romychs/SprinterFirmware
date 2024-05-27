

;[BEGIN]
;//MODULE: KEYINTER
;//CREATE: 19-05-1998	AUTHOR:	Denis Parinov
;//UPDATE: 24-10-1999	DNS	Restore	module
;------------------------------------------------
;R01	10-02-2003 DNS	Add cursor visualisation
;
; 	    DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SBUF
        DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 	    DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 	    DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 	    DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
EBUF

HEAD	DB	#00
HOST	DB	#00

K_LOCK	EQU	$-KEYFLAG
KEYFLAG	DB	#02	;D0-Key	Pressed
K_SHIFT	EQU	$-KEYFLAG
KEYCTRL	DB	#00
KEYFLG	EQU	$-KEYFLAG
	    DB	#00
  	    DB	#03
UNICODE DW  0

LANG_L	EQU	7
PAUSE_L	EQU	6
RES5_L	EQU	5
RES4_L	EQU	4
NUM_L	EQU	3
SCRL_L	EQU	2
INS_L	EQU	1
CAPS_L	EQU	0
L_SHIFT	EQU	7
R_SHIFT	EQU	6
X_CTRL	EQU	5
X_ALT	EQU	4
L_CTRL	EQU	3
L_ALT	EQU	2
R_CTRL	EQU	1
R_ALT	EQU	0

FLAG_E0	EQU	7
FLAG_F0	EQU	6
FLAG_E1	EQU	5
FLAG_04	EQU	4
FLAG_03	EQU	3
FLAG_02	EQU	2
FLAG_01	EQU	1
FLAG_00	EQU	0

;SOUND_K	EQU	$-KEYFLAG
FLAG_S7	EQU	7
FLAG_S6	EQU	6
FLAG_S5	EQU	5
FLAG_S4	EQU	4
FLAG_S3	EQU	3
FLAG_S2	EQU	2
SF_ALT	EQU	1
SF_BUFF	EQU	0

;      D15 - LShift
;      D14 - RShift
;      D13 - CTRL
;      D12 - ALT
;      D11 - LCTRL
;      D10 - LALT
;	D9 - RCTRL
;	D8 - RALT
;	D7 - Language Lock
;	D6 - Reserved
;	D5 - Reserved
;	D4 - Reserved
;	D3 - Num Lock
;	D2 - Scroll Lock
;	D1 - Insert Lock
;	D0 - Caps Lock

;      D15 - Keystroke
;      D14
;      D13 \
;      D12  \
;      D11 -- Position code (0...5Ah)
;      D10  /
;	D9 /
;	D8
;   D7..D0 - ASCII codeKEYFLAG


WAITKEY
	LD	HL,HOST
	LD	A,(HEAD)
	CP	(HL)
	JR	Z,WAITKEY
	CALL GETSYM
	LD	A,E
	AND	A
	RET

SCANKEY
	LD	HL,HOST
	LD	A,(HEAD)
	CP	(HL)
	RET	Z
	CALL	GETSYM
	LD	A,E
	RET

; TODO FixIt!
ECHOKEY0
    CALL ECHO_PREP_3

ECHOKEY
    CALL       SCANKEY
    JR         Z,ECHOKEY
    PUSH       DE
    PUSH       BC
    PUSH       AF
    CALL       ECHO_PREP
    POP        AF
    OR         A
    CALL       NZ,PUTCHAR
    POP        BC
    POP        DE
    LD         A,E
    AND        A
    RET

CTRLKEY	LD	HL,HOST
	LD	A,(HEAD)
	CP	(HL)
	LD	BC,(KEYFLAG)
	LD	A,#00
	RET	Z
	DEC	A
	RET

TESTKEY	LD	HL,HOST
	LD	A,(HEAD)
	CP	(HL)
	RET	Z
	LD	L,(HL)
	LD	H,4                     ; SBUF/256
	LD	E,(HL)
	INC	L
	LD	D,(HL)
	INC	L
	LD	B,(HL)
	INC	L
	LD	C,(HL)
	LD	A,E
	RET

K_CLEAR
	LD	A,(HOST)
	LD	(HEAD),A
	LD	A,#2F
	CP	B
	JR	C,K_C2
	LD	A,1
	SCF
	RET

K_C2
	LD	A,#35
	CP	B
	JR	NC,K_C3
	LD	A,1
	SCF
	RET

K_C3
	LD	C,B
	RST	#10
	RET

PUTSYM	
    LD	HL,HEAD
	LD	A,(HOST)
	SUB	4
	AND	#3F
	CP	(HL)
	JR	Z,FULL_BF
	LD	A,(HL)
	INC	(HL)
	INC	(HL)
	INC	(HL)
	INC	(HL)
	RES	6,(HL)
	LD	L,A
	LD	H,4                     ; SBUF/256
	LD	(HL),E
	INC	L
	LD	(HL),D
	INC	L
	LD	(HL),B
	INC	L
	LD	(HL),C
	RET

GETSYM
	LD	HL,HOST
	LD	A,(HEAD)
	CP	(HL)
	RET	Z
	LD	A,(HL)
	INC	(HL)
	INC	(HL)
	INC	(HL)
	INC	(HL)
	RES	6,(HL)
	LD	L,A
	LD	H,4                     ; SBUF/256
	LD	E,(HL)
	INC	L
	LD	D,(HL)
	INC	L
	LD	B,(HL)
	INC	L
	LD	C,(HL)
	RET

FULL_BF	EX	AF,AF'
	BIT	SF_BUFF,(IX+SOUND_K)
	JR	Z,FBF
	EXX
	LD	DE,230
	LD	HL,50
	CALL	BEEP
	EXX
FBF	EX	AF,AF'
	RET

E0_KEY	SET	FLAG_E0,(IX+KEYFLG)
	JR	RESCAN

F0_KEY	SET	FLAG_F0,(IX+KEYFLG)
	JR	RESCAN

E1_KEY	SET	FLAG_E1,(IX+KEYFLG)
	JR	RESCAN

KEYSCAN	LD	IX,KEYFLAG

RESCAN	IN	A,(COM_A)
	BIT	0,A
	RET	Z
	IN	A,(DAT_A)
	CP	#F0
	JR	Z,F0_KEY
	CP	#E0
	JR	Z,E0_KEY
	CP	#E1
	JR	Z,E1_KEY
	BIT	FLAG_F0,(IX+KEYFLG)
	JR	NZ,UN_KEY
	LD	L,A
	CALL	XLAT
	CALL	SHIFTS
	RES	FLAG_E0,(IX+KEYFLG)
	RES	FLAG_E1,(IX+KEYFLG)
	RET	Z		;IT'S SHIFT KEY

	CALL	INPCODE		;L - AT	POS. CODE
;
PUTCODE	
    LD	HL,#1C00	;Caps Lock
	AND	A
	SBC	HL,DE
	CALL	Z,CAPS_X
	LD	HL,#B800	;Ctrl +	Space
	AND	A
	SBC	HL,DE
	CALL	Z,RUS_X
	LD	HL,#5000	;Insert
	AND	A
	SBC	HL,DE
	CALL	Z,INS_X
	LD	HL,#4900	;Num Lock
	AND	A
	SBC	HL,DE
	CALL	Z,NUM_X
	LD	HL,#C900	;Pause Lock
	AND	A
	SBC	HL,DE
	CALL	Z,PAUSE_X
	LD	HL,#4800	;Scroll	Lock
	AND	A
	SBC	HL,DE
	CALL	Z,SCL_X
	LD	HL,#CF00	;Ctrl +	Alt + Del
	AND	A
	SBC	HL,DE
	CALL	Z,RST_X
	LD	BC,(KEYFLAG)
	JP	PUTSYM

UN_KEY	
    RES	FLAG_F0,(IX+KEYFLG)
	LD	L,A
	CALL	XLAT
	CALL	UNSHIFT
	RES	FLAG_E0,(IX+KEYFLG)
	LD	H,0
	LD	(UNICODE),HL
	RET

CAPS_X	LD	A,(IX+K_LOCK)
	XOR	#01
	LD	(IX+K_LOCK),A
	RET

RUS_X	BIT	X_CTRL,(IX+K_SHIFT)
	RET	Z
	LD	A,(IX+K_LOCK)
	XOR	#80
	LD	(IX+K_LOCK),A
	BIT	SF_ALT,(IX+SOUND_K)
	RET	Z
	EXX
	LD	DE,190
	LD	HL,20
	CALL	BEEP
	EXX
	RET

INS_X
	LD	A,(IX+K_LOCK)
	XOR	0x2
	LD	(IX+K_LOCK),A
	RET

NUM_X
	LD	A,(IX+K_LOCK)
	XOR	0x8
	LD	(IX+K_LOCK),A
	RET

PAUSE_X
    BIT X_CTRL,(IX+K_SHIFT)
    RET Z
    LD  A,(IX+K_LOCK)
    XOR 0x40
    LD  (IX+K_LOCK),A
    BIT PAUSE_L,(IX+K_LOCK)
    RET Z
    EI

PAUSE_
	HALT
	BIT	PAUSE_L,(IX+K_LOCK)
	JR	NZ,PAUSE_
	DI
	RET

SCL_X
	LD	A,(IX+K_LOCK)
	XOR	0x04
	LD	(IX+K_LOCK),A
	RET

RST_X
    LD      C,0x30
    LD      A,(IX+K_SHIFT)
    AND     C
    CP      C
    RET     NZ
    XOR     A
    LD      BC,0x1FD
    RST     0x8
    RET

UNSHIFT
	LD	A,L
	CP	#37	                    ; L ALT
	JR	NZ,USH1
	RES	L_ALT,(IX+K_SHIFT)
	BIT	R_ALT,(IX+K_SHIFT)
	RET	NZ
	RES	X_ALT,(IX+K_SHIFT)
	RET

USH1
	CP	#39	;R ALT
	JR	NZ,USH2
	RES	R_ALT,(IX+K_SHIFT)
	BIT	L_ALT,(IX+K_SHIFT)
	RET	NZ
	RES	X_ALT,(IX+K_SHIFT)
	RET
USH2	
    CP	#36	;L CTRL
	JR	NZ,USH3
	RES	L_CTRL,(IX+K_SHIFT)
	BIT	R_CTRL,(IX+K_SHIFT)
	RET	NZ
	RES	X_CTRL,(IX+K_SHIFT)
	RET
USH3	CP	#3A	;R CTRL
	JR	NZ,USH4
	RES	R_CTRL,(IX+K_SHIFT)
	BIT	L_CTRL,(IX+K_SHIFT)
	RET	NZ
	RES	X_CTRL,(IX+K_SHIFT)
	RET
USH4
	CP	#29	;L SHIFT
	JR	NZ,USH5
	RES	L_SHIFT,(IX+K_SHIFT)
	RET
USH5
	CP	#34	;R SHIFT
	RET NZ
	RES	R_SHIFT,(IX+K_SHIFT)
USH6
	RET

SHIFTS	LD	A,L
	CP	#37	;L ALT
	JR	NZ,NSH1
	SET	L_ALT,(IX+K_SHIFT)
	SET	X_ALT,(IX+K_SHIFT)
	RET
NSH1	CP	#39	;R ALT
	JR	NZ,NSH2
	SET	R_ALT,(IX+K_SHIFT)
	SET	X_ALT,(IX+K_SHIFT)
	RET
NSH2	CP	#36	;L CTRL
	JR	NZ,NSH3
	SET	L_CTRL,(IX+K_SHIFT)
	SET	X_CTRL,(IX+K_SHIFT)
	RET
NSH3
	CP	#3A	;R CTRL
	JR	NZ,NSH4
	SET	R_CTRL,(IX+K_SHIFT)
	SET	X_CTRL,(IX+K_SHIFT)
	RET
NSH4
	CP	#29	;L SHIFT
	JR	NZ,NSH5
	SET	L_SHIFT,(IX+K_SHIFT)
	RET
NSH5
	CP	0x34	;R SHIFT
    RET NZ
	SET	R_SHIFT,(IX+K_SHIFT)
	RET

;	TODO: Strange part for keyboard inter =================
VER
	DI
    PUSH AF
	CALL	KINIT
	CALL	PRINT_INIT
	LD	C,0
	RST	#30
	LD	A,(VMODE)
	LD	C,#81
	RST	#30
    CALL INITDVC
    EI
    ; Set new address fn. VERSION
	LD	DE,VERSION
	LD	HL,ADRST10
	LD	(HL),E
    INC H
    LD	(HL),D
    ; Allocate memory
    LD  BC,0x3c2
    RST 0x08
    LD  HL,BANKTBL
    LD  C,A
    LD  B,0x2

VERINIT				     
    PUSH	BC
    PUSH	HL
    LD	A,C
    LD	C,0xc4
    RST	 0x08 
    POP	 HL
    POP	 BC
    JR	C,VER_L2
    LD	(HL),A		
    INC	 HL
    DEC	 B
    JP	M,VER_L2
    JR	VERINIT
VER_L2				      
    CALL	VER_IN
    LD	B,0xff
    CALL	ENVIRON
    LD	A,0x1
    CALL    BANK		   
    EX	AF,AF'
    LD	HL,0xe000
    PUSH	HL
    LD	DE,0xe001
    LD	BC,0x262
    XOR	 A
    LD	(HL),A
    LDIR
    LD	BC,0x3d
    POP	 HL
    LD	E,0xa
    DEC	 A
VER_L3				      
    LD	(HL),A
    ADD	 HL,BC
    DEC	 E
    JR	NZ,VER_L3
    EX	AF,AF'
    OUT	 (0x00e2),A
    POP	 AF
    CALL	SETBOOT		   
    PUSH	AF
    CALL	CHNDISK		   
    POP	 AF
    ADD	 A,0x41
    LD	(BOOT_LBL_DRV),A		 
    LD	HL,BOOT_LBL
    LD	B,0x2
    CALL	ENVIRON
    JP	VERSION

BOOT_LBL    
    DB 'BOOTDSK='
BOOT_LBL_DRV 
    DB 'A:'
    DS 199, 0x00

; End of strange part ================ 

;	ALIGN	256
;	DEFS	$/256+1*256-$,0

;      0   1   2   3   4   5   6   7   8   9   A   B   C   D   E
;   F
XLAT_T
 DB #00,#43,#00,#3F,#3D,#3B,#3C,#46,#00,#44,#42,#40,#3E,#0F,#00,#00 ;00
 DB #00,#37,#29,#00,#36,#10,#02,#00,#00,#00,#2A,#1E,#1D,#11,#03,#00 ;10
 DB #00,#2C,#2B,#1F,#12,#05,#04,#00,#00,#38,#2D,#20,#14,#13,#06,#00 ;20
 DB #00,#2F,#2E,#22,#21,#15,#07,#00,#00,#00,#30,#23,#16,#08,#09,#00 ;30
 DB #00,#31,#24,#17,#18,#0B,#0A,#00,#00,#32,#33,#25,#26,#19,#0C,#00 ;40
 DB #00,#00,#27,#00,#1A,#0D,#00,#00,#1C,#34,#28,#1B,#00,#35,#00,#00 ;50
 DB #00,#00,#00,#00,#00,#00,#0E,#00,#00,#51,#00,#54,#57,#00,#00,#00 ;60
 DB #50,#4F,#52,#55,#56,#58,#01,#49,#45,#4D,#53,#4C,#4B,#59,#48,#00 ;70
 DB #00,#00,#00,#41,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00 ;80

XLAT	BIT	FLAG_E0,(IX+KEYFLG)
	JR	Z,W_O_E0
	CP	#11	;Right ALT
	LD	L,#39
	RET	Z
	CP	#14	;Right CTRL
	LD	L,#3A
	RET	Z
	CP	#5A	;enter
	LD	L,#4E
	RET	Z
	CP	#4A	; /
	LD	L,#4A
	RET	Z
	CP	#7C	; * - Print Screen
	LD	L,#47
	RET	Z
	LD	L,A
W_O_E0	LD	H,XLAT_T/256
	LD	L,(HL)
	RET


;INPCODE BIT	 1,(IX+1)	 ;00110000
;	 JR	 NZ,FN_KEY	 ;LRCAcaRP

INPCODE	LD	D,L
	LD	E,0
	BIT	LANG_L,(IX+K_LOCK)
	JP	NZ,RUSCODE
	LD	A,(IX+K_SHIFT)
	AND	#C0
	JR	NZ,SHIFT_L
	SET	7,D
	BIT	X_ALT,(IX+K_SHIFT)
	RET	NZ
	BIT	X_CTRL,(IX+K_SHIFT)
	RET	NZ
	LD	D,L
	BIT	CAPS_L,(IX+K_LOCK)
	LD	BC,CAPSTAB
	JR	NZ,CONVER
	LD	BC,NORMTAB
CONVER	LD	H,0
	ADD	HL,BC
	LD	E,(HL)
	RET

SHIFT_L	LD	BC,SHIFTAB
	BIT	CAPS_L,(IX+K_LOCK)
	JR	Z,CONVER5
	LD	BC,SHF2TAB
CONVER5	LD	H,0
	ADD	HL,BC
	LD	E,(HL)
	SET	7,D
	RET

RUSCODE	LD	A,(IX+K_SHIFT)
	AND	#C0
	JR	NZ,SHIFT_R
	SET	7,D
	BIT	X_ALT,(IX+K_SHIFT)
	RET	NZ
	BIT	X_CTRL,(IX+K_SHIFT)
	RET	NZ
	LD	D,L
	BIT	CAPS_L,(IX+K_LOCK)
	LD	BC,CAPSRUS
	JR	NZ,CONVER2
	LD	BC,NORMRUS
CONVER2
	LD	H,0
	ADD	HL,BC
	LD	E,(HL)
	RET

SHIFT_R	LD	BC,SHIFRUS
	BIT	CAPS_L,(IX+K_LOCK)
	JR	Z,CONVER4
	LD	BC,SHF2RUS
CONVER4
    LD	H,0
	ADD	HL,BC
	LD	E,(HL)
	SET	7,D
	RET

K_SETUP
	INC	B
	DEC	B
	JR	Z,KEYMAP
	DEC	B
	JR	Z,K_SND_R
	DEC	B
	JR	Z,K_SND_W
	LD	A,#0E
	SCF
	RET

K_SND_R	LD	A,(SOUND_K)
	AND	A
	RET

K_SND_W	LD	(SOUND_K),A
	AND	A
	RET

KEYMAP	LD	BC,ENDNORM-NORMTAB
	BIT	7,A
	JR	NZ,READMAP
	LD	DE,NORMTAB
	OR	A
	JR	Z,LTAB
	LD	DE,SHIFTAB
	DEC	A
	JR	Z,LTAB
	LD	DE,CAPSTAB
	DEC	A
	JR	Z,LTAB
	LD	DE,SHF2TAB
	DEC	A
	JR	Z,LTAB
	LD	DE,NORMRUS
	DEC	A
	JR	Z,LTAB
	LD	DE,SHIFRUS
	DEC	A
	JR	Z,LTAB
	LD	DE,CAPSRUS
	DEC	A
	JR	Z,LTAB
	LD	DE,SHF2RUS
	DEC	A
	JR	Z,LTAB
	XOR	A
	SCF
	RET
LTAB
	LDIR
	XOR	A
	RET

READMAP
	RES	7,A
	LD	DE,NORMTAB
	OR	A
	JR	Z,RTAB
	LD	DE,SHIFTAB
	DEC	A
	JR	Z,RTAB
	LD	DE,CAPSTAB
	DEC	A
	JR	Z,RTAB
	LD	DE,SHF2TAB
	DEC	A
	JR	Z,RTAB
	LD	DE,NORMRUS
	DEC	A
	JR	Z,RTAB
	LD	DE,SHIFRUS
	DEC	A
	JR	Z,RTAB
	LD	DE,CAPSRUS
	DEC	A
	JR	Z,RTAB
	LD	DE,SHF2RUS
	DEC	A
	JR	Z,RTAB
	XOR	A
	SCF
	RET
RTAB
	EX	DE,HL
	LDIR
	XOR	A
	RET

;	 `
;	 0
;	Esc,"1","2","3","4","5","6","7","8","9","0","-","=",Back
;	 1   2	 3   4	 5   6	 7   8	 9   A	 B   C	 D   E
;	Tab,"Q","W","E","R","T","Y","U","I","O","P","[","]"
;	 F  10	11  12	13  14	15  16	17  18	19  1A	1B
;	Cps,"A","S","D","F","G","H","J","K","L",";","'",Enter
;	1C  1D	1E  1F	20  21	22  23	24  25	26  27	28
;	LSh,"Z","X","C","V","B","N","M",",",".","/",RSh,#5C
;	29  2A	2B  2C	2D  2E	2F  30	31  32	33  34	35
;	LCl,LAt,SPC,Rat,RCl,F01,F02,F03,F04,F05,F06,F07,F08
;	36  37	38  39	3A  3B	3C  3D	3E  3F	40  41	42
;	F09,F10,F11,F12,prn,scr,num,"/","*","-","+",ent,Del
;	43  44	45  46	47  48	49  4A	4B  4C	4D  4E	4F
;	Ins,End,Dwn,PgD,Lft,"5",Rgh,Hom,Upp,PgU
;	50  51	52  53	54  55	56  57	58  59
;
;================================
Esc	EQU	#1B
Bcs	EQU	#08
Tab	EQU	#09
Cps	EQU	#00
Spc	EQU	#20
Ent	EQU	#0D

;Standart ASCII	tables
NORMTAB	DB	"`",Esc,"1","2","3","4","5","6","7","8","9","0","-","=",Bcs
	DB	Tab,"q","w","e","r","t","y","u","i","o","p","[","]"
	DB	Cps,"a","s","d","f","g","h","j","k","l",";","'",Ent
	DB	#00,"z","x","c","v","b","n","m",#2C,".","/",#00,#5C
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
ENDNORM

SHIFTAB	DB	"~",Esc,"!","@","#","$","%","^","&","*","(",")","_","+",Bcs
	DB	Tab,"Q","W","E","R","T","Y","U","I","O","P","{","}"
	DB	Cps,"A","S","D","F","G","H","J","K","L",":",#22,Ent
	DB	#00,"Z","X","C","V","B","N","M","<",">","?",#00,"|"
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

CAPSTAB	DB	"`",Esc,"1","2","3","4","5","6","7","8","9","0","-","=",Bcs
	DB	Tab,"Q","W","E","R","T","Y","U","I","O","P","[","]"
	DB	Cps,"A","S","D","F","G","H","J","K","L",";","'",Ent
	DB	#00,"Z","X","C","V","B","N","M",#2C,".","/",#00,#5C
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

SHF2TAB	DB	"~",Esc,"!","@","#","$","%","^","&","*","(",")","_","+",Bcs
	DB	Tab,"q","w","e","r","t","y","u","i","o","p","{","}"
	DB	Cps,"a","s","d","f","g","h","j","k","l",":",#22,Ent
	DB	#00,"z","x","c","v","b","n","m","<",">","?",#00,"|"
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

;Standart Russian tables
NORMRUS	DB	#F1,Esc,"1","2","3","4","5","6","7","8","9","0","-","=",Bcs
	DB	Tab,#A9,#E6,#E3,#AA,#A5,#AD,#A3,#E8,#E9,#A7,#E5,#EA
	DB	Cps,#E4,#EB,#A2,#A0,#AF,#E0,#AE,#AB,#A4,#A6,#ED,Ent
	DB	#00,#EF,#E7,#E1,#AC,#A8,#E2,#EC,#A1,#EE,".",#00,#5C
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

SHIFRUS	DB	#F0,Esc,"!",#22,"#","$",":",#2C,".",";","?","%","_","+",Bcs
	DB	Tab,#89,#96,#93,#8A,#85,#8D,#83,#98,#99,#87,#95,#9A
	DB	Cps,#94,#9B,#82,#80,#8F,#90,#8E,#8B,#84,#86,#9D,Ent
	DB	#00,#9F,#97,#91,#8C,#88,#92,#9C,#81,#9E,#2C,#00,"|"
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

CAPSRUS	DB	#F0,Esc,"1","2","3","4","5","6","7","8","9","0","-","=",Bcs
	DB	Tab,#89,#96,#93,#8A,#85,#8D,#83,#98,#99,#87,#95,#9A
	DB	Cps,#94,#9B,#82,#80,#8F,#90,#8E,#8B,#84,#86,#9D,Ent
	DB	#00,#9F,#97,#91,#8C,#88,#92,#9C,#81,#9E,".",#00,#5C
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

SHF2RUS	DB	#F1,Esc,"!",#22,"#","$",":",#2C,".",";","?","%","_","+",Bcs
	DB	Tab,#A9,#E6,#E3,#AA,#A5,#AD,#A3,#E8,#E9,#A7,#E5,#EA
	DB	Cps,#E4,#EB,#A2,#A0,#AF,#E0,#AE,#AB,#A4,#A6,#ED,Ent
	DB	#00,#EF,#E7,#E1,#AC,#A8,#E2,#EC,#A1,#EE,#2C,#00,"|"
	DB	#00,#00,Spc,#00,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
	DB	#00,#00,#00,"/","*","-","+",Ent,#00
	DB	#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

;================================

BEEP	LD	A,#10
	OUT	(#FE),A
	LD	B,D
	LD	C,E
BPP	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,BPP
	LD	A,#00
	OUT	(#FE),A
	LD	B,D
	LD	C,E
BPP2	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,BPP2
	DEC	HL
	LD	A,H
	OR	L
	JR	NZ,BEEP
	RET

COM_A	EQU	#19
DAT_A	EQU	#18

KINIT
	LD	A,0x30
	OUT	(COM_A),A
	LD	A,0x18
	OUT	(COM_A),A
	LD	A,0x01	
	OUT	(COM_A),A
	LD	A,0x00
	OUT	(COM_A),A
	LD	A,0x03
	OUT	(COM_A),A
	LD	A,0xC1
	OUT	(COM_A),A
	LD	A,0x04
	OUT	(COM_A),A
	LD	A,0x07
	OUT	(COM_A),A
	LD	A,0x05
	OUT	(COM_A),A
    IF      SPRINTER=97
        LD      A,0x60
    ELSE
        LD      A,0x62
    ENDIF
    OUT     (COM_A),A
    RET

;//MODULE: KEYINTER
;[END]

