;P2.0 -> 1 STOP
;P2.0 -> 0 START
;P2.1 -> 1 STOPWATCH
;P2.1 -> 0 CLOCK

MOV 40H, #0C0H ;0
MOV 41H, #0F9H ;1
MOV 42H, #0A4H ;2
MOV 43H, #0B0H ;3
MOV 44H, #099H ;4
MOV 45H, #092H ;5
MOV 46H, #082H ;6
MOV 47H, #0F8H ;7
MOV 48H, #080H ;8
MOV 49H, #090H ;9

MOV TMOD, #01H ;Time interrupt of mode 1  using only timer 1 

MOV R2, #40H ; clock Ones - Seconds
MOV R3, #40H ; clock Tens - Seconds
MOV R4, #40H ; clock Ones - Minutes
MOV R5, #40H ; clock Tens - Minutes
MOV R6, #40H ; stopwatch Ones - Seconds
MOV R7, #40H ; stopwatch Tens - Seconds
MOV 10H, #40H ; stopwatch Ones - Minutes
MOV 11H, #40H ; stopwatch Tens - Minutes
MOV 12H, #01H


loop:
	
DISPLAY1:
	JNB P2.1, disp1
DISPLAY2:
	JB P2.1, disp2
CLI:
CALL clockinc
SWI:
	JNB P2.0, stopwatchinc
STP:
	JB P2.0, stop
	JMP loop	


disp1:				;displays time
	CLR P3.3
	CLR P3.4
	MOV A, R2
	MOV R1, A
	MOV P1, @R1
	CALL delay1

	SETB P3.3
	CLR P3.4
	MOV A, R3
	MOV R1, A
	MOV P1, @R1
	CALL delay1

	CLR P3.3
	SETB P3.4
	MOV A, R4
	MOV R1, A
	MOV P1, @R1
	CALL delay1

	SETB P3.3
	SETB P3.4
	MOV A, R5
	MOV R1, A
	MOV P1, @R1
	CALL delay1
	JMP CLI

disp2:				;displays time
	CLR P3.3
	CLR P3.4
	MOV A, R6
	MOV R1, A
	MOV P1, @R1
	CALL delay1

	SETB P3.3
	CLR P3.4
	MOV A, R7
	MOV R1, A
	MOV P1, @R1
	CALL delay1

	CLR P3.3
	SETB P3.4
	MOV A, 10H
	MOV R1, A
	MOV P1, @R1
	CALL delay1

	SETB P3.3
	SETB P3.4
	MOV A, 11H
	MOV R1, A
	MOV P1, @R1
	CALL delay1

	JMP CLI

stop:
	MOV 12H, #00H
	JMP loop

clockinc:
	CJNE R2, #4AH, clockinc1
	MOV R2,	#40H
	CJNE R3, #45H, clockinc2
	MOV R3,	#40H
	CJNE R4, #4AH, clockinc3
	MOV R4,	#40H
	CJNE R5, #45H, clockinc4
	MOV R5,	#40H
	RET

stopwatchinc:
	MOV A, 12H
	CJNE A, #01H, stopwatch
STOPWATCHINIT:
	MOV 12H, #01H
	CJNE R6, #4AH, stopwatchinc1
	MOV R6,	#40H
	CJNE R7, #45H, stopwatchinc2
	MOV R7,	#40H
	MOV A, 10H
	CJNE A, #4AH, stopwatchinc3
	MOV 10H,	#40H
	MOV A, 11H
	CJNE A, #45H, stopwatchinc4
	MOV 11H,	#40H
	JMP STP

clockinc1:		;increments ones place of seconds and displays time
	
	INC R2
	RET

clockinc2:		;increments tens place of seconds and displays time
	INC R3
	INC R2
	RET

clockinc3:		;increments ones place of minutes and displays time
	INC R4
	INC R2
	RET
clockinc4:		;increments tens place of minutes and displays time
	INC R5
	INC R2
	RET


stopwatchinc1:		;increments ones place of seconds and displays time
	
	INC R6
	JMP STP

stopwatchinc2:		;increments tens place of seconds and displays time
	INC R7
	INC R6
	JMP STP

stopwatchinc3:		;increments ones place of minutes and displays time
	JB P2.0, stop	
	INC 10H
	INC R6
	JMP STP
stopwatchinc4:		;increments tens place of minutes and displays time
	JB P2.0, stop	
	INC 11H
	INC R3
	JMP STP


stopwatch:

	MOV R6, #40H ; stopwatch Ones - Seconds
	MOV R7, #40H ; stopwatch Tens - Seconds
	MOV 10H, #40H ; stopwatch Ones - Minutes
	MOV 11H, #40H ; stopwatch Tens - Minutes
JMP STOPWATCHINIT




delay1:					;a delay of 250ms
	MOV R0, #5
	DLOOP:
		MOV TL0, #0B0H
		MOV TH0, #03CH
		SETB TR0
		AGAIN1: JNB TF0, AGAIN1
		CLR TR0
		CLR TF0
		DJNZ R0, DLOOP
	RET
