#include "test_macros.h"
#include "compliance_test.h"
#include "common_macro.S"

        .section .text.init
        .align  6
        .globl  _start

_start:
        nop

set_msg_csr:
	WRITE_TEST_ITEM(0,1,2)

        // just test core0 default
        WRITE_TEST_STATUS( 0, 2)    
        WRITE_TEST_STATUS( 1, 1)    
        WRITE_TEST_STATUS( 2, 1)    
        WRITE_TEST_STATUS( 3, 1)    
        WRITE_TEST_STATUS( 4, 1)    
        WRITE_TEST_STATUS( 5, 1)    
        WRITE_TEST_STATUS( 6, 1)    
        WRITE_TEST_STATUS( 7, 1)    
        WRITE_TEST_STATUS( 8, 1)    
        WRITE_TEST_STATUS( 9, 1)    
        WRITE_TEST_STATUS(10, 1)    
        WRITE_TEST_STATUS(11, 1)    
        WRITE_TEST_STATUS(12, 1)    
        WRITE_TEST_STATUS(13, 1)    
        WRITE_TEST_STATUS(14, 1)    
        WRITE_TEST_STATUS(15, 1)    

        // IMC donot test
        WRITE_TEST_STATUS(16, 1)    
imc_boot:
        nop

set_mtatus_fs:
        li      a0,     3<<13                                   // start to use a0
        csrs    mstatus,        a0                              // for some filed in mstatus is WPRI type, so not changing these fields, release a0

ini_gpr:
        addi    x1,     x0,     0
        addi    x2,     x0,     0
        addi    x3,     x0,     0
        addi    x4,     x0,     0
        addi    x5,     x0,     0
        addi    x6,     x0,     0
        addi    x7,     x0,     0
        addi    x8,     x0,     0
        addi    x9,     x0,     0
        addi    x10,    x0,     0
        addi    x11,    x0,     0
        addi    x12,    x0,     0
        addi    x13,    x0,     0
        addi    x14,    x0,     0
        addi    x15,    x0,     0
        addi    x16,    x0,     0
        addi    x17,    x0,     0
        addi    x18,    x0,     0
        addi    x19,    x0,     0
        addi    x20,    x0,     0
        addi    x21,    x0,     0
        addi    x22,    x0,     0
        addi    x23,    x0,     0
        addi    x24,    x0,     0
        addi    x25,    x0,     0
        addi    x26,    x0,     0
        addi    x27,    x0,     0
        addi    x28,    x0,     0
        addi    x29,    x0,     0
        addi    x30,    x0,     0
        addi    x31,    x0,     0

ini_fpr:
        fmv.d.x f0,     x0
        fmv.d.x f1,     x0
        fmv.d.x f2,     x0
        fmv.d.x f3,     x0
        fmv.d.x f4,     x0
        fmv.d.x f5,     x0
        fmv.d.x f6,     x0
        fmv.d.x f7,     x0
        fmv.d.x f8,     x0
        fmv.d.x f9,     x0
        fmv.d.x f10,    x0
        fmv.d.x f11,    x0
        fmv.d.x f12,    x0
        fmv.d.x f13,    x0
        fmv.d.x f14,    x0
        fmv.d.x f15,    x0
        fmv.d.x f16,    x0
        fmv.d.x f17,    x0
        fmv.d.x f18,    x0
        fmv.d.x f19,    x0
        fmv.d.x f20,    x0
        fmv.d.x f21,    x0
        fmv.d.x f22,    x0
        fmv.d.x f23,    x0
        fmv.d.x f24,    x0
        fmv.d.x f25,    x0
        fmv.d.x f26,    x0
        fmv.d.x f27,    x0
        fmv.d.x f28,    x0
        fmv.d.x f29,    x0
        fmv.d.x f30,    x0
        fmv.d.x f31,    x0

set_current_base_addr:
#ifdef CASE_IN_ROM0
        li      s10,    0xff7ff00000
#endif
#ifdef CASE_IN_ROM7
        li      s10,    0xff7ffe0000
#endif
#ifdef CASE_IN_RAM
        li      s10,    0xff60400000
#endif
#ifdef CASE_IN_DDR
        li      s10,    0x0
#endif
#ifdef CASE_IN_FLASH
        li      s10,    0xff68000000
