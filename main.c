#include <stdio.h>
#include "pcie-designware.h"
#include "glue.h"
#include "cfg.h"

#ifdef TEST
static uint32_t readl(void *addr){return 0;}
static uint32_t readw(void *addr){return 0;}
static uint32_t readb(void *addr){return 0;}

static void writeb(uint8_t val, void *addr){}
static void writew(uint16_t val, void *addr){}
static void writel(uint32_t val, void *addr){}
#endif

int dw_pcie_read(void  *addr, int size, uint32_t *val)
{
	if (!IS_ALIGNED((uintptr_t)addr, size)) {
		*val = 0;
		return PCIBIOS_BAD_REGISTER_NUMBER;
	}

	if (size == 4) {
		*val = readl(addr);
	} else if (size == 2) {
		*val = readw(addr);
	} else if (size == 1) {
		*val = readb(addr);
	} else {
		*val = 0;
		return PCIBIOS_BAD_REGISTER_NUMBER;
	}

	return PCIBIOS_SUCCESSFUL;
}

int dw_pcie_write(void  *addr, int size, uint32_t val)
{
	if (!IS_ALIGNED((uintptr_t)addr, size))
		return PCIBIOS_BAD_REGISTER_NUMBER;

	if (size == 4)
		writel(val, addr);
	else if (size == 2)
		writew(val, addr);
	else if (size == 1)
		writeb(val, addr);
	else
		return PCIBIOS_BAD_REGISTER_NUMBER;

	return PCIBIOS_SUCCESSFUL;
}

uint32_t dw_pcie_read_dbi(struct dw_pcie *pci, uint32_t reg, size_t size)
{
	int ret;
	uint32_t val;

	if (pci->ops->read_dbi)
		return pci->ops->read_dbi(pci, pci->dbi_base, reg, size);

	ret = dw_pcie_read(pci->dbi_base + reg, size, &val);
	if (ret)
		dev_err(pci->dev, "Read DBI address failed\n");

	return val;
}

void dw_pcie_write_dbi(struct dw_pcie *pci, uint32_t reg, size_t size, uint32_t val)
{
	int ret;

	if (pci->ops->write_dbi) {
		pci->ops->write_dbi(pci, pci->dbi_base, reg, size, val);
		return;
	}

	ret = dw_pcie_write(pci->dbi_base + reg, size, val);
	if (ret)
		dev_err(pci->dev, "Write DBI address failed\n");
}

uint32_t dw_pcie_read_dbi2(struct dw_pcie *pci, uint32_t reg, size_t size)
{
	int ret;
	uint32_t val;

	if (pci->ops->read_dbi2)
		return pci->ops->read_dbi2(pci, pci->dbi_base2, reg, size);

	ret = dw_pcie_read(pci->dbi_base2 + reg, size, &val);
	if (ret)
		dev_err(pci->dev, "read DBI address failed\n");

	return val;
}

void dw_pcie_write_dbi2(struct dw_pcie *pci, uint32_t reg, size_t size, uint32_t val)
{
	int ret;

	if (pci->ops->write_dbi2) {
		pci->ops->write_dbi2(pci, pci->dbi_base2, reg, size, val);
		return;
	}

	ret = dw_pcie_write(pci->dbi_base2 + reg, size, val);
	if (ret)
		dev_err(pci->dev, "write DBI address failed\n");
}

uint32_t dw_pcie_read_atu(struct dw_pcie *pci, uint32_t reg, size_t size)
{
	int ret;
	uint32_t val;

	if (pci->ops->read_dbi)
		return pci->ops->read_dbi(pci, pci->atu_base, reg, size);

	ret = dw_pcie_read(pci->atu_base + reg, size, &val);
	if (ret)
		dev_err(pci->dev, "Read ATU address failed\n");

	return val;
}

void dw_pcie_write_atu(struct dw_pcie *pci, uint32_t reg, size_t size, uint32_t val)
{
	int ret;

	if (pci->ops->write_dbi) {
		pci->ops->write_dbi(pci, pci->atu_base, reg, size, val);
		return;
	}

	ret = dw_pcie_write(pci->atu_base + reg, size, val);
	if (ret)
		dev_err(pci->dev, "Write ATU address failed\n");
}

static uint32_t dw_pcie_readl_ob_unroll(struct dw_pcie *pci, uint32_t index, uint32_t reg)
{
	uint32_t offset = PCIE_GET_ATU_OUTB_UNR_REG_OFFSET(index);

	return dw_pcie_readl_atu(pci, offset + reg);
}

