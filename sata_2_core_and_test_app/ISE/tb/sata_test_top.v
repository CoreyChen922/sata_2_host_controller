`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////
//  File name   : sata_test_top.v
//  Note        : This is the top module which connects SATA controller, 
//                Microblaze System and SATA test logic.
//  Test/Verification Environment
//  Dependencies   : Nil
/////////////////////////////////////////////////////////////////////////////// 

module sata_test_top(
    input          fpga_0_RS232_Uart_1_RX_pin,
    output         fpga_0_RS232_Uart_1_TX_pin,
    input          fpga_0_clk_1_sys_clk_pin,
    input          fpga_0_rst_1_sys_rst_pin,
    
    input           TILE0_REFCLK_PAD_P_IN,  // MGTCLKA,  clocks GTP_X0Y0-2 
    input           TILE0_REFCLK_PAD_N_IN,  // MGTCLKA 
    input           GTPRESET_IN,            // GTP initialization
    output          TILE0_PLLLKDET_OUT,     // GTP PLL locked

    output          TXP0_OUT,               // SATA Connector TX P pin
    output          TXN0_OUT,               // SATA Connector TX N pin
    input           RXP0_IN,                // SATA Connector RX P pin
    input           RXN0_IN,                // SATA Connector RX N pin
      
    output          DCMLOCKED_OUT,          // PHY Layer DCM locked
    output          LINKUP,                 // SATA PHY initialisation completed LINK UP
    output          GEN2,                   // 1 when a SATA2 device detected, 0 when SATA1 device detected
    output          PHY_CLK_OUT,            // PHY layer clock out
    output          CLK_OUT                // LINK and Transport Layer clock out CLK_OUT = PHY_CLK_OUT / 2
    
  );
  
//  input fpga_0_RS232_Uart_1_RX_pin;
//  output fpga_0_RS232_Uart_1_TX_pin;
//  input fpga_0_clk_1_sys_clk_pin;
//  input fpga_0_rst_1_sys_rst_pin;


  wire              host_read_en; 
  wire              host_write_en;
  wire [4:0]        host_addr_reg;
  wire [31:0]       host_to_trnsp_data;
  wire [31:0]       trnsp_to_host_data;
  wire              reset_out;
  wire              write_hold_u;
  wire              read_hold_u;
  wire              dma_rqst;
  wire       [31:0] dma_rx_data_out;
  wire              dma_rx_ren;
  wire       [31:0] dma_tx_data_in;
  wire              dma_tx_wen; 
  
  wire              sata_reset;

  
  wire       [31:0] MB2IP_Addr_pin;
  wire              MB2IP_CS_pin;
  wire              MB2IP_RNW_pin;
  wire       [31:0] MB2IP_Data_pin;
  wire       [31:0] IP2mb_Data_pin;
  wire              IP2MB_RdAck_pin;
  wire              IP2MB_WrAck_pin;
  wire              IP2MB_Error_pin;
  wire        [3:0] MB2IP_BE_pin;
  wire              ipf;
  wire              dma_terminated;
  wire              r_err;
  wire              illegal_state;
  wire              tx_fifo_reset;
  wire              rx_fifo_reset;
  
  wire              mb_rst_0;
  reg               mb_rst_1;
  reg               mb_rst_2;
  reg               mb_rst_3;
  wire              mb_rst_debounce;
  reg               fpga_0_rst_1_sys_rst_pin_1;
  reg               fpga_0_rst_1_sys_rst_pin_2;
  
    
  always @(posedge fpga_0_clk_1_sys_clk_pin)
  begin
   fpga_0_rst_1_sys_rst_pin_1 <= fpga_0_rst_1_sys_rst_pin;
   fpga_0_rst_1_sys_rst_pin_2 <= fpga_0_rst_1_sys_rst_pin_1;
  end
    
  assign mb_rst_0 = fpga_0_rst_1_sys_rst_pin_2;  

  always @(posedge fpga_0_clk_1_sys_clk_pin)
  begin
   mb_rst_1 <= mb_rst_0;
   mb_rst_2 <= mb_rst_1;
   mb_rst_3 <= mb_rst_2;
  end

  assign mb_rst_debounce = (mb_rst_1 & mb_rst_2 & mb_rst_3);
      
    //assign data_out = trnsp_to_host_data;
  //assign data_out = dma_rqst? dma_rx_data_out : trnsp_to_host_data;
  
  
    (* BOX_TYPE = "user_black_box" *)
    system mb_system (
    .fpga_0_RS232_Uart_1_RX_pin         (fpga_0_RS232_Uart_1_RX_pin), 
    .fpga_0_RS232_Uart_1_TX_pin         (fpga_0_RS232_Uart_1_TX_pin), 
    .fpga_0_clk_1_sys_clk_pin           (fpga_0_clk_1_sys_clk_pin), 
    .fpga_0_rst_1_sys_rst_pin           (mb_rst_debounce), 
    
    .sata_test_logic_0_MB2IP_Clk_pin    (MB2IP_Clk_pin), 
    .sata_test_logic_0_MB2IP_Reset_pin  (MB2IP_Reset_pin), 
    .sata_test_logic_0_MB2IP_Addr_pin   (MB2IP_Addr_pin), 
    .sata_test_logic_0_MB2IP_CS_pin     (MB2IP_CS_pin), 
    .sata_test_logic_0_MB2IP_RNW_pin    (MB2IP_RNW_pin), 
    .sata_test_logic_0_MB2IP_Data_pin   (MB2IP_Data_pin), 
    .sata_test_logic_0_MB2IP_BE_pin     (MB2IP_BE_pin), 
    .sata_test_logic_0_IP2mb_Data_pin   (IP2mb_Data_pin), 
    .sata_test_logic_0_IP2MB_RdAck_pin  (IP2MB_RdAck_pin), 
    .sata_test_logic_0_IP2MB_WrAck_pin  (IP2MB_WrAck_pin), 
    .sata_test_logic_0_IP2MB_Error_pin  (IP2MB_Error_pin)
    );


  // Instantiate the module
  SATA_TOP SATA_TOP1(
    .TILE0_REFCLK_PAD_P_IN  (TILE0_REFCLK_PAD_P_IN), 
    .TILE0_REFCLK_PAD_N_IN  (TILE0_REFCLK_PAD_N_IN), 
    .GTPRESET_IN            (sata_reset), //(GTPRESET_IN), 
    .TILE0_PLLLKDET_OUT     (TILE0_PLLLKDET_OUT), 
    .TXP0_OUT               (TXP0_OUT), 
    .TXN0_OUT               (TXN0_OUT), 
    .RXP0_IN                (RXP0_IN), 
    .RXN0_IN                (RXN0_IN), 
    .DCMLOCKED_OUT          (DCMLOCKED_OUT), 
    .LINKUP                 (LINKUP), 
    .GEN2                   (GEN2), 
    .PHY_CLK_OUT            (PHY_CLK_OUT), 
    .CLK_OUT                (CLK_OUT), 
    .HOST_READ_EN           (host_read_en), 
    .HOST_WRITE_EN          (host_write_en), 
    .HOST_ADDR_REG          (host_addr_reg), 
    .HOST_DATA_IN           (host_to_trnsp_data),
    .HOST_DATA_OUT          (trnsp_to_host_data),
    .RESET_OUT              (reset_out),
    .WRITE_HOLD_U           (write_hold_u),
    .READ_HOLD_U            (read_hold_u),
    .PIO_CLK_IN             (CLK_OUT),
    .DMA_CLK_IN             (CLK_OUT),
    .DMA_RQST               (dma_rqst),
    .DMA_RX_DATA_OUT        (dma_rx_data_out),
    .DMA_RX_REN             (dma_rx_ren),
    .DMA_TX_DATA_IN         (dma_tx_data_in),
    .DMA_TX_WEN             (dma_tx_wen),
    .CE                     (1'b1),
    .IPF                    (ipf),
    .DMA_TERMINATED         (dma_terminated),
    .R_ERR                  (r_err),
    .ILLEGAL_STATE          (illegal_state),
    .RX_FIFO_RESET          (rx_fifo_reset),
    .TX_FIFO_RESET          (tx_fifo_reset) 
    );


  // Instantiate the module
  sata_test sata_test1(
    .CLK               (CLK_OUT), 
    .RESET             (reset_out),
    .CTRL_READ_EN      (host_read_en), 
    .CTRL_WRITE_EN     (host_write_en), 
    .CTRL_ADDR_REG     (host_addr_reg), 
    .CTRL_DATA_OUT     (host_to_trnsp_data),
    .CTRL_DATA_IN      (trnsp_to_host_data),
    .SATA_WR_HOLD_IN   (write_hold_u),
    .SATA_RD_HOLD_IN   (read_hold_u),
    .DMA_RQST_OUT      (dma_rqst),
    .DMA_RX_DATA_IN    (dma_rx_data_out),
    .DMA_RX_REN_OUT    (dma_rx_ren),
    .DMA_TX_DATA_OUT   (dma_tx_data_in),
    .DMA_TX_WEN_OUT    (dma_tx_wen),
    .MB_ADRESS         (MB2IP_Addr_pin),
    .MB_CS             (MB2IP_CS_pin),
    .MB_RNW            (MB2IP_RNW_pin),
    .MB_DATA_IN        (MB2IP_Data_pin),
    .MB_DATA_OUT       (IP2mb_Data_pin),
    .MB_CLK            (MB2IP_Clk_pin),
    .MB_RESET          (MB2IP_Reset_pin),
    .GTP_RESET_IN      (GTPRESET_IN),
    .SATA_RESET_OUT    (sata_reset),
    .INTERRUPT_IN      (ipf),
    .DMA_TERMINATED    (dma_terminated),
    .R_ERR             (r_err),
    .ILLEGAL_STATE     (illegal_state),
    .LINKUP            (LINKUP),
    .MB_RD_ACK         (IP2MB_RdAck_pin),
    .RX_FIFO_RESET_OUT (rx_fifo_reset),
    .TX_FIFO_RESET_OUT (tx_fifo_reset) 
    );
    
    assign IP2MB_WrAck_pin = MB2IP_CS_pin && !MB2IP_RNW_pin;
    assign IP2MB_Error_pin = 0;


endmodule
