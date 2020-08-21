// This file includes common functions,
// Rule:
//    1. s0 is function name
//    2. s1,s2,... are the input parameters
//    3. so, a function is called by:
//            la   s0, func_name
//            li   s1, xxxx (or la s1, label)
//            jalr s0          

// function: delay ( num )
delay:
        addi    s1,     s1,     -1
        bgez    s1,     delay
        ret


// function: print ( str_addr )
print:
        lw      s2,     0x0(s1)
        li      s3,     0xFF601FFF60
        sw      s2,     0x0(s3)
        addi    s1,     s1, 4
        andi    s4,     s2, 0xff
        beqz    s4,     print_end   // check [7:0]
        srli    s2,     s2,8
        andi    s4,     s2, 0xff
        beqz    s4,     print_end   // check [15:8]
        srli    s2,     s2,8
        andi    s4,     s2, 0xff
        beqz    s4,     print_end   // check [23:16]
        srli    s2,     s2,8
        andi    s4,     s2, 0xff
        beqz    s4,     print_end   // check [31:24]
        j       print

print_end:
        ret

//--------------------------------------------------------------------------
// Status
//--------------------------------------------------------------------------
IMC_Pass:
        PRINT(imc_pass_msg)
        WRITE_TEST_STATUS(16, 4)
        TEST_FINISH(0x10)
        wfi
        
IMC_Fail:
        PRINT(imc_fail_msg)
        WRITE_TEST_STATUS(16, 8)
        TEST_FINISH(0x10)
        wfi

APC_Pass:
        #       li      t0,     0x100
        #       csrr    s1,     mhartid
        #       slli    s1,     s1,     14
        #       add     s1,     s1,     t0
        #       jal     delay
        csrr    s1,     mhartid
        slli    s1,     s1,     7       // for align 7
        la      t1,     core0_pass
        add     s1,     t1,     s1
        or      s1,     s1,     s10
        jr      s1
        
APC_Fail:
        //li      t0,     0x100
        //csrr    s1,     mhartid
        //slli    s1,     s1,     10
        //add     s1,     s1,     t0
        //jal     delay
        csrr    s1,     mhartid
        slli    s1,     s1,     7       // for align 7
        la      t1,     core0_fail
        add     s1,     t1,     s1
        or      s1,     s1,     s10
        jr      s1

        .align  7
core0_pass:
        PRINT(cpu0_pass_msg)
        WRITE_TEST_STATUS(0, 4)
        TEST_FINISH(0x0)
        wfi

        .align  7
core1_pass:
        //PRINT(cpu1_pass_msg)
        WRITE_TEST_STATUS(1, 4)
        TEST_FINISH(0x1)
        wfi

        .align  7
core2_pass:
        //PRINT(cpu2_pass_msg)
        WRITE_TEST_STATUS(2, 4)
        TEST_FINISH(0x2)
        wfi

        .align  7
core3_pass:
        //PRINT(cpu3_pass_msg)
        WRITE_TEST_STATUS(3, 4)
        TEST_FINISH(0x3)
        wfi

        .align  7
core4_pass:
        //PRINT(cpu4_pass_msg)
        WRITE_TEST_STATUS(4, 4)
        TEST_FINISH(0x4)
        wfi

        .align  7
core5_pass:
        //PRINT(cpu5_pass_msg)
        WRITE_TEST_STATUS(5, 4)
        TEST_FINISH(0x5)
        wfi

        .align  7
core6_pass:
        //PRINT(cpu6_pass_msg)
        WRITE_TEST_STATUS(6, 4)
        TEST_FINISH(0x6)
        wfi

        .align  7
core7_pass:
        //PRINT(cpu7_pass_msg)
        WRITE_TEST_STATUS(7, 4)
        TEST_FINISH(0x7)
        wfi

        .align  7
core8_pass:
        //PRINT(cpu8_pass_msg)
        WRITE_TEST_STATUS(8, 4)
        TEST_FINISH(0x8)
        wfi

        .align  7
core9_pass:
        //PRINT(cpu9_pass_msg)
        WRITE_TEST_STATUS(9, 4)
        TEST_FINISH(0x9)
        wfi

        .align  7