static void dw_pcie_writel_ob_unroll(struct dw_pcie *pci, uint32_t index, uint32_t reg,
				     uint32_t val)
{
	uint32_t offset = PCIE_GET_ATU_OUTB_UNR_REG_OFFSET(index);

	dw_pcie_writel_atu(pci, offset + reg, val);
}

static void dw_pcie_prog_outbound_atu_unroll(struct dw_pcie *pci, int index,
					     int type, uint64_t cpu_addr,
					     uint64_t pci_addr, uint32_t size)
{
	uint32_t retries, val;

	dw_pcie_writel_ob_unroll(pci, index, PCIE_ATU_UNR_LOWER_BASE,
				 lower_32_bits(cpu_addr));
	dw_pcie_writel_ob_unroll(pci, index, PCIE_ATU_UNR_UPPER_BASE,
				 upper_32_bits(cpu_addr));
	dw_pcie_writel_ob_unroll(pci, index, PCIE_ATU_UNR_LIMIT,
				 lower_32_bits(cpu_addr + size - 1));
	dw_pcie_writel_ob_unroll(pci, index, PCIE_ATU_UNR_LOWER_TARGET,
				 lower_32_bits(pci_addr));
	dw_pcie_writel_ob_unroll(pci, index, PCIE_ATU_UNR_UPPER_TARGET,
				 upper_32_bits(pci_addr));
	dw_pcie_writel_ob_unroll(pci, index, PCIE_ATU_UNR_REGION_CTRL1,
				 type);
	dw_pcie_writel_ob_unroll(pci, index, PCIE_ATU_UNR_REGION_CTRL2,
				 PCIE_ATU_ENABLE);

	/*
	 * Make sure ATU enable takes effect before any subsequent config
	 * and I/O accesses.
	 */
	for (retries = 0; retries < LINK_WAIT_MAX_IATU_RETRIES; retries++) {
		val = dw_pcie_readl_ob_unroll(pci, index,
					      PCIE_ATU_UNR_REGION_CTRL2);
		if (val & PCIE_ATU_ENABLE)
			return;

		mdelay(LINK_WAIT_IATU);
	}
	dev_err(pci->dev, "Outbound iATU is not being enabled\n");
}

void dw_pcie_prog_outbound_atu(struct dw_pcie *pci, int index, int type,
			       uint64_t cpu_addr, uint64_t pci_addr, uint32_t size)
{
	uint32_t retries, val;

	if (pci->ops->cpu_addr_fixup)
		cpu_addr = pci->ops->cpu_addr_fixup(pci, cpu_addr);

	if (pci->iatu_unroll_enabled) {
		dw_pcie_prog_outbound_atu_unroll(pci, index, type, cpu_addr,
						 pci_addr, size);
		return;
	}

	dw_pcie_writel_dbi(pci, PCIE_ATU_VIEWPORT,
			   PCIE_ATU_REGION_OUTBOUND | index);
	dw_pcie_writel_dbi(pci, PCIE_ATU_LOWER_BASE,
			   lower_32_bits(cpu_addr));
	dw_pcie_writel_dbi(pci, PCIE_ATU_UPPER_BASE,
			   upper_32_bits(cpu_addr));
	dw_pcie_writel_dbi(pci, PCIE_ATU_LIMIT,
			   lower_32_bits(cpu_addr + size - 1));
	dw_pcie_writel_dbi(pci, PCIE_ATU_LOWER_TARGET,
			   lower_32_bits(pci_addr));
	dw_pcie_writel_dbi(pci, PCIE_ATU_UPPER_TARGET,
			   upper_32_bits(pci_addr));
	dw_pcie_writel_dbi(pci, PCIE_ATU_CR1, type);
	dw_pcie_writel_dbi(pci, PCIE_ATU_CR2, PCIE_ATU_ENABLE);

	/*
	 * Make sure ATU enable takes effect before any subsequent config
	 * and I/O accesses.
	 */
	for (retries = 0; retries < LINK_WAIT_MAX_IATU_RETRIES; retries++) {
		val = dw_pcie_readl_dbi(pci, PCIE_ATU_CR2);
		if (val & PCIE_ATU_ENABLE)
			return;

		mdelay(LINK_WAIT_IATU);
	}
	dev_err(pci->dev, "Outbound iATU is not being enabled\n");
}

static uint32_t dw_pcie_readl_ib_unroll(struct dw_pcie *pci, uint32_t index, uint32_t reg)
{
	uint32_t offset = PCIE_GET_ATU_INB_UNR_REG_OFFSET(index);

	return dw_pcie_readl_atu(pci, offset + reg);
}

