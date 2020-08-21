#ifndef __GLUE_H__
#define __GLUE_H__

#ifndef SDFIRM
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#endif

#ifdef SDFIRM
#include <target/list.h>
#include <target/delay.h>
#include <driver/pci_regs.h>
#include <asm/io.h>
#else
#include "cfg.h"
#include "list.h"
#include "pci_regs.h"
#endif

#ifndef TEST
#define readl(addr) __raw_readl(addr)
#define writel(addr, data) __raw_writel(data, addr)
#else
static inline void writel(uint32_t addr, uint32_t data){}
static inline uint32_t readl(uint32_t addr){}
#endif

#if !defined(SDFIRM) && !defined(TEST)
static inline void __raw_writeb(uint8_t v, uint32_t a)
{
        asm volatile("sb %0, 0(%1)" : : "r"(v), "r"(a));
}
static inline void __raw_writew(uint16_t v, uint32_t a)
{
        asm volatile("sh %0, 0(%1)" : : "r" (v), "r" (a));
}
static inline void __raw_writel(uint32_t v, uint64_t a)
{
        asm volatile("sw %0, 0(%1)" : : "r" (v), "r" (a));
}
static inline void __raw_writeq(uint32_t v, uint64_t a)
{
        asm volatile("sd %0, 0(%1)" : : "r" (v), "r" (a));
}
static inline uint8_t __raw_readb(const uint32_t a)
{
        uint8_t v;

        asm volatile("lb %0, 0(%1)" : "=r" (v) : "r" (a));
            return v;
}
static inline uint16_t __raw_readw(const uint32_t a)
{
        uint16_t v;

        asm volatile("lh %0, 0(%1)" : "=r" (v) : "r" (a));
            return v;
}
static inline uint32_t __raw_readl(const uint64_t a)
{
        uint32_t v;

        asm volatile("lw %0, 0(%1)" : "=r" (v) : "r" (a));
            return v;
}
static inline uint32_t __raw_readq(const uint64_t a)
{
        uint32_t v;

        asm volatile("ld %0, 0(%1)" : "=r" (v) : "r" (a));
            return v;
}
#endif

#ifdef TEST
#define udelay(x)       usleep(x)
#define mdelay(x)       usleep(1000*x)
#define usleep_range(x, y)  usleep(1000*(x + y)/2)  
#endif

#ifdef CONFIG_TESTCHIP
#ifndef TESTCHIP
#define TESTCHIP
#endif
#endif

#define BIT(nr)			(UL(1) << (nr))
#define BIT_ULL(nr)		(ULL(1) << (nr))

#define offset(type, member)    ((size_t)&((type *)0)->member)
#define container_of(ptr, type, member) ({              \
        void *tmp = (void *)ptr;            \
        (type *)(tmp - offset(type, member));})

#define __bf_shf(x) (__builtin_ffsll(x) - 1)
#define FIELD_PREP(_mask, _val)						\
	({								\
		((typeof(_mask))(_val) << __bf_shf(_mask)) & (_mask);	\
	})

#ifndef SDFIRM
typedef unsigned long size_t;

#define UL(x)   x##UL
#define ULL(x)  x##ULL

#define BIT_MASK(nr)		(UL(1) << ((nr) % BITS_PER_LONG))
#define BIT_WORD(nr)		((nr) / BITS_PER_LONG)
#define BIT_ULL_MASK(nr)	(ULL(1) << ((nr) % BITS_PER_LONG_LONG))
#define BIT_ULL_WORD(nr)	((nr) / BITS_PER_LONG_LONG)
#define BITS_PER_BYTE		8
#define BITS_PER_LONG       64
#define BITS_PER_LONG_LONG  64

#define IS_ALIGNED(x, a)    ((x & (typeof(x))(a - 1)) == 0) 

#define GENMASK(h, l) \
	(((~UL(0)) - (UL(1) << (l)) + 1) & \
	 (~UL(0) >> (BITS_PER_LONG - 1 - (h))))

#define GENMASK_ULL(h, l) \
	(((~ULL(0)) - (ULL(1) << (l)) + 1) & \
	 (~ULL(0) >> (BITS_PER_LONG_LONG - 1 - (h))))

#endif

#define upper_32_bits(n) ((uint32_t)(((n) >> 16) >> 16))
#define lower_32_bits(n) ((uint32_t)(n))

#define dev_dbg(dev, fmt, ...)      printf(fmt, ##__VA_ARGS__)
#define dev_info(dev, fmt, ...)     printf(fmt, ##__VA_ARGS__)
#define dev_err(dev, fmt, ...)      printf(fmt, ##__VA_ARGS__)

#ifdef STANDALONE
#define CRCNTL_BASE             ULL(0xFF60000000)
#define CRCNTL_REG(offset)      (CRCNTL_BASE + (offset))
#define SW_RST_CFG0             CRCNTL_REG(0x130)    

#define pcie0_aclk              0x5
#define pcie0_pclk              0x6
#define pcie0_aux_clk           0x7
#define pcie0_ref_clk           0x8 
#define srst_pcie0              0x2 
#define srst_pcie0_por          0x1

int printf(const char *format, ...);
void clock_init(void);
#endif

#endif
