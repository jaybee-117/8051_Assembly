			Org 0000h
		
RS 			Equ  	P1.3
E			Equ		P1.2
MODE        Equ     P2.0       ;0 => Name | 1=> Clock
; R/W* is hardwired to 0V, therefore it is always in write mode
; ---------------------------------- Main -------------------------------------
Main:
;Start the Timer
            Mov TMOD, #01  ;Start Timer 0 in 16-Bit timer mode
; Select Instruction Register (IR)			
			Clr RS		   	; RS=0 - Instruction register is selected. 

; Function set 
			Call FuncSet
; Display on/off control	
			Call DispCon
; Entry mode set (4-bit mode)			
			Call EntryMode
;Initialise the registers
            Mov R1, #'0'    ;
			Mov R2, #'0'    ;
			Mov R3, #'0'    ;
			Mov R4, #'0'    ;
; ---------------------------------- Clock -------------------------------------            
Clock:
            SetB RS         ;|Data write mode

            Call CursorPos0 ;|
            Mov A, R4       ;
			Call SendChar	; Send data to LCD to be displayed
            Call CursorPos1 ;|
            Mov A, R3       ;
			Call SendChar	; Send data to LCD to be displayed
            Call CursorPos2 ;|
            Mov A, R2       ;
			Call SendChar	; Send data to LCD to be displayed
            Call CursorPos3 ;|
            Mov A, R1       ;
			Call SendChar	; Send data to LCD to be displayed
            Clr A           ;|Intialize Clk = 0:0:0:0

S0:         Jnb MODE, Name  ; Jump to Name if MODE = 0
            Call Wait		;
			Call CursorPos3 ; Ones Seconds
			Inc R1          ;
			Mov A, R1 		;
			Call SendChar	; Send data to LCD to be displayed
			Cjne R1,#'9',S0 ; Check if s0 = 9 if not, loop and go again
			Call Wait       ;|if s0 = 9: wait a sec,reset it to 0, display it; move on
			Mov R1, #'0'    ;|
			Mov A, R1		;|
			Call CursorPos3 ;|
			Call SendChar	;|
S1:         Call CursorPos2 ; Tens Seconds
            Inc R2          ;
			Mov A, R2       ;
            Call SendChar	; Send data to LCD to be displayed
			Cjne R2,#'5',S0 ; Check if s1 = 5 if not, loop and go again
			Call Wait       ;|if s1 = 5: wait a sec,reset it to 0, display it; move on
			Mov R2, #'0'    ;|
			Mov A, R2		;|
			Call CursorPos2 ;|
			Call SendChar	;|
M0:         Call CursorPos1 ; Ones Minutes
            Inc R3          ;
			Mov A, R3       ;
            Call SendChar	; Send data to LCD to be displayed
			Cjne R3,#'9',S0 ; Check if m0 = 9 if not, loop and go again
			Call Wait       ;|if m0 = 9: wait a sec,reset it to 0, display it; move on
			Mov R3, #'0'    ;|
			Mov A, R3		;|
			Call CursorPos1 ;|
			Call SendChar	;|
M1:         Call CursorPos0 ; Tens Minutes
            Inc R4          ;
			Mov A, R4       ;
            Call SendChar	; Send data to LCD to be displayed
			Cjne R4,#'5',S0 ; Check if m1 = 5 if not, loop and go again
			Call Wait       ;|if m1 = 5: wait a sec,reset it to 0, display it; move on
			Mov R4, #'0'    ;|
			Mov A, R4		;|
			Call CursorPos0 ;|
			Call SendChar	;|
; ---------------------------------- End of Clock -------------------------------------   
; -------------------------------------- Name -------------------------------------	
Name:
            SetB RS			; RS=1 - Data register is selected. 
							; Send data to data register to be displayed.
            Call CursorPos0 ; Start writing from the first cell
			Mov DPTR, #LUT  ; Move datapointer to the look-up table
Back:		Clr A           ; Clear the accumulator
			Movc A,@A+DPTR  ; Go to the next effective address
			Jz Continue     ;
			Call SendChar	; Send data to LCD to be displayed
			Inc DPTR        ;
			Jmp Back		;
Continue:  
S00:        Jb MODE, Clear  ;Jump to Clear if MODE = 1
            Call Wait		;
			Inc R1          ;
			Cjne R1,#'9',S00; Check if s0 = 9 if not, loop and go again
			Call Wait       ;|if s0 = 9: wait a sec,reset it to 0, display it; move on
			Mov R1, #'0'    ;|
S10:        Inc R2          ;
			Cjne R2,#'5',S00; Check if s1 = 5 if not, loop and go again
			Call Wait       ;|if s1 = 5: wait a sec,reset it to 0, display it; move on
			Mov R2, #'0'    ;|
M00:        Inc R3          ;
			Cjne R3,#'9',S00; Check if m0 = 9 if not, loop and go again
			Call Wait       ;|if m0 = 9: wait a sec,reset it to 0, display it; move on
			Mov R3, #'0'    ;|
M10:        Inc R4          ;
			Cjne R4,#'5',S00; Check if m1 = 5 if not, loop and go again
			Call Wait       ;|if m1 = 5: wait a sec,reset it to 0, display it; move on
			Mov R4, #'0'    ;|
; ---------------------------------- End of Name -------------------------------------	
Finish:		Jmp $			; Program ends and stays here
; ------------------------------- End of Main ---------------------------------



;-------------------------------- Subroutines ---------------------------------

; ------------------------- Function set --------------------------------------
FuncSet:	Clr  P1.7		; |
			Clr  P1.6		; |
			SetB P1.5		; | bit 5 = '1'
			Clr  P1.4		; | DL = '0' - puts LCD module into 4-bit mode 
	
			Call Pulse

			Call Delay		; wait for BF to clear

			Call Pulse
							
			SetB P1.7		; P1.7=1 (N) - 2 lines 
			Clr  P1.6
			Clr  P1.5
			Clr  P1.4
			
			Call Pulse
			
			Call Delay
			Ret

;------------------------------- Display on/off control -----------------------
; The display is turned on, the cursor is turned on
DispCon:	Clr P1.7		; |
			Clr P1.6		; |
			Clr P1.5		; |
			Clr P1.4		; | high nibble set (0H - hex)

			Call Pulse

			SetB P1.7		; |
			SetB P1.6		; |Sets entire display ON
			SetB P1.5		; |Cursor ON
			SetB P1.4		; |Cursor blinking ON
			Call Pulse

			Call Delay		; wait for BF to clear	
			Ret
;------------------------------------ Clear Display v2.0--------------------------------            
Clear:
            SetB RS			; RS=1 - Data register is selected. 
							; Send data to data register to be displayed.
            Call CursorPos0 ; Start writing from the first cell
			Mov DPTR, #LUT2  ; Move datapointer to the look-up table
Again:		Clr A           ; Clear the accumulator
			Movc A,@A+DPTR  ; Go to the next effective address
			Jz Go           ;
			Call SendChar	; Send data to LCD to be displayed
			Inc DPTR        ;
			Jmp Again		;
Go:         Jmp Clock       ;
;------------------------------------ Clear Display --------------------------------
; The display is turned on, the cursor is turned on
DispClc:	Clr P1.7		; |
			Clr P1.6		; |
			Clr P1.5		; |
			Clr P1.4		; | high nibble set (0H - hex)

			Call Pulse

			Clr P1.7		; |
			Clr P1.6		; |
			Clr P1.5		; |
			SetB P1.4		; | low nibble set
			Call Pulse

			Call Delay		; wait for BF to clear
			Ret			
;----------------------------- Entry mode set (4-bit mode) ----------------------
;    Set to increment the address by one and cursor shifted to the right
EntryMode:	Clr P1.7		; |P1.7=0
			Clr P1.6		; |P1.6=0
			Clr P1.5		; |P1.5=0
			Clr P1.4		; |P1.4=0

			Call Pulse

			Clr  P1.7		; |P1.7 = '0'
			SetB P1.6		; |P1.6 = '1'
			SetB P1.5		; |P1.5 = '1'
			Clr  P1.4		; |P1.4 = '0'
 
			Call Pulse

			Call Delay		; wait for BF to clear
			Ret
;----------------------------------Cursor address------------------------------------
CursorPos0:	Clr RS
			SetB P1.7		; Sets the DDRAM address
			Clr P1.6		; Set address. Address starts here - '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0' 
							; high nibble
			Call Pulse

			Clr P1.7		; 									 '0'
			Clr P1.6		; 									 '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0'
							; low nibble
							; Therefore address is 000 0000 or 00H
			Call Pulse

			Call Delay		; wait for BF to clear	

			SetB RS
			Ret	
CursorPos1:	Clr RS
			SetB P1.7		; Sets the DDRAM address
			Clr P1.6		; Set address. Address starts here - '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0' 
							; high nibble
			Call Pulse

			Clr P1.7		; 									 '0'
			Clr P1.6		; 									 '0'
			Clr P1.5		; 									 '0'
			SetB P1.4		; 									 '1'
							; low nibble
							; Therefore address is 000 0001 or 01H
			Call Pulse

			Call Delay		; wait for BF to clear	
			SetB RS
			Ret
CursorPos2:	Clr RS
			SetB P1.7		; Sets the DDRAM address
			Clr P1.6		; Set address. Address starts here - '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0' 
							; high nibble
			Call Pulse

			Clr P1.7		; 									 '0'
			Clr P1.6		; 									 '0'
			SetB P1.5		; 									 '1'
			Clr P1.4		; 									 '0'
							; low nibble
							; Therefore address is 000 0010 or 02H
			Call Pulse

			Call Delay		; wait for BF to clear	
			SetB RS
			Ret	
CursorPos3:	Clr RS
			SetB P1.7		; Sets the DDRAM address
			Clr P1.6		; Set address. Address starts here - '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0' 
							; high nibble
			Call Pulse

			Clr P1.7		; 									 '0'
			Clr P1.6		; 									 '0'
			SetB P1.5		; 									 '1'
			SetB P1.4		; 									 '1'
							; low nibble
							; Therefore address is 000 0011 or 03H
			Call Pulse

			Call Delay		; wait for BF to clear	
			SetB RS
			Ret				
;------------------------------------ Pulse -----------------------------------------
Pulse:		SetB E		; |*P1.2 is connected to 'E' pin of LCD module*
			Clr  E		; | negative edge on E	
			Ret

;------------------------------------- SendChar -------------------------------------			
SendChar:	Mov C, ACC.7		; |
			Mov P1.7, C			; |
			Mov C, ACC.6		; |
			Mov P1.6, C			; |
			Mov C, ACC.5		; |
			Mov P1.5, C			; |
			Mov C, ACC.4		; |
			Mov P1.4, C			; | high nibble set

			Call Pulse

			Mov C, ACC.3		; |
			Mov P1.7, C			; |
			Mov C, ACC.2		; |
			Mov P1.6, C			; |
			Mov C, ACC.1		; |
			Mov P1.5, C			; |
			Mov C, ACC.0		; |
			Mov P1.4, C			; | low nibble set

			Call Pulse

			Call Delay			; wait for BF to clear
			Ret
;------------------------------------- Delay -----------------------------------------			
Delay:		Mov R0, #50
			Djnz R0, $
			Ret
;------------------------------------- 1 second delay -----------------------------------------	
Wait:       Mov R7, #20         ;To loop it 20 times
Reinit:     Mov TH0, #3CH       ;65535-50000 = 15535 = Ox3CAF = 50ms delay
            Mov TL0, #0AFH      ;
            SetB TR0            ;starting the timer
            Jnb TF0, $          ;looping till overflow of timer, upon overflow: go to the next line
            Clr TR0             ;|
            Clr TF0             ;|reset
            Djnz R7, Reinit     ;Create a 50ms x 20 = 1s delay
            Ret
;------------------------------------ Look up Table ----------------------------------
			Org 0200h
LUT: DB 'S','U','D','A','R','S','H','A','N',0 ;
LUT2:DB ' ',' ',' ',' ',' ',' ',' ',' ',' ',0 ;
;----------------------------------- End of subroutines --------------------------------		
Stop:		Jmp $
	
			End