static void dw_pcie_writel_ib_unroll(struct dw_pcie *pci, uint32_t index, uint32_t reg,
				     uint32_t val)
{
	uint32_t offset = PCIE_GET_ATU_INB_UNR_REG_OFFSET(index);

	dw_pcie_writel_atu(pci, offset + reg, val);
}

static int dw_pcie_prog_inbound_atu_unroll(struct dw_pcie *pci, int index,
					   int bar, uint64_t cpu_addr,
					   enum dw_pcie_as_type as_type)
{
	int type;
	uint32_t retries, val;

	dw_pcie_writel_ib_unroll(pci, index, PCIE_ATU_UNR_LOWER_TARGET,
				 lower_32_bits(cpu_addr));
	dw_pcie_writel_ib_unroll(pci, index, PCIE_ATU_UNR_UPPER_TARGET,
				 upper_32_bits(cpu_addr));

	switch (as_type) {
	case DW_PCIE_AS_MEM:
		type = PCIE_ATU_TYPE_MEM;
		break;
	case DW_PCIE_AS_IO:
		type = PCIE_ATU_TYPE_IO;
		break;
	default:
		return -EINVAL;
	}

	dw_pcie_writel_ib_unroll(pci, index, PCIE_ATU_UNR_REGION_CTRL1, type);
	dw_pcie_writel_ib_unroll(pci, index, PCIE_ATU_UNR_REGION_CTRL2,
				 PCIE_ATU_ENABLE |
				 PCIE_ATU_BAR_MODE_ENABLE | (bar << 8));

	/*
	 * Make sure ATU enable takes effect before any subsequent config
	 * and I/O accesses.
	 */
	for (retries = 0; retries < LINK_WAIT_MAX_IATU_RETRIES; retries++) {
		val = dw_pcie_readl_ib_unroll(pci, index,
					      PCIE_ATU_UNR_REGION_CTRL2);
		if (val & PCIE_ATU_ENABLE)
			return 0;

		mdelay(LINK_WAIT_IATU);
	}
	dev_err(pci->dev, "Inbound iATU is not being enabled\n");

	return -EBUSY;
}

int dw_pcie_prog_inbound_atu(struct dw_pcie *pci, int index, int bar,
			     uint64_t cpu_addr, enum dw_pcie_as_type as_type)
{
	int type;
	uint32_t retries, val;

	if (pci->iatu_unroll_enabled)
		return dw_pcie_prog_inbound_atu_unroll(pci, index, bar,
						       cpu_addr, as_type);

	dw_pcie_writel_dbi(pci, PCIE_ATU_VIEWPORT, PCIE_ATU_REGION_INBOUND |
			   index);
	dw_pcie_writel_dbi(pci, PCIE_ATU_LOWER_TARGET, lower_32_bits(cpu_addr));
	dw_pcie_writel_dbi(pci, PCIE_ATU_UPPER_TARGET, upper_32_bits(cpu_addr));

	switch (as_type) {
	case DW_PCIE_AS_MEM:
		type = PCIE_ATU_TYPE_MEM;
		break;
	case DW_PCIE_AS_IO:
		type = PCIE_ATU_TYPE_IO;
		break;
	default:
		return -EINVAL;
	}

	dw_pcie_writel_dbi(pci, PCIE_ATU_CR1, type);
	dw_pcie_writel_dbi(pci, PCIE_ATU_CR2, PCIE_ATU_ENABLE
			   | PCIE_ATU_BAR_MODE_ENABLE | (bar << 8));

	/*
	 * Make sure ATU enable takes effect before any subsequent config
	 * and I/O accesses.
	 */
	for (retries = 0; retries < LINK_WAIT_MAX_IATU_RETRIES; retries++) {
		val = dw_pcie_readl_dbi(pci, PCIE_ATU_CR2);
		if (val & PCIE_ATU_ENABLE)
			return 0;

		mdelay(LINK_WAIT_IATU);
	}
	dev_err(pci->dev, "Inbound iATU is not being enabled\n");

	return -EBUSY;
}

static uint8_t dw_pcie_iatu_unroll_enabled(struct dw_pcie *pci)
{
	uint32_t val;

	val = dw_pcie_readl_dbi(pci, PCIE_ATU_VIEWPORT);
	if (val == 0xffffffff)
		return 1;

	return 0;
}

void dw_pcie_disable_atu(struct dw_pcie *pci, int index,
			 enum dw_pcie_region_type type)
{
	int region;

