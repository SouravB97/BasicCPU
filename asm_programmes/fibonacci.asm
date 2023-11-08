#define origin 20h
#define a efh

jmp `origin

#orig `origin
ldar0 `a
lda 1
ldb 0
loop: mov_a_mem
	add
	mov_mem_b
	jncar loop
hlt