#endif

set_default_handler:
        la      t0,     imc_default_mm_handler
        or      t0,     t0,     s10
        csrw    mtvec,  t0

check_BootMode:
        li      t0,     0xff60100000
        lw      t1,     0x4(t0)         // BootMode
        li      t2,     0
        beq     t1,     t2,     BootMode0
        li      t2,     1
        beq     t1,     t2,     BootMode1
        li      t2,     2
        beq     t1,     t2,     BootMode2
        li      t2,     3
        beq     t1,     t2,     BootMode3
        li      t2,     8
        beq     t1,     t2,     BootMode8
        li      t2,     9
        beq     t1,     t2,     BootMode9
        li      t2,     10
        beq     t1,     t2,     BootModeA

apc_boot:
        j       IMC_Pass

restart_cpu:
        li      t0,     0xff605ff400            // the last 4K in RAM + 1024
        lw      t1,     0x0(t0)                 // load the restart address
        jr      t1

BootMode0:
//      SD initial
#ifdef TEST_IN_DDR
//      Mode data from SD to DDR
#endif
#ifdef TEST_IN_RAM
//      Mode data from SD to RAM
#endif
        beqz    zero,   imc_boot_start

BootMode1:
//      SSI initial
#ifdef TEST_IN_DDR
//      Mode data from SSI to DDR
#endif
#ifdef TEST_IN_RAM
//      Mode data from SSI to RAM
#endif
        beqz    zero,   imc_boot_start

BootMode2:
//      SPI Flash initial
#ifdef TEST_IN_DDR
//      Mode data from SPI Flash to DDR
#endif
#ifdef TEST_IN_RAM
//      Mode data from SPI Flash to RAM
#endif
        beqz    zero,   imc_boot_start

BootMode3:
//      SPI Flash initial
#ifdef TEST_IN_DDR
//      Mode data from SPI Flash to DDR
#endif
#ifdef TEST_IN_RAM
//      Mode data from SPI Flash to RAM
#endif
        beqz    zero,   imc_boot_start

BootMode8:
//      SD initial
        j       imc_boot_start

BootMode9:
//      SSI initial
        j       imc_boot_start

BootModeA:
//      SPI Flash initial
        j       imc_boot_start

imc_boot_start:
        nop

//---->>>> pwrup_pull(SOC_PLL) start
pwrup_soc_pll:
        li      t0,     0xFF60000000                            // CRCNTL_BASE_ADDR + 0x00
        li      t1,     0x900000                                // {5'h0, 10'h90, 16'h0}
        sw      t1,     0x0(t0)                                 // SoC PLL

pw_soc_pll_cfg1:
        li      t1,     0x4104100                               // GEAR_SHIFT = 1; LOWFREQ = 0; VCO_MODE = 1; p = 1; r = 1
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_soc_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_soc_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_soc_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_soc_pll_gearshift:
        li      t2,     0x4000000                               // setp4: GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_soc_pll_enp_enr:
        li      t2,     0x1000000                               // step6: ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

soc_pll_delay:
        li      s1,     300
        jal     delay

soc_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   soc_pll_Lock
//<<<<---- pwrup_pll(SOC_PLL) end
        
//---->>>> pwrup_pll(DDR0_PLL) start
pwrup_ddr0_pll:                                                 // DDR PLL
        li      t0,     0xFF60000040                            // CRCNTL_BASE_ADDR + 0x40
        li      t1,     0x700000                                // {5'h0, 10'h70, 16'h0}
        sw      t1,     0x0(t0)                                 // DDR PLL

pw_ddr0_pll_cfg1:
        li      t1,     0x6104100                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 1 ; p = 1 ; r = 1
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_ddr0_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_ddr0_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_ddr0_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_ddr0_pll_gearshift:                                          // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_ddr0_pll_enp_enr:                                            // step 6
        li      t2,     0x1000000                               // ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

ddr0_pll_delay:
        li      s1,     300
        jal     delay

ddr0_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   ddr0_pll_Lock
//<<<<---- pwrup_pll(DDR0_PLL) end

