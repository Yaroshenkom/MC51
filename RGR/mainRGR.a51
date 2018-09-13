timers_off	EQU 00001111b
timers_off_matrix 	EQU 00101111b
TC0_mode1_cnt	EQU 00001110b ;counter mode
TC0_mode1_tmr	EQU 00000001b ;timer mode
TC0_and_TC1_mode1_tmr	EQU 00010001b ;timer mode
timers_on 	EQU 01010000b

ORG 	0
	JMP 	start
ORG 3
	JMP 	MYINT0
ORG 13h
	JMP 	MYINT1
ORG		30h
NumberTable:
	DB 	00001110b ;code for matrix
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	00000100b
	DB 	00001100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00011111b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00000010b
	DB 	00000100b
	DB 	00001000b
	DB 	00010000b
	DB 	00011111b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00000001b
	DB 	00000010b
	DB 	00000001b
	DB 	00010001b
	DB 	00001110b

	DB 	00000100b
	DB 	00001100b
	DB 	00010100b
	DB 	00011110b
	DB 	00000100b
	DB 	00000100b
	DB 	00011111b
		
	DB 	00011111b
	DB 	00010000b
	DB 	00010000b
	DB 	00001110b
	DB 	00000001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	00000010b
	DB 	00000100b
	DB 	00001000b
	DB 	00011110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	00011111b
	DB 	00000010b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
	DB 	00000100b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001110b
		
	DB 	00001110b
	DB 	00010001b
	DB 	00010001b
	DB 	00001111b
	DB 	00000010b
	DB 	00000100b
	DB 	00001000b
		
	DB 	00011111b ;symbol that finishes the indication cycle
	DB 	00011111b
	DB 	00011111b
	DB 	00011111b
	DB 	00011111b
	DB 	00011111b
	DB 	00011111b
	
;===============MAIN===============	
start:
	MOV 	IE, #10000101b  ;IE - wa allow interruptions
	MOV 	IP, #00000101b  ;IP - interruptions from SW15 and SW16 have the highest priority
	SETB 	IT1 ;interruption INT1 by negative edge
	SETB 	IT0 ;interruption INT0 by negative edge
	MOV 	SP, #20h ;our stack shouldn't be connected with registers in use
	CALL 	CLEAN ;clean the rigesters which will be used
infcycle:
	JMP 	infcycle
;================MYINT1================	
MYINT1:
	PUSH	ACC 		
	CALL 	ANTI_BOUNCE_DELAY ;0.065 s delay
	JB 		P3.3, endint1 ;check pressing again
	INC 	@R1 ;increase the number of strokes
	CALL 	STATIC_SHOW ;show digits of input walues
	CALL 	ANTI_BOUNCE_DELAY
endint1:
	POP 	ACC
RETI
;===================MYINT0===============
MYINT0:
	PUSH	ACC 		
	CALL 	ANTI_BOUNCE_DELAY
	JB 		P3.2, endint0
	INC 	R1
	;allocation of input strokes to X and Y - if R1=8,9 - to X
	; if R1=10,11 - to Y
	CJNE 	R1, #10, int0_check_12 
	INC 	R0
	JMP 	int0_delay
int0_check_12:
	CJNE 	R1, #12, int0_delay
	MOV 	R1, #8
	MOV 	R0, #12
	CALL 	CALCULATE ;calculate Z
indication:	;show digits of Z
	MOV 	R0,14 ;hundreds
	CALL 	INDICATE
	MOV 	R0,15 ;dizens
	CALL 	INDICATE
	MOV 	R0,16 ;units
	CALL 	INDICATE
	MOV 	R0, #10 ;symbol that finishes the cycle of indication
	CALL 	INDICATE

	JB 		P3.2, indication 
	CALL 	ANTI_BOUNCE_DELAY
	JB 		P3.2, indication
	CALL 	CLEAN
check_reset0:
	JNB 	P3.2, check_reset0 ;if SW15 is pushed and released - finish the cycle of indication and restart the program
	CALL 	ANTI_BOUNCE_DELAY
	JNB 	P3.2, check_reset0
	JMP 	endint0
int0_delay:
	CALL 	ANTI_BOUNCE_DELAY
endint0:
	POP 	ACC
RETI

ANTI_BOUNCE_DELAY:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL0, #0BFh 	;wait for 0,03s 
	MOV 	TH0, #63h
	ORL 	88h, #timers_on
wait:	
	JNB 	TF0, wait
RET	
;==================STATIC_SHOW==================
STATIC_SHOW:
	PUSH 	ACC
	PUSH 	2
	MOV 	A, @R1
check_8: ;allocate input strokes
	CJNE 	R1, #8, check_9
	JMP 	decimal_write
check_9:
	CJNE 	R1, #9, check_10
	JMP 	ordinary_write
check_10:
	CJNE 	R1, #10, ordinary_write
	JMP 	decimal_write
decimal_write: ;convert strokes to older digits
	SWAP 	A
	ANL 	A, #11110000b
	MOV 	@R0, A ; and wirte them to 8 (if X) or 10 (if Y) 
	JMP 	indicate_static
ordinary_write: ;convert strokes to younger digits
	ANL 	A, #00001111b
	MOV 	R2, A
	MOV 	A, @R0 ; and write them to 9 (if X) or 11 (if Y)
	ANL 	A, #11110000b
	ORL 	A, R2
	MOV 	@R0, A
