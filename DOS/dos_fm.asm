
;[BEGIN]
;//MODULE: DOS_FM
;//CREATE: 19-05-1998	AUTHOR:	Denis Parinov
;//UPDATE: 24-10-1999	DNS	Restore	module
;//R01	 : 16-11-1999	DNS	ERROR READING FAT CHAIN

NAM	                        EQU	0
EXT	                        EQU	8
ATR	                        EQU	11
TIM1	                    EQU	22
TIM2	                    EQU	23
DAT1	                    EQU	24
DAT2	                    EQU	25
CLU1	                    EQU	26
CLU2	                    EQU	27
LEN1	                    EQU	28
LEN2	                    EQU	29
LEN3	                    EQU	30
LEN4	                    EQU	31
POS1	                    EQU	32
POS2	                    EQU	33
POS3	                    EQU	34
POS4	                    EQU	35
DIRCLU1	                    EQU	36
DIRCLU2	                    EQU	37
HND1	                    EQU	38
HND2	                    EQU	39
FDRV	                    EQU	40
AMODE	                    EQU	41
FTASK	                    EQU	42

FMCOUNT	                    EQU	10

FMS	DB	0x00

;ACCESS	MODE:
;	00 - READ/WRITE
;	01 - READ
;	02 - WRITE

;File Manipulator (FM)
FM_BUF
	DB	".       "	;+00 NAME
	DB	"   "		;+08 EXT
FM_BUF_ATTR        ; Attribute
	DB	10h
FM_BUF_RES         ; Reserved
    DS  10,0
FM_BUF_TIME        ; Time
    DW	0h
FM_BUF_DATE        ; Date
    DW	0h
FM_BUF_ST_CL       ; Start cluster
    DW	0h
FM_BUF_FSL         ; FileSize low word
    DW	0h
FM_BUF_FSH         ; FileSize hi word
    DW	0h
FM_BUF_FPL         ; File position low word
    DW	0h
FM_BUF_FPH         ; File position hi word
    DW	0h
FM_BUF_DIR_CL      ; Directory cluster
    DW  0h
FM_BUF_HNDL        ; Handle  number
    DW  0h          
FM_BUF_DC          ; DRIVE OR CURRENT
    DB 0h
FM_BUF_AM          ; ACCESS MODE
    DB 0h
FM_BUF_TASK        ; TASK
    DB 0h
FM_BUF_REM         
    DS  17,0x00
END_FM
;End of	FM

FM_SIZE     EQU	END_FM-FM_BUF


; TODO: Rewritten sub
SET_FM
    CP	0xb
    JP	NC,ABS_FM
    PUSH	DE
    PUSH	HL
    PUSH	BC
    EX	AF,AF'
    LD	A,0x1
    CALL	BANK
    EX	AF,AF'
    LD	C,A
    LD	A,(FMS)
    CP	C
    JR	Z,SET_FM3
    LD	A,C
    PUSH	AF
    CALL	SET_FM_SUB
    POP	AF
    LD	HL,0xe000
    LD	DE,0x3d
    OR	A
    JR	Z,SET_FM2

SET_FM1
    ADD	HL,DE
    CP	(HL)
    JR	Z,SET_FM2
    DJNZ	SET_FM1
    POP	BC
    POP	HL
    POP	DE
    EX	AF,AF'
    OUT	 (PAGE3),A
    
ABS_FM
    LD	A,0x5
    SCF
    RET
SET_FM2
    LD	DE,FMS
    LD	BC,0x3d
    LDIR
SET_FM3
    EX	AF,AF'
    OUT	 (PAGE3),A
    POP	 BC
    POP	 HL
    POP	 DE
    RET

; TODO: New sub
SET_FM_SUB
    PUSH	DE
    LD	A,(FMS)
    INC	 A
    JR	Z,SFS_L3
    DEC	 A
    LD	B,A
    LD	HL,0xe000
    LD	DE,0x3d
    OR	B
    JR	Z,SFS_L2
SFS_L1
    ADD	 HL,DE
    DJNZ	SFS_L1
SFS_L2
    EX	DE,HL
    LD	HL,FMS
    LD	BC,0x3d
    LDIR
