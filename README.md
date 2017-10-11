# sata_2_host_controller
Sata 2 Host Controller for FPGA implimentation.
SATA is a computer bus interface that connects host bus adapters to mass storage devices such as hard disk drives and optical drives .The SATA Host Controller IP is  able to transfer data to and from a SATA device. 


Features of the IP core are
1. Fully compliant with the Serial ATA specification revision 2.0
2. Simple transaction interface with Host processor
3. 32-bit internal data path
4. IP Core system clock of 37.5MHz and PHY clock 75MHz for SATA-I
5. IP Core system clock of 75.0MHz and PHY clock 150MHz for SATA-II
6. Supports 1.5 Gbit/s and 3.0 Gbit/s data transfer rates
7. Supports DMA and PIO commands
8. Hardware support for Speed auto negotiation for SATA I/II
9. 48-bit address set
10. Detection of OOB, COMWAKE, K28.5, etc.
11. 8b/10b coding and decoding
12. CRC generation and checking
13. Implements the shadow register block and the SATA status and control registers
14. Target FPGA : Xilinx Virtex5
