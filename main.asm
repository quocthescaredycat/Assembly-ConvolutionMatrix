.data
output: .asciiz "output_matrix.txt"
input: .asciiz "input_matrix.txt"
kernel: .word 0:17

padded_matrix: .word 0:100
newline: .asciiz "\n"
space: .asciiz " "
error: .asciiz "Error: size not match"
prompt_error: .asciiz "Error opening"
read_buffer: .space 100000
write_buffer: .space 100000
matrix_size: .word 0:4
image: .word 0:50
out: .word 0:50
minus1: .float -1.0
ten: .float 10.0
zero: .float 0.0
minuszero5: .float -0.5
zero5: .float 0.5

.text
.globl main
main:
    li $v0, 13
    la $a0, input
    li $a1, 0                  
    syscall
    move $s0, $v0
    li $t1, -1
    beq $s0, $t1, file_error
    
    li $v0, 14
    move $a0, $s0
    la $a1, read_buffer
    li $a2, 100000
    syscall
    move $t0, $v0 
    beq $t1, $t0, file_error
    
    la $a0, read_buffer
    la $s5, matrix_size
parese_first_line:
    li $t1, 0
store_char:
    lb $s1, 0($a0)
    sub $s1, $s1, '0'
    beq $t1, 0, store_N
    beq $t1, 1, store_M
    beq $t1, 2, store_P
    beq $t1, 3, store_s
    j pre_parsing
store_N:
    sb $s1, 0($s5)
    addi $s5, $s5, 1
    addi $t1, $t1, 1
    addi $a0, $a0, 4
    j store_char
store_M:
    sb $s1, 0($s5)
    addi $s5, $s5, 1
    addi $t1, $t1, 1
    addi $a0, $a0, 4
    j store_char
store_P:
    sb $s1, 0($s5)
    addi $s5, $s5, 1
    addi $t1, $t1, 1
    addi $a0, $a0, 4
    j store_char
store_s:
    sb $s1, 0($s5)
    addi $s5, $s5, 1
    addi $t1, $t1, 1
    addi $a0, $a0, 4
    j store_char
pre_parsing:
    la $s5, matrix_size
    lb $s1, 0($s5) #N
    lb $s2, 1($s5) #M
    la $t7,read_buffer
    lb $s3, 2($t7) #P
    lb $s4, 3($t7) #S
    add $t7, $t7, $t0 
    subi $t7, $t7, 1 #last element
    li $t6, 0 # Counter
    mul $s5, $s1, $s1 #N*N
    mul $s6, $s2, $s2 #M*M
    add $s6, $s5, $s6 #total elements
    
    la $s7, read_buffer
    addi $s7, $s7, 16 # Skip N, M, P, S
    
parse_matrix:
    li $t0, 0       # Integer part
    li $t1, 0       # Fractional part
    li $t2, 1       # Fractional multiplier
    la $s2, kernel
    la $s4, image
    li $t3, 0       # Decimal flag
    li $t5, 1       # Sign flag
matrix_loop:
    lb $t4, 0($s7)
    beq $t4, '-', set_sign
    beq $t4, '.', set_decimal
    beq $t4,' ', store_number 
    beq $t4, '\r', store_number
    beq $t4, '\n', next_char
    beq $t4, 0, store_number
    beq $t3, 0, integer
    # Fractional part
    sub $t4, $t4, 48 
    mul $t2, $t2, 10 
    mul $t1, $t1, 10
    add $t1, $t1, $t4
    j next_char
integer:
    sub $t4, $t4, 48
    mul $t0, $t0, 10
    add $t0, $t0, $t4
    j next_char
set_decimal:
    li $t3, 1
    j next_char
set_sign:
    li $t5, -1
    j next_char
next_char:
    bge $s7, $t7, store_number 
    addi $s7, $s7, 1
    j matrix_loop
store_number:
    mtc1 $t2, $f2
    mtc1 $t1, $f1
    cvt.s.w $f1, $f1
    mtc1 $t5, $f5
    cvt.s.w $f2, $f2
    div.s $f1, $f1, $f2
    mtc1 $t0, $f0
    cvt.s.w $f5, $f5
    cvt.s.w $f0, $f0
    add.s $f0, $f0, $f1 
    
    mul.s $f0, $f0, $f5
    # Check if counter is in range
    blt $t6, $s5, store_image
    blt $t6, $s6, store_kernel
store_image:
    swc1 $f0, 0($s4)
    addi $s4, $s4, 4
    addi $t6, $t6, 1
    j print_matrix
store_kernel:
    sub $t6, $t6, $s5  
    swc1 $f0, 0($s2)
    addi $s2, $s2, 4
    addi $t6, $t6, 1
    add $t6, $t6, $s5
    j print_matrix
print_matrix:
    beq $t7, $s7, padding #done
    # Reset
    li $t0, 0
    li $t1, 0
    li $t2, 1
    li $t3, 0
    li $t5, 1
    
    addi $s7, $s7, 1
    j matrix_loop
padding:
    la $s4, matrix_size
    lb $s1, 0($s4) #N
    lb $s2, 2($s4) #P
    add $s7,$s2,$s1 #N+P 
    la $s5, padded_matrix
    la $s6, image
    add $s3, $s2,$s2 #2P

    li $t2,0 #outer loop
    add $s4,$s3,$s1 #N+2P padded matrix size
pad1:
    bge $t2, $s4, pad_done 
    li $t3, 0 # column counter
pad2:
    bge $t3, $s4, next_pad1
    blt $t2, $s2, pad_zero     
    bge $t2, $s7, pad_zero    
    blt $t3, $s2, pad_zero    
    bge $t3, $s7, pad_zero     

    lwc1 $f0, 0($s6)
    swc1 $f0, 0($s5)
    addi $s6, $s6, 4         
    addi $t3, $t3, 1
    addi $s5, $s5, 4
    j pad2
pad_zero:
    mtc1 $0, $f0
    swc1 $f0, 0($s5)
    addi $t3, $t3, 1
    addi $s5, $s5, 4
    j pad2
next_pad1:
    addi $t2, $t2, 1
    j pad1
pad_done:
la $s3, matrix_size
lb $s1, 1($s3) #M kernel size
lb $s2, 3($s3) #S
# Check if kernel is larger than padded matrix
bgt $s1, $s4, errorSize
sub $s3, $s4, $s1 #N+2P - M (matrix-kernel)
div $t0, $s3, $s2 
addi $t0, $t0, 1 #output size

li $t2, 0 #i
conv_outer_loop:
    bge $t2, $t0, conv_done
    li $t3, 0 #j
conv_inner_loop:
    bge $t3, $t0, next_loop1 
    mtc1 $0, $f0
    li $t4, 0 #k
k_loop:
    bge $t4, $s1, next_loop2    #storeresult
    li $t5, 0 #l
l_loop:
    bge $t5, $s1, next_loop3    #next_k
    # Calculate padded_matrix[(i*s + ki)][(j*s + kj)]
    mul $t7, $t2, $s2      # i * stride
    add $t6, $t7, $t4      # (i * stride) + ki
    mul $t6, $t6, $s4      # * padded_size
    mul $t7, $t3, $s2      # j * stride
    add $t7, $t7, $t5      # (j * stride) + kj
    add $t6, $t6, $t7      # final index
    mul $t6, $t6, 4        # * 4 bytes
    la $s5, padded_matrix
    add $s5, $s5, $t6
    lwc1 $f1, 0($s5)       # Load padded value

    # Calculate kernel[ki][kj]
    mul $t6, $t4, $s1      # ki * M
    add $t6, $t6, $t5      # + kj
    mul $t6, $t6, 4        # * 4 bytes
    la $s6, kernel
    add $s6, $s6, $t6
    lwc1 $f2, 0($s6)       # Load kernel value
    
    # sum += padded * kernel
    mul.s $f1, $f1, $f2
    add.s $f0, $f0, $f1
    
    addi $t5, $t5, 1       
    j l_loop
next_loop1:
    addi $t2, $t2, 1
    j conv_outer_loop
next_loop2:
    l.s $f9, ten             
    mul.s $f1, $f0, $f9        
    round.w.s $f1, $f1         
    cvt.s.w $f2, $f1          
    div.s $f0, $f2, $f9

    # Store output[i][j] = sum
    mul $t6, $t2, $t0      # i * outDim
    add $t6, $t6, $t3      # + j
    mul $t6, $t6, 4        # * 4 bytes
    la $s7, out
    add $s7, $s7, $t6
    swc1 $f0, 0($s7)       # Store result
    
    # Print to console
    li $v0, 2
    mov.s $f12, $f0
    syscall
    li $v0, 4
    la $a0, space
    syscall

    addi $t3, $t3, 1       # j++
    j conv_inner_loop
next_loop3:
    addi $t4, $t4,1
    j k_loop

conv_done:
    li $v0, 13
	la $a0, output
	la $a1, 1
	li $a2, 0
	syscall
    move $s0, $v0
    bltz $s0, file_error

    mul $s1, $t0, $t0 #total elmts
    la $s5, out
    li $s7, 0 #counter    
    
    jal write_to_file

    # Write buffer to file
    li $v0, 15
    move $a0, $s0
    la $a1, write_buffer
    move $a2, $s7
    syscall
    # Close file
    li $v0, 16
    move $a0, $s0
    syscall
    j exit
Error:
    li $v0, 13       									
    la $a0, output    									
    li $a1, 1        									
    li $a2, 0        									
    syscall            									
    move $s6, $v0      									
    bltz $v0, file_error
    
    li $v0, 15
    move $a0, $s6
    la $a1, error
    li $a2, 22
    syscall
    li $v0, 16
    move $a0, $s0
    syscall
    j exit
write_to_file:
    li $t1, 0
    la $a0, write_buffer
write:
    l.s $f0, 0($s5)             # Load current result

    l.s $f30, ten       
    mul.s $f0, $f0, $f30         

    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    div $t8, $t0, 10
    mfhi $t9                   

    li $t7, 0                    # Stack counter
    
    bgez $t0, positive
    li $t2, '-'
    sb $t2, 0($a0)
    addi $a0, $a0, 1
    addi $s7, $s7, 1
    mul $t8, $t8, -1
    mul $t9, $t9, -1
positive:
    # Handle integer part
    bnez $t8, int_to_string_loop
    addi $t8, $t8, 48            
    sb $t8, 0($a0)
	addi $a0, $a0, 1
	addi $s7, $s7, 1
    j decimal_part
int_to_string_loop:
    div $t8, $t8, 10         
    mfhi $t3                     
    addi $t3, $t3, '0'           
    addi $sp, $sp, -4
    sw $t3, 0($sp)              
    addi $t7, $t7, 1
    bnez $t8, int_to_string_loop

int_to_string_pop:
    lw $t3, 0($sp)
    sb $t3, 0($a0)
    addi $a0, $a0, 1
    addi $sp, $sp, 4
    subi $t7, $t7, 1
    addi $s7, $s7, 1
    bgtz $t7, int_to_string_pop
decimal_part:
    li $t8, '.'                  
    sb $t8, 0($a0)           
    addi $a0, $a0, 1         
    addi $s7, $s7, 1

    addi $t9, $t9, 48            
    sb $t9, 0($a0)
    addi $a0, $a0, 1
    addi $s7, $s7, 1
    
    addi $s5, $s5, 4             # Next result element
    addi $t1, $t1, 1             # Increment counter
    
    beq $t1, $s1, exit_write     # If all elements written
    
    # Add space between numbers
    li $t8, ' '
    sb $t8, 0($a0)
    addi $a0, $a0, 1
    addi $s7, $s7, 1
    j write

exit_write:
    jr $ra
exit:
	li $v0,10
	syscall

errorSize:
    li $v0, 4
    la $a0, error
    syscall
    j Error
file_error: 
    li $v0, 4
    la $a0, prompt_error
    syscall
    li $v0,10
	syscall

