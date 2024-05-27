
; DISK DRIVER SPECIFICATION
;---------------------------------------------
; COMMAND 00h (INITIALIZATION)
;
;   INPUT: A - DRIVE LETTER
;	  IX - ENVIRONMENT
;  RETURN: A - AMOUNT DRIVE SUPPORT
;	  HL - LENGHT DRIVER
;---------------------------------------------
; COMMAND 01h (OPEN)
;
;   INPUT: A - DRIVE
;
;---------------------------------------------
; COMMAND 02h (CLOSE)
;
;   INPUT: A - DRIVE
;  RETURN: A -
;---------------------------------------------
; COMMAND 03h (MEDIA CHECK)
;
;   INPUT: A - DRIVE
;  RETURN: A - 00h - OLD DISK, 0FFh - NEW DISK
;---------------------------------------------
; COMMAND 04h (GET BPB)
;
;   INPUT: HL -	ADDRESS
;	    A -	DRIVE
;---------------------------------------------
; COMMAND 05h (INPUT)
;
;   INPUT: IX:DE - ABSOLUTE SECTOR
;	      HL - MEMORY ADDRESS
;	       B - SECTORS COUNT
;	       A - DRIVE
;---------------------------------------------
; COMMAND 06h (OUTPUT)
;
;   INPUT: IX:DE - ABSOLUTE SECTOR
;	      HL - MEMORY ADDRESS
;	       B - SECTORS COUNT
;	       A - DRIVE
;---------------------------------------------
; COMMAND 07h (REMOVABLE)
;
;   INPUT: A - DRIVE
;  RETURN: A = 0 - REMOVABLE
;	   A = 1 - NONREMOVABLE
;---------------------------------------------
; COMMAND 08h (GENERIC IOCTL)
;
;   INPUT: A - DRIVE
;	   B - SUBCOMMAND
;	  DE - MAGIC NUMBER (55AAh)
;   SUBCOMMAND
;----------------------
;	  00 - GET DEVICE PARAMETERS
;	  01 - READ TRACK
;	  02 - TEST TRACK
;	  80 - SET DEVICE PARAMETERS
;	  81 - WRITE TRACK
;	  82 - FORMAT TRACK
;---------------------------------------------
;
; ERRORS:
;   0 -	NO ERRORS
;   1 -	BAD COMMAND
;   2 -	BAD DRIVE NUMBER
;   3 -	UNKNOW FORMAT
;   4 -	NOT READY
;   5 -	SEEK ERROR
;   6 -	SECTOR NOT FOUND
;   7 -	CRC ERROR
;   8 -	WRITE PROTECT
;   9 -	READ ERROR
;  10 -	WRITE ERROR
;  11 -	FAILURE
;  12 -	BUSY (DEVICE OPENED)
;  13 -	RESERVED

;INTDISK PUSH	 HL
;	 PUSH	 BC
;	 LD	 HL,DEVICE
;	 INC	 A
;INTD001 DEC	 A
;	 JP	 Z,YEP
;	 LD	 C,(HL)
;	 INC	 C
;	 INC	 HL
;	 INC	 HL
;	 INC	 HL
;	 JP	 NZ,INTD001
;	 POP	 BC
;	 POP	 HL
;	 LD	 A,2
;	 SCF
;	 RET

;YEP	 LD	 A,(HL)
;	 INC	 HL
;	 LD	 C,(HL)
;	 INC	 HL
;	 LD	 H,(HL)
;	 LD	 L,C
;	 POP	 BC
;	 EX	 (SP),HL
;	 RET


INTDISK:
	PUSH    HL
	PUSH    BC
	LD	C,A
	ADD	A,A
	ADD	A,C
	LD	C,A
	LD	B,0
	LD	HL,DEVICE
	ADD	HL,BC
	LD	A,(HL)
	INC	A
	JR	Z,NODEV
	DEC	A
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,C
	POP	BC
	EX	(SP),HL
	RET 

NODEV:
	POP	BC
	POP	HL
	LD	A,2
	SCF 
	RET 

PDEVICE:
	DW	DEVICE

DEVICE:
	DEFS	26*3,0xFF
	;DB	0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	;DB	0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	;DB	0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	DB	0xFF

FLOPPY	EQU	0x0001
FIXED	EQU	0x0002
CDROM	EQU	0x0004
NETWORK	EQU	0x0008

;DISKS	 DB	 27	 ;LENGHT DISK INFO
;	DW	FLOPPY	;DISK TYPE
;	DB	2,"A:"	;DISK NAME
;	DB	11,"NO NAME    "
;	DB	8,"FAT12   "
;
;	DB	#00	;PHISICAL DRIVE	NUMBER
;
;	DB	27	;LENGHT	DISK INFO
;	DW	FLOPPY	;DISK TYPE
;	DB	2,"B:"	;DISK NAME
;	DB	11,"NO NAME    "
;	DB	8,"FAT12   "
;
;	DB	#01	;PHISICAL DRIVE	NUMBER
;
;	DB	27	;LENGHT	DISK INFO
;	DW	FIXED	;DISK TYPE
;	DB	2,"C:"	;DISK NAME
;	DB	11,"NO NAME    "
;	DB	8,"FAT16   "
;
;	DB	#80	;PHISICAL DRIVE	NUMBER
;
;	DB	#00	;END OF	TABLE

INITDVC:
	XOR	A
	LD	(LDRIVE),A
	LD	HL,DEVICE
	LD	(PDEVICE),HL
	LD	C,A
	CALL	FDDRIVE
	LD	DE,FDDRIVE
	CALL	MAKEDVC
	XOR	A
	LD	C,A
	CALL	HDDRIVE
	LD	DE,HDDRIVE
	CALL	MAKEDVC
	XOR	A
	LD	C,A
	CALL	RMDRIVE
	LD	DE,RMDRIVE
	CALL	MAKEDVC
	XOR	A
	RET 

MAKEDVC:	
    LD	C,A
	LD	HL,LDRIVE
	ADD	A,(HL)
	LD	(HL),A
	LD	A,C
	LD	C,0
	OR	A
	RET	Z
	LD	HL,(PDEVICE)
MAKEDV1:
	LD	(HL),C
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	INC	C
	DEC	A
	JR	NZ,MAKEDV1
	LD	(PDEVICE),HL
	DEC	A
	LD	(HL),A
	RET 

; TODO Unknown new function
NEW_FN1
    DI
    CALL	INITDVC
    LD	A,(LDRIVE)
    EI
    RET
    
BOOTDSK
    LD	A,(BOOTDRV)
    AND	A
    RET

SETBOOT
    LD	B,A
    LD	C,0x0
NXTDV
    PUSH	BC
    LD	A,C
    LD	BC,0x8
    LD	DE,0x55aa
    RST	A0018
    POP	BC
    JR	C,NO_SUPP
    EX	AF,AF'
    CP	B
    JR	NZ,NO_SUPP
    LD	A,C
    LD	(BOOTDRV),A
    AND	A
    RET
NO_SUPP
    INC	C
    LD	A,(LDRIVE)
    CP	C
    JR	NZ,NXTDV
    SCF
    RET

