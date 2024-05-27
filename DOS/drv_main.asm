;[BEGIN]
;//MODULE: DRV-MAIN	AUTHOR: Denis Parinov
;//CREATE: 2003-03-12
;---------------------------------------------------------------
;Rev	Date	   Name	Description
;---------------------------------------------------------------
;R00	2003-03-19 DNS	Initial version
;---------------------------------------------------------------
	include	"hardware.inc"
	include	"bios.inc"

PAGEDRV	EQU	#00

	ORG	0x0000

A0000	JP	RST_00		;CLOSE TASK
	DB	#FF,#FF,#FF,#FF,#FF
A0008	PUSH	AF		;INT BIOS
	LD	A,#00
	OUT	(#7C),A
	POP	AF
	RET
	RET
A0010	JP	RST_10		;INT DOS
	DB	#FF,#FF,#FF,#FF,#FF
;A0018	JP	INTDISK		;INT DISK
;	DB	#FF,#FF,#FF,#FF,#FF
A0018	PUSH	AF
	PUSH	BC
	LD	BC,PAGEDRV+PAGE0
	JP	ENTER
A0020	JP	RST_20		;
	DB	#FF,#FF,#FF,#FF,#FF
A0028	JP	RST_28		;
	DB	#FF,#FF,#FF,#FF,#FF
A0030	JP	RST_30		;INT MOUSE
	DB	#FF,#FF,#FF,#FF,#FF
A0038	JP	RST_38		;INTERRUPT

;WARNING! DON'T	CHANGE LENGHT OF MASK INTERUPT!
;FOR CORRECTED WORKING "Non-Mask Interupt"

RST_38	;MAIN INTERUPT
INT_	PUSH	AF
	EX	AF,AF'
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	EXX
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	CALL	KEYSCAN
	LD	C,#80
	RST	#30
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	EXX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EX	AF,AF'
	POP	AF
	EI
	RETI

RST_00
RST_20
RST_28
RST_30
	LD	A,1
	SCF
	RET

NMI	RETN
	NOP
	NOP
	NOP
A0066	JP	NMI

;!!!!!!!!!!!!!!!!!!
ADRST10	EQU	#00	;!!!
;!!!!!!!!!!!!!!!!!!

RST_10	PUSH	HL
	LD	L,C
	LD	H,ADRST10/256
	LD	C,(HL)
	INC	H
	LD	H,(HL)
	LD	L,C
	EX	(SP),HL
	RET

;Move to #007E
	DS	8	;ALIGN
;------=====------
LEAVE	PUSH	BC
RETBANK	LD	BC,#0000+PAGE0
	OUT	(C),B
;Entry point from DSS main page
	LD	(RETBANK+2),A
	POP	BC
	POP	AF
ADCALL	CALL	DISPATCH
	JR	LEAVE

	LD	B,#00		;2
	OUT	(C),A		;9
;---
	POP	BC		;10
	RET			;11
;------=====------

ENTER
	RET


DISPATCH
	CALL	INITDVC
	LD	HL,INTDISK
	LD	(ADCALL+1),HL
	LD	A,(LDRIVE)
	AND	A
	RET

KEYSCAN
	RET


LDRIVE	DB	#00

	INCLUDE	"disk_x.asm"
	INCLUDE	"ide_drv0.asm"
	INCLUDE	"fdd_drv0.asm"
	INCLUDE	"ram_drv0.asm"

	DB	0
;[END]
