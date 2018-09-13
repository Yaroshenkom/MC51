timers_off	EQU 00001111b 
TC0_mode1_cnt	EQU 00001110b ;counter mode
TC0_mode1_tmr	EQU 00000001b ;timer mode
timers_on 	EQU 01010000b

ORG 0
	JMP start
	
Columns:
	DB 		6
	DB		5
	DB 		3
Codes:
	DB 		00000110b ;1
	DB		01100110b ;4
	DB 		00000111b ;7
	DB 		10000000b ;*
	
	DB 		01011011b ;2
	DB		01101101b ;5
	DB 		01111111b ;8	
	DB 		00111111b ;0
		
	DB 		01001111b ;3
	DB 		01111101b ;6
	DB 		01101111b ;9
	DB 		01110110b ;#
ORG 13h
	JMP MYINT
start:
	MOV 	IE, #10000100b  ;IE
	MOV 	IP, #00000100b  ;IP
	SETB 	IT1
	MOV 	SP, #20h
infcycle:
	JMP 	infcycle


MYINT:
	PUSH	ACC 	
	
	CALL 	ANTI_BOUNCE_DELAY
	JB 		P3.3, endint1
	INC 	8
	MOV 	A, 8
	CJNE 	A,#2,endint1
	MOV 	8,#0
	MOV 	DPTR, #8002h
	MOV 	A, #0FFh
	MOVX	@DPTR, A
	MOV 	DPTR, #8001h
	MOVX	@DPTR, A
	CALL 	ASKKEYBOARD
endint1:
	POP 	ACC
RETI
	
ASKKEYBOARD:
	PUSH 	ACC
	PUSH 	1
	PUSH 	2
initiate_columnask:	
	MOV 	A, #1
	MOV 	DPTR, #9006h
	MOVX	@DPTR, A
	MOV 	DPTR, #9005h
	MOVX	@DPTR, A
	MOV 	DPTR, #9003h
	MOVX	@DPTR, A

	MOV 	R1, #3
	MOV 	A, #0
columnask:
	CALL 	ANTI_BOUNCE_DELAY
	MOV 	DPTR, #Columns
	PUSH 	ACC
	MOVC 	A, @A+DPTR
	MOV 	DPH, #90h
	MOV 	DPL, A
	MOV 	A, #0
	MOVX 	@DPTR, A
	MOV 	DPL, #0
read_again:	
	MOVX 	A, @DPTR
	CJNE	A, #0Fh, read_column
	JMP		carry_on
read_column:
	MOV 	R0, A
	
	CALL 	ANTI_BOUNCE_DELAY
	MOVX 	A, @DPTR
	CJNE	A, 0, carry_on

	POP 	ACC
	PUSH 	ACC
	CALL 	TAKE_BUTTON_CODE
	
read_release1:	
	MOVX 	A, @DPTR
	CJNE	A, 0, read_release2
	JMP 	read_release1
read_release2:
	CALL 	ANTI_BOUNCE_DELAY
	MOVX 	A, @DPTR
	CJNE	A, 0,carry_on
	JMP 	read_release1
carry_on:
	POP 	ACC
	PUSH 	ACC
	MOV 	DPTR, #Columns
	MOVC 	A, @A+DPTR
	MOV 	DPH, #90h
	MOV 	DPL, A
	MOV 	A, #1
	MOVX 	@DPTR, A
	POP 	ACC
	INC 	A

	DJNZ 	R1, columnask
	JMP 	initiate_columnask
	
	POP 	2
	POP 	1
	POP 	ACC
RET

TAKE_BUTTON_CODE:
	PUSH 	2
	PUSH 	1
	PUSH 	DPL
	PUSH 	DPH
	
	MOV 	R2, 0
	ANL 	0, #0Fh
	CJNE 	R0, #0Fh, initiate_find_symbol
end_tkb:

	MOV 	R0, 2

	POP 	DPH
	POP 	DPL
	POP 	1
	POP 	2
RET
initiate_find_symbol:
	MOV 	R1, #4
	MOV 	B, #4
	MUL 	AB
	PUSH 	ACC
	PUSH 	0
find_symbol:
	POP 	ACC
	MOV 	R0, A
	JB 		ACC.0, end_find_cycle
	
	MOV 	DPTR, #8002h
	MOV 	A, #0FFh
	MOVX	@DPTR, A
	POP 	ACC
	PUSH 	ACC
	MOV 	DPTR, #Codes
	MOVC 	A, @A+DPTR
	MOV 	DPTR, #8001h
	MOVX	@DPTR, A
	
	
end_find_cycle:
	POP 	ACC
	INC 	A
	PUSH 	ACC
	MOV 	A, R0
	RR 		A
	PUSH 	ACC
	DJNZ 	R1, find_symbol
	
	POP 	ACC
	POP 	ACC
	JMP 	end_tkb
	
ANTI_BOUNCE_DELAY:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL0, #67h 	;wait for 0,03s 
	MOV 	TH0, #0C5h
	ORL 	88h, #timers_on
wait:	
	JNB 	TF0, wait
RET	


	
END