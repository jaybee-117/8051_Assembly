;update freq = 100Hz
ORG 0
JMP main
ORG 0BH
JMP timer0ISR
ORG 3BH
main:
	SETB IT0		; set external 0 interrupt as edge-activated
	SETB EX0		; enable external 0 interrupt
	MOV TMOD, #2		; set timer 0 as 8-bit auto-reload interval timer

	MOV TH0, #-50		; | put -50 into timer 0 high-byte - this reload value, 
   				; | with system clock of 12 MHz, will result in a timer 0 overflow every 50 us

	MOV TL0, #-50		; | put the same value in the low byte to ensure the timer starts counting from 
   				; | 236 (256 - 50) rather than 0

	SETB TR0		; start timer 0
	SETB ET0		; enable timer 0 interrupt
	SETB EA			; set the global interrupt enable bit

	JMP $

ext0ISR:
CLR P3.7
;storing binary bits as characters
MOV 30H, #0
MOV 31H, #'0'
MOV 32H, #'0'
MOV 33H, #'0'
MOV 34H, #'0'
MOV 35H, #'0'
MOV 36H, #'0'
MOV 37H, #'0'
MOV 38H, #'0'

data0:
JB P2.0, loop0
data1:
JB P2.1, loop1
data2:
JB P2.2, loop2
data3:
JB P2.3, loop3
data4:
JB P2.4, loop4
data5:
JB P2.5, loop5
data6:
JB P2.6, loop6
data7:
JB P2.7, loop7
JMP display

loop0:
	MOV 31H, #'1'
	JMP data1
loop1:
	MOV 32H, #'1'
	JMP data2
loop2:
	MOV 33H, #'1'
	JMP data3
loop3:
	MOV 34H, #'1'
	JMP data4
loop4:
	MOV 35H, #'1'
	JMP data5
loop5:
	MOV 36H, #'1'
	JMP data6
loop6:
	MOV 37H, #'1'
	JMP data7
loop7:
	MOV 38H, #'1'
	JMP display
	

; initialise the display
; see instruction set for details
display:
	CLR P1.3		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
				; function set low nibble sent
	CALL delay		; wait for BF to clear

; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		; wait for BF to clear

; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		; wait for BF to clear

; send data
	CALL CursorPos
	SETB P1.3		; clear RS - indicates that data is being sent to module
	MOV R1, #38H	; data to be sent to LCD is stored in 8051 RAM, starting at location 30H
loop:
	MOV A, @R1		; move data pointed to by R1 to A
	JZ finish		; if A is 0, then end of data has been reached - jump out of loop
	CALL sendCharacter	; send data in A to LCD module
	DEC R1			; point to next piece of data
	JMP loop		; repeat

finish:
	JMP timer0ISR

CursorPos:	Clr P1.3
			SetB P1.7		; Sets the DDRAM address
			Clr P1.6		; Set address. Address starts here - '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0' 
							; high nibble
			SETB P1.2
			CLR P1.2

			Clr P1.7		; 									 '0'
			Clr P1.6		; 									 '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0'
							; low nibble
							; Therefore address is 000 0000 or 00H
							
			SETB P1.2
			CLR P1.2
			Call Delay		; wait for BF to clear	
			Ret	

sendCharacter:
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	CALL delay			; wait for BF to clear

delay:
	MOV R0, #50
	DJNZ R0, $
	RET
SETB P3.7
RETI

timer0ISR:
	CLR P3.6		; clear ADC WR line
	SETB P3.6		; then set it - this results in the required positive edge to start a conversion
	CLR TF0
	JMP ext0ISR
	RETI			; return from interrupt

