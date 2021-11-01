ORG 000H
MOV TMOD, #50H			; put timer 1 in event counting mode
	SETB TR1			; start timer 1

	MOV DPL, #LOW(LEDcodes)		; | put the low byte of the start address of the
					; | 7-segment code table into DPL

	MOV DPH, #HIGH(LEDcodes)	; put the high byte into DPH

	CLR P3.4			; |
	CLR P3.3			; | enable Display 0
again:
	CALL setDirection		; set the motor's direction
	MOV A, TL1			; move timer 1 low byte to A
	CJNE A, #10, skip		; if the number of revolutions is not 10 skip next instruction
	CALL clearTimer			; if the number of revolutions is 10, reset timer 1
skip:
	MOVC A, @A+DPTR			; | get 7-segment code from code table - the index into the table is
					; | decided by the value in A 
					; | (example: the data pointer points to the start of the 
					; | table - if there are two revolutions, then A will contain two, 
					; | therefore the second code in the table will be copied to A)

	MOV C, F0			; move motor direction value to the carry
	MOV ACC.7, C			; and from there to ACC.7 (this will ensure Display 0's decimal point 
					; will indicate the motor's direction)

	MOV P1, A			; | move (7-seg code for) number of revolutions and motor direction 
					; | indicator to Display 0

	JMP again			; do it all again

setDirection:
	PUSH ACC			; save value of A on stack
	PUSH 20H			; save value of location 20H (first bit-addressable 
					;	location in RAM) on stack
	CLR A				; clear A
	MOV 20H, #0			; clear location 20H
	MOV C, P2.0			; put SW0 value in carry
	MOV ACC.0, C			; then move to ACC.0
	MOV C, F0			; move current motor direction in carry
	MOV 0, C			; and move to LSB of location 20H (which has bit address 0)

	CJNE A, 20H, changeDir		; | compare SW0 (LSB of A) with F0 (LSB of 20H)
					; | - if they are not the same, the motor's direction needs to be reversed

	JMP finish			; if they are the same, motor's direction does not need to be changed
changeDir:
	CLR P3.0			; |
	CLR P3.1			; | stop motor

	CALL clearTimer			; reset timer 1 (revolution count restarts when motor direction changes)
	MOV C, P2.0			; move SW0 value to carry
	MOV F0, C			; and then to F0 - this is the new motor direction
	MOV P3.0, C			; move SW0 value (in carry) to motor control bit 1
	CPL C				; invert the carry

	MOV P3.1, C			; | and move it to motor control bit 0 (it will therefore have the opposite
					; | value to control bit 1 and the motor will start 
					; | again in the new direction)
finish:
	POP 20H				; get original value for location 20H from the stack
	POP ACC				; get original value for A from the stack
	RET				; return from subroutine

clearTimer:
	CLR A				; reset revolution count in A to zero
	CLR TR1				; stop timer 1
	MOV TL1, #0			; reset timer 1 low byte to zero
	SETB TR1			; start timer 1
	RET				; return from subroutine

LEDcodes:	; | this label points to the start address of the 7-segment code table which is 
		; | stored in program memory using the DB command below
	DB 11000000B, 11111001B, 10100100B, 10110000B, 10011001B, 10010010B, 10000010B, 11111000B, 10000000B, 10010000B