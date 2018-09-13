timers_off	EQU 00001111b 
TC0_mode1_cnt	EQU 00001110b ;counter mode
TC0_mode1_tmr	EQU 00000001b ;timer mode
timers_on 	EQU 01010000b
org 0
JMP 	start
NumberTable:
	DB 	00001110b ;code for matrix
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	00111111b ;code for dynamic indication
		
	DB 	00000100b
	DB 	00001100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00011111b
	
	DB 	00000110b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00000010b
	DB 	00000100b
	DB 	00001000b
	DB 	00010000b
	DB 	00011111b
		
	DB 	01011011b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00000001b
	DB 	00000010b
	DB 	00000001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	01001111b

	DB 	00000100b
	DB 	00001100b
	DB 	00010100b
	DB 	00011110b
	DB 	00000100b
	DB 	00000100b
	DB 	00011111b
		
	DB 	01100110b
		
	DB 	00011111b
	DB 	00010000b
	DB 	00010000b
	DB 	00001110b
	DB 	00000001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	01101101b
		
	DB 	00000010b
	DB 	00000100b
	DB 	00001000b
	DB 	00011110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	01111101b
		
	DB 	00011111b
	DB 	00000010b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
		
	DB 	00000111b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	01111111b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001111b
	DB 	00000010b
	DB 	00000100b
	DB 	00001000b

	DB 	01101111b

	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00011111b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
		
	DB 	01110111b
	
	DB 	00011110b
	DB 	00010001b
	DB 	00010001b
	DB 	00011110b
	DB 	00010001b
	DB 	00010001b
	DB 	00011110b
		
	DB 	01111100b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00010000b
	DB 	00010000b
	DB 	00010000b
	DB 	00010001b
	DB 	00001110b
		
	DB 	00111001b
		
	DB 	00011110b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00011110b
		
	DB 	01011110b
		
	DB 	00011111b
	DB 	00010000b
	DB 	00010000b
	DB 	00011100b
	DB 	00010000b
	DB 	00010000b
	DB 	00011111b
		
	DB 	01111001b
		
	DB 	00011111b
	DB 	00010000b
	DB 	00010000b
	DB 	00011100b
	DB 	00010000b
	DB 	00010000b
	DB 	00010000b
		
	DB 	01110001b
		
start:
MOV 	A, #0FFh
MOV 	DPTR, #8000h ;turn off the matrix catodes
MOVX 	@DPTR, A

MOV 	A, #0
MOV 	DPTR, #8001h ;turn the dynamic indication off
MOVX 	@DPTR, A
indicatecycle1:
MOV 	R1, #16
MOV 	R0, #0
indicatecycle2:
CALL 	INDICATE
INC 	R0
DJNZ 	R1,indicatecycle2
JMP 	indicatecycle1



INDICATE:
PUSH 	ACC
PUSH 	1
PUSH 	2
PUSH	3
PUSH	4
PUSH 	5
MOV 	R4, SP

MOV R3,#15 ;15 1-second cycles ~1 s
prog:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL0, #00h 	;wait for 0,065s 
	MOV 	TH0, #00h
	ORL 	88h, #timers_on
cycle1: 				;initial settings for the current symbol
MOV 	SP, R4

;turning on necessary diode in line
MOV 	A,#0
MOV 	DPTR, #0A006h
MOVX 	@DPTR, A
MOV 	A, R0
SUBB 	A, #8
JNB 	PSW.7, carry_on ;if current symbol =<7, then turn on the diode
CLR 	PSW.7
PUSH 	1
MOV 	R1, 0
MOV 	A, #00000001b
rotate_cycle: ;choosing one relevant diode
RL 		A
DJNZ 	R1, rotate_cycle
MOV 	DPTR, #0A006h
MOVX 	@DPTR, A
POP 	1


carry_on:
MOV 	A, R0
MOV 	B,#8
MUL 	AB 				;first line in table for matrix
PUSH 	ACC
ADD		A, #7
MOV 	R5, A			;code for dynamic indication
MOV 	A,#10111111b	;only one catode is active when we activate one line of the matrix
PUSH 	ACC
MOV 	R1, #7
cycle2:
POP 	ACC
MOV 	DPTR, #8002h	
MOVX 	@DPTR, A		;activate catodes of current line
RR 		A
MOV 	R2, A

MOV 	DPTR, #NumberTable
POP 	ACC
PUSH 	ACC
MOVC	A, @A+DPTR		;current line choosing 
MOV 	DPTR, #8000h	
MOVX 	@DPTR, A		;activate anodes of current line
POP 	ACC
INC 	ACC
PUSH 	ACC

MOV 	A, R2
PUSH 	ACC

MOV 	A, #0
MOVX	@DPTR, A

MOV 	DPTR, #8002h	
MOV 	A, #11111100b	;pick the first indicator
MOVX 	@DPTR, A
MOV 	DPTR, #NumberTable
MOV 	A, R5
MOVC	A, @A+DPTR
MOV 	DPTR, #8001h
MOVX 	@DPTR, A		;activate necessary segments
MOV 	A, #0
MOVX	@DPTR, A

DJNZ 	R1, cycle2

check:
	JNB 	TF0, cycle1
	DJNZ	R3,prog
POP 	ACC
POP 	ACC
POP 	5
POP 	4
POP 	3
POP 	2
POP 	1
POP 	ACC
RET
END