;---------------------------------------------------------------
;Rev	Date	   Name	Description
;---------------------------------------------------------------
;R02	06-08-2001 DNS	Secondary IDE
;R01	06-08-2001 DNS	Fixed BUG with partitions on Second hard disk
;---------------------------------------------------------------
;
; Disk Driver Specification ver. 2.20
;[]===========================================================[]
;Procedure : Initialization
;
;Function  : Initialization device(s)
;
;Input	   : C = 00h
;	    IX - Environment
;Output	   : A = Amount	drive support
;	    HL = Size driver
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Open
;
;Function  : Open disk
;
;Input	   : C = 01h
;	     A - Drive
;Output	   : None
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Close
;
;Function  : Close disk
;
;Input	   : C = 02h
;	     A - Drive
;Output	   : None
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Media check
;
;Function  : Checking change line
;
;Input	   : C = 03h
;	     A - Drive
;Output	   : A = 00h disk no changed
;	     A = 0FFh disk changed
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Get BPB
;
;Function  : Get Block Parameters BIOS
;
;Input	   : C = 04h
;	    DE - Address
;Output	   : None
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Input
;
;Function  : Input from	disk
;
;Input	   : C = 05h
;	 HL:IX - Logical Block (sector)
;	    DE - Address
;	     B - Sector	count
;Output	   : None
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Output
;
;Function  : Output to disk
;
;Input	   : C = 06h
;	 HL:IX - Logical Block (sector)
;	    DE - Address
;	     B - Sector	count
;Output	   : None
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Removable
;
;Function  : Checking change line
;
;Input	   : C = 07h
;	     A - Drive
;Output	   : A = 00h Removable
;	     A = FFh Nonremovable
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Generic IOCTL
;
;Function  : Generic Input Output Control
;
;Input	   : C = 08h
;	     B - Subcommand
;	    DE = 55AAh Magic Number
;      Subcommand
;----------------------
;	  00h -	Get Device Parameters
;	  01h -	Read track
;	  02h -	Test track
;	  80h -	Set Device Parameters
;	  81h -	Write track
;	  82h -	Format track
;Output	   :
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Read Long
;
;Function  : Reading sectors from disk
;
;Input	   : C = 0Ah
;	 HL:IX - Logical Block (sector)
;	    DE - Address
;	     B - Sector	count
;	     A'- Page
;Output	   : A'- Next Page
;	 HL:IX - Next Logical Block (sector)
;	    DE - Next Address
;
;[]===========================================================[]
;[]===========================================================[]
;Procedure : Write Long
;
;Function  : Writing sectors to	disk
;
;Input	   : C = 0Bh
;	 HL:IX - Logical Block (sector)
;	    DE - Address
;	     B - Sector	count
;	     A'- Page
;Output	   : A'- Next Page
;	 HL:IX - Next Logical Block (sector)
;	    DE - Next Address
;
;[]===========================================================[]
;
; Errors:
;   0 (00h) - NO ERRORS
;   1 (01h) - BAD COMMAND
;   2 (02h) - BAD DRIVE	NUMBER
;   3 (03h) - UNKNOW FORMAT
;   4 (04h) - NOT READY
;   5 (05h) - SEEK ERROR
;   6 (06h) - SECTOR NOT FOUND
;   7 (07h) - CRC ERROR
;   8 (08h) - WRITE PROTECT
;   9 (09h) - READ ERROR
;  10 (0Ah) - WRITE ERROR
;  11 (0Bh) - FAILURE
;  12 (0Ch) - BUSY (DEVICE OPENED)
;  13 (0Dh) - RESERVED

LD_DSK	EQU	16

IDE0	EQU	#0C1C0
IDE1	EQU	#0C1C8
PART	EQU	#C000

HDDRIVE
	INC	C
	DEC	C
	JR	Z,INIT_H	;#00
	DEC	C
	JP	Z,RESE_H	;#01
	DEC	C
	JP	Z,STAT_H	;#02
	DEC	C
	JP	Z,CHEK_H	;#03
	DEC	C
	JP	Z,GBPB_H	;#04
	DEC	C
	JP	Z,READH		;#05
	DEC	C
	JP	Z,WRITEH	;#06
	DEC	C
	JP	Z,REMOV_H	;#07
	DEC	C
	JP	Z,IOCTL_H	;#08
	DEC	C
	JR	Z,RESR_H	;#09
	DEC	C
	JP	Z,LREADH	;#0A
	DEC	C
	JP	Z,LWRITEH	;#0Bh

RESR_H                              ; TODO: UNK?
	LD	A,1
	SCF 
	RET 

