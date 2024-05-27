
; -------------------------------------
; Error handler
; -------------------------------------

CERR_VECT
CERR_BNK DW	0
CERR_ADR DW	ERRSTUB


SET_CERROR_VECTOR:
	LD	(CERR_BNK),DE
	LD	(CERR_ADR),HL
	LD	(CERR_STK),IX
	AND	A
	RET

GET_CERROR_VECTOR:
	LD	DE,(CERR_BNK)
	LD	HL,(CERR_ADR)
	LD	IX,(CERR_STK)
	AND	A
	RET

;
; CALL CERR_BNK:CERR_ADR
;

CERROR:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX

	LD	HL,0
	ADD	HL,SP
	EX	DE,HL

	LD	C,PAGE3
	IN	B,(C)

	LD	HL,(CERR_BNK)
	OUT	(C),L

	LD	SP,(ERRSTACK)

	PUSH	DE
	PUSH	BC
	LD	HL,(CERR_ADR)
	LD	(_CALL01+1),HL
_CALL01:
	CALL	#0000
	POP	BC
	POP	HL
	OUT	(C),B
	LD	SP,HL

	POP	IX
	POP	HL
	POP	DE
	POP	BC
	RET

F_RETRY		                    EQU	0
F_IGNORE	                    EQU	1
F_FAIL		                    EQU	2

ERRSTUB:
	PUSH	AF
	LD	HL,ER_ABORT
	LD	C,PCHARS
	RST	#10
	POP	AF
	LD	HL,ER_RETRY
	BIT	F_RETRY,A	                        ; RETRY
	CALL	NZ,ADD_EMSG
	LD	HL,ER_IGNORE
	BIT	F_IGNORE,A	                        ; IGNORE
	CALL	NZ,ADD_EMSG
	LD	HL,ER_FAIL
	BIT	F_FAIL,A	                        ; FAIL
	CALL	NZ,ADD_EMSG
	LD	A,'?'
	LD	C,PUTCHAR
	RST	#10
KEYAGA:
	PUSH	AF
	LD	C,WAITKEY
	RST	#10
	CALL	UPPER
	CP	'A'
	JR	Z,CM_ABORT
	CP	'R'		
	JR	Z,CM_RETRY
	CP	'I'
	JR	Z,CM_IGNORE
	CP	'F'
	JR	Z,CM_FAIL
	POP	AF
	JR	KEYAGA

CM_FAIL:
	POP	AF
	BIT	F_FAIL,A
	JR	Z,KEYAGA
	LD	A,3	;FAIL
	RET

CM_ABORT:
	POP	AF
	BIT	F_ABORT,A
	JR	Z,KEYAGA
	LD	A,2	;ABORT
	RET

CM_RETRY:
	POP	AF
	BIT	F_RETRY,A
	JR	Z,KEYAGA
	LD	A,1	;RETRY
	RET

CM_IGNORE:
	POP	AF
	BIT	F_IGNORE,A
	JR	Z,KEYAGA
	LD	A,0	;IGNORE
	RET

ADD_EMSG:
	PUSH	AF
	LD	A,","
	LD	C,PUTCHAR
	RST	#10
	LD	A," "
	LD	C,PUTCHAR
	RST	#10
	LD	C,PCHARS
	RST	#10
	POP	AF
	RET

ER_ABORT:
	DB	13,10,"Abort",0
ER_RETRY:
	DB	"Retry",0
ER_IGNORE:
	DB	"Ignore",0
ER_FAIL:
	DB	"Fail",0
