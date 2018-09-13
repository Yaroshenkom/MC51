timers_off	EQU 00011111b 
TC0_mode1_cnt	EQU 00001110b ;counter mode
TC0_mode1_tmr	EQU 00000001b ;timer mode 0
TC1_mode1_tmr	EQU 00010000b ;timer mode 1
timers_on 	EQU 01010000b

ORG 	0
	JMP start
org 	0Bh
	JMP 	MYINT	
	
ORG 	30h	
Columns: ;this number loaded to DPL when we ask keyboard column
	DB 		6 ;DPH=90h, DPL=06h - first column
	DB		5 ;DPH=90h, DPL=05h - second column
	DB 		3 ;DPH=90h, DPL=03h - third column
Codes: ;kit of indication codes for 9006h
	DB 		00000110b ;1
	DB		01100110b ;4
	DB 		00000111b ;7
	DB 		10000000b ;*
	;kit of indication codes for 9005h
	DB 		01011011b ;2
	DB		01101101b ;5
	DB 		01111111b ;8	
	DB 		00111111b ;0
	;kit of indication codes for 9003h	
	DB 		01001111b ;3
	DB 		01111101b ;6
	DB 		01101111b ;9
	DB 		01110110b ;#

start:
	MOV 	IE, #10000010b  ;IE - allow interruptions
	MOV 	IP, #00000010b  ;IP - TC0 has the highest priority
	SETB 	IT0
	MOV 	SP, #20h
	MOV 	8, #0
	MOV 	9, #0
	CALL 	PROGRAM_TIMER
infcycle:
	CALL 	ASKKEYBOARD
	JMP 	infcycle

ASKKEYBOARD:
	PUSH 	ACC
	PUSH 	1
	PUSH 	2
initiate_columnask:	
	
	MOV 	R1, #3
	MOV 	A, #0
columnask:
	MOV 	DPTR, #Columns 
	PUSH 	ACC
	MOVC 	A, @A+DPTR ;choosing the keyboad column
	MOV 	DPH, #90h
	MOV 	DPL, A
read_again:	
	MOVX 	A, @DPTR ;read the chosen column
	MOV 	R0, A 
	
	CALL 	ANTI_BOUNCE_DELAY
	MOVX 	A, @DPTR
	CJNE	A, 0, carry_on ;if button isn't pushed, it was contact bounce

	POP 	ACC
	PUSH 	ACC
	CALL 	TAKE_BUTTON_CODE
	
carry_on:
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
	CJNE 	R0, #0Fh, initiate_find_symbol ;if button isn't pushed, then finish the procedure
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
	MUL 	AB ;choosing the kit of indication codes for current column
	PUSH 	ACC
	PUSH 	0
find_symbol:
	POP 	ACC
	MOV 	R0, A
	JB 		ACC.0, end_find_cycle ;if current bit=0, then current button is pushed
	
	MOV 	DPTR, #8002h
	MOV 	A, #0FFh
	MOVX	@DPTR, A ;choosing the 4th indicator
	POP 	ACC
	PUSH 	ACC
	MOV 	DPTR, #Codes
	MOVC 	A, @A+DPTR
	MOV 	DPTR, #8001h ;show the symbol on indicator
	MOVX	@DPTR, A
	
	
end_find_cycle:
	POP 	ACC
	INC 	A
	PUSH 	ACC
	MOV 	A, R0
	RR 		A ;get ready to analyze next bit read from the keyboard
	PUSH 	ACC
	DJNZ 	R1, find_symbol
	
	POP 	ACC
	POP 	ACC
	JMP 	end_tkb


ANTI_BOUNCE_DELAY:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL1, #67h 	;wait for 0,03s 
	MOV 	TH1, #0C5h
	ORL 	88h, #timers_on
wait:	
	JNB 	TF1, wait
RET	



PROGRAM_TIMER:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL0, #0h 	;wait for 0,06s 
	MOV 	TH0, #0h
	ORL 	88h, #timers_on
RET

MYINT:
	PUSH 	ACC
	INC 	8
	MOV 	A, 8
	CJNE 	A,#15,endint1 ;if amount of interruptions is less than 15, then don't increment the amount of seconds
	MOV 	8,#0
	INC 	9
	MOV 	A, 9
	CJNE 	A,#60,static_out ;don't show the number of seconds bigger than 60
	MOV 	9, #0
static_out:
	MOV 	DPTR, #0B000h ;show new amount of seconds
	MOV 	A, 9
	MOVX 	@DPTR, A
endint1:
	CALL 	PROGRAM_TIMER
	POP 	ACC
RETI
END