timers_off	EQU 00001111b 
TC0_mode1_cnt	EQU 00001110b ;counter mode
TC0_mode1_tmr	EQU 00000001b ;timer mode
timers_on 	EQU 01010000b
org 0	
	start:
mov a,#1
MOV dptR, #8000h
MOVx @dptr,a
MOV a,#00111111b
MOV dptR, #8002h
MOVx @dptr,a
CALL 	WAIT
	
MOV a,#0
MOV dptR, #8000h
MOVx @dptr,a
CALL WAIT
jmp start
WAIT:	
	MOV r3,#15
prog:
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL0, #00h ;wait for 30ms 
	MOV 	TH0, #00h
	ORL 	88h, #timers_on
check:
	JNB 	TF0, check
	DJNZ	r3,prog
RET
end