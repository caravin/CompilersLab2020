.data
endline: .asciiz "\n"
.text
main:
subu $sp, $sp, 500
sw $ra, 496($sp)
sw $fp, 492($sp)
move $fp, $sp
li $v0 5
syscall
move $t0, $v0
sw $t0, 404($sp)
li $t0, 0
li $t1, 0
add $t1, $t1, $t0
li $t2, 1
mul $t1, $t1, 4
li $s1, 400
addu $s0, $sp, $s1
sub $s0, $s0, $t1
sw $t2, 0($s0)
li $t2, 1
li $t1, 0
add $t1, $t1, $t2
li $t0, 1
mul $t1, $t1, 4
li $s1, 400
addu $s0, $sp, $s1
sub $s0, $s0, $t1
sw $t0, 0($s0)
li $t0, 2
sw $t0, 0($sp)
L15:
lw $t1, 0($sp)
lw $t2, 404($sp)
slt $t3, $t1, $t2
beq $t3, 0, L45
j L26
L21:
lw $t2, 0($sp)
addu $t1, $t2, 1
sw $t1, 0($sp)
j L15
L26:
lw $t2, 0($sp)
li $t3, 0
add $t3, $t3, $t2
lw $t0, 0($sp)
li $t2, 1
sub $t1, $t0, $t2
li $t2, 0
add $t2, $t2, $t1
mul $t2, $t2, 4
li $s1, 400
addu $s0, $sp, $s1
sub $s0, $s0, $t2
lw $t0, 0($s0)
lw $t2, 0($sp)
li $t1, 2
sub $t4, $t2, $t1
li $t1, 0
add $t1, $t1, $t4
mul $t1, $t1, 4
li $s1, 400
addu $s0, $sp, $s1
sub $s0, $s0, $t1
lw $t2, 0($s0)
add $t1, $t0, $t2
mul $t3, $t3, 4
li $s1, 400
addu $s0, $sp, $s1
sub $s0, $s0, $t3
sw $t1, 0($s0)
j L21
L45:
lw $t1, 404($sp)
li $t3, 1
sub $t2, $t1, $t3
li $t3, 0
add $t3, $t3, $t2
mul $t3, $t3, 4
li $s1, 400
addu $s0, $sp, $s1
sub $s0, $s0, $t3
lw $t1, 0($s0)
move $a0, $t1
li $v0 1
syscall
li $v0, 4
la $a0, endline
syscall
li $t3, 0
move $v0, $t3
j end_main
end_main:
move $sp, $fp
lw $ra, 496($sp)
lw $fp, 492($sp)
addu $sp, $sp, 500
j $ra
