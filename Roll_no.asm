ORG 00H

START:
SETB P0.7; Turning the decoder on
SETB P3.4; Selecting the first display
SETB P3.3; Selecting the first display
MOV  P1,#11111001B;
CALL DELAY;

SETB P3.4; Selecting the second display
CLR  P3.3; Selecting the second display
MOV  P1,#10000000B;
CALL DELAY;

CLR  P3.4; Selecting the third display
SETB P3.3; Selecting the third display
MOV  P1,#10000110B;
CALL DELAY;

CLR  P3.4; Selecting the fourth display
CLR  P3.3; Selecting the fourth display
MOV  P1,#11000110B;
CALL DELAY;

SJMP START;
DELAY:
MOV R0,#1000B;
DELAY1: DJNZ R0,DELAY1;
RET
END