	switch (type) {
	case DW_PCIE_REGION_INBOUND:
		region = PCIE_ATU_REGION_INBOUND;
		break;
	case DW_PCIE_REGION_OUTBOUND:
		region = PCIE_ATU_REGION_OUTBOUND;
		break;
	default:
		return;
	}

	dw_pcie_writel_dbi(pci, PCIE_ATU_VIEWPORT, region | index);
	dw_pcie_writel_dbi(pci, PCIE_ATU_CR2, (uint32_t)~PCIE_ATU_ENABLE);
}

static int dw_pcie_rd_own_conf(struct pcie_port *pp, int where, int size,
			       uint32_t *val)
{
	struct dw_pcie *pci;

	if (pp->ops->rd_own_conf)
		return pp->ops->rd_own_conf(pp, where, size, val);

	pci = to_dw_pcie_from_pp(pp);
	return dw_pcie_read(pci->dbi_base + where, size, val);
}

static int dw_pcie_wr_own_conf(struct pcie_port *pp, int where, int size,
			       uint32_t val)
{
	struct dw_pcie *pci;

	if (pp->ops->wr_own_conf)
		return pp->ops->wr_own_conf(pp, where, size, val);

	pci = to_dw_pcie_from_pp(pp);
	return dw_pcie_write(pci->dbi_base + where, size, val);
}

int dw_pcie_link_up(struct dw_pcie *pci)
{
	uint32_t val;

	if (pci->ops->link_up)
		return pci->ops->link_up(pci);

	val = readl(pci->dbi_base + PCIE_PORT_DEBUG1);
	return ((val & PCIE_PORT_DEBUG1_LINK_UP) &&
		(!(val & PCIE_PORT_DEBUG1_LINK_IN_TRAINING)));
}

int dw_pcie_wait_for_link(struct dw_pcie *pci)
{
	int retries;

	/* Check if the link is up or not */
	for (retries = 0; retries < LINK_WAIT_MAX_RETRIES; retries++) {
		if (dw_pcie_link_up(pci)) {
			dev_info(pci->dev, "Link up\n");
			return 0;
		}
		usleep_range(LINK_WAIT_USLEEP_MIN, LINK_WAIT_USLEEP_MAX);
	}

	dev_info(pci->dev, "Phy link never came up\n");

	return -ETIMEDOUT;
}

int post_platform_init(struct dw_pcie *pci)
{
	if (dw_pcie_link_up(pci))
		return 0;

	/* Enable Link Training state machine */
	//if (pcie->ops->ltssm_enable)    //qcom_pcie_2_3_2_ltssm_enable
	//	pcie->ops->ltssm_enable(pcie);

	return dw_pcie_wait_for_link(pci);

}

void dw_pcie_setup(struct dw_pcie *pci)
{
	int ret;
	uint32_t val;
	uint32_t lanes = LANES;
	struct device *dev = pci->dev;

	if (pci->version >= 0x480A || (!pci->version &&
				       dw_pcie_iatu_unroll_enabled(pci))) {
		pci->iatu_unroll_enabled = true;
		if (!pci->atu_base)
			pci->atu_base = pci->dbi_base + DEFAULT_DBI_ATU_OFFSET;
	}
	dev_dbg(pci->dev, "iATU unroll: %s\n", pci->iatu_unroll_enabled ?
		"enabled" : "disabled");

	/* Set the number of lanes */
	val = dw_pcie_readl_dbi(pci, PCIE_PORT_LINK_CONTROL);
	val &= ~PORT_LINK_MODE_MASK;
	switch (lanes) {
	case 1:
		val |= PORT_LINK_MODE_1_LANES;
		break;
	case 2:
		val |= PORT_LINK_MODE_2_LANES;
		break;
	case 4:
		val |= PORT_LINK_MODE_4_LANES;
		break;
	case 8:
		val |= PORT_LINK_MODE_8_LANES;
		break;
	default:
		dev_err(pci->dev, "num-lanes %u: invalid value\n", lanes);
		return;
	}
	dw_pcie_writel_dbi(pci, PCIE_PORT_LINK_CONTROL, val);

	/* Set link width speed control register */
	val = dw_pcie_readl_dbi(pci, PCIE_LINK_WIDTH_SPEED_CONTROL);
	val &= ~PORT_LOGIC_LINK_WIDTH_MASK;
	switch (lanes) {
	case 1:
		val |= PORT_LOGIC_LINK_WIDTH_1_LANES;
		break;
	case 2:
		val |= PORT_LOGIC_LINK_WIDTH_2_LANES;
		break;
	case 4:
		val |= PORT_LOGIC_LINK_WIDTH_4_LANES;
		break;
	case 8:
		val |= PORT_LOGIC_LINK_WIDTH_8_LANES;
		break;
	}
	dw_pcie_writel_dbi(pci, PCIE_LINK_WIDTH_SPEED_CONTROL, val);
/*
	if (of_property_read_bool(np, "snps,enable-cdm-check")) {
		val = dw_pcie_readl_dbi(pci, PCIE_PL_CHK_REG_CONTROL_STATUS);
		val |= PCIE_PL_CHK_REG_CHK_REG_CONTINUOUS |
		       PCIE_PL_CHK_REG_CHK_REG_START;
		dw_pcie_writel_dbi(pci, PCIE_PL_CHK_REG_CONTROL_STATUS, val);
	}
*/
}


