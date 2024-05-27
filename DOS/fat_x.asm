
;[BEGIN]
;//MODULE: FAT_X
;//CREATE: 19-05-1998	AUTHOR:	Denis Parinov
;//UPDATE: 24-10-1999	DNS	Restore	module
;---------------------------------------------------------------
;Rev	Date	   Name	Description
;---------------------------------------------------------------
;R01	10-02-1999 DNS	UPGRADE	FAT CASH
;---------------------------------------------------------------

R_CLUST
	LD	HL,#0001
	LD	(G_CLUST+1),HL
	RET 

G_CLUST
	LD	HL,#0001
G_CLUS1
	INC	HL
	CALL	R_F_FAT
	CP	10
	SCF 
	RET	Z
	LD	A,D
	OR	E
	JR	NZ,G_CLUS1
	LD	(G_CLUST+1),HL
	XOR	A
	RET 

; HL - CLUSTER

INC_FAT
	PUSH	HL
	CALL	G_CLUST
	POP	DE
	RET	C
	PUSH	HL
	PUSH	HL
	EX	DE,HL
INC_FA2
	CALL	R_F_FAT
	EX	DE,HL
	JR	NC,INC_FA2
	EX	DE,HL
	POP	DE
	CALL	W_T_FAT
	POP	HL
	LD	DE,(ENDCLUS)
	CALL	W_T_FAT
	CALL	WR_FAT
	AND	A
	RET 

;R01

; HL - CLUSTER
; DE - (CLUSTER)

R_F_FAT
	EX	DE,HL
	LD	HL,(MAX_CLU)
	AND	A
	SBC	HL,DE
	EX	DE,HL
	LD	A,10
	RET	C
	EXX 
	LD	A,FATPAGE
	CALL	BANK
	EXX 
	PUSH	HL
	PUSH	AF
	LD	A,(FAT_TYP)
	CP	"2"
	JR	Z,R_F_F12
R_F_F16
	LD	A,H
	LD	B,A
	AND	#0F
	LD	H,A
	LD	A,B
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	AND	#0F	;  A - BLOCK FAT (1 BLOCK = 8192 BYTES)
	ADD	HL,HL	; HL - FAT OFFSET (FROM	CASH)
	LD	BC,(FATCASH)   ; C - BLOCK FAT IN CASH
	CP	C
	CALL	NZ,RE_FAT      ; A <> C	- READ NEW BLOCK FAT
	LD	DE,FAT
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	AF
	OUT	(PAGE3),A
	LD	HL,#FFEF
	XOR	A
	SBC	HL,DE
	POP	HL
	RET 

;R01; HL - CLUSTER
;R01; DE - (CLUSTER)
;R01
;R01R_F_FAT EX	    DE,HL
;R01	    LD	    HL,(MAX_CLU)
;R01	    AND	    A
;R01	    SBC	    HL,DE
;R01	    EX	    DE,HL
;R01	    LD	    A,10
;R01	    RET	    C
;R01	    PUSH    HL
;R01	    LD	    A,(FAT_TYP)
;R01	    CP	    "2"
;R01	    JP	    Z,R_F_F12
;R01R_F_F16 LD	    DE,768  ; DE - CLUSTERS IN CASH
;R01	    XOR	    A
;R01R_F_00H INC	    A	    ; HL - CLUSTER
;R01	    SBC	    HL,DE
;R01	    JP	    NC,R_F_00H
;R01	    ADD	    HL,DE
;R01	    ADD	    HL,HL   ; HL - FAT OFFSET (FROM CASH)
;R01	    DEC	    A
;R01	    LD	    BC,(FATCASH)    ; A	- ELEMENT OF CASH
;R01	    CP	    C
;R01	    CALL    NZ,RE_FAT
;R01	    LD	    DE,FAT
;R01	    ADD	    HL,DE
;R01	    LD	    E,(HL)
;R01	    INC	    HL
;R01	    LD	    D,(HL)
;R01	    LD	    HL,#FFEF
;R01	    AND	    A
;R01	    SBC	    HL,DE
;R01	    POP	    HL
;R01	    LD	    A,0
;R01	    RET
;R01
;R01R_F_F12 LD	    D,H
;R01	    LD	    E,L
;R01	    ADD	    HL,HL
;R01	    ADD	    HL,DE
;R01	    RR	    H
;R01	    RR	    L
;R01	    PUSH    AF
;R01	    EX	    DE,HL
;R01	    LD	    HL,(B_P_S)
;R01	    LD	    B,H
;R01	    LD	    C,L
;R01	    ADD	    HL,HL
;R01	    ADD	    HL,BC
;R01	    EX	    DE,HL
;R01	    XOR	    A	    ; DE - SIZE	SECTOR * 3
;R01R_F_00  INC	    A	    ; HL - FAT OFFSET
;R01	    SBC	    HL,DE
;R01	    JP	    NC,R_F_00
;R01	    ADD	    HL,DE
;R01	    DEC	    A

R_F_F12
	LD	D,H
	LD	E,L
	ADD	HL,HL
	ADD	HL,DE
	RR	H
	RR	L	;CLUSTER * 1.5
	PUSH	AF
	LD	A,H
	LD	B,A
	AND	#1F
	LD	H,A
	LD	A,B
	RLCA 
	RLCA 
	RLCA 
	AND	#07
	LD	BC,(FATCASH)
	CP	C
	CALL	NZ,RE_FAT
	LD	DE,FAT
	ADD	HL,DE
	POP	AF
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	JR	C,R_F_F01
	LD	A,D
	AND	#0F
	LD	D,A
	JR	R_F_F02

R_F_F01	LD	A,E
	AND	#F0
	LD	E,A
	RR	D
	RR	E
	RR	D
	RR	E
	RR	D
	RR	E
	RR	D
	RR	E
R_F_F02
	POP	AF
	OUT	(PAGE3),A
	LD	HL,#0FEF
	XOR	A
	SBC	HL,DE
	POP	HL
	RET 

; HL - CLUSTER
; DE - (CLUSTER)

W_T_FAT
	PUSH	DE
	EX	DE,HL
	LD	HL,(MAX_CLU)
	AND	A
	SBC	HL,DE
	EX	DE,HL
	POP	DE
	LD	A,10
	RET	C
	EXX 
	LD	A,FATPAGE
	CALL	BANK
	EXX 
	PUSH	HL
	PUSH	AF
	LD	A,1
	LD	(FATCASH+1),A
	LD	A,(FAT_TYP)
	CP	"2"
	JR	Z,W_T_F12
W_T_F16	PUSH	DE
	LD	A,H
	LD	B,A
	AND	#0F
	LD	H,A
	LD	A,B
	RRCA 
	RRCA 
	RRCA 
	RRCA 
	AND	#0F	;  A - BLOCK FAT (1 BLOCK = 8192 BYTES)
	ADD	HL,HL	; HL - FAT OFFSET (FROM	CASH)
	LD	BC,(FATCASH)   ; C - BLOCK FAT IN CASH
	CP	C
	CALL	NZ,RE_FAT      ; A <> C	- READ NEW BLOCK FAT
	LD	DE,FAT
	ADD	HL,DE
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	POP	AF
	POP	HL
	OUT	(PAGE3),A
	XOR	A
	RET 

W_T_F12	PUSH	DE
	LD	D,H
	LD	E,L
	ADD	HL,HL
	ADD	HL,DE
	RR	H
	RR	L	;CLUSTER * 1.5
	PUSH	AF
	LD	A,H
	LD	B,A
	AND	#1F
	LD	H,A
	LD	A,B
	RLCA 
	RLCA 
	RLCA 
	AND	#07
	LD	BC,(FATCASH)
	CP	C
	CALL	NZ,RE_FAT
	LD	DE,FAT
	ADD	HL,DE
	POP	AF
	POP	DE
	JR	C,W_T_F01
	LD	(HL),E
	INC	HL
	LD	A,(HL)
	AND	#F0
	OR	D
	LD	(HL),A
	POP	AF
	POP	HL
	OUT	(PAGE3),A
	AND	A
	RET 

W_T_F01	SLA	E
	RL	D
	RL	E
	RL	D
	RL	E
	RL	D
	RL	E
	RL	D
	LD	A,(HL)
	AND	#0F
	OR	E
	LD	(HL),A
	INC	HL
	LD	(HL),D
	POP	AF
	POP	HL
	OUT	(PAGE3),A
	AND	A
	RET 

;R01
; A - NEW FAT BLOCK

RE_FAT
	PUSH	HL
	PUSH	AF
	LD	A,(FATCASH+1)
	OR	A
	CALL	NZ,WR_FAT_
	POP	AF
	LD	L,A
	LD	H,0
	LD	(FATCASH),HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL	;FAT BLOCK * 16	= SECTOR OF FAT
	LD	DE,(FAT_FRM)
	ADD	HL,DE
	EX	DE,HL
	LD	IX,0
	ADD	IX,DE
	LD	HL,0	;HL:IX - SECTOR	FAT FOR	READING
	LD	DE,FAT	;   DE - FAT ADDRESS
	LD	A,(DRIVE)
	LD	B,16	;16 * 512 = 8192 (CASH SIZE)
	LD	C,5
	RST	#18
	POP	HL
	RET 

WR_FAT	EXX 
	LD	A,FATPAGE
	CALL	BANK
	EXX 
	PUSH	AF
	CALL	WR_FAT_
	POP	AF
	OUT	(PAGE3),A
	RET 

WR_FAT_
	LD	HL,(FATCASH)
	LD	H,0
	LD	(FATCASH),HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL	;FAT BLOCK * 16	= SECTOR OF FAT

	PUSH	HL
	LD	B,H
	LD	C,L	;BC - BLOCK OF FAT
	LD	DE,16
	ADD	HL,DE	;+ SIZE	CASH (16 SECTORS)

	LD	DE,(S_P_F)
	LD	A,16
	AND	A
	SBC	HL,DE
	JR	C,WALLFAT
	EX	DE,HL
	LD	HL,16
	SBC	HL,DE
	JR	C,FATERR
	LD	A,L
WALLFAT
	LD	H,B
	LD	L,C
	LD	DE,(FAT_FRM)
	ADD	HL,DE
	EX	DE,HL
	LD	IX,0
	ADD	IX,DE
	LD	HL,0	;HL:IX - SECTOR	OF FAT FOR SAVE
	LD	DE,FAT
	LD	B,A
	LD	C,6
	LD	A,(DRIVE)
	PUSH	BC
	RST	#18
	POP	BC
	POP	HL
	LD	DE,(FAT2_XX)
	ADD	HL,DE
	EX	DE,HL
	LD	IX,0
	ADD	IX,DE
	LD	DE,FAT
	LD	HL,0
	LD	A,(DRIVE)
	LD	C,6
	RST	#18
	RET 
;R01

;R01WR_FAT  LD	    HL,(FATCASH)
;R01	    LD	    H,0
;R01	    LD	    (FATCASH),HL
;R01	    LD	    E,L
;R01	    LD	    D,H
;R01	    ADD	    HL,HL
;R01	    ADD	    HL,DE
;R01	    PUSH    HL
;R01	    LD	    B,H
;R01	    LD	    C,L
;R01	    INC	    HL
;R01	    INC	    HL
;R01	    INC	    HL
;R01	    LD	    DE,(S_P_F)
;R01	    LD	    A,3
;R01	    AND	    A
;R01	    SBC	    HL,DE
;R01	    JP	    C,WR_FAT1
;R01	    EX	    DE,HL
;R01	    LD	    HL,3
;R01	    AND	    A
;R01	    SBC	    HL,DE
;R01	    JP	    C,FATERR
;R01	    LD	    A,L
;R01WR_FAT1 LD	    H,B
;R01	    LD	    L,C
;R01	    LD	    DE,(FAT_FRM)
;R01	    ADD	    HL,DE
;R01	    EX	    DE,HL
;R01	    LD	    IX,0
;R01	    ADD	    IX,DE
;R01	    LD	    DE,FAT
;R01	    LD	    HL,0
;R01	    LD	    B,A
;R01	    LD	    C,6
;R01	    LD	    A,(DRIVE)
;R01	    PUSH    BC
;R01	    RST	    #18
;R01	    POP	    BC
;R01	    POP	    HL
;R01	    LD	    DE,(FAT2_XX)
;R01	    ADD	    HL,DE
;R01	    EX	    DE,HL
;R01	    LD	    IX,0
;R01	    ADD	    IX,DE
;R01	    LD	    DE,FAT
;R01	    LD	    HL,0
;R01	    LD	    A,(DRIVE)
;R01	    LD	    C,6
;R01	    RST	    #18
;R01	    RET

FATERR	POP	HL
	SCF 
	RET 

FATCASH	DW	#0000
MAX_CLU	DW	#0FF0

;//MODULE: FAT_X
;[END]