core10_pass:
        //PRINT(cpu10_pass_msg)
        WRITE_TEST_STATUS(10, 4)
        TEST_FINISH(0xa)
        wfi

        .align  7
core11_pass:
        //PRINT(cpu11_pass_msg)
        WRITE_TEST_STATUS(11, 4)
        TEST_FINISH(0xb)
        wfi

        .align  7
core12_pass:
        //PRINT(cpu12_pass_msg)
        WRITE_TEST_STATUS(12, 4)
        TEST_FINISH(0xc)
        wfi

        .align  7
core13_pass:
        //PRINT(cpu13_pass_msg)
        WRITE_TEST_STATUS(13, 4)
        TEST_FINISH(0xd)
        wfi

        .align  7
core14_pass:
        //PRINT(cpu14_pass_msg)
        WRITE_TEST_STATUS(14, 4)
        TEST_FINISH(0xe)
        wfi

        .align  7
core15_pass:
        //PRINT(cpu15_pass_msg)
        WRITE_TEST_STATUS(15, 4)
        TEST_FINISH(0xf)
        wfi

        .align  7
core0_fail:
        PRINT(cpu0_fail_msg)
        WRITE_TEST_STATUS(0, 8)
        TEST_FINISH(0x0)
        wfi

        .align  7
core1_fail:
        PRINT(cpu1_fail_msg)
        WRITE_TEST_STATUS(1, 8)
        TEST_FINISH(0x1)
        wfi

        .align  7
core2_fail:
        PRINT(cpu2_fail_msg)
        WRITE_TEST_STATUS(2, 8)
        TEST_FINISH(0x2)
        wfi

        .align  7
core3_fail:
        PRINT(cpu3_fail_msg)
        WRITE_TEST_STATUS(3, 8)
        TEST_FINISH(0x3)
        wfi

        .align  7
core4_fail:
        PRINT(cpu4_fail_msg)
        WRITE_TEST_STATUS(4, 8)
        TEST_FINISH(0x4)
        wfi

        .align  7
core5_fail:
        PRINT(cpu5_fail_msg)
        WRITE_TEST_STATUS(5, 8)
        TEST_FINISH(0x5)
        wfi

        .align  7
core6_fail:
        PRINT(cpu6_fail_msg)
        WRITE_TEST_STATUS(6, 8)
        TEST_FINISH(0x6)
        wfi

        .align  7
core7_fail:
        PRINT(cpu7_fail_msg)
        WRITE_TEST_STATUS(7, 8)
        TEST_FINISH(0x7)
        wfi

        .align  7
core8_fail:
        PRINT(cpu8_fail_msg)
        WRITE_TEST_STATUS(8, 8)
        TEST_FINISH(0x8)
        wfi

        .align  7
core9_fail:
        PRINT(cpu9_fail_msg)
        WRITE_TEST_STATUS(9, 8)
        TEST_FINISH(0x9)
        wfi

        .align  7
core10_fail:
        PRINT(cpu10_fail_msg)
        WRITE_TEST_STATUS(10, 8)
        TEST_FINISH(0xa)
        wfi

        .align  7
core11_fail:
        PRINT(cpu11_fail_msg)
        WRITE_TEST_STATUS(11, 8)
        TEST_FINISH(0xb)
        wfi

        .align  7
core12_fail:
        PRINT(cpu12_fail_msg)
        WRITE_TEST_STATUS(12, 8)
        TEST_FINISH(0xc)
        wfi

        .align  7
core13_fail:
        PRINT(cpu13_fail_msg)
        WRITE_TEST_STATUS(13, 8)
        TEST_FINISH(0xd)
        wfi

        .align  7
core14_fail:
        PRINT(cpu14_fail_msg)
        WRITE_TEST_STATUS(14, 8)
        TEST_FINISH(0xe)
        wfi

        .align  7
core15_fail:
        PRINT(cpu15_fail_msg)
        WRITE_TEST_STATUS(15, 8)
        TEST_FINISH(0xf)
        wfi

Sleep:
        la      s0,     print
        or      s0,     s0,     s10
        la      s1,     cpu_sleep_msg
        or      s1,     s1,     s10
        jalr    s0
        wfi