//---->>>> pwrup_pll(DDR1_PLL) start
pwrup_ddr1_pll:                                                 // DDR PLL
        li      t0,     0xFF60000080                            // CRCNTL_BASE_ADDR + 0x80
        li      t1,     0x700000                                // {5'h0, 10'h70, 16'h0}
        sw      t1,     0x0(t0)                                 // DDR PLL

pw_ddr1_pll_cfg1:
        li      t1,     0x6104100                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 1 ; p = 1 ; r = 1
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_ddr1_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_ddr1_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_ddr1_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_ddr1_pll_gearshift:                                          // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_ddr1_pll_enp_enr:                                            // step 6
        li      t2,     0x1000000                               // ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

ddr1_pll_delay:
        li      s1,     300
        jal     delay

ddr1_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   ddr1_pll_Lock
//<<<<---- pwrup_pll(DDR1_PLL) end

//---->>>> pwrup_pll(PCIE_PLL) start
pwrup_pcie_pll:                                                 // PCIE PLL
        li      t0,     0xFF600000C0                            // CRCNTL_BASE_ADDR + 0xC0
        li      t1,     0x700000                                // {5'h0, 10'h70, 16'h0}
        sw      t1,     0x0(t0)                                 // DDR PLL

pw_pcie_pll_cfg1:
        li      t1,     0x61041dd                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 1 ; p = 1 ; r = 1 ; divvcop/divvcor = d 
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_pcie_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_pcie_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_pcie_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_pcie_pll_gearshift:                                          // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_pcie_pll_enp_enr:                                            // step 6
        li      t2,     0x1000000                               // ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

pcie_pll_delay:
        li      s1,     300
        jal     delay

pcie_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   pcie_pll_Lock
//<<<<---- pwrup_pll(PCIE_PLL) end

        // clock enable
        li      t1,     0xffffffff
        li      t0,     0xFF60000140
        sw      t1,     0x0(t0)
        sw      t1,     0x4(t0)
        sw      t1,     0x8(t0)

sw_rst:
        li      t0,     0xFF60000130
        li      t1,     0x6
        sw      t1,     0x0(t0)
        sw      zero,   0x4(t0)
        sw      zero,   0x8(t0)

//---->>>> pwrup_pll(COH_PLL); start
pwrup_coh_pll_coh:                                              // COH PLL
        li      t0,     0xFF02100000                            // COHFAB_CFG_BASE_ADDR
        li      t1,     0x900000                                // {5'h0, 10'h90, 16'h0}, 0x90 = 144
        sw      t1,     0x0(t0)                                 // COH PLL

pw_coh_pll_cfg1:
        li      t1,     0x4100000                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 1
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_coh_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_coh_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_coh_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_coh_pll_gearshift:                                           // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_coh_pll_enp_enr:                                             // step 6
        li      t2,     0x1000000                               // ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

coh_pll_delay:
        li      s1,     300
        jal     delay

        //li      t0,     0x0210000c                            // step 7
coh_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   coh_pll_Lock
//<<<<---- pwrup_pll(COH_PLL); end

// imc_wr((`COHFAB_CFG_BASE_ADDR + 'h18),32'h0); // clock select & clock on
coh_clk_rst:
        //li      t0,     0x02100040
        li      t1,     2
        sw      t1,     0x40(t0)

//---->>>> pwrup_cluster(0); start
pwrup_c0:
        nop

// imc_wr((base_addr+'h40), 32'h3); // reset on 
pwrc0_reset_on:
        li      t0,     0xFF01000000
        li      t1,     0x3FFFF
        sw      t1,     0x50(t0)

// #400
pwrc0_d0:
        li      s1,     10
        jal     delay

pwrc0_boot_address:
        //li      t0,     0x01000000  
        li      t1,     0x60400000  // reset_address_lo
        sw      t1,     0x60(t0)
        sw      t1,     0x68(t0)
        li      t1,     0xFF        // reset_address_hi
        sw      t1,     0x64(t0)
        sw      t1,     0x6C(t0)

//<<<<---- pwrup_cluster(0); end

//---->>>> pwrup_cluster(1); start
pwrup_c1:
        nop

// imc_wr((base_addr+'h40), 32'h3); // reset on
pwrc1_reset_on:
        li      t0,     0xFF01100000
        li      t1,     0x3FFFF
        sw      t1,     0x50(t0)

// #400
pwrc1_d0:
        li      s1,     10
        jal     delay