;Commands for restart #18
INIT_H
	PUSH	IY
	LD	HL,LOGDRV
	LD	(OFFSECT),HL
	LD	IX,DEVICE_CFG
	LD	C,#5F
	RST	#08
	XOR	A
	LD	B,(IX+2)	;HDD
	CP	B
	JR	Z,NO_HARDS
    LD  B,0x04                      ; TODO: 1op
	LD	C,0x80

NX_DVCI
	PUSH	BC
	LD	A,C
	LD	(DRV),A
	CALL	PARTIT
	POP	BC
	INC	C
	DJNZ	NX_DVCI

NO_HARDS
	POP	IY
	LD	HL,(OFFSECT)
	LD	DE,LOGDRV
	XOR	A
	SBC	HL,DE
	RET	Z
	LD	DE,LD_DSK

DRVCLC
	INC	A
	SBC	HL,DE
	JR	NZ,DRVCLC
	AND	A
	RET 

LOGDRV DB 0                             ;+00	BYTE	MASTER/SLAVE PHISICAL DRIVE NUMBER #80/#81/...
SOFF   DW 0,0                           ;+01	LONG	SECTOR OFFSET
NSECT  DW 0,0                           ;+05	LONG	SIZE IN	SECTORS
       DS 183,0                         ;+09	FREE

DEVICE_CFG	EQU	#4000


;+00	;SECTORS PER TRACK
;+01	;TRACKS	PER CYLLINDER
;+02	;RESERVED
;+03	;HDD/DRIVE/LBA
;+04	;SECTOR	PER CYLINDER LOW
;+05	;SECTOR	PER CYLINDER HIGH
;+06	;RESERVED
;+07	;RESERVED

DRVHD_H	EQU	0
SC_PT_H	EQU	1
HEADS_H	EQU	2
CYL_L_H	EQU	3
CYL_H_H	EQU	4
SPCLL_H	EQU	5
SPCLH_H	EQU	6


;IDE0	 DB	 #FF	 ;DRIVE/HEAD REGISTER	      ;00
;	 DB	 #FF	 ;SECTORS PER TRACK	      ;01
;	 DB	 #FF	 ;HEADS			      ;02
;	 DB	 #FF	 ;CYLINDERS LOW		      ;03
;	 DB	 #FF	 ;CYLINDERS HIGH	      ;04
;	 DB	 #FF	 ;SECTOR PER CYLINDER LOW     ;05
;	 DB	 #FF	 ;SECTOR PER CYLINDER HIGH    ;06
;	 DB	 #FF	 ;RESERVED		      ;07

;IDE1	 DB	 #FF	 ;DRIVE/HEAD REGISTER	      ;00
;	 DB	 #FF	 ;SECTORS PER TRACK	      ;01
;	 DB	 #FF	 ;HEADS			      ;02
;	 DB	 #FF	 ;CYLINDERS LOW		      ;03
;	 DB	 #FF	 ;CYLINDERS HIGH	      ;04
;	 DB	 #FF	 ;SECTOR PER CYLINDER LOW     ;05
;	 DB	 #FF	 ;SECTOR PER CYLINDER HIGH    ;06
;	 DB	 #FF	 ;RESERVED		      ;07


SELHDD
    PUSH       DE
    PUSH       BC
    PUSH       HL
    LD         L,A
    LD         H,0x0
    ADD        HL,HL
    ADD        HL,HL
    ADD        HL,HL
    ADD        HL,HL
    EX         DE,HL
    LD         HL,LOGDRV
    ADD        HL,DE
    LD         A,(HL)			; LOGDRV
    INC        HL
    LD         C,(HL)			; =>SOFF+0
    INC        HL
    LD         B,(HL)			; =>SOFF+1
    INC        HL
    LD         E,(HL)			; =>SOFF+2
    INC        HL
    LD         D,(HL)			; =>SOFF+3
    POP        HL
    ADD        IX,BC
    ADC        HL,DE
    POP        BC
    POP        DE
    RET


;	  00 - GET DEVICE PARAMETERS
;	  01 - READ TRACK
;	  02 - TEST TRACK
;	  80 - SET DEVICE PARAMETERS
;	  81 - WRITE TRACK
;	  82 - FORMAT TRACK

IOCTL_H	
    BIT	7,B
	JR	NZ,O_CTL_H
	INC	B
	DEC	B
	JR	Z,HGETPRM
	DEC	B
	JR	Z,HRDTRAC
	DEC	B
	JR	Z,HCHTRAC
	LD	A,1
	SCF 
	RET 

O_CTL_H
	RES	7,B
	INC	B
	DEC	B
	JR	Z,HSETPRM
	DEC	B
	JR	Z,HWRTRAC
	DEC	B
	JR	Z,HFRTRAC
	LD	A,1
	SCF 
	RET 

HRDTRAC
	LD	A,11
	SCF 
	RET 

HCHTRAC
	LD	B,L
	JP	CHECKH

HSETPRM
	AND	A
	RET 

HWRTRAC
	LD	A,11
	SCF 
	RET 

HFRTRAC
	LD	A,11
	SCF 
	RET 

; HL:DE	- SECTORS ON LOGICAL DISK
; HL'	- CYLINDERS ON PHISICAL	DISK
; DE'	- HEADS	ON PHISICAL DISK
; BC'	- SECTORS PER TRACK ON PHISICAL	DISK
;  A'	- PHISICAL DRIVE NUMBER
;  A	- DRIVE/HEAD REGISTER PHISICAL DISK
;	D0...D3	- "0" RESERVED (MAY BE OTHER)
;	D4	- DEVICE MASTER/SLAVE
;	D5	- "1" RESERVED
;	D6	- ADDRESSING MODE LBA/CHS
;	D7	- "1" RESERVED

HGETPRM
	EX	DE,HL
	LD	BC,#55AA
	AND	A
	SBC	HL,BC
	LD	L,A
	LD	A,11
	SCF 
	RET	NZ
	PUSH	IY
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	B,H
	LD	C,L
	LD	IY,LOGDRV
	ADD	IY,BC
	LD	E,(IY+5)    ; Number of sectors 0
	LD	D,(IY+6)    ; Number of sectors 1
	LD	L,(IY+7)    ; Number of sectors 2
	LD	H,(IY+8)    ; Number of sectors 3

	LD	A,(IY+0)    ; drv
	LD	C,A
	LD	IY,IDE0
	AND	#0F
	JR	Z,GELH1
	LD	IY,IDE1
GELH1
	IN	A,(PAGE3)
	PUSH	AF
	LD	A,SYSPAGE
	OUT	(PAGE3),A

	LD	A,(IY+DRVHD_H)	     ;HDD/DRV
	EXX 
	LD	L,(IY+CYL_L_H)	     ;CYLINDER LOW
	LD	H,(IY+CYL_H_H)	     ;CYLINDER HIGH
	LD	E,(IY+HEADS_H)	     ;HEADS
	LD	D,0
	LD	B,D
	LD	C,(IY+SC_PT_H)	     ;SECTORS
	EXX 
	EX	AF,AF'
	POP	AF
	OUT	(PAGE3),A
	LD	A,C
	EX	AF,AF'
	POP	IY
	AND	A
	RET 

REMOV_H
	LD	A,1
	AND	A
	RET 

RESE_H
    LD         L,A
    LD         H,0x0
    ADD        HL,HL
    ADD        HL,HL
    ADD        HL,HL
    ADD        HL,HL
    EX         DE,HL
    LD         HL,LOGDRV
    ADD        HL,DE
    LD         A,(HL)
    RET

STAT_H
	XOR	A
	RET 

CHEK_H
	LD	A,#FF
	AND	A
	RET 

;HL:IX - SECTOR
;   DE - ADDRESS

GBPB_H
    LD  HL,0x0
    LD  IX,0x0
    CALL    SELHDD
    LD  BC,0x155
    JP  A0008

;HL:IX - SECTOR
;   DE - ADDRESS
;    B - COUNTER
;    A'- PAGE

;READ SECTOR
LREADH
	CALL	SELHDD
	LD	C,0x52
    JP  A0008

;HL:IX - SECTOR
;   DE - ADDRESS
;    B - COUNTER
;    A'- PAGE

;WRITE SECTOR
LWRITEH
	CALL	SELHDD
	LD	C,0x53
    JP  A0008

;HL:IX - SECTOR
;   DE - ADDRESS
;    B - COUNTER

;WRITE SECTOR
WRITEH
	CALL	SELHDD
	LD	C,0x56
    JP  A0008

;HL:IX - SECTOR
;   DE - ADDRESS
;    B - COUNTER

;READ SECTOR
READH
	CALL	SELHDD
	LD	C,0x55
    JP  A0008

;HL:IX - SECTOR
;   DE - ADDRESS
;    B - COUNTER

;CHECK SECTOR
CHECKH
	CALL	SELHDD
	LD	C,0x54
    JP  A0008

