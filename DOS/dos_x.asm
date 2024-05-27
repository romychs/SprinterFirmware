
;[BEGIN]
;//MODULE: DOS_X
;//CREATE: 19-05-1998	AUTHOR:	Denis Parinov
;//UPDATE: 24-10-1999	DNS	Restore	module
;---------------------------------------------------------------
;Rev	Date	   Name	Description
;---------------------------------------------------------------
;R11	15-04-2003 DNS	ROUTINE FOR STORE CURDISK AND CURDIR
;R10	03-04-2003 DNS	IMPROVED FN. VERSION
;R09	27-03-2003 DNS	PASTED SET/GET BOOT FN.
;R08	14-11-2002 DNS	IMPROVE BPB-FUNCTION
;R07	17-12-1999 DNS	BUG FIX	SIGNATURE #55AA	AT 510 OFFSET
;R06	21-11-1999 DNS	FN. DISKINF SUPPORT ALL	DISKS
;R05	21-11-1999 DNS	BUG FIX	SIGNATURE #55AA	IN BOOT	SECTOR
;R04	08-11-1999 DNS	KILL OLD FUNCTIONS
;R03	23-11-1998 DNS	BUG FIX (IX+28)	-> (IY+28)
;R02	21-11-1998 DNS	CHANGE FUNCTION "MAKE FAT"
;R01	20-11-1998 DNS	REPAIR FUNCTION	"SAVE"
;---------------------------------------------------------------

RGADR	                        EQU	0x89	;VIDEO CONTROL REGISTER
PAGE0	                        EQU	0x82	;WIN 0x0000-#3FFF
PAGE1	                        EQU	0xA2	;WIN #4000-#7FFF
PAGE2	                        EQU	0xC2	;WIN #8000-#BFFF
PAGE3	                        EQU	0xE2	;WIN #C000-0xFFFF

SYSPAGE	                        EQU	0xFE

;Commands for restart #10
;NOPS
;	LD	A,ERR_INVALID_FUNCTION
;	SCF 
;	RET 

VERSION	
	XOR	A
    LD	DE,VERS*256+MODF
    LD  BC, SUBMOD
	LD	H,A
	LD	L,A
	RET 

CHNDISK
	LD	C,A
	PUSH	BC
	LD	C,0x1
	RST	0x18
	POP	BC
	JR	C,NDISK11
	LD	A,C
	LD	(DRIVE),A
	CALL	RD_BPB
	RET	C
	LD	A,(LDRIVE)
	AND	A
	RET
NDISK11
	CP	0x2
	SCF
	RET	Z
	LD	A,0x14
	RET

CURRDSK
	LD	A,(DRIVE)
	AND	A
	RET 

DISKINF
	INC	A
	JR	Z,CURRDS	;R06
	DEC	A		;R06
	CALL	CHNDISK		;R06
	RET	C		;R06

CURRDS
	LD	HL,2
	LD	BC,0

FRESP
	PUSH	BC
	CALL	R_F_FAT
	POP	BC
	CP	10
	JR	Z,FRESP2
	XOR	A
	CP	E
	JR	NZ,SKIC
	CP	D
	JR	NZ,SKIC
	INC	BC
SKIC
	INC	HL
	JR	FRESP

FRESP2
	LD	D,B
	LD	E,C
	LD	HL,(MAX_CLU)
	DEC	HL
	LD	BC,(B_P_S)
	LD	A,(S_P_C)
	AND	A
	RET 

LDRIVE	DB	0x02
TDRIVE	DB	0x00
TCLUST	DW	0x0000
TCOUNT	DW	0x0000
        DB  0
RD_BPB
	LD	C,PAGE3
	IN	B,(C)
	PUSH	BC
    EX  AF,AF'
    IN	A,(PAGE0)
	OUT	(PAGE3),A
	LD	DE,SECBUF+0xC000	;R08
    EX  AF,AF'
	LD	C,4
	RST	0x18
	POP	BC
	OUT	(C),B
	JP	C,RDERR1
    LD	DE,#AA55
	LD	HL,(SECBUF+510)
	AND	A		
	SBC	HL,DE	
	JP	NZ,ERR_BPB
	LD	HL,SECBUF
	LD	DE,BOOT	
	LD	BC,SIZE_OF_BOOT
	LDIR
    LD A, (ID_FORM)
	CP	0xF0
	JP	C,ERR_BPB
	LD	HL,0	      ;	calc. first sector FAT
	LD	DE,(RESERVE)    ;Reserve sec
    EX  DE,HL
	LD	(FAT_FRM),HL  ;	first sector FAT
	LD	(FAT2_XX),HL  ;	first sector FAT #2
    LD  DE,(S_P_F)
    LD	A,(FAT_NUM)   ;	amount FATs
	CP	1
	JR	Z,C_DATA1
	DEC	A
	ADD	HL,DE
	LD	(FAT2_XX),HL

