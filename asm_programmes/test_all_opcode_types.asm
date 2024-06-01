lda 0xBD 		;;mvi
mov_a_b			;;mov_reg_reg
ldar0 0xf0
mov_mem_b		;;mov mem_rd
inc_ar			;;system
mov_a_mem
inc					;;alu
nop					;;system
jmp 0x15		;;unconditional jump
#orig 0x10
label: nop
	lda 0x00
	hlt
#orig 0x15
jepar label		;;conditional jump fail
jopar label		;;CJ pass	
hlt