SFS_L3
    POP	 DE
    RET

RES_FM
    CP	0xb
    JR	NC,ABS_FM
    EX	AF,AF'
    LD	A,0x1
    CALL	BANK
    EX	AF,AF'
    PUSH	HL
    PUSH	BC
    LD	HL,0xe000
    LD	DE,0x3d
    LD	B,A
RES_FM1
    ADD	 HL,DE
    DJNZ	RES_FM1
    LD	A,0xff
    LD	(FMS),A
    LD	DE,FMS
    EX	DE,HL
    PUSH	HL
    PUSH	DE
    INC	 HL
    XOR	 A
    LD	(HL),A 
    LD	BC,0x3c
    LDIR
    POP	DE
    POP	HL
    LD	BC,0x3d
    LDIR
    EX	AF,AF'
    OUT	 (PAGE3),A
    POP	 BC
    POP	 HL
    RET

; TODO: New sub, called from OPENAT
GET_FM
    PUSH	HL
    PUSH	DE
    LD	A,0x1
    CALL	BANK
    EX	AF,AF'
    CALL	SET_FM_SUB
    LD	B,0xa
    LD	C,0x0
    LD	HL,0xe000
    LD	DE,0x3d
GET_FM1
    ADD	 HL,DE
    INC	 C
    LD	A,(HL)
    INC	 A
    JR	Z,GET_FM2
    DJNZ	GET_FM1
    SCF
    JP	GET_FM3
GET_FM2
    LD	A,C
    LD	DE,FMS
    LD	BC,0x3d
    LDIR
    LD	(FMS),A
    LD	C,A
GET_FM3
    POP	DE
    POP	HL
    EX	AF,AF'
    OUT	 (PAGE3),A
    RET

; HL:IX	- OFFSET POINTER
;     A	- FILE MANIPULATOR
MOVE_FP
	CALL	SET_FM
	RET	C
	INC	B
	DEC	B
	JR	Z,MOVE_FA
	DEC	B
	JR	Z,MOVE_FB
	DEC	B
	JR	Z,MOVE_FC
    JP NOPS
;from Start File
MOVE_FA
	LD	BC,0
	LD	E,C
    LD	D,C
	JR	MOVE_F1

;from End File
MOVE_FC
	LD	BC,(FM_BUF_FSL)
	LD	DE,(FM_BUF_FSH)
	JR	MOVE_F1

;from Current Position
MOVE_FB
	LD	BC,(FM_BUF_FPL)
	LD	DE,(FM_BUF_FPH)

MOVE_F1
	ADD	IX,BC
	ADC	HL,DE
	LD	(FM_BUF_FPL),IX
    LD	(FM_BUF_FPH),HL
	XOR	A
	RET 

;FP COMPARE
; CY - FILE POINTER > SIZE
; NC - FILE POINTER < SIZE
MOVE_CP
    LD	HL,(FM_BUF_FSL)
    LD	DE,(FM_BUF_FPL)
    AND	A
    SBC	HL,DE
    LD	HL,(FM_BUF_FSH)
    LD	DE,(FM_BUF_FPH)
    SBC	HL,DE
    RET

;--------------------

ECL2:
	POP	BC
	POP	DE
	AND	A
	RET 

BLOKRD0:
	POP	BC
	POP	DE
	SCF 
	RET 



; -------------------------------------
; READ FILE SECTORS
; HL:DE - File pos in sectors
; B - Count of sectors
BLOK_RD:
	PUSH	BC
	LD	(READMEM),IX
	LD	A,(S_P_C)	;SECTORS PER CLUSTER
    CALL DIV32
    PUSH HL
    LD HL,(FM_BUF_ST_CL)
    LD A,H
    OR L
	JR	NZ,BLOKRD2
	JR	ECL2		;R01 JR	     BLOKRD0

BLOKRD1:
	PUSH	BC
	CALL	R_F_FAT
	POP	BC
	JR	C,ECL2		;R01
	EX	DE,HL
	DEC	BC

BLOKRD2:
	LD	A,B
	OR	C
	JR	NZ,BLOKRD1
	POP	DE
	POP	BC
	LD	A,(S_P_C)
	SUB	E
	LD	C,A
	CP	B
	JR	C,BLOKRD3	;SIZE >	RESIDUE	CLUSTER
	LD	C,B		;SIZE <	CLUSTER
