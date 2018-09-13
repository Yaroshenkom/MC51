org	0000h
;initial values
MOV 	R0, #2 ;start value
MOV 	R1, #3h ;will be added to start value
MOV 	R2, #2 ;will be substracted from end value
MOV 	R4, #4Ah ;end value
begin:
MOV 	A, #0 
MOV 	DPTR,#0A000h ;show "00" on the right part of the indicator
MOVX	@DPTR, A

MOV 	A, R0
MOV 	DPTR,#0B000h ;show "00" on the left part of the indicator	
MOVX 	@DPTR, A

cycle1:
ADD 	A, R1
CALL 	ZAD
MOVX 	@DPTR, A ;show result of current addition
CJNE 	A, 4, cycle1

MOV 	DPTR,#0A000h
MOVX	@DPTR, A

cycle2:
SUBB 	A, R2
CALL 	ZAD
MOVX 	@DPTR, A ;show result of current substraction
CJNE 	A, 0, cycle2
JMP		begin

ZAD: 
PUSH 	1
PUSH 	2
C1:
mov R1,#0FFh
C2: mov R2,#0FFh
C4: djnz R2, C4 ;secondary cycle - 255*2 us
djnz R1, C2 ;the main cycle - consists of 255 secondary cycles
POP 	2
POP 	1
ret
END