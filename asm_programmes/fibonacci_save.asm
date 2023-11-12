#define code_mem 0x10
;stack
#define heap_ptr 0xFF	;stores current address of heap
#define a_tmp	0XFE	;to store current value of a
#define b_tmp	0XFD	;to store current value of b
;heap
#define output_start 0XE0	;start location of output


jmp `code_mem

#orig `code_mem
ldar0 `heap_ptr
lda `output_start
mov_a_mem

; fibonacci
; init b with smaller value, a with larger value
ldb 0
lda 1
; move a and b to temp
ldar0 `b_tmp
mov_b_mem
ldar0 `a_tmp
mov_a_mem

loop: nop
  ; store a at value given at heap_ptr
	ldar0 `heap_ptr
	mov_mem_ar0
	mov_a_mem
  ; increment heap_ptr
	ldar0 `heap_ptr
	mov_mem_a
	inc
	mov_a_mem
  
	;fibonacci code
  ; restore a from a_tmp, b from b_tmp
	ldar0 `a_tmp
	mov_mem_a
	ldar0 `b_tmp
	mov_mem_b

	; add a and b
	add 
	ldar0 `a_tmp	;b = a
	mov_mem_b
  ; move a and b to temp
	ldar0 `a_tmp	;not needed, AR0 already set
	mov_a_mem
	ldar0 `b_tmp
	mov_b_mem

	jncar loop
hlt
