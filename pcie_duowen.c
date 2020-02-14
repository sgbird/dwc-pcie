#include "pcie_duowen.h"

#ifdef TEST
void writel(uint32_t addr, uint32_t data){}
uint32_t readl(uint32_t addr){}
#endif


struct duowen_pcie_subsystem pcie_subsystem;

struct dw_pcie controllers[] = 
{
    // X16
    {
        .axi_dbi_port = AXI_DBI_PORT_X16,
        .dbi_base = DBI_BASE_X16,
    },

    // X8
    {
        .axi_dbi_port = AXI_DBI_PORT_X8,
        .dbi_base = DBI_BASE_X8,
    },

    // X4_0
    {
        .axi_dbi_port = AXI_DBI_PORT_X4_0,
        .dbi_base = DBI_BASE_X4_0,
    },

    //X4_1
    {
        .axi_dbi_port = AXI_DBI_PORT_X4_1,
        .dbi_base = DBI_BASE_X4_1,
    },
};

uint32_t read_apb(uint32_t addr, uint8_t port)
{
    uint32_t data;
#ifdef IPBENCH
    apb_read_c(addr, &data, port);
#else
    data = readl(addr);
#endif
    printf("ReadAPB: addr: 0x%08x; data: 0x%08x, port: %d\n", addr, data, port);
    return data;
}

void write_apb(uint32_t addr, uint32_t data, uint8_t port)
{
    printf("WriteAPB: addr: 0x%08x; data: 0x%08x, port: %d\n", addr, data, port);
#ifdef IPBENCH
    apb_write_c(addr, data, port);
#else
    writel(addr, data);
#endif
}

static uint8_t duowen_get_link_mode(struct duowen_pcie_subsystem *pcie_subsystem)
{
    return DEFAULT_LINK_MODE;
}

void reset_init(struct duowen_pcie_subsystem *pcie_subsystem)
{
    uint32_t base = pcie_subsystem->cfg_apb[SUBSYS];
    uint8_t port = APB_PORT_SUBSYS;

    write_apb((base + RESET_PHY), 0x0, port);

    write_apb((base + RESET_CORE_X16), 0xff, port);
    write_apb((base + RESET_CORE_X8), 0xff, port);
    write_apb((base + RESET_CORE_X4_0), 0xff, port);
    write_apb((base + RESET_CORE_X4_1), 0xff, port);

    write_apb((base + RESET_PHY), 0xff, port);
}

static void subsys_link_init_pre(struct duowen_pcie_subsystem *pcie_subsystem)
{
    uint32_t base = pcie_subsystem->cfg_apb[SUBSYS];
    struct dw_pcie *controller = pcie_subsystem->controller;
    uint8_t port = APB_PORT_SUBSYS;
    uint8_t link_mode = pcie_subsystem->link_mode;

    //assert(link_mode != LINK_MODE_INVALID);

    switch (link_mode) {
    case LINK_MODE_4_4_4_4:
        (controller + X16)->lane_num = 4;
        (controller + X8)->lane_num = 4;
        (controller + X4_0)->lane_num = 4;
        (controller + X4_1)->lane_num = 4;

        (controller + X16)->active = true;
        (controller + X8)->active = true;
        (controller + X4_0)->active = true;
        (controller + X4_1)->active = true;

        (controller + X16)->order = 0;
        (controller + X8)->order = 1;
        (controller + X4_0)->order = 2;
        (controller + X4_1)->order = 3;
        break;
    case LINK_MODE_8_4_0_4:
        (controller + X16)->lane_num = 8;
        (controller + X8)->lane_num = 4;
        (controller + X4_0)->lane_num = 0;
        (controller + X4_1)->lane_num = 4;

        (controller + X16)->active = true;
        (controller + X8)->active = true;
        (controller + X4_0)->active = false;
        (controller + X4_1)->active = true;

        (controller + X16)->order = 0;
        (controller + X8)->order = 1;
        (controller + X4_0)->order = 0xff;
        (controller + X4_1)->order = 2;
        break;
    case LINK_MODE_8_8_0_0:
        (controller + X16)->lane_num = 8;
        (controller + X8)->lane_num = 8;
        (controller + X4_0)->lane_num = 0;
        (controller + X4_1)->lane_num = 0;

        (controller + X16)->active = true;
        (controller + X8)->active = true;
        (controller + X4_0)->active = false;
        (controller + X4_1)->active = false;

        (controller + X16)->order = 0;
        (controller + X8)->order = 1;
        (controller + X4_0)->order = 0xff;
        (controller + X4_1)->order = 0xff;
        break;
    case LINK_MODE_16_0_0_0:
        (controller + X16)->lane_num = 16;
        (controller + X8)->lane_num = 0;
        (controller + X4_0)->lane_num = 0;
        (controller + X4_1)->lane_num = 0;

        (controller + X16)->active = true;
        (controller + X8)->active = false;
        (controller + X4_0)->active = false;
        (controller + X4_1)->active = false;

        (controller + X16)->order = 0;
        (controller + X8)->order = 0xff;
        (controller + X4_0)->order = 0xff;
        (controller + X4_1)->order = 0xff;
        break;
    }

    write_apb((base + SUBSYS_CONTROL), link_mode, port);   
}

static void subsys_link_init_post(struct duowen_pcie_subsystem *pcie_subsystem)
{

} 

void instance_subsystem(struct duowen_pcie_subsystem *pcie_subsystem)
{
    memset(pcie_subsystem, 0, sizeof(pcie_subsystem));

    pcie_subsystem->cfg_apb[X16] = APB_X16;
    pcie_subsystem->cfg_apb[X8] = APB_X8;
    pcie_subsystem->cfg_apb[X4_0] = APB_X4_0;
    pcie_subsystem->cfg_apb[X4_1] = APB_X4_1;
    pcie_subsystem->cfg_apb[SUBSYS] = APB_SUBSYS;

    pcie_subsystem->link_mode = duowen_get_link_mode(pcie_subsystem);
    //init_controller
    pcie_subsystem->controller = &controllers[0];
}

void init_duowen_pcie_subsystem(void)
{
    struct duowen_pcie_subsystem *pcie_subsys;
    struct dw_pcie *controller;
    int i;

    pcie_subsys = &pcie_subsystem;
    instance_subsystem(pcie_subsys);

    //clock_init();
    reset_init(pcie_subsys);
    subsys_link_init_pre(pcie_subsys);
    
    controller = pcie_subsys->controller;
    for(i = 0; i < sizeof(controllers)/sizeof(struct dw_pcie); i++) {
        dw_pcie_setup_rc(&((controller + i)->pp));
    }
}