pwrc1_boot_address:
        //li      t0,     0x01100040  // reset_address_lo
        li      t1,     0x60400000  // reset_address_lo
        sw      t1,     0x60(t0)
        sw      t1,     0x68(t0)
        li      t1,     0xFF        // reset_address_hi
        sw      t1,     0x64(t0)
        sw      t1,     0x6C(t0)

//<<<<---- pwrup_cluster(1); end

//---->>>> pwrup_cluster(2); start
pwrup_c2:
        nop

// imc_wr((base_addr+'h40), 32'h3); // reset on
pwrc2_reset_on:
        li      t0,     0xFF01200000
        li      t1,     0x3FFFF
        sw      t1,     0x50(t0)

// imc_wr((base_addr+'h40), 32'hF); // clock on
pwrc2_boot_address:
        //li      t0,     0x01200040
        li      t1,     0x60400000  // reset_address_lo
        sw      t1,     0x60(t0)
        sw      t1,     0x68(t0)
        li      t1,     0xFF        // reset_address_hi
        sw      t1,     0x64(t0)
        sw      t1,     0x6C(t0)

//<<<<---- pwrup_cluster(2); end

//---->>>> pwrup_cluster(3); start
pwrup_c3:
        nop

// imc_wr((base_addr+'h40), 32'h3); // reset on
pwrc3_reset_on:
        li      t0,     0xFF01300000
        li      t1,     0x3FFFF
        sw      t1,     0x50(t0)                                 // pwr_on

pwrc3_boot_address:
        //li      t0,     0x01300040
        li      t1,     0x60400000  // reset_address_lo
        sw      t1,     0x60(t0)
        sw      t1,     0x68(t0)
        li      t1,     0xFF        // reset_address_hi
        sw      t1,     0x64(t0)
        sw      t1,     0x6C(t0)

//<<<<---- pwrup_cluster(3); end

//---->>>> pwrup_pll(CL0_PLL); start
pwrup_cl0_pll:                                                  // CL0 PLL
        li      t0,     0xFF01000000                            // CL0_PLL_ADDR + 0x10
        li      t1,     0xb80000                                // {5'h0, 10'hb8, 16'h0}, 10'd184 = 10'hb8
        sw      t1,     0x0(t0)                                 // other PLL

pw_cl0_pll_cfg1:
        li      t1,     0x6000000                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 0
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_cl0_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_cl0_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_cl0_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_cl0_pll_gearshift:                                           // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_cl0_pll_enp_enr:                                             // step 6
        li      t2,     0x1000000                               // ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

cl0_pll_delay:
        li      s1,     300
        jal     delay

cl0_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   cl0_pll_Lock
//<<<<---- pwrup_pll(CL0_PLL); end
        
//---->>>> pwrup_pll(CL1_PLL); start
pwrup_cl1_pll:                                                  // CL0 PLL
        li      t0,     0xFF01100000                            // CRCNTL_BASE_ADDR + 0x10
        li      t1,     0xb80000                                // {5'h0, 10'h90, 16'h0}, 10'd144 = 10'h90
        sw      t1,     0x0(t0)                                 // other PLL

pw_cl1_pll_cfg1:
        li      t1,     0x6000000                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 1
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_cl1_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_cl1_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_cl1_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_cl1_pll_gearshift:                                           // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_cl1_pll_enp_enr:                                             // step 6
        li      t2,     0x1000000                               // ENP/R
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

cl1_pll_delay:
        li      s1,     300
        jal     delay

cl1_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   cl1_pll_Lock
//<<<<---- pwrup_pll(CL1_PLL); end
        
//---->>>> pwrup_pll(CL2_PLL); start
pwrup_cl2_pll:                                                  // CL0 PLL
        li      t0,     0xFF01200000                            // CRCNTL_BASE_ADDR + 0x10
        li      t1,     0xb80000                                // {5'h0, 10'h90, 16'h0}, 10'd144 = 10'h90
        sw      t1,     0x0(t0)                                 // other PLL

pw_cl2_pll_cfg1:
        li      t1,     0x6000000                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 1
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_cl2_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_cl2_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_cl2_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_cl2_pll_gearshift:                                           // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_cl2_pll_enp_enr:                                             // step 6
        li      t2,     0x1000000                               // ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

