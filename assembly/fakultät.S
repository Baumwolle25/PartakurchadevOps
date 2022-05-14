j main

#  int32_t fakultaet(int32_t n)
#  {
#    if (n < 1) return (1);
#    else return (n * fakultaet(n-1));
#  }

fakultaet:
    # Prolog
    addi sp, sp, -8
    sw ra, 4(sp) # Rücksprungadresse sichern

    addi t0, a0, -1
    bge t0, zero, 1f
    li a0, 1
    j 2f

1:  sw s0, 0(sp)
    mv s0, a0
    addi a0, a0, -1
    jal fakultaet # rekursiver Aufruf
    mul a0, s0, a0 # t0=n a0=fakultaet(n-1) # falsch
    lw s0, 0(sp)

2:  # Epilog
    lw ra, 4(sp)  # Rücksprungadresse wiederherstellen
    addi sp, sp, 8
    ret

main:
    li a0, 10 # n=4
    jal fakultaet

    # Rückgabewert ausgeben
    mv a1, a0
    li a0, 1 # print_int
    ecall

    # Programm beenden, Rückgabewert 0
    li a1, 0  # Rückgabewert
    li a0, 10 # exit
    ecall
