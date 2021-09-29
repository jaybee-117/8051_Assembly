;|Clock period = 500us
;|Rise/Fall time = 25us
;|Duty Cycle = 40% = 200us
ORG 000H
	CLR P0.7;
Start:				;
	MOV P1,#0		;
	CALL delay125	;|125us @0

	MOV R2,#10		;|
loop1:				;|
	MOV P1,A		;|
	ADD A,#25		;|
	DJNZ R2,loop1	;|25us rise time

	Mov P1,#255		;|
	Call delay200	;|200us @5V

	MOV R2,#10		;|
loop2:				;|
	MOV P1,A		;|
	SUBB A,#25		;|
	DJNZ R2,loop2	;|25us Fall time

	Mov P1,#0		;|
	CALL delay125	;|125us @0V
	JMP Start		;

delay125:
	Mov R1,#50		;
	DJNZ R1,$		;
	RET				;

delay200:
	Mov R1,#80		;
	DJNZ R1,$		;
	RET				;