indicate_static: ;show current state of Y on static indicator
	CJNE 	R0, #13, indicate_left
	MOV 	DPTR, #0B000h
	JMP 	show
indicate_left: ;show current state of X on static indicator
	MOV 	DPTR, #0A000h
show:
	MOVX 	@DPTR, A
	POP 	2
	POP 	ACC
RET
;===============CALCULATE===================
CALCULATE: ;calculation of Z=X*Y+Y
	PUSH 	ACC
	PUSH 	0
	PUSH 	1
	PUSH 	2
	MOV 	R1, #2
	MOV 	R0, #16
	MOV 	A, 12
	MOV 	B, 13
	MUL 	AB
	ADD		A, 13
convert_to_bcd: ;convert Z from binary to decimal form
	MOV 	B, #10
	DIV 	AB ; by dividing it by 10
	MOV 	@R0, B ; and saving to 14 (hundreds), 15 (dozens), 16 (units)
	DEC 	R0
	DJNZ 	R1, convert_to_bcd
	MOV 	14, A
	POP 	2
	POP 	1
	POP 	0
	POP 	ACC
RET

;==================INDICATE======================
INDICATE:
PUSH 	ACC
PUSH 	1
PUSH 	2
PUSH	3
PUSH	4
PUSH 	5
MOV 	R4, SP
MOV 	R6, #0

MOV R3,#16
prog:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_and_TC1_mode1_tmr
	MOV 	TL0, #00h 	;wait for 0,065s 
	MOV 	TH0, #00h
	ORL 	88h, #timers_on
cycle1: 				;initial settings for the current symbol
MOV 	SP, R4

MOV 	A, R0
MOV 	B,#7
MUL 	AB 				;first line for matrix
PUSH 	ACC				; save it to stack
MOV 	A,#10111111b	;only one catode is active when we activate one line of the matrix
PUSH 	ACC				; save the states of cathodes to stack
MOV 	R1, #7
cycle2:
POP 	ACC
MOV 	DPTR, #8002h	
MOVX 	@DPTR, A		;activate catodes of current line
RR 		A				; prepare them to next line of matrix
MOV 	R2, A			; and save them to R2 as a buffer before saving to stack

MOV 	DPTR, #NumberTable
POP 	ACC				;take the offset in NumberTable from stack
PUSH 	ACC
MOVC	A, @A+DPTR		;take a code for anodes from the NumberTable
MOV 	DPTR, #8000h	
MOVX 	@DPTR, A		;activate anodes of current line
POP 	ACC
INC 	ACC				;prepare anodes for next line
PUSH 	ACC

MOV 	A, R2
PUSH 	ACC

MOV 	A, #0			;turn off anodes of current line
MOVX	@DPTR, A

DJNZ 	R1, cycle2
INC 	R6 				;R6 - number of elementary delays (PWM)
CALL 	MATRIX_DELAY
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
;===============MATRIX_DELAY=====================
MATRIX_DELAY: ;controller of delays for PWM
	PUSH	ACC
	PUSH 	1
	MOV 	R1,#0
	MOV 	A, R6
	CJNE 	A, #0, carry_on ;if R6==0 then R6=1
	MOV 	R6,#1 ;because we will have DJNZ which will make 255 delays except of 0
carry_on:
	MOV 	A, R3
	SUBB 	A, #11
	JNB 	PSW.7, decrease_delays ;increase brightness first 325 ms (first 5 overflows of TC0)
	CLR 	PSW.7
	MOV 	A, R3
	SUBB 	A, #6
	JB  	PSW.7, increase_delays ;decrease brightness last 325 ms (last 5 overflows of TC0)
	MOV 	R6, #1 ;constant brightness of matrix (one 9 us delay)
	MOV 	A, R6
	JMP 	prog_tmr
decrease_delays: ;decrease number of delays by substraction R6 from 255
	CLR 	PSW.7
	MOV 	1, R6
	MOV 	A, #0FFh
	SUBB 	A, R1
	JMP 	prog_tmr
increase_delays:
	MOV 	A, R6
prog_tmr:
	ANL 	88h, #timers_off_matrix
	MOV 	89h, #TC0_and_TC1_mode1_tmr
	MOV 	TL1, #0F6h 	;wait for 9 us - elementary delay for PWM
	MOV 	TH1, #0FFh
	ORL 	88h, #timers_on
waitd:
	JNB 	TF1, waitd
	DJNZ 	ACC, prog_tmr

	POP		1
	POP 	ACC
RET
;============CLEAN=====================
CLEAN:
	MOV 	R6, #0	;amount of delays for PWM
	MOV 	R7, #0
	MOV 	8, #0	;elder digit of X
	MOV 	9, #0	;younger digit of x
	MOV 	10, #0	;elder digit of Y
	MOV 	11, #0	;younger digit of Y
	MOV 	12, #0	;X
	MOV 	13, #0	;Y
	MOV 	14, #0	;hundreds of result
	MOV 	15, #0	;dozens of result
	MOV 	16, #0	;units of result
	MOV 	R1, #8	;pointer on input digits
	MOV 	R0, #12	;pointer on output digits
	MOV 	A, #0
	MOV 	DPTR, #0A000h
	MOVX 	@DPTR, A
	MOV 	DPTR, #0B000h
	MOVX 	@DPTR, A
RET
END