ORG 000H
	CLR P0.7;
loop:
	MOV P1,A	;
	SUBB A,#4	;
	JMP loop	;

;45 degrees T = 250us @Decrement = 4
;30 degrees T = 443us @Decrement = 2.25
;60 degrees T = 144us @Decrement = 6.92