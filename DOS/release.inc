
;Release Types

RELEASE	                        EQU	0
RC	                            EQU	1
BETA	                        EQU	2
DP	                            EQU	3

OSTYPE		                    EQU	BETA
REVISION	                    EQU	0

C_OSNAME	macro
		db	"ESTEX",0
		endm


C_OSRELEASE	macro
		db	"Estex DSS",0
		endm

	; if OSTYPE=DP
	; db	"-DP",#30+REVISION,0
	; endif

	; if OSTYPE=BETA
	; db	"-BETA",#30+REVISION,0
	; endif

	; if OSTYPE=RC
	; db	"-RC",#30+REVISION,0
	; endif

	; if OSTYPE=RELEASE
	; db	"-RELEASE",0
	; endif

	; if OSTYPE != RELEASE & OSTYPE != RC & OSTYPE != BETA & OSTYPE != DP
	; db	"-UNKNOWN",0
	; endif