BLOKRD3:
	LD	A,B
	SUB	C
	LD	B,A
	PUSH	HL
	PUSH	BC
	PUSH	DE
	CALL	NSECTOR
	POP	DE
	ADD	IX,DE
	JR	NC,BLOKRD4
	INC	HL
BLOKRD4:
	LD	DE,(READMEM)
	LD	A,(DRIVE)
	LD	B,C
	LD	C,5
	RST	#18
	JR	C,BLOKRD0
	POP	BC
	LD	HL,(READMEM)
	LD	DE,(B_P_S)
BLOKRD5:
	ADD	HL,DE
	DEC	C
	JR	NZ,BLOKRD5
	LD	(READMEM),HL
	POP	DE
	LD	A,B
	OR	A
	RET	Z
BLOKRD6:
	LD	HL,S_P_C
	LD	A,B
	SUB	(HL)
	LD	B,A
	LD	C,(HL)
	JR	NC,BLOKRD7
	LD	B,0
	ADD	A,(HL)	;0 AND CF
	LD	C,A
	OR	A	;CLEAR CF
	RET	Z
BLOKRD7:    
    EX	DE,HL
	PUSH	BC
	CALL	R_F_FAT
	POP	BC
	JR	C,ECL1	;R01?
	EX	DE,HL
	PUSH	HL
	PUSH	BC
	CALL	NSECTOR
	LD	DE,(READMEM)
	LD	A,(DRIVE)
	LD	B,C
	LD	C,5
	RST	#18
	JP	C,BLOKRD0
	POP	BC
	LD	HL,(READMEM)
	LD	DE,(B_P_S)
BLOKRD8:
	ADD	HL,DE
	DEC	C
	JR	NZ,BLOKRD8
	LD	(READMEM),HL
	POP	DE
	JR	BLOKRD6

ECL1:
	AND	A
	RET 

;--------------------

BLOKWRC:
	POP	BC
BLOKWR0:
	POP	BC
	POP	DE
	SCF 
	RET 

; -------------------------------------
; WRITE FILE SECTORS 
; HL:DE - File pointer in sectors
;     B - Count of sectors
BLOK_WR:
	PUSH	BC
	LD	(READMEM),IX
	LD	A,(S_P_C)	    ;SECTORS PER CLUSTER
	CALL	DIV32
    PUSH HL
    LD HL,(FM_BUF_ST_CL)
	LD	A,H
	OR	L
	JR	NZ,BLOKWR2
	PUSH	BC
	CALL	G_CLUST
	JR	C,BLOKWRC
	LD	(FM_BUF_ST_CL),HL
	LD	DE,(ENDCLUS)
	CALL	W_T_FAT
	PUSH	HL
	CALL	WR_FAT
	POP	HL
	POP	BC
	JR	BLOKWR2
BLOKWR1	
    PUSH	BC
	CALL	R_F_FAT
	JR	NC,BLOKWRB
	PUSH	HL
	CALL	INC_FAT
	POP	HL
	JR	C,BLOKWRC
	CALL	R_F_FAT
BLOKWRB
    POP	BC
	EX	DE,HL
	DEC	BC
BLOKWR2
	LD	A,B
	OR	C
	JR	NZ,BLOKWR1
	POP	DE
	POP	BC
	LD	A,(S_P_C)
	SUB	E
	LD	C,A
	CP	B
	JR	C,BLOKWR3	    ;SIZE >	RESIDUE	CLUSTER
	LD	C,B		        ;SIZE <	CLUSTER
BLOKWR3
	LD	A,B
	SUB	C
	LD	B,A
	PUSH	HL
	PUSH	BC
	PUSH	DE
	CALL	NSECTOR
	POP	DE
	ADD	IX,DE
	JR	NC,BLOKWR4
	INC	HL
BLOKWR4
	LD	DE,(READMEM)
	LD	A,(DRIVE)
	LD	B,C
	LD	C,6
	RST	#18
	JP	C,BLOKWR0
	POP	BC
	LD	HL,(READMEM)
	LD	DE,(B_P_S)
