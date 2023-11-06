;this is my code

#define origin	0x20
#define sourav 25

#ORIG 00
JMP origin

#orig origin
LDAR1 0
LDAR0 0xF0

LDA sourav
MOV_A_MEM INC_AR
LDB 50
ADD 
MOV_A_MEM INC_AR
LSH 
MOV_A_MEM INC_AR
LSH
MOV_A_MEM INC_AR
RSH
MOV_A_MEM INC_AR
HLT

#ORIG D0H
#DB 45H

#orig 0xF0
NOP
NOP
HLT

#ORIG 0xE0
#DB 10

;;NOP
;;LDA 0
;;MOV_A_B
;;MOV_B_MEM
;;INC
;;INC_AR
;;JMP 7
;;HLT
