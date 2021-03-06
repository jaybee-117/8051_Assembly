ORG 000H
	CLR P0.7	; enable the DAC WR line

	MOV DPTR, #LUT2 ; Move datapointer to the look-up table
    MOV R2,#0       ;
loop:
    CLR A           ; Clear the accumulator
	MOVC A,@A+DPTR  ; Go to the next effective address
    MOV P1,A        ;
	Inc DPTR        ;
    Inc R2          ;
    CJNE R2,#62,loop; jump back to loop
    MOV DPTR, #LUT2 ;
    MOV R2, #0      ;
    JMP loop        ;

ORG 0200H ;125 points
LUT1: DB 128,134,140,147,153,159,165,171,177,183,189,194,200,205,210,215,219,224,228,232,235,238,241,244,247,249,251,252,253,254,255,255,255,255,254,253,251,250,248,245,243,240,237,233,230,226,222,217,212,208,202,197,192,186,180,174,168,162,156,150,143,137,131,124,118,112,105,99,93,87,81,75,69,63,58,53,47,43,38,33,29,25,22,18,15,12,10,7,5,4,2,1,0,0,0,0,1,2,3,4,6,8,11,14,17,20,23,27,31,36,40,45,50,55,61,66,72,78,84,90,96,102,108,115,121;

ORG 0280H ;62 points
LUT2: DB 128,140,153,166,178,189,200,211,220,228,236,242,247,251,254,255,255,254,251,247,242,236,228,220,211,200,189,178,166,153,140,128,115,102,89,77,66,55,44,35,27,19,13,8,4,1,0,0,1,4,8,13,19,27,35,44,55,66,77,89,102,115;