void dw_pcie_setup_rc(struct pcie_port *pp)
{
	uint32_t val, ctrl, num_ctrls;
	struct dw_pcie *pci = to_dw_pcie_from_pp(pp);

    dw_pcie_dbi_ro_wr_en(pci);

    dw_pcie_setup(pci);

	/* Setup RC BARs */
	dw_pcie_writel_dbi(pci, PCI_BASE_ADDRESS_0, 0x00000004);
	dw_pcie_writel_dbi(pci, PCI_BASE_ADDRESS_1, 0x00000000);

	/* Setup interrupt pins */
	val = dw_pcie_readl_dbi(pci, PCI_INTERRUPT_LINE);
	val &= 0xffff00ff;
	val |= 0x00000100;
	dw_pcie_writel_dbi(pci, PCI_INTERRUPT_LINE, val);

	/* Setup bus numbers */
	val = dw_pcie_readl_dbi(pci, PCI_PRIMARY_BUS);
	val &= 0xff000000;
	val |= 0x00ff0100;
	dw_pcie_writel_dbi(pci, PCI_PRIMARY_BUS, val);

	/* Setup command register */
	val = dw_pcie_readl_dbi(pci, PCI_COMMAND);
	val &= 0xffff0000;
	val |= PCI_COMMAND_IO | PCI_COMMAND_MEMORY |
		PCI_COMMAND_MASTER | PCI_COMMAND_SERR;
	dw_pcie_writel_dbi(pci, PCI_COMMAND, val);

	/*
	 * If the platform provides ->rd_other_conf, it means the platform
	 * uses its own address translation component rather than ATU, so
	 * we should not program the ATU here.
	 */
	if (!pp->ops->rd_other_conf) {
		dw_pcie_prog_outbound_atu(pci, PCIE_ATU_REGION_INDEX0,
					  PCIE_ATU_TYPE_MEM, pp->mem_base,
					  pp->mem_bus_addr, pp->mem_size);
		if (pci->num_viewport > 2)
			dw_pcie_prog_outbound_atu(pci, PCIE_ATU_REGION_INDEX2,
						  PCIE_ATU_TYPE_IO, pp->io_base,
						  pp->io_bus_addr, pp->io_size);
	}

	dw_pcie_wr_own_conf(pp, PCI_BASE_ADDRESS_0, 4, 0);

	/* Program correct class for RC */
	dw_pcie_wr_own_conf(pp, PCI_CLASS_DEVICE, 2, PCI_CLASS_BRIDGE_PCI);

	dw_pcie_rd_own_conf(pp, PCIE_LINK_WIDTH_SPEED_CONTROL, 4, &val);
	val |= PORT_LOGIC_SPEED_CHANGE;
	dw_pcie_wr_own_conf(pp, PCIE_LINK_WIDTH_SPEED_CONTROL, 4, val);

	dw_pcie_dbi_ro_wr_dis(pci);
}


int pre_platform_init(void)
{
    // configure clock and resets
    
    // phy_power_on
    return 0;
}


int dw_pcie_host_init(struct pcie_port *pp)
{
	struct dw_pcie *pci = to_dw_pcie_from_pp(pp);

    pre_platform_init();//qcom_pcie_init_2_3_3

    dw_pcie_setup_rc(pp);

    post_platform_init(pci); //qcom_pcie_establish_link

    return 0;
}


int pcie_init(struct dw_pcie *pci)
{
    //phy_init();
    
    dw_pcie_host_init(&pci->pp);

    //bus_enumerate();

    return 0;
}



#ifdef TEST
int main (int argc, char *argv[])
{
    struct dw_pcie pci;

    pcie_init(&pci);

    return 0;
}
#endif