BLOKWR5
	ADD	HL,DE
	DEC	C
	JR	NZ,BLOKWR5
	LD	(READMEM),HL
	POP	DE
	LD	A,B
	OR	A
	RET	Z
BLOKWR6
	LD	HL,S_P_C
	LD	A,B
	SUB	(HL)
	LD	B,A
	LD	C,(HL)
	JR	NC,BLOKWR7
	LD	B,0
	ADD	A,(HL)	;0 AND CF
	LD	C,A
	OR	A	;CLEAR CF
	RET	Z
BLOKWR7
	EX	DE,HL
	PUSH	BC
	CALL	R_F_FAT
	JR	NC,BLOKWR9
	PUSH	HL
	CALL	INC_FAT
	POP	HL
	JR	C,BLOKWRA
	CALL	R_F_FAT
BLOKWR9
	POP	BC
	EX	DE,HL
	PUSH	HL
	PUSH	BC
	CALL	NSECTOR
	LD	DE,(READMEM)
	LD	A,(DRIVE)
	LD	B,C
	LD	C,6
	RST	#18
	JP	C,BLOKWR0
	POP	BC
	LD	HL,(READMEM)
	LD	DE,(B_P_S)
BLOKWR8
	ADD	HL,DE
	DEC	C
	JR	NZ,BLOKWR8
	LD	(READMEM),HL
	POP	DE
	JR	BLOKWR6

BLOKWRA
	POP	BC
	LD	A,10
	SCF 
	RET 

TSTSIZE
	XOR	A
	LD	(READCOD),A
	LD	HL,(FM_BUF_FPL)	;FP LOW
	ADD	HL,DE
	EXX 
    LD  E,A
    LD  D,A
	LD	HL,(FM_BUF_FPH)
	ADC	HL,DE
	EXX			;HL':HL	- NEW FP
	LD	BC,(FM_BUF_FSL)
	AND	A
	SBC	HL,BC
	EXX 
	LD	BC,(FM_BUF_FSH)	;SIZE HIGH
	SBC	HL,BC
	EXX 
	RET	C		;OK READ ALL
	EX	DE,HL
	SBC	HL,DE		;VERY BIG
	EX	DE,HL
	LD	A,0xFF
	LD	(READCOD),A
	RET 

; HL - ADDRESS
; DE - SIZE
;  A - FM
READ
	LD	(R_POINT),HL
	LD	(S_POINT),HL
	CALL	SET_FM
	RET	C
	CALL	TSTSIZE
	LD	A,D
	OR	E
	JP	Z,NOREAD
	PUSH	DE
	LD	A,(FM_BUF_DC)
	CALL	OPENDSK
	JP	C,RPERR1
    LD HL, FM_BUF_FPL
    LD C,(HL)
    INC HL
    LD A,(HL)
    INC HL
	LD	E,A
	AND	0x01
	LD	B,A
	LD	D,(HL)
    INC HL
    LD  L,(HL)
    LD	H,0
	OR	A
	RR	L
	RR	D
	RR	E	;HL:DE FP (in sectors)
			;   BC FP residue (in bytes)
	LD	A,B
	OR	C
	JP	NZ,ROV1
ROV4
	POP	BC
	PUSH	BC
	SRL	B
	JR	Z,ROV2
	LD	(SECTORH),HL
	LD	(SECTORL),DE
	LD	IX,(R_POINT)
	CALL	BLOK_RD
	JP	C,RPERR1
	LD	DE,(R_POINT)
	LD	HL,(READMEM)
	AND	A
	SBC	HL,DE
	LD	C,H
	LD	B,0
	ADD	HL,DE
	LD	(R_POINT),HL
	SRL	C
	LD	HL,(SECTORL)
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(SECTORH)
	LD	C,B
	ADC	HL,BC
ROV2
	POP	BC
	LD	A,B
	AND	#01
	LD	B,A
	OR	C
	JR	Z,ROV6
	PUSH	BC
	LD	IX,BUFFER+#C000
	LD	B,1
	IN	A,(PAGE3)
	PUSH	AF
	IN	A,(PAGE0)
	OUT	(PAGE3),A
	CALL	BLOK_RD
	POP	BC
	LD	C,PAGE3
	OUT	(C),B
	JP	C,RPERR1
	LD	HL,BUFFER
	LD	DE,(R_POINT)
	POP	BC
	LDIR 
	LD	(R_POINT),DE
ROV6
	LD	HL,(S_POINT)
	LD	DE,(R_POINT)
	EX	DE,HL
	AND	A
	SBC	HL,DE
	PUSH	HL
	EX	DE,HL
	LD	XH,D
	LD	XL,E
	LD	HL,0
	CALL	MOVE_FB
	POP	DE
NOREAD
	LD	A,(READCOD)
	OR	A
	RET 

ROV1
	PUSH	BC
	PUSH	HL
	PUSH	DE
	LD	IX,BUFFER+#C000
	LD	B,1
	IN	A,(PAGE3)
	PUSH	AF
	IN	A,(PAGE0)
	OUT	(PAGE3),A
	CALL	BLOK_RD
	POP	BC
	LD	C,PAGE3
	OUT	(C),B
	POP	HL
	JR	C,RPERR3
	LD	BC,1
	ADD	HL,BC
	EX	DE,HL
	POP	HL
	LD	C,B
	ADC	HL,BC
	EXX 
	POP	DE
	LD	HL,512
	AND	A
	SBC	HL,DE
	LD	B,H
	LD	C,L
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,ROV3
	ADD	HL,BC
	LD	B,H
	LD	C,L
	LD	HL,0
ROV3
	PUSH	HL
	LD	HL,BUFFER
	ADD	HL,DE
	LD	DE,(R_POINT)
	LDIR 
	LD	(R_POINT),DE
	EXX 
	JP	ROV4

RPERR3
	POP	HL
RPERR2
	POP	HL
RPERR1
	POP	BC
	SCF 
	RET 

PWERR3
	POP	HL
PWERR2
	POP	HL
PWERR1
	POP	BC
	SCF 
	RET 

RD_ONLY
	POP	DE
	LD	A,8
	SCF 
	RET 

; HL - ADDRESS
; DE - SIZE
;  A - FM
WRITE
	LD	(R_POINT),HL
	LD	(S_POINT),HL
	PUSH DE
	CALL SET_FM
	JR	C,PWERR1
	LD	A,(FM_BUF_AM)
    LD C,A
	AND	0x01
	JR	NZ,RD_ONLY
    LD A,C 
	SET	7,A
    LD (FM_BUF_AM),A
	LD	A,(FM_BUF_ATTR)
    SET	5,A
    LD (FM_BUF_ATTR),A
    LD	A,(FM_BUF_DC)
	CALL	OPENDSK
	JR	C,PWERR1
    LD HL,FM_BUF_FPL
	LD	C,(HL)
    INC HL
	LD	A,(HL)
    INC HL
	LD	E,A
	AND	#01
	LD	B,A
	LD	D,(HL)
    INC HL
	LD	L,(HL)
	LD	H,0x0000
	OR	A
	RR	L
	RR	D
	RR	E	;HL:DE FP (in sectors)
			;   BC FP residue (in bytes)
	LD	A,B
	OR	C
	JP	NZ,WOV1
WOV4
	POP	BC
	PUSH	BC
	SRL	B
	JR	Z,WOV2
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	IX,(R_POINT)
	CALL	BLOK_WR
	POP	BC
	JP	C,PWERR3
	LD	C,B
	LD	HL,(R_POINT)
	LD	DE,#0200
WOV5
	ADD	HL,DE
	DJNZ	WOV5
	LD	(R_POINT),HL
	POP	HL
	ADD	HL,BC
	EX	DE,HL
	POP	HL
	LD	C,B
	ADC	HL,BC
