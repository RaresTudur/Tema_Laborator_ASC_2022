# vector adiacenta = [2,2,1,0]
.data
    ns: .space 4
    nd: .space 4
    n: .space 4
    nr_cerinta: .space 4
    vector_adiacenta: .space 400
    m1: .space 40000
    m2: .space 40000
    mres: .space 40000
    element: .space 4
    index: .space 4
    index_sec: .space 4
    index_k: .space 4
    formatscanf: .asciz "%d"
    formatprintf: .asciz "%d "
    formatprintf2: .asciz "%d\n"
    new_line: .asciz " \n"
    lungime_drum: .space 4

.text
.global main

afisare_matrice:
    movl $0,index
    for_linii:
        movl index,%ecx
        cmp %ecx,n
        je et_exit

        movl $0,index_sec
        for_coloane:
            movl index_sec,%ecx
            cmp %ecx,n
            je linie_noua

            lea m1,%edi
            movl index,%eax
            xorl %edx,%edx
            mull n
            addl index_sec,%eax
            movl (%edi,%eax,4),%ebx
            push %ebx
            push $formatprintf
            call printf
            pop %ebx
            pop %ebx
            pushl $0
            call fflush
            pop %ebx
            incl index_sec
            jmp for_coloane
            
    linie_noua:
        incl index
        jmp for_linii

afisare_cerinta_2:
    lea mres,%edi
    movl ns,%eax
    xorl %edx,%edx
    mull n
    addl nd,%eax
    movl (%edi,%eax,4),%ebx
    
    push %ebx
    push $formatprintf2
    call printf
    addl $8,%esp

    pushl $0
    call fflush
    popl %ebx

    jmp et_exit

matrix_mult:
    pushl %ebp
    movl %esp,%ebp
    pushl %ebx
    pushl %edi
    subl $40,%esp # variabile locala pt index linie,coloana si k
    movl 20(%ebp),%ecx # n
    movl 16(%ebp),%ebx # adresa lui mres
    movl 12(%ebp),%esi # adresa lui m2
    movl 8(%ebp),%edi # adresa lui m1
    movl $0,-12(%ebp) # index_linie = 0
    for_linie_mult: # index_linie
        cmp -20(%ebp),%ecx
        je exit_proc
        movl $0,-16(%ebp) # index_coloana
        for_coloana_mult:
            cmp -16(%ebp),%ecx
            je incl_linie
            movl $0,-20(%ebp) # k
            for_coloana_k:
                cmp -20(%ebp),%ecx
                je incl_coloana_mult
                # [i][k]
                movl -12(%ebp),%eax
                xorl %edx,%edx
                mull %ecx
                addl -20(%ebp),%eax
                movl %eax,-24(%ebp)
                # [k][j]
                movl -20(%ebp),%eax
                xorl %edx,%edx
                mull %ecx # n
                addl -16(%ebp),%eax
                movl %eax,-28(%ebp)
                # [i][j]
                movl -12(%ebp),%eax
                xorl %edx,%edx
                mull %ecx # n
                addl -16(%ebp),%eax
                movl %eax,-32(%ebp)

                movl -24(%ebp),%edx
                movl (%edi,%edx,4),%eax
                movl -28(%ebp),%edx
                movl (%esi,%edx,4),%ecx
                xorl %edx,%edx
                mull %ecx
                movl -32(%ebp),%ecx
                addl %eax,(%ebx,%ecx,4)

                movl 20(%ebp),%ecx
                incl -20(%ebp)
                jmp for_coloana_k

    incl_coloana_mult:
        incl -16(%ebp)
        jmp for_coloana_mult
    incl_linie:
        incl -12(%ebp)
        jmp for_linie_mult
    exit_proc:
        addl $40,%esp
        popl %edi
        popl %ebx
        popl %ebp
        ret

rez_cerinta_2:
    # citirea lungimii drumului
    push $lungime_drum
    push $formatscanf
    call scanf
    addl $8,%esp
    # citirea nodului sursa
    push $ns
    push $formatscanf
    call scanf
    addl $8,%esp
    # citirea nodului destinatie
    push $nd
    push $formatscanf
    call scanf
    addl $8,%esp
    # initializare m2 si mres
    push n
	push $mres
	push $m1
	push $m1
	call matrix_mult
    addl $16,%esp
    movl $1,index
    for_numar_inmultiri:
        movl index,%ecx
        cmp %ecx,lungime_drum
        je afisare_cerinta_2
        movl $0,index_sec
        for_j:
            movl index_sec,%ecx
            cmp %ecx,n
            je inmultire_matrice
            movl $0,index_k
            for_k:
                movl index_k,%ecx
                cmp %ecx,n
                je inc_index_j
                lea mres,%edi
                movl index_sec,%eax
                xorl %edx,%edx
                mull n
                addl index_k,%eax
                movl (%edi,%eax,4),%ebx
                lea m2,%edi
                movl %ebx,(%edi,%eax,4)
                incl index_k
                jmp for_k
        inc_index_j:
            incl index_sec
            jmp for_j
    inmultire_matrice:
        push n
        push $mres
        push $m2
        push $m1
        call matrix_mult
        addl $16,%esp
        incl index
        jmp for_numar_inmultiri        

main:
    # citirea cerintei scanf("%d",nr_cerinta)  
    push $nr_cerinta
    push $formatscanf
    call scanf
    addl $8,%esp
    # citirea numarul de noduri scanf("%d",n)
    push $n
    push $formatscanf
    call scanf
    addl $8,%esp

    xorl %ecx,%ecx
    lea vector_adiacenta,%edi
    for_citire_vector_adicenta:
        cmp %ecx,n
        je for_citire_legaturi_nod
        push %ecx
        push %edx
        push $element
        push $formatscanf
        call scanf
        addl $8,%esp
        pop %edx
        pop %ecx
        movl element,%ebx
        movl %ebx,(%edi,%ecx,4)
        incl %ecx
        jmp for_citire_vector_adicenta
    for_citire_legaturi_nod:
        xorl %ecx,%ecx
        movl $0,index
        for_noduri:
            movl index,%ecx
            cmp %ecx,n
            je verificare_cerinta
            movl (%edi,%ecx,4),%ebx
            cmp $0,%ebx
            je inc_nod
            movl $0,index_sec
            for_noduri_vector_adiacenta:
                movl index_sec,%ecx
                cmp %ecx,%ebx
                je inc_nod
                push %ecx
                push $element
                push $formatscanf
                call scanf
                addl $8,%esp
                pop %ecx
                # matrice_adicenta[index][element] = 1
                movl index,%eax
                xorl %edx,%edx
                mull n
                addl element,%eax
                lea m1,%esi
                movl $1,(%esi,%eax,4)
                incl index_sec
                jmp for_noduri_vector_adiacenta               
        inc_nod:
            incl index
            jmp for_noduri
    verificare_cerinta:
        movl nr_cerinta,%edx
        cmp $1,%edx
        je afisare_matrice
        cmp $2,%edx
        je rez_cerinta_2

et_exit:
    movl $1,%eax
    xorl %ebx,%ebx
    int $0x80