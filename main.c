#include "pcie-designware.h"

int main (int argc, char *argv[])
{
    struct dw_pcie pci;

    pcie_init(&pci);

    return 0;
}

