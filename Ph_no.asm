ORG 00H

START:
MOV P1, #10000000B; 8
CALL DELAY;
MOV P1, #10000010B; 6
CALL DELAY;
MOV P1, #10010010B; 5
CALL DELAY;
MOV P1, #10110000B; 3
CALL DELAY;
MOV P1, #10000000B; 8
CALL DELAY;
MOV P1, #10011001B; 4
CALL DELAY;
MOV P1, #11000000B; 0
CALL DELAY;
MOV P1, #10010010B; 5
CALL DELAY;
MOV P1, #10010000B; 9
CALL DELAY;
MOV P1, #11000000B; 0
CALL DELAY;
SJMP START;

DELAY:
MOV R0,#1000B;
DELAY1: DJNZ R0,DELAY1;
RET

END