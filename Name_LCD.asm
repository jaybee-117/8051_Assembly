			Org 0000h
		
RS 			Equ  	P1.3
E			Equ		P1.2
; R/W* is hardwired to 0V, therefore it is always in write mode
; ---------------------------------- Main -------------------------------------
Main:		
; Select Instruction Register (IR)			
			Clr RS		   	; RS=0 - Instruction register is selected. 
							; Stores instruction codes, e.g., clear display...
; Function set 
			Call FuncSet
; Display on/off control	
			Call DispCon
; Entry mode set (4-bit mode)			
			Call EntryMode	;|Increment DDRAM address by 1
							;|Cursor shifted to the right by 1		
; Send data
			SetB RS			; RS=1 - Data register is selected. 
							; Send data to data register to be displayed.

			Mov DPTR, #LUT  ; Move datapointer to the look-up table
Back:		Clr A           ; Clear the accumulator
			Movc A,@A+DPTR  ; Go to the next effective address
			Jz Finish       ;
			Call SendChar	; Send data to LCD to be displayed
			Inc DPTR        ;
			Jmp Back		;
			
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
;------------------------------------ Look up Table ----------------------------------
			Org 0200h
LUT: DB 'S','U','D','A','R','S','H','A','N',0 ;
;----------------------------------- End of subroutines --------------------------------		
Stop:		Jmp $
	
			End
