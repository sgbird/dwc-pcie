#ifndef __GLUE_H__
#define __GLUE_H__

#include <stdbool.h>

typedef unsigned long size_t;

#define UL(x)   x##UL
#define ULL(x)  x##ULL

#define BIT(nr)			(UL(1) << (nr))
#define BIT_ULL(nr)		(ULL(1) << (nr))
#define BIT_MASK(nr)		(UL(1) << ((nr) % BITS_PER_LONG))
#define BIT_WORD(nr)		((nr) / BITS_PER_LONG)
#define BIT_ULL_MASK(nr)	(ULL(1) << ((nr) % BITS_PER_LONG_LONG))
#define BIT_ULL_WORD(nr)	((nr) / BITS_PER_LONG_LONG)
#define BITS_PER_BYTE		8
#define BITS_PER_LONG       32
#define BITS_PER_LONG_LONG  64

#define IS_ALIGNED(x, a)    ((x & (typeof(x))(a - 1)) == 0) 

#define GENMASK(h, l) \
	(((~UL(0)) - (UL(1) << (l)) + 1) & \
	 (~UL(0) >> (BITS_PER_LONG - 1 - (h))))

#define GENMASK_ULL(h, l) \
	(((~ULL(0)) - (ULL(1) << (l)) + 1) & \
	 (~ULL(0) >> (BITS_PER_LONG_LONG - 1 - (h))))

#define __bf_shf(x) (__builtin_ffsll(x) - 1)
#define FIELD_PREP(_mask, _val)						\
	({								\
		((typeof(_mask))(_val) << __bf_shf(_mask)) & (_mask);	\
	})

#define offset(type, member)    ((size_t)&((type *)0)->member)
#define container_of(ptr, type, member) ({              \
        void *tmp = (void *)ptr;            \
        (type *)(tmp - offset(type, member));})

#define upper_32_bits(n) ((uint32_t)(((n) >> 16) >> 16))
#define lower_32_bits(n) ((uint32_t)(n))

#define dev_dbg(dev, fmt, ...)      printf(fmt, ##__VA_ARGS__)
#define dev_info(dev, fmt, ...)     printf(fmt, ##__VA_ARGS__)
#define dev_err(dev, fmt, ...)      printf(fmt, ##__VA_ARGS__)

#ifdef TEST
#define mdelay(x)       usleep(1000*x)
#define usleep_range(x, y)  usleep(1000*(x + y)/2)  
#endif



#endif
