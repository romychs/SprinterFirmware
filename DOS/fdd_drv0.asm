
; Disk Driver Specification ver. 2.00
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

R_COM	EQU	#0F	;Command/Status
R_TRK	EQU	#3F	;Track
R_SEC	EQU	#5F	;Sector
R_DAT	EQU	#7F	;Data
R_DSK	EQU	#FF	;Drive Control

COM_B	EQU	#1B

FDDRIVE
	INC	C
	DEC	C
	JR	Z,INIT		;#00
	DEC	C
	JR	Z,RESE		;#01
	DEC	C
	JR	Z,STAT		;#02
	DEC	C
	JR	Z,CHEK		;#03
	DEC	C
	JR	Z,GBPB		;#04
	DEC	C
	JR	Z,READD		;#05
	DEC	C
	JR	Z,WRITED	;#06
	DEC	C
	JP	Z,REMOV_F	;#07
	DEC	C
	JR	Z,IOCTL_F	;#08
	LD	A,1                             ; TODO: NOOP?
	SCF 
	RET 

;Commands for restart #18
INIT
	LD	A,2
	AND	A
	RET 

RESE
	LD	C,#51
	RST	#08
	RET 

STAT
	XOR	A
	RET 

CHEK
	LD	A,#FF
	AND	A
	RET 

;DE - ADDRESS

GBPB
	LD	IX,0
	LD	HL,0
	PUSH	DE
	PUSH	AF
	LD	BC,#0155
	RST	#08
	POP	DE
	POP	HL
	RET	C
	LD	BC,#0018
	ADD	HL,BC
	LD	E,(HL)
	PUSH	DE
	LD	A,D
	LD	C,#58
	RST	#08
	LD	A,H
	POP	HL
	PUSH	HL
	LD	H,A
	POP	AF
	LD	C,#59
	RST	#08
	XOR	A
	RET 

;READTR
;	XOR	A
;	RET 

READD
	LD	C,#55
	RST	#08
	RET 

WRITED
	LD	C,#56
	RST	#08
	RET 

;	  00 - GET DEVICE PARAMETERS
;	  01 - READ TRACK
;	  02 - TEST TRACK
;	  80 - SET DEVICE PARAMETERS
;	  81 - WRITE TRACK
;	  82 - FORMAT TRACK


IOCTL_F
	BIT	7,B
	JR	NZ,O_CTL_F
	INC	B
	DEC	B
	JR	Z,FGETPRM
	LD	A,1
	SCF 
	RET 

O_CTL_F
	RES	7,B
	INC	B
	DEC	B
	JR	Z,FSETPRM
	LD	A,1
	SCF 
	RET 


; HL:DE	- SECTORS ON LOGICAL DISK
; HL'	- CYLINDERS ON PHISICAL	DISK
; DE'	- HEADS	ON PHISICAL DISK
; BC'	- SECTORS PER TRACK ON PHISICAL	DISK
;  A'	- PHISICAL DRIVE NUMBER
;  A	- EXTENDED INFORMATION
;	D0...D3	- "0" RESERVED (MAY BE OTHER)
;	D4	- DEVICE MASTER/SLAVE
;	D5	- "1" RESERVED
;	D6	- ADDRESSING MODE LBA/CHS
;	D7	- "1" RESERVED

FGETPRM	EX	DE,HL
	LD	BC,#55AA
	AND	A
	SBC	HL,BC
	LD	L,A
	LD	A,11
	SCF 
	RET	NZ
	LD	A,L
	AND	#0F
	PUSH	AF
	LD	C,#58
	RST	#08
	JR	C,NONEF
	PUSH	HL
	PUSH	DE
	LD	A,H
	LD	H,0
MULL1
	ADD	HL,HL
	DEC	A
	JR	NZ,MULL1
; HL - SECTOR PER CYLLINDER
	LD	B,H
	LD	C,L
	EX	AF,AF'
    XOR A
	LD  L,A
    LD  H,A

MULL2
	EX	AF,AF'
	ADD	HL,BC
	ADC	A,0
	DEC	DE
	EX	AF,AF'
	LD	A,D
	OR	E
	JR	NZ,MULL2
	EX	AF,AF'
	LD	E,A
	EX	DE,HL
	EXX 
	POP	DE
	POP	HL
	POP	AF
	EX	AF,AF'
	LD	A,B
	LD	C,L
	LD	B,0
	LD	L,H
	LD	H,B
	EX	DE,HL
	EXX 
	AND	A
	RET 

NONEF
	POP	AF
	LD	A,2
	SCF 
	RET 


; HL:DE	- SECTORS ON LOGICAL DISK
; HL'	- CYLINDERS ON PHISICAL	DISK
; DE'	- HEADS	ON PHISICAL DISK
; BC'	- SECTORS PER TRACK ON PHISICAL	DISK
;  A'	- EXTENDED INFORMATION
;	D0...D3	- "0" RESERVED (MAY BE OTHER)
;	D4	- DEVICE MASTER/SLAVE
;	D5	- "1" RESERVED
;	D6	- ADDRESSING MODE LBA/CHS
;	D7	- "1" RESERVED

FSETPRM
	PUSH	AF
	EXX 
	EX	DE,HL
	LD	H,L
	LD	L,C
	POP	AF
	AND	#0F
	PUSH	AF
	PUSH	HL
	PUSH	DE
	LD	C,#58
	RST	#08
	POP	DE
	POP	HL
	JR	C,NONEF
	POP	AF
	LD	C,#59
	RST	#08
	RET	C
	AND	A
	RET 

REMOV_F
	LD	A,1
	AND	A
	RET 

;==============================================