//--------------------------------------------------------------------------
// exception handler
//--------------------------------------------------------------------------

imc_default_mm_handler:
        csrr    t0,     mcause
        csrr    t1,     mstatus
        csrr    t2,     mepc
        csrr    t3,     mtval
        j       IMC_Fail

apc_default_mm_handler:
        csrr    t0,     mcause
        csrr    t1,     mstatus
        csrr    t2,     mepc
        csrr    t3,     mtval
        j       APC_Fail

apc_default_sm_handler:
        csrr    t0,     scause
        csrr    t1,     sstatus
        csrr    t2,     sepc
        csrr    t3,     stval
        j       APC_Fail

//--------------------------------------------------------------------------
// Data segment
//--------------------------------------------------------------------------

.align 5
boot_end_msg:
        .asciz "Boot end !!"

.align 5
imc_fail_msg:
        .asciz "IMC_Fail is executed !!"

.align 5
imc_pass_msg:
        .asciz "IMC_Pass is executed !!"

.align 5
cpu0_fail_msg:
        .asciz "CPU0_Fail is executed !!"

.align 5
cpu1_fail_msg:
        .asciz "CPU1_Fail is executed !!"

.align 5
cpu2_fail_msg:
        .asciz "CPU2_Fail is executed !!"

.align 5
cpu3_fail_msg:
        .asciz "CPU3_Fail is executed !!"

.align 5
cpu4_fail_msg:
        .asciz "CPU4_Fail is executed !!"

.align 5
cpu5_fail_msg:
        .asciz "CPU5_Fail is executed !!"

.align 5
cpu6_fail_msg:
        .asciz "CPU6_Fail is executed !!"

.align 5
cpu7_fail_msg:
        .asciz "CPU7_Fail is executed !!"

.align 5
cpu8_fail_msg:
        .asciz "CPU8_Fail is executed !!"

.align 5
cpu9_fail_msg:
        .asciz "CPU9_Fail is executed !!"

.align 5
cpu10_fail_msg:
        .asciz "CPU10_Fail is executed !!"

.align 5
cpu11_fail_msg:
        .asciz "CPU11_Fail is executed !!"

.align 5
cpu12_fail_msg:
        .asciz "CPU12_Fail is executed !!"

.align 5
cpu13_fail_msg:
        .asciz "CPU13_Fail is executed !!"

.align 5
cpu14_fail_msg:
        .asciz "CPU14_Fail is executed !!"

.align 5
cpu15_fail_msg:
        .asciz "CPU15_Fail is executed !!"

.align 5
cpu0_pass_msg:
        .asciz "CPU0_Pass is executed !!"

.align 5
cpu1_pass_msg:
        .asciz "CPU1_Pass is executed !!"

.align 5
cpu2_pass_msg:
        .asciz "CPU2_Pass is executed !!"

.align 5
cpu3_pass_msg:
        .asciz "CPU3_Pass is executed !!"

.align 5
cpu4_pass_msg:
        .asciz "CPU4_Pass is executed !!"

.align 5
cpu5_pass_msg:
        .asciz "CPU5_Pass is executed !!"

.align 5
cpu6_pass_msg:
        .asciz "CPU6_Pass is executed !!"

.align 5
cpu7_pass_msg:
        .asciz "CPU7_Pass is executed !!"

.align 5
cpu8_pass_msg:
        .asciz "CPU8_Pass is executed !!"

.align 5
cpu9_pass_msg:
        .asciz "CPU9_Pass is executed !!"

.align 5
cpu10_pass_msg:
        .asciz "CPU10_Pass is executed !!"

.align 5
cpu11_pass_msg:
        .asciz "CPU11_Pass is executed !!"

.align 5
cpu12_pass_msg:
        .asciz "CPU12_Pass is executed !!"

.align 5
cpu13_pass_msg:
        .asciz "CPU13_Pass is executed !!"

.align 5
cpu14_pass_msg:
        .asciz "CPU14_Pass is executed !!"

.align 5
cpu15_pass_msg:
        .asciz "CPU15_Pass is executed !!"

.align 5
cpu_sleep_msg:
        .asciz "Sleep is executed !!"

.align 5
dummy_msg:
        .asciz "Dummy is executed !!"
.align 5
