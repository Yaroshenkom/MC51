wr_adr 		EQU 20h
check_value EQU 0F5h
timers_off	EQU 00001111b 
TC0_mode1_cnt	EQU 00001110b ;counter mode
TC0_mode1_tmr	EQU 00000001b ;timer mode
timers_on 	EQU 01010000b
	
org 0000h
Beginning:
	MOV 	R0, #wr_adr
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_cnt
	MOV 	TL0, #253  ;wait 3 negative edges from INT0
	MOV 	TH0, #253
	ORL 	88h, #timers_on
	
wait:
	JNB 	TF0, wait
	
	ANL 	88h, #timers_off
	MOV 	89h, #TC0_mode1_tmr
	MOV 	TL0, #0CFh ;wait for 30ms 
	MOV 	TH0, #8Ah
	ORL 	88h, #timers_on
	
check_cycle:
	JBC 	TF0, exit
	MOV 	P2, #255
	MOV 	R2, P2
	MOV 	A, R2
	CLR 	PSW.7
	SUBB 	A, #check_value ;if P2=0F5h then stop reading P2
	JZ 		exit
overflow_check:
	MOV 	A, R0 ;if P2 isn't equal 0F5h then write it to memory from the 20h adress
	CLR 	PSW.7
	SUBB 	A, #7Fh
	JNZ 	write	
	MOV 	R0, #wr_adr	
write:	
	MOV 	@R0, 2
	INC 	R0
	SJMP 	check_cycle
exit:
END
	