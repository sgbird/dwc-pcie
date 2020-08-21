// RISC-V Compliance Test Header File
// Copyright (c) 2017, Codasip Ltd. All Rights Reserved.
// See LICENSE for license details.
//
// Description: Common header file for RV32I tests

#ifndef _COMPLIANCE_TEST_H
#define _COMPLIANCE_TEST_H

#include "riscv_test.h"

//-----------------------------------------------------------------------
// RV Compliance Macros
//-----------------------------------------------------------------------

#define RV_COMPLIANCE_HALT                                      \
        RVTEST_PASS                                             \

#define RV_COMPLIANCE_RV32M                                     \
        RVTEST_RV32M                                            \

#define RV_COMPLIANCE_CODE_BEGIN                                \
        RVTEST_CODE_BEGIN                                       \

#define RV_COMPLIANCE_CODE_END                                  \
fail:                                                           \
        jal     test_section_end;                               \
        li      t0,     0x13000000;                             \
        li      t1,     8;                                      \
        sw      t1,     0x0(t0);                                \
        RV_COMPLIANCE_HALT;                                     \
test_section_end:                                               \
        li      t0,     50;                                     \
wait_simv_end:                                                  \
        addi    t0,     t0,     -1;                             \
        bnez    t0,     wait_simv_end;                          \
        ret;                                                    \
pass:                                                           \
        jal     test_section_end;                               \
        li      t0,     0x13000000;                             \
        li      t1,     4;                                      \
        sw      t1,     0x0(t0);                                \
        RV_COMPLIANCE_HALT;                                     \
        RVTEST_CODE_END                                         \

#define RV_COMPLIANCE_DATA_BEGIN                                \
        RVTEST_DATA_BEGIN                                       \

#define RV_COMPLIANCE_DATA_END                                  \
        RVTEST_DATA_END                                         \

#endif
