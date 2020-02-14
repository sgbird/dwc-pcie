#include "pcie-designware.h"

#define X16         0
#define X8          1
#define X4_0        2
#define X4_1        3
#define SUBSYS      4

#define APB_X16         0
#define APB_X8          0
#define APB_X4_0        0
#define APB_X4_1        0
#define APB_SUBSYS      0

#define APB_PORT_X16                0x4
#define APB_PORT_X8                 0x5
#define APB_PORT_X4_0               0x6
#define APB_PORT_X4_1               0x7
#define APB_PORT_SUBSYS             0x8

#define AXI_DBI_PORT_X16            0x0
#define AXI_DBI_PORT_X8             0x1
#define AXI_DBI_PORT_X4_0           0x2
#define AXI_DBI_PORT_X4_1           0x3

#define RESET_CORE_X16              0x0
#define RESET_CORE_X8               0x4
#define RESET_CORE_X4_0             0x8
#define RESET_CORE_X4_1             0xC
#define RESET_PHY                   0x10
#define SUBSYS_CONTROL              0x14

#define DBI_BASE_X16                0x0
#define DBI_BASE_X8                 0x0
#define DBI_BASE_X4_0               0x0
#define DBI_BASE_X4_1               0x0

#define LINK_MODE_4_4_4_4           0x0
#define LINK_MODE_8_4_0_4           0x1
#define LINK_MODE_8_8_0_0           0x2
#define LINK_MODE_16_0_0_0          0x3
#define LINK_MODE_INVALID           0xff
#define DEFAULT_LINK_MODE           LINK_MODE_16_0_0_0


#ifdef IPBENCH
void apb_read_c(uint32_t addr, uint32_t *data, int port);
void apb_write_c(uint32_t addr, uint32_t data, int port);
#endif

void init_duowen_pcie_subsystem(void);


struct duowen_pcie_subsystem
{
    uint32_t cfg_apb[5];
    uint8_t link_mode;

#ifdef IPBENCH
    //uint8_t port_
#endif

    struct dw_pcie *controller;

    //uint8_t (* get_link_mode)(struct duowen_pcie_subsystem *pcie_subsystem);
    //uint32_t (* apb_read)(uint64_t *addr);
    //void (* apb_write)(uint64_t *addr, uint32_t val);
};
