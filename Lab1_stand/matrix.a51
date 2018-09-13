timers_off	EQU 00001111b 
TC0_mode1_cnt	EQU 00001110b ;counter mode
TC0_mode1_tmr	EQU 00000001b ;timer mode
timers_on 	EQU 01010000b
org 0	
NumberTable:
	DB 	00011111b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00011111b
	
	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00011111b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
start:
MOV 	A, #0
MOV 	DPTR, #8002h
MOVX 	@DPTR, A
MOV 	R0, #0
indicatecycle:
CALL 	INDICATE
JMP indicatecycle


INDICATE:
PUSH 	0
PUSH 	ACC
INC 	A
MOV 	B,#7
mulcycle:
MUL 	AB
DJNZ 	R0,mulcycle

MOV r3,#15
prog:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL0, #00h ;wait for 0,065s 
	MOV 	TH0, #00h
	ORL 	88h, #timers_on
cycle1:
MOV 	A, #0
cycle2:
MOV 	DPTR, #NumberTable
MOVC	A, @A+DPTR
INC 	A
CJNE 	A,#7,cycle2
check:
	JNB 	TF0, cycle1
	DJNZ	r3,prog
POP 	ACC
POP 	0
RET
END