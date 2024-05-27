
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

RMDRIVE
	INC	C
	DEC	C
	JP	Z,INIT_RD
	DEC	C
	JR	Z,RESE_RD
	DEC	C
	JR	Z,STAT_RD
	DEC	C
	JR	Z,CHEK_RD
	DEC	C
	JR  Z,GBPB_RD
	DEC	C
	JR	Z,READR
	DEC	C
	JR	Z,WRITER
	LD	A,1
	SCF 
	RET 

RESE_RD
	XOR	A
	RET 

STAT_RD
	XOR	A
	RET 

CHEK_RD
	LD	A,#FF
	AND	A
	RET 

;DE - ADDRESS

GBPB_RD
	LD	IX,0
	LD	HL,0
	LD	B,#01
	;JP	READR

;READ SECTORS
; HL:IX	- SECTOR
;    DE	- ADDRESS
;     B	- COUNT
;     A	- DRIVE

READR
	PUSH	BC
	PUSH	IX
	PUSH	HL
	PUSH	BC
	CALL	RAMADDR
	POP	BC
	LD	IX,512
RAMRLOP
	PUSH	BC
	PUSH	IX
	CALL	LRDSEC
	POP	IX
	POP	BC
	DJNZ	RAMRLOP
	POP	HL
	POP	IX
	POP	BC
	XOR	A
	CP	B
	LD	C,B
	LD	B,A
	JR	Z,DYEP256
	ADD	IX,BC
	LD	C,B
	ADC	HL,BC
	XOR	A
	RET 

DYEP256	INC	B
	ADD	IX,BC
	LD	B,C
	ADC	HL,BC
	XOR	A
	RET 


;WRITE SECTORS
; HL:IX	- SECTOR
;    DE	- ADDRESS
;     B	- COUNT
;     A	- DRIVE

WRITER	PUSH	BC
	PUSH	IX
	PUSH	HL
	PUSH	BC
	CALL	RAMADDR
	POP	BC
	LD	IX,512
RAMWLOP
	PUSH	BC
	PUSH	IX
	CALL	WRDSEC
	POP	IX
	POP	BC
	DJNZ	RAMWLOP
	POP	HL
	POP	IX
	POP	BC
	XOR	A
	CP	B
	LD	C,B
	LD	B,A
	JR	Z,WYEP256
	ADD	IX,BC
	LD	C,B
	ADC	HL,BC
	XOR	A
	RET 

WYEP256	INC	B
	ADD	IX,BC
	LD	B,C
	ADC	HL,BC
	XOR	A
	RET 


INIT_RD
    LD         A,0x20
    LD         (S_P_P),A
    LD         DE,RAMDTBL
    LD         BC,0xce

INIT_R0
	PUSH	BC
	LD	A,B
	RST	#08
	OR	A
	JR	Z,NORAMD
	LD	(DE),A
	INC	DE

NORAMD
	POP	BC
	INC	B
	LD	A,#10
	CP	B
	JR	NZ,INIT_R0
	LD	HL,RAMDTBL
	EX	DE,HL
	AND	A
	SBC	HL,DE
	LD	A,L
	AND	A
	RET 

RAMDTBL	DB	#FF,#FF,#FF,#FF
	DB	#FF,#FF,#FF,#FF
	DB	#FF,#FF,#FF,#FF
	DB	#FF,#FF,#FF,#FF

; SECTOR / S_P_P = START PAGE
; INPUT	: HL:IX	-SECTOR
; OUTPUT: A':HL	- ADDRESS

RAMADDR
	LD	BC,RAMDTBL
	ADD	A,C
	LD	C,A
	LD	A,0
	ADC	A,B
	LD	B,A
	LD	A,(BC)
	EX	AF,AF'
	LD	B,XH
	LD	C,XL
	LD	A,(S_P_P)	;   (S_P_P)	  ;SECTORS PER P
;AGE
DIVR0
	RRCA 
	JR	C,DIVR1
	RR	H
	RR	L
	RR	B
	RR	C
	JR	DIVR0
DIVR1
	LD	B,C
	LD	C,#C4	;GET FIRST PAGE
	EX	AF,AF'
	RST	#08
	EX	AF,AF'
	LD	A,(S_P_P)
	LD	C,A
	DEC	C
	LD	A,XL
	AND	C
	INC	A
	LD	HL,#C000
	LD	BC,512
	SBC	HL,BC
ADDLP
	ADD	HL,BC
	DEC	A
	JR	NZ,ADDLP
	RET 

S_P_P	DB	#00

; A':HL	- ADDRESS SOURCE
;    DE	- ADDRESS DESTINATION

LRDSEC	LD	A,D
	CP	#A0
	LD	C,PAGE3
	SET	6,H
	JR	C,RMDL02
	LD	C,PAGE1
	RES	7,H
RMDL02
	IN	A,(C)
	EX	AF,AF'
	DI 
	OUT	(C),A
	LD	B,XH
	LD	XH,C
	LD	C,XL
	LDIR 
	EX	AF,AF'
	LD	C,XH
	OUT	(C),A
	LD	A,H
	AND	#7F
	EI 
	RET	NZ
	LD	C,PAGE3		;GET NEXT PAGE
	IN	B,(C)
	LD	A,SYSPAGE
	OUT	(C),A
	EX	AF,AF'
	LD	XH,#C2
	LD	XL,A
	LD	A,(IX)
	EX	AF,AF'
	OUT	(C),B
	LD	H,#C0
	RET 

; A':HL	- ADDRESS SOURCE
;    DE	- ADDRESS DESTINATION

WRDSEC	LD	A,D
	CP	#A0
	LD	C,PAGE3
	SET	6,H
	JR	C,WMDL02
	LD	C,PAGE1
	RES	7,H
WMDL02	IN	A,(C)
	EX	AF,AF'
	DI 
	OUT	(C),A
	LD	B,XH
	LD	XH,C
	LD	C,XL
	EX	DE,HL
	LDIR 
	EX	DE,HL
	EX	AF,AF'
	LD	C,XH
	OUT	(C),A
	LD	A,H
	AND	#7F
	EI 
	RET	NZ
	LD	C,PAGE3		;GET NEXT PAGE
	IN	B,(C)
	LD	A,SYSPAGE
	OUT	(C),A
	EX	AF,AF'
	LD	XH,#C2
	LD	XL,A
	LD	A,(IX)
	EX	AF,AF'
	OUT	(C),B
	LD	H,#C0
	RET 

ENDDRVR

