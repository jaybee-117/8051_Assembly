ORG 000H
START:
MOV 30H, #'0' ; store the ASCII values
MOV 31H, #'1'
MOV 32H, #'2'
MOV 33H, #'3'
MOV 34H, #'4'
MOV 35H, #'5'
MOV 36H, #'6'
MOV 37H, #'7'
MOV 38H, #'8'
MOV 39H, #'9'
; setting up the LCD module
CLR P1.3 ; clear RS -
; function set , 4-bit mode
CLR P1.7 ; high nibble set
CLR P1.6
SETB P1.5
CLR P1.4
SETB P1.2 ;negative edge on E
CLR P1.2
ACALL DELAY ; wait for BF to clear
SETB P1.2 ;negative edge on E
CLR P1.2
SETB P1.7 ; low nibble set
SETB P1.2 ; negative edge on E
CLR P1.2
ACALL delay ; wait for BF to clear
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
TX: CLR SM0
SETB SM1 ; put serial port in 8-bit UART mode
MOV A, PCON
SETB ACC.7
MOV PCON, A ; | set SMOD in PCON to double baud rate
MOV TMOD, #20H ; put timer 1 in 8-bit auto-reload mode
MOV TH1, #243 ; put -13 in timer 1 high byte
MOV TL1, #243 ; put same value in low byte
CLR F0
ACALL SCAN
MOV A, R0
CLR F0
ACALL SCAN
ADD A, R0
SETB TR1 ; start timer 1 ; put data start address in R0
MOV B, #10
DIV AB ; obtain individual unit place digits
ADD A, #30H ; ACSII value location
MOV R1, A
MOV A, @R1 ; obtain value
MOV SBUF, A ; move data to be sent to the serial port
JNB TI, $ ; wait for TI to be set after byte is sent
CLR TI ; clear TI
MOV A, #30H
ADD A, B ; location for second digit
MOV R1, A
MOV A, @R1
MOV SBUF, A ; move data to be sent to the serial port
JNB TI, $ ; wait for TI to be set after byte is sent
CLR TI ; clear TI
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
SCAN: MOV R0, #1H ; clear R0 - the first key is key0
; scan row0
SETB P0.3 ; set row3
CLR P0.0 ; clear row0
CALL colScan ; call column-scan subroutine
JB F0, finish2 ; | if F0 is set, jump to end of program
; scan row1
SETB P0.0 ; set row0
CLR P0.1 ; clear row1
CALL colScan ; call column-scan subroutine
JB F0, finish2 ; | if F0 is set, jump to end of program
; scan row2
SETB P0.1 ; set row1
CLR P0.2 ; clear row2
CALL colScan ; call column-scan subroutine
JB F0, finish2 ; | if F0 is set, jump to end of program
; scan row3
SETB P0.2 ; set row2
CLR P0.3 ; clear row3
CALL colScan ; call column-scan subroutine
JB F0, finish2 ; | if F0 is set, jump to end of program
JMP SCAN ; | go back to scan row 0
finish2: RET ; key is found - return
; column-scan subroutine
colScan:JB P0.4, SKIP1 ; if col0 is cleared - key found
SETB F0
JNB P0.4, $
RET
SKIP1: INC R0 ; otherwise move to next key
JB P0.5, SKIP2 ; if col0 is cleared - key found
SETB F0
JNB P0.5, $
RET
SKIP2: INC R0 ; otherwise move to next key
JB P0.6, SKIP3 ; if col0 is cleared - key found
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
DELAY: MOV R2, #50 ; delay for BF to clear
HERE: DJNZ R2, HERE
RET