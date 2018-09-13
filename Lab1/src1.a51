org 0000h ;start program from adr 0
		MOV 	R5, #20h ;initial adr for recorded bytes
	Check1:
		MOV 	A, #0F5h    
		MOV 	P1, #11111111b
		MOV 	R0, P1
		SUBB 	A, R0  ;if P1=0F5h, we won't check P2
		JZ	 	Check1
		
		MOV 	P2, #10011101b 
		MOV 	R0, P2
		MOV 	R1, #3 ;R1 points on R3
		MOV 	R3, #0 ;1-counter for least significant tetrade
		MOV 	R4, #0 ;1-counter for most significant tetrade
		MOV 	A, R0
		MOV 	R2, #8 ;one shift for everey bit
	cnt:
		CJNE 	R2, #4, cmp ;calculate amount of 1 for LST (R2>4) or MST (R2<4)
		INC 	R1
	cmp:
		JNB 	ACC.0, back
	m2:
		INC 	@R1 ;if checked bit=1, then increase necessary counter
	back:	
		DEC 	R2
		RR 		A ;check next bit in the next cycle
		CJNE 	R2, #0, cnt
		
		MOV 	A, R4
		SUBB 	A, R3
		JNC 	Check1 ;if R4<R3 record byte from P2
		MOV 	A, R5
		MOV 	R1, A
		MOV 	A, R0
		MOV 	@R1, A ;the next recorded byte will be record in 21h and so on...
		INC 	R5
		AJMP 	Check1 ;start the whole cycle again
end