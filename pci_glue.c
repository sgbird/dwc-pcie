#include "pci_glue.h"

#ifdef STANDALONE
int printf(const char *format, ...){};
void udelay(uint32_t time){};
void* memset(void* dst,int val, size_t count)
{
    void* ret = dst;
    while(count--)
    {
        *(char*)dst = (char)val;
        dst = (char*)dst + 1;
    }
    return ret;
}

void clk_enable(uint8_t num)
{
    uint32_t var;

    if (num > 2)
        return;

    var = readl(SW_RST_CFG0);
    var &= ~(1 << num);
    writel(SW_RST_CFG0, var);
}
#endif
