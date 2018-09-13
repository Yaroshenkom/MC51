org 0
start:
	MOV 	R0, #128 ;the analysis starts from the most significant bit
	MOV 	A,#0	
	MOV 	DPTR, #0F000h 
	MOVX 	@DPTR, A ;turn off the DAC
	CALL 	DELAY ;need some time to setup necessary voltage on DAC
	MOV 	R1, #8
comparing:
	ORL 	A, R0
	MOVX 	@DPTR, A
	CALL 	DELAY
	JB 		P1.7, carry_on ;if DAC voltage is less than the measured one, then write 1 in current bit of a result 
	CALL 	INVERT_R0 ; if not, put 0 in the current bit
	ANL 	A, R0
	CALL 	INVERT_R0
carry_on:
	CALL 	ROTATE_R0 ;get ready to fill next bit
	DJNZ 	R1, comparing ;go to next bit
	MOV 	DPTR, #0A000h ;show the result
	MOVX	@DPTR, A
	JMP 	start
	
INVERT_R0:
	PUSH 	ACC
	MOV 	A, R0
	CPL 	A
	MOV 	R0, A
	POP 	ACC
RET

ROTATE_R0:
	PUSH 	ACC
	MOV 	A, R0
	RR 		A
	MOV 	R0, A
	POP 	ACC
RET

DELAY:
	PUSH 	2
	MOV 	R2,#200;
wait:
	DJNZ 	R2,wait
	POP 	2
RET

END