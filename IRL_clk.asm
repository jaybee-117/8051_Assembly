ORG 00H

MOV TMOD, #01H ;16-Bit timer mode
      ;Storing 0-9 in 30H to 39H for future use in display
 MOV 30H, #11000000B
 MOV 31H, #11111001B
 MOV 32H, #10100100B
 MOV 33H, #10110000B
 MOV 34H, #10011001B
 MOV 35H, #10010010B
 MOV 36H, #10000011B
 MOV 37H, #11111000B
 MOV 38H, #10000000B
 MOV 39H, #10011000B
       
       
start: 
min1: MOV R2, #30H ;reset bit 1 of minute 
min0: MOV R3, #30H ;reset bit 0 of minute 
sec1: MOV R4, #30H ;reset bit 1 of second 
sec0: MOV R5, #30H ;reset bit 0 of second 
display:
;R2:R3:R4:R5 is the mmss display order. The accumulator works
;as a temporary storage for the number to be fed to it's corresponding
;7-segment display
 MOV A, R2
 MOV R1, A
 SETB P3.4
 SETB P3.3
 MOV P1, @R1
 CALL delay ;total delay 1/4 second
 MOV P1, #11111111B ;for no glitches
 MOV A, R3
 MOV R1, A
 CLR P3.3
 MOV P1, @R1
 CALL delay ;total delay 1/2 second
 MOV P1, #11111111B
 MOV A, R4
 MOV R1, A
 CLR P3.4
SETB P3.3
 MOV P1, @R1
CALL delay ;total delay 3/4 second
 MOV P1, #11111111B
 MOV A, R5
 MOV R1, A
 CLR P3.3
 MOV P1, @R1
 CALL delay ;total delay 1 second
 MOV P1, #11111111B
 INC R5
 CJNE R5, #3AH, display ;second 0 bit moves from 0 to 9
 INC R4
 CJNE R4, #36H, sec0 ;second 1 bit moves from 0 to 5
 INC R3
 CJNE R3, #3AH, sec1 ;minute 0 bit moves from 0 to 9
 INC R2
 CJNE R2, #36H, min0 ;minute 1 bit moves from 0 to 5
 JMP start ;clock reset to 0:0:0:0
       
       
       
       
      ;FEFB value for timer
      ;50K/4 ops made 12 seconds delay
      ;To get 1/4 second delay we need
      ;timer value of 50K/(4*12*4)
      delay:
 MOV TH0, #0FEH ;65535-(50K/4*12*4)
 MOV TL0, #0FBH
 SETB TR0 ;starting the timer
 JNB TF0, $ ;looping till overflow of timer, upon overflow: reset
 CLR TR0
 CLR TF0
 RET
