#define origin 20H
JMP origin

#orig 3
#DB 0xAB

#orig origin
LDAR0 0xf0
LDA 1
void_loop: MOV_A_MEM
INC_AR
LSH
JNCAR void_loop
HLT

