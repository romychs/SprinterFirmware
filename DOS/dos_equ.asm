
; -------------------------------------
; DOS Function numbers definitions
; -------------------------------------

VERSION	                        EQU	#00     ; VERSION (Version of DSS)
CHDISK	                        EQU	#01     ; CHDISK (Set the current disk)
CURDISK	                        EQU	#02     ; CURDISK (Get the current disk)
DSKINFO	                        EQU	#03     ; DSKINFO (Information about disk)
G_ENTRY	                        EQU	#04     ; 

BOOTDSK	                        EQU	#09     ; BOOTDSK (Get number of boot disk)
CREATE	                        EQU	#0A     ; CREATE (Create file)
CREAT_N	                        EQU	#0B     ; CREATE NEW FILE
ERASE	                        EQU	#0D
DELETE	                        EQU	#0E
MOVE	                        EQU	#0F
RENAME	                        EQU	#10
OPEN	                        EQU	#11
CLOSE	                        EQU	#12
READ	                        EQU	#13
WRITE	                        EQU	#14
MOVE_FP	                        EQU	#15
ATTRIB	                        EQU	#16
GET_D_T	                        EQU	#17
PUT_D_T	                        EQU	#18
F_FIRST	                        EQU	#19
F_NEXT	                        EQU	#1A
MKDIR	                        EQU	#1B
RMDIR	                        EQU	#1C
CHDIR	                        EQU	#1D
CURDIR	                        EQU	#1E
SYSTIME	                        EQU	#21
SETTIME	                        EQU	#22
                        
WAITKEY	                        EQU	#30
SCANKEY	                        EQU	#31
ECHOKEY	                        EQU	#32
CTRLKEY	                        EQU	#33
EDIT	                        EQU	#34
K_CLEAR	                        EQU	#35
                        
SETWIN	                        EQU	#38
SETWIN1	                        EQU	#39
SETWIN2	                        EQU	#3A
SETWIN3	                        EQU	#3B
FREEMEM	                        EQU	#3C
GETMEM	                        EQU	#3D
RETMEM	                        EQU	#3E
SETMEM	                        EQU	#3F
                        
EXEC	                        EQU	#40
EXIT	                        EQU	#41
WAIT	                        EQU	#42
                        
GSWITCH	                        EQU	#43
DOSNAME	                        EQU	#44
                        
SETVMOD	                        EQU	#50
GETVMOD	                        EQU	#51
LOCATE	                        EQU	#52
CURSOR	                        EQU	#53
SELPAGE	                        EQU	#54
SCROLL	                        EQU	#55
CLEAR	                        EQU	#56
RDCHAR	                        EQU	#57
WRCHAR	                        EQU	#58
WINCOPY	                        EQU	#59
WINREST	                        EQU	#5A
PUTCHAR	                        EQU	#5B
PCHARS	                        EQU	#5C
RES_PRN	                        EQU	#5D
CTRLPRN	                        EQU	#5E
PRINT	                        EQU	#5F
                        
                        
                        
                        