cl2_pll_delay:
        li      s1,     300
        jal     delay

cl2_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   cl2_pll_Lock
//<<<<---- pwrup_pll(CL2_PLL); end
        
//---->>>> pwrup_pll(CL3_PLL); start
pwrup_cl3_pll:                                                  // CL0 PLL
        li      t0,     0xFF01300000                            // CRCNTL_BASE_ADDR + 0x10
        li      t1,     0xb80000                                // {5'h0, 10'h90, 16'h0}, 10'd144 = 10'h90
        sw      t1,     0x0(t0)                                 // other PLL

pw_cl3_pll_cfg1:
        li      t1,     0x6000000                               // GEAR_SHIFT = 1; LOWFREQ = 1; VCO_MODE = 1
        sw      t1,     0x4(t0)                                 // pll_cfg1

pw_cl3_pll_test_rst_n:
        li      t2,     0x20000000                              // TEST_RESET = 1;
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 1: test_rst_n

pw_cl3_pll_pwron_rst:
        li      t2,     0x10000000                              // PWRON = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // Step 2: pwron & rst_n

pw_cl3_pll_reset:
        li      t2,     0x8000000                               // RESET = 1
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)                                 // 

pw_cl3_pll_gearshift:                                           // step 4
        li      t2,     0x4000000                               // GEAR_SHIFT = 0
        not     t2,     t2
        and     t1,     t1,     t2
        sw      t1,     0x4(t0)

pw_cl3_pll_enp_enr:                                             // step 6
        li      t2,     0x1000000                               // ENP
        or      t1,     t1,     t2
        sw      t1,     0x4(t0)

cl3_pll_delay:
        li      s1,     300
        jal     delay

cl3_pll_Lock:
        lw      t1,     0xC(t0)
        andi    t1,     t1,     1
        beq     t1,     zero,   cl3_pll_Lock
//<<<<---- pwrup_pll(CL3_PLL); end
        
// imc_wr((`CL0_CFG_BASE_ADDR+'h18), 32'h0); // clock select & clock on
cl0_clk:
        li      t0,     0xFF01000040
        li      t1,     2
        sw      t1,     0x0(t0)

cl1_clk:
        li      t0,     0xFF01100040
        li      t1,     2
        sw      t1,     0x0(t0)

cl2_clk:
        li      t0,     0xFF01200040
        li      t1,     2
        sw      t1,     0x0(t0)

cl3_clk:
        li      t0,     0xFF01300040
        li      t1,     2
        sw      t1,     0x0(t0)

sel_pll_clk:
        // clock select
        li      t0,     0xFF60000150
        sw      zero,   0x0(t0)

delay_before_reset_cluster0_cpu0:
        li      s1,     300
        jal     delay
        j       boot_end

boot_end:
        la      s1,     boot_end_msg
        or      s1,     s1,     s10
        jal     print
	li	sp,	0xff60410000
	jal	pci_platform_init
	j	.

go_to_DDR_or_RAM:
#ifdef TEST_IN_DDR
        jr      zero
#endif
#ifdef TEST_IN_RAM
        li      t1,     0xff60400000
        jr      t1
#endif
        nop
imc_default_end:
        WRITE_TEST_STATUS( 0, 1)    
        WRITE_TEST_STATUS( 1, 1)    
        WRITE_TEST_STATUS( 2, 1)    
        WRITE_TEST_STATUS( 3, 1)    
        WRITE_TEST_STATUS( 4, 1)    
        WRITE_TEST_STATUS( 5, 1)    
        WRITE_TEST_STATUS( 6, 1)    
        WRITE_TEST_STATUS( 7, 1)    
        WRITE_TEST_STATUS( 8, 1)    
        WRITE_TEST_STATUS( 9, 1)    
        WRITE_TEST_STATUS(10, 1)    
        WRITE_TEST_STATUS(11, 1)    
        WRITE_TEST_STATUS(12, 1)    
        WRITE_TEST_STATUS(13, 1)    
        WRITE_TEST_STATUS(14, 1)    
        WRITE_TEST_STATUS(15, 1)
	j .    
        //j       IMC_Pass

//--------------------------------------------------------------------------
// common code 
//--------------------------------------------------------------------------

#include "common_func.S"

