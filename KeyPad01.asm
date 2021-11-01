ORG 000H
START: 
MOV 30H, #0 ; store ASCII values of characters
MOV 31H, #'0'
MOV 32H, #'/'
MOV 33H, #'9'
MOV 34H, #'8'
MOV 35H, #'7'
MOV 36H, #'6'
MOV 37H, #'5'
MOV 38H, #'4'
MOV 39H, #'3'
MOV 3AH, #'2'
MOV 3BH, #'1'
; initiate LCD module
CLR P1.3 ; clear RS
; function set , 4-bit mode
CLR P1.7 ; high nibble set
CLR P1.6
SETB P1.5
CLR P1.4
SETB P1.2 ;negative edge on E
CLR P1.2
ACALL DELAY ; wait for BF to clear
SETB P1.2 ; negative edge on E
CLR P1.2
SETB P1.7 ; low nibble set
SETB P1.2 ; negative edge on E
CLR P1.2
ACALL DELAY ; wait for BF to clear
; entry mode set
; set to increment with no shift
CLR P1.7 ; high nibble set
CLR P1.6
CLR P1.5
CLR P1.4
SETB P1.2 ;negative edge on E
CLR P1.2
SETB P1.6 ; lower nibble set
SETB P1.5
SETB P1.2 ;negative edge on E
CLR P1.2
ACALL DELAY ; wait for BF to clear
; display on/off control
; display on, cursor on ,blinking on
CLR P1.7 ; high nibble set
CLR P1.6
CLR P1.5
CLR P1.4
SETB P1.2 ;negative edge on E
CLR P1.2
SETB P1.7 ; lower nibble set
SETB P1.6
SETB P1.5
SETB P1.4
SETB P1.2 ;negative edge on E
CLR P1.2
ACALL DELAY ; wait for BF to clear
; subroutine for transmitting data
TX: CLR SM0 ; |
SETB SM1 ; | put serial port in 8-bit UART mode
MOV A, PCON
SETB ACC.7
MOV PCON, A ; set SMOD in PCON to double baud rate
MOV TMOD, #20H ; put timer 1 in 8-bit auto-reload mode
MOV TH1, #243 ; put -13 in timer 1 high byte
MOV TL1, #243 ; put same value in low byte
SETB TR1 ; start timer 1 ; put data start address in R0
AGAIN: CLR F0 ;clear flag 0
ACALL SCAN ; scan number from keypad,
MOV A, @R0 ; move from location pointed to by R0 to the accumulator
JZ RX ; if the accumulator contains 0, jump to RX
MOV SBUF, A ; move data to be sent to the serial port
INC R0 ; increment R0 to point at next byte of data to be sent
JNB TI, $ ; wait for TI to be set, indicating serial port has finished sending byte
CLR TI ; clear TI
JMP AGAIN ; send next byte
; Receiving data
RX: CLR SM0
SETB SM1 ; | put serial port in 8-bit UART mode
SETB REN ; enable serial port receiver
MOV A, PCON
SETB ACC.7
MOV PCON, A ; | set SMOD in PCON to double baud rate
MOV TMOD, #20H ; put timer 1 in 8-bit auto-reload mode
MOV TH1, #243 ; put -13 in timer 1 high byte
MOV TL1, #243 ; put same value in low byte
SETB TR1 ; start timer 1
MOV R1, #40H ; put data start address in R1
SETB P1.3
AGAIN1: JNB RI, $ ; wait for byte to be received
CLR RI ; clear the RI flag
MOV A, SBUF ; move received byte to A
; send data
ACALL DATA
CJNE A, #0DH, SKIP ; compare it with 0DH - if it's not, skip
JMP FINISH1 ; if it is the terminating character, jump to finish1
SKIP: MOV @R1, A ; move from A to location pointed to by R1
INC R1 ; increment R1 to point at next location
JMP AGAIN1 ; jump back to waiting for next byte
FINISH1:JMP $ ; do nothing
SCAN: MOV R0, #30H ; move address of ASCII data
; scan row0
SETB P0.3 ; set row3
CLR P0.0 ; clear row0
ACALL colScan ; call column-scan subroutine
JB F0, finish2 ; if F0 is set, jump to end of program
; scan row1
SETB P0.0 ; set row0
CLR P0.1 ; clear row1
ACALL colScan ; call column-scan subroutine
JB F0, finish2 ; | if F0 is set, jump to end of program
; scan row2
SETB P0.1 ; set row1
CLR P0.2 ; clear row2
ACALL colScan ; call column-scan subroutine
JB F0, finish2 ; | if F0 is set, jump to end of program
; scan row3
SETB P0.2 ; set row2
CLR P0.3 ; clear row3
ACALL colScan ; call column-scan subroutine
JB F0, finish2 ; | if F0 is set, jump to end of program
JMP SCAN ; | go back to scan row 0
finish2: RET ; key is found - return
; column-scan subroutine
colScan: JB P0.4, SKIP1 ; if col0 is cleared - key found, else skip
SETB F0
JNB P0.4, $
RET
SKIP1: INC R0 ; otherwise move to next key
JB P0.5, SKIP2 ; if col1 is cleared - key found, else skip
SETB F0
JNB P0.5, $
RET
SKIP2: INC R0 ; otherwise move to next key
JB P0.6, SKIP3 ; if col2 is cleared - key found, else skip
SETB F0
JNB P0.6, $
RET
SKIP3: INC R0 ; otherwise move to next key
RET
; send data byte-wise
DATA: MOV C, ACC.7 ; higher nibble set
MOV P1.7, C
MOV C, ACC.6
MOV P1.6, C
MOV C, ACC.5
MOV P1.5, C
MOV C, ACC.4
MOV P1.4, C
SETB P1.2 ;negative edge on E
CLR P1.2
MOV C, ACC.3 ; lower nibble set
MOV P1.7, C
MOV C, ACC.2
MOV P1.6, C
MOV C, ACC.1
MOV P1.5, C
MOV C, ACC.0
MOV P1.4, C
SETB P1.2 ;negative edge on E
CLR P1.2
ACALL DELAY ; wait for BF to clear
RET
DELAY: MOV R2, #50 ; delay for busy flag to clear
HERE: DJNZ R2, HERE
RET