C_DATA1
	ADD	HL,DE
	DEC	A
	JR	NZ,C_DATA1
	LD	(DIR_FRM),HL  ;	first sector DIR
    LD  BC,(B_P_S)
	RL	C
	RL	B
	RL	C
	RL	B
	RL	C
	RL	B
	LD	C,B
	LD	B,0	      ;	BC - File handels in sectors
	LD	A,C
	LD	(F_P_S),A
    LD  DE,(F_P_DIR)
	EX	DE,HL
	DEC	HL
	XOR	A
NEXTAD2
	INC	A
	JP	Z,ERR_BPB
	SBC	HL,BC
	JR	NC,NEXTAD2
	EX	DE,HL
	LD	C,A	      ;	A - sectors in DIR
	LD	B,0
	LD	(DIR_S_S),A
	ADD	HL,BC	      ;	Start DATA area
	LD	(DAT_FRM),HL
	LD	BC,(B_P_S)    ;	Size sector
	LD	HL,0
	LD	A,(S_P_C)
NEXTAD3
	ADD	HL,BC	      ;	calc. cluster size
	DEC	A
	JR	NZ,NEXTAD3
	LD	(CLU_LEN),HL
	EX	DE,HL
	LD	HL,#3FFF
	XOR	A
NEXTAD4
	INC	A
	JP	Z,ERR_BPB
	SBC	HL,DE
	JR	NC,NEXTAD4
	LD	(C_P_B),A      ; A - Clusters per bank (16k)

	LD	HL,ID_FAT
	LD	DE,FATMSG
	LD	B,3
R_BPBL1
	LD	A,(DE)
	CP	(HL)
	JP	NZ,IBMDOS_
	INC	HL
	INC	DE
	DJNZ	R_BPBL1
FID
	LD	A,(HL)
	INC	HL
	CP	#20
	JR	Z,FID
	CP	"1"
	JP	NZ,ERR_BPB
	LD	A,(HL)
	CP	"6"	       ; FAT16
	LD	HL,0xFFFF
	JR	Z,BPB_FAT
	CP	"2"	       ; FAT12
	JP	NZ,ERR_BPB
	LD	HL,0x0FFF
BPB_FAT
	LD	(FAT_TYP),A
	LD	(ENDCLUS),HL
	LD	HL,0
	LD	BC,(S_P_T)    ;	Sector per track
	LD	A,(HEADS)
BPB_L1:			      ;	calc. sector per cylinder
	ADD	HL,BC
	DEC	A
	JR	NZ,BPB_L1
	LD	(S_X_H),HL
	LD	DE,(DAT_FRM)
	LD	HL,(S_P_D)
	LD	A,H
	OR	L
	JR	NZ,HDDSMAL
	LD	HL,(BPB_BIG_TOTAL_SECTORS)
	LD	BC,(BPB_BIG_TOTAL_SECTORS+2)
	SBC	HL,DE
	JR	NC,HDDBIG
	DEC	BC
	JR	HDDBIG
HDDSMAL
	SBC	HL,DE
	LD	BC,0
HDDBIG
	LD	A,(S_P_C)
	SCF 
S4C01
	RRA 
	JR	C,S4C02
	RR	B
	RR	C
	RR	H
	RR	L
	JR	S4C01
S4C02
	INC	HL
	LD	(MAX_CLU),HL
	LD	HL,0
	LD	(FATCASH),HL
	LD	A,FATPAGE
	CALL	BANK
	PUSH	AF
	XOR	A
	CALL	RE_FAT
	POP	AF
	OUT	(PAGE3),A
	CALL	R_CLUST
	XOR	A
	RET 

IBMDOS_
	LD	A,(ID_FORM)
	CP	0xF0
	JR	C,ERR_BPB
	CP	0xF8
	LD	A,"6"
	LD	HL,0xFFFF
	JR	Z,BPB_FAT
	LD	A,"2"
	LD	HL,0x0FFF
	JP	BPB_FAT

ERR_BPB
	LD	A,13
	SCF 
	RET 

RDERR1
	LD	A,20
	SCF 
	RET 

FATMSG	DB	"FAT"

READ_PG	DB	0x00

BLOCK	DB	0x00

DIR_CLU	DW	0x0000

;DRIVE	DB	0x01
FAT_FRM
FAT1_XX	DW	0x0000	; MSD_FAT_SEC first sector FAT
FAT2_XX	DW	0x0000
DIR_FRH	DW	0x0000	; MSD_CAT_SEC first sector DIR
DIR_FRM
DIR_FRL	DW	0x0000	; MSD_CAT_SEC first sector DIR
F_P_S	DB	0x00
DIR_S_S	DB	0x00	; DIR_SEC_SIZE
DAT_FRM	DW	0x0000	; MSD_DAT_SEC
CLU_LEN
B_P_C	DW	0x0000	; CLUSTER_LEN
C_P_B	DB	0x00	; A - Clusters per bank	(16k)
FAT_TYP	DB	0x00	; TYPE FAT (#32	- 12bit, #36 - 16bit)
S_X_H	DW	0x0000
ENDCLUS	DW	0xFFFF

DIRSPEC	DB	#5C	; \
	    DS	256


;=============================================
;//MODULE: DOS_X
;[END]