WOV2
	POP	BC
	LD	A,B
	AND	0x01
	LD	B,A
	OR	C
	JR	Z,WOV6
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	IX,BUFFER+#C000
	LD	B,1
	IN	A,(PAGE3)
	PUSH	AF
	IN	A,(PAGE0)
	OUT	(PAGE3),A
	CALL	BLOK_RD
	POP	BC
	LD	C,PAGE3
	OUT	(C),B
	LD	DE,BUFFER
	LD	HL,(R_POINT)
	POP	BC
	JP	C,PWERR2
	LDIR 
	LD	(R_POINT),HL
	POP	DE
	POP	HL
	LD	IX,BUFFER+#C000
	LD	B,1
	IN	A,(PAGE3)
	PUSH	AF
	IN	A,(PAGE0)
	OUT	(PAGE3),A
	CALL	BLOK_WR
	POP	BC
	LD	C,PAGE3
	OUT	(C),B
	RET	C
WOV6
	LD	DE,(S_POINT)
	LD	HL,(R_POINT)
	AND	A
	SBC	HL,DE
	PUSH	HL
	EX	DE,HL
	LD	XH,D
	LD	XL,E
	LD	HL,0
	CALL	MOVE_FB
	CALL	MOVE_CP
	POP	DE
	RET	NC
	LD	HL,(FM_BUF_FPL)
	LD	BC,(FM_BUF_FPH)
	LD	(FM_BUF_FSL),HL
    LD	(FM_BUF_FSH),BC
	AND	A
	RET 

WOV1
	PUSH	BC
	PUSH	HL
	PUSH	DE
	LD	IX,BUFFER+#C000
	LD	B,1

WOV_PG  EQU $ + 1
	IN	A,(PAGE3)
	PUSH	AF
	IN	A,(PAGE0)
	OUT	(PAGE3),A
	CALL	BLOK_RD
	POP	BC
	LD	C,PAGE3
	OUT	(C),B
	POP	DE
	POP	HL
	EXX 
	POP	DE
	JP	C,PWERR1
	LD	HL,512
	AND	A
	SBC	HL,DE
	LD	B,H
	LD	C,L
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,WOV3
	ADD	HL,BC
	LD	B,H
	LD	C,L
	LD	HL,0
WOV3
	PUSH	HL
	LD	HL,BUFFER
	ADD	HL,DE
	LD	DE,(R_POINT)
	EX	DE,HL
	LDIR 
	LD	(R_POINT),HL
	EXX 
	PUSH	HL
	PUSH	DE
	LD	IX,BUFFER+#C000
	LD	B,1
	IN	A,(PAGE3)
	PUSH	AF
	IN	A,(PAGE0)
	OUT	(PAGE3),A
	CALL	BLOK_WR
	POP	BC
	LD	C,PAGE3
	OUT	(C),B
	POP	HL
	JP	C,PWERR2
	LD	BC,1
	ADD	HL,BC
	EX	DE,HL
	POP	HL
	LD	C,B
	ADC	HL,BC
	JP	WOV4


; HL - CLUSTER
; HL:IX	- SECTOR
NSECTOR
    LD  DE,0x0000
	DEC	HL
	DEC	HL
	LD	A,(S_P_C)
	LD	B,A
    DEC A
    LD A,B
    LD B,E
    JR	Z,ADD_DE2
    RRCA
ADD_DE1
	ADD	HL,HL
    RL E
    RL D
	RRCA
	JP  NC,ADD_DE1              ; TODO: JR?

ADD_DE2
    EX DE,HL
    DB 0xDD                     ; TODO: fix to undocumented
    LD L,E
    DB 0xDD
    LD H,D

	LD	DE,(DAT_FRM)
	ADD	IX,DE
    LD  E,B
    LD  D,B
	ADC	HL,DE
    AND A
	RET 

;	HL:DE /	BC => DE:IX HL-OSTATOK
DIV32
    LD	B,A
    DEC	A
    JP	NZ,DIV001
    LD	C,A
    JR	DIV003
DIV001
    AND	E
    LD	C,A
    LD	A,B
    RRCA
DIV002
    SRL	H
    RR	L
    RR	D
    RR	E
    RRCA
    JR	NC,DIV002
DIV003
    EX	DE,HL
    LD	B,H
    LD	H,0x0
    LD	A,C
    LD	C,L
    LD	L,A
    RET

READCOD
	DB	0x00

READMEM
	DW	0x0000

SECTORH
	DW	0
SECTORL
	DW	0

R_POINT
	DW	0
S_POINT
	DW	0



;//MODULE: DOS_FM
;[END]