;-----------------
EASYDOS
MEDIDOS
HIGHDOS
	LD	E,(IY+08)
	LD	D,(IY+09)
	LD	L,(IY+10)
	LD	H,(IY+11)
	LD	IX,(CURSECL)
	ADD	IX,DE
	LD	DE,(CURSECH)
	ADC	HL,DE
	LD	D,XH
	LD	E,XL
	LD	IX,(OFFSECT)
	LD	(IX+1),E	;BPB SECTOR
	LD	(IX+2),D
	LD	(IX+3),L
	LD	(IX+4),H
;	LD	DE,(CURSECL)
;	LD	HL,(CURSECH)
;	LD	(IX+1),E	;START DISK
;	LD	(IX+2),D
;	LD	(IX+3),L
;	LD	(IX+4),H
	LD	E,(IY+12)
	LD	D,(IY+13)
	LD	L,(IY+14)
	LD	H,(IY+15)
	LD	(IX+5),E       ;SIZE DISK
	LD	(IX+6),D
	LD	(IX+7),L
	LD	(IX+8),H
	LD	A,(DRV)
	LD	(IX+0),A
	LD	DE,LD_DSK      ;  DSKITEM
	ADD	IX,DE
	LD	(OFFSECT),IX
NXTPART
	LD	DE,#10
	ADD	IY,DE
	POP	BC
	DJNZ	DOSAGA
	AND	A
	RET 

PARTIT	IN	A,(PAGE3)
	PUSH	AF
	LD	A,#FF
	OUT	(PAGE3),A
	CALL	PARTIT1
	POP	AF
	OUT	(PAGE3),A
	RET 

PARTIT1
	LD	IX,0
	LD	DE,0
	LD	(EXTDOSL),DE	;R01
	LD	(EXTDOSH),IX	;R01
PARTIT2
	LD	(CURSECL),DE
	LD	(CURSECH),IX
	CALL	LOADSEC
    RET C
	LD	HL,(PART+510)
	LD	DE,#AA55
	AND	A
	SBC	HL,DE
	JR	NZ,NODEFIN
	LD	IY,PART+#01BE
	LD	B,4
DOSAGA
	PUSH	BC
	LD	A,(IY+4)
	CP	5
	JR	NZ,NOEXTDS

SUBLEV
	PUSH	IY
	LD	DE,(CURSECL)
	LD	IX,(CURSECH)
	PUSH	DE
	PUSH	IX
	CALL	EXTDOS
	POP	IX
	POP	DE
	LD	(CURSECL),DE
	LD	(CURSECH),IX
	CALL	LOADSEC
	POP	IY
	JR	NXTPART
    
NOEXTDS	
    CP	0xf
    JR	Z,SUBLEV
    CP	0xe
    JP	Z,HIGHDOS
    CP	0x6
    JP	Z,HIGHDOS
    CP	0x4
    JP	Z,HIGHDOS
    CP	0x1
    JP	Z,HIGHDOS
    CP	0xb
    JR	Z,SUBLEV
    CP	0x7
    JR	Z,SUBLEV
    CP	0x82
    JR	Z,SUBLEV
    CP	0x83
    JR	Z,SUBLEV
    CP	0xeb
    JR	Z,SUBLEV
    POP	BC
    OR	A
    RET	Z
NODEFIN
	SCF 
	RET 

EXTDOS
	LD	HL,(EXTDOSL)
	LD	DE,(EXTDOSH)
	LD	A,L
	OR	H
	OR	E
	OR	D
	LD	E,(IY+08)
	LD	D,(IY+09)
	LD	L,(IY+10)
	LD	H,(IY+11)
	JR	NZ,EXTDOS2
	LD	(EXTDOSL),DE
	LD	(EXTDOSH),HL
	LD	IX,(EXTDOSH)
	JP	PARTIT2

EXTDOS2
	LD	IX,(EXTDOSL)
	ADD	IX,DE
	PUSH	IX
	LD	DE,(EXTDOSH)
	ADC	HL,DE
	PUSH	HL
	POP	IX
	POP	DE
	JP	PARTIT2

LOADSEC
	PUSH	IY
	LD	IX,(CURSECL)
	LD	HL,(CURSECH)
	LD	DE,PART
	LD	BC,#0155
	LD	A,(DRV)
	RST	#08
	POP	IY
	RET 

DRV	DB	#00	;PHISICAL DRIVE	NUMBER

CURSECL	DW	#0000	;CURRENT SECTOR	LOADED
CURSECH	DW	#0000

EXTDOSL	DW	#0000	;CURRENT PARTITION TABLE
EXTDOSH	DW	#0000

OFFSECT	DW	LOGDRV	;POINTER ON CURRENT DISK RECORD

;=======================================================