/*
	Author: martin.orehek@hm.edu
	Date: 	22.03.2021
	Description:
		Simple ASM File showing Trap behaviour
*/

/*
	relevant documentation:
	-> https://riscv.org/wp-content/uploads/2019/12/riscv-spec-20191213.pdf (Chapter 25, +++)
	-> https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.md
	-> https://web.mit.edu/gnu/doc/html/as_7.html 
*/

.include "ecall_ids.inc"

.section .text.bios
.global _enter
# ########################################
# system startup
_enter: 
	nop # workaround because setting breakpoint on first line is not possible

	# initialize BIOS "stack pointer" (symbol comes from linker script / action)
	la t0, _bios_sp
    csrw mscratch, t0

	# initialize stack pointer (symbol comes from linker script / action)
    la sp, _sp

    # initialize interrupt vector register
    # => trap_handler is the entry point
    # => direct mode (!)
    la t0, trap_handler
    csrw mtvec, t0 # write CSR

    # clear all pending interrupt requests (if any)
    csrw mstatus, zero
    csrw mip, zero

    # initialize other basic stuff    
	jal init_bios

	# things to check in simulator
	# 
	# monitor cpu MSTATUS	-> interrupts are enabled globally
	# monitor cpu MIP 		-> no iterrupt is pending
	# monitor cpu MIE 		-> selected interrupts are enabled
	#
	# monitor cpu MTVEC 	-> ...
	#
	# monitor cpu MCAUSE 	-> ...
	# monitor cpu MTVAL 	-> ...
	# monitor cpu MEPC	 	-> ...
	# monitor cpu MSCRATCH 	-> ...
	#
	# monitor cpu PRIV 		-> check current priviledges
	#

    # start user user program here
	jal start

# ########################################
# trap handler jumped to during interrupt execution
#
# align to 4 bytes => [1:0] ... mtvec.MODE
.balign 4, 0
trap_handler:
	nop
	csrrw sp, mscratch, sp # save sp; sp = mscratch (BIOS stack area)
	addi sp, sp, -40
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)
	sw a2, 12(sp)
	sw t0, 16(sp)
	sw t1, 20(sp)
	sw t2, 24(sp)
	sw t3, 28(sp)
	sw t4, 32(sp)
	sw t5, 36(sp)

	
	# TODO:
	# -> many things are missing here!!
	#	 (e.g. has the execution of this code side-effecs on the "interrupted" code path?!)

    # get MCAUSE of the current trap (t0)
    csrr t0, mcause # read CSR
	# Interrupts can be separated from other traps with a single branch 
	# on the sign of the mcause register value. 
	# A shift left can remove the interrupt bit and scale the exception codes to index
	# into a trap vector table.
	slli t1, t0, 2

	# load start of correct interrupt hander table
    bltz t0, 1f # branch less-than-zero

	# => SW Interrupt
	la t2, softwareInterruptTable
	j 2f

1:	# => HW Interrupt
	la t2, hardwareInterruptTable

	# jump to location specified in t2
2:	add t2, t2, t1
	jalr zero, t2, 0

# ########################################
# SW Interrupt Handler Table
.balign 4, 0
softwareInterruptTable:
swirq0:
	j unhandled_trap
swirq1:
	j unhandled_trap
swirq2:
	j unhandled_trap
swirq3:
	j unhandled_trap
swirq4:
	j unhandled_trap
swirq5:
	j unhandled_trap
swirq6:
	j unhandled_trap
swirq7:
	j unhandled_trap
swirq8:
	j env_call
swirq9:
	j env_call
swirq10:
	j unhandled_trap
swirq11:
	j env_call
swirq12:
	j unhandled_trap
swirq13:
	j unhandled_trap
swirq14:
	j unhandled_trap
swirq15:
	j unhandled_trap

# ########################################
/* environment call (ecall) */
errMsgEcall: .string "catched unsuported ecall function!!!\n"
.balign 4
# env_call:
	# check for a0 => what is being called
	# a1 ... contains additional parameters (!)
env_call:
	csrr t0, mepc
    addi t0, t0, 4
	csrw mepc, t0

    addi t0, zero, PRINT_STRING
    beq a0, t0, printString

    addi t0, zero, PRINT_CHAR
    beq a0, t0, printChar

	# own code
	addi t0, zero, INT2STR
    beq a0, t0, integer2String

# Unuspported ecall
    la a0, errMsgEcall
    jal puts

1:	# endless loop !!!
    j 1b

/* ecall: PRINT_CHAR */
printChar:
	mv a0, a1
	jal	putc
	j end_trap_handler

/* ecall: PRINT_STRING */
printString:
	mv a0, a1
	jal	puts
	j end_trap_handler

/* ecall: INT2STR */
integer2String:
	nop 
	
	sw zero, 0(a2)	# vorgänger String löschen im intString	
	sw zero, 8(a2)

	beq a1, zero, integer_zero 	# speziall Fall für die Zahl 0
	bltz a1, negativ			# Fall das die Zahl kleiner als 0 ist 

	

	jal count			# Änderung der Startadresse für den IntegerString für positive Zahlen
	addi a2, a2, -1		# Startadresse um 1 dekrementieren 
	jal store_number	# Speichern der einzelnen Dezimalstellen in IntegerString
	j end
	
integer_zero:
	li t5, 48			# Ascii-Wert für '0' 
	sb t5, 0(a2)		# Speichern der '0' im IntegerString
	j end

negativ:
	li t5, -1			
	mul a1, a1, t5		# Multiplikation von der negativ Zahl zu einer positiven
	jal count			# Änderung der Startadresse für den IntegerString für positive Zahlen
	jal store_number	# Speichern der einzelnen Dezimalstellen in IntegerString


	addi a2, a2, -1		# Startadresse um 1 dekrementieren 
	li t5, 45			# Ascii-Wert für '-' 
	sb t5, 0(a2)		# Speichern des Minuszeichens an der erstenstelle

end:

	j end_trap_handler

# ########################################
# Hardware Interrupt Handler Table
errMsgHwTrap: .string "catched unsuported interrupt cause\n"
.balign 4, 0
hardwareInterruptTable:
hwirq0: // User software interrupt
	j unhandled_trap
hwirq1: // Supervisor software interrupt
	j unhandled_trap
hwirq2: // Reserved
	j unhandled_trap
hwirq3: // Machine software interrupt
	j unhandled_trap
hwirq4: // User timer interrupt
	j unhandled_trap
hwirq5: // Supervisor timer interrupt
	j unhandled_trap
hwirq6: // Reserved
	j unhandled_trap
hwirq7: // Machine timer interrupt
	j unhandled_trap
hwirq8: // User external interrupt
	j unhandled_trap
hwirq9: // Supervisor external interrupt
	j unhandled_trap
hwirq10: // Reserved
	j unhandled_trap
hwirq11: // Machine external interrupt
	j unhandled_trap
hwirq12: // Reserved
	j unhandled_trap
hwirq13: // Reserved
	j unhandled_trap
hwirq14: // Reserved
	j unhandled_trap
hwirq15: // Reserved
	j unhandled_trap

# ########################################
/* unhandled trap */
.balign 4
unhandled_trap:
	csrr t0, mcause
	csrr t1, mepc
	csrr t2, mtval
	j unhandled_trap

# ########################################
# End or Ignored
end_trap_handler:
	lw ra, 0(sp)
	lw a0, 4(sp)
	lw a1, 8(sp)
	lw a2, 12(sp)
	lw t0, 16(sp)
	lw t1, 20(sp)
	lw t2, 24(sp)
	lw t3, 28(sp)
	lw t4, 32(sp)
	lw t5, 36(sp)
	addi sp, sp, 40

	csrrw sp, mscratch, sp # mscratch = current sp (BIOS stack area); restore sp to user_code stack;	
    mret

# ########################################
/* helper functions */
# ########################################

# initialize basic I/O system
init_bios:
	addi sp, sp, -4
	sw ra, 0(sp)

	# init UART0
	jal init_uart0	

	lw ra, 0(sp)
	addi sp, sp, 4	
	ret

# output char on Console
putc:
	addi sp, sp, -4
	sw ra, 0(sp)

	jal putc_uart0

	lw ra, 0(sp)
	addi sp, sp, 4		
	ret

# output string on Console
puts:
	addi sp, sp, -4
	sw ra, 0(sp)

	jal puts_uart0

	lw ra, 0(sp)
	addi sp, sp, 4		
	ret

# Zählt die Dezimalstellen in a1 und rechnet sie auf die Adresse a2 vom IntString
count:
	addi sp, sp, -4
	sw ra, 0(sp)

	li t3, 10						# statische 10
	mv t1, a1						# Schreibt die Zahl von a1 in t1
	li t2, 0						# Zähler für die einzelnen Dezimalstellen der Zahl in t1

decimal_places:
	beqz t1, 1f						# Checkt ob t1 Null ist
	divu t1, t1, t3					# Teilt t1 um 10
	addi t2, t2, 1					# Imkementiert den Zähler der Dezimalstelle um 1
	j decimal_places

1:
	add a2, a2, t2					# Startadresse für die kleinste Stelle für IntegerString
	lw ra, 0(sp)
	addi sp, sp, 4		
	ret

# Speichert die einzelnen Dezimalstellen in den IntString
store_number:
	addi sp, sp, -4
	sw ra, 0(sp)

	li t3, 10						# statische 10

begin:
	beqz a1, end_store_number		# Schreife endet wenn die Zahl in a1 gleich 0 ist
	remu t4, a1, t3					# Schreibt die kleinste Deizmalstelle in t4
	
	sub a1, a1, t4					# Zieht die kleinste Dezimalstelle von der Zahl in a1 ab
	
	addi t5, t4, 48					# Schreibt die aktuelle Dezimalstelle als Ascii-Wert in t5
	sb t5, 0(a2)					# Speichert die Ascii-Wert an die richtige Speicheradresse von IntegerString
	beqz a1, over					# Checkt ob die Zahl in a1 schon Null ist
	addi a2, a2, -1					# Dekrementiert die Speicheradresse für die nächste Dezimalstelle
	
over:
	divu a1, a1, t3
	j begin	

end_store_number:
	lw ra, 0(sp)
	addi sp, sp, 4		
	ret

# end of bios.S
