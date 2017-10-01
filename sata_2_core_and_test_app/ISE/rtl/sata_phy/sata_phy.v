//Device: Virtex-5 LXT
//Design Name: ML505_GTP_speed_negotiation
//Purpose:
// This module handles the SATA Gen1/Gen2 speed negotiation

module sata_phy # 
(
    // Simulation attributes
    parameter   SIM_GTPRESET_SPEEDUP=   1,         // Set to 1 to speed up sim reset
    parameter   SIM_PLL_PERDIV2     =   9'h14d,    // Set to the VCO Unit Interval time

    // Refclk attributes
    parameter   CLKINDC_B           =   "TRUE", 
    
    // Channel bonding attributes
    parameter   CHAN_BOND_MODE_0    =   "OFF",  // "MASTER", "SLAVE", or "OFF"
    parameter   CHAN_BOND_LEVEL_0   =   0,      // 0 to 7. See UG for details
    parameter   CHAN_BOND_MODE_1    =   "OFF",  // "MASTER", "SLAVE", or "OFF"
    parameter   CHAN_BOND_LEVEL_1   =   0,       // 0 to 7. See UG for details
    parameter   CHIPSCOPE           =   0

)    

(
	TILE0_REFCLK_PAD_P_IN,			// MGTCLKA,  clocks GTP_X0Y0-2 
	TILE0_REFCLK_PAD_N_IN,			// MGTCLKA 
	GTPRESET_IN,			          // GTP initialization
	TILE0_PLLLKDET_OUT, 			  // TX PLL LOCK

	TXP0_OUT,
	TXN0_OUT,
	RXP0_IN,
	RXN0_IN,		
	DCMLOCKED_OUT,
	LINKUP,
	logic_clk,	
 	GEN2,
  tx_data_in,
  tx_charisk_in,
  rx_data_out,
  rx_charisk_out,
  logic_reset,
  align_count,
  div2_logic_clock
);
	       
	input		TILE0_REFCLK_PAD_P_IN;	    // GTP reference clock input
	input		TILE0_REFCLK_PAD_N_IN;	    // GTP reference clock input
	input		GTPRESET_IN;  		          // Main GTP reset
	input           RXP0_IN;		        // Receiver input
	input           RXN0_IN;		        // Receiver input
  input   [15:0] tx_data_in;
  input   tx_charisk_in;
 

	output		DCMLOCKED_OUT;		        // DCM locked 
 
	output 		TILE0_PLLLKDET_OUT;  			// PLL Lock Detect
	output		TXP0_OUT;
	output		TXN0_OUT;
	output		LINKUP;
	output		logic_clk;
	output		GEN2;
  output    [15:0] rx_data_out;
  output    [1:0] rx_charisk_out;
  output    logic_reset;
  output    [1:0] align_count;
  output    div2_logic_clock;

  
	wire	[1:0]	rxcharisk;
	wire        	gtp_rxusrclk, gtp_rxusrclk2;
	wire            gtp_txusrclk, gtp_txusrclk2;
	wire	[2:0]   rxstatus;
	wire		txcomtype, txcomstart;
	wire		sync_det_out, align_det_out;
	wire		tx_charisk;
	wire    [1:0]   rx_charisk_out;
	wire		txelecidle,   rxelecidle0, rxelecidle1, rxenelecidleresetb; 
	wire		resetdone0, resetdone1;
	wire	[15:0]	txdata, rxdata, rxdataout; // TX/RX data
	wire	[3:0]	CurrentState_out;
	wire	[4:0]	state_out;
	wire		rx_sof_det_out, rx_eof_det_out;
	//wire		TILE0_PLLLKDET_OUT;
 	wire 		linkup;
	wire		clk0, clk2x, dcm_clk0, dcm_clkdv, dcm_clk2x; // DCM output clocks
	wire		usrclk, logic_clk; //GTP user clocks
	wire		dcm_locked;
	wire		gtp_refclkout;
	wire		system_reset;
	wire		speed_neg_rst;
	wire	[6:0]	daddr;	//DRP Address
	wire        	den;	//DRP enable
	wire	[15:0]	di;	//DRP data in
	wire	[15:0]	do;	//DRP data out
	wire		drdy;	//DRP ready
	wire		dwe;	//DRP write enable 
	wire		rxreset;	//GTP Rxreset
	wire 				RXBYTEREALIGN0, RXBYTEISALIGNED0;
	wire 		RXRECCLK0;
	wire 		dcm_reset;
	wire 		rst_0;
	wire 		rst_debounce;
	wire 		push_button_rst;
	wire 		dcm_refclkin;   
	     		
	reg  		rst_1;  
	reg  		rst_2;
	reg  		rst_3;
	reg  		rx_sof_det_out_reg, rx_eof_det_out_reg;
	reg	[15:0]	rxdataout_reg;
  reg     GTPRESET_IN_1;
  reg     GTPRESET_IN_2;
  
	assign system_reset = rst_debounce;
	assign gtp_reset = rst_debounce|| speed_neg_rst;	
	assign dcm_reset = ~TILE0_PLLLKDET_OUT || speed_neg_rst;
	
	assign LINKUP = linkup;	
	assign	DCMLOCKED_OUT	=  dcm_locked; // LED active high 

	//assign TILE0_PLLLKDET_OUT_N = TILE0_PLLLKDET_OUT;         
	assign  rxelecidlereset0          =   (rxelecidle0 && resetdone0);
	assign  rxenelecidleresetb        =   !rxelecidlereset0;
  assign  rx_data_out = rxdataout;  
  assign  rx_charisk_out = rx_charisk_out;
  assign  logic_reset = gtp_reset;

always @(posedge logic_clk or posedge system_reset)
begin
if(system_reset)
	begin
		rx_sof_det_out_reg <= 1'b0;
		rx_eof_det_out_reg <= 1'b0;
		rxdataout_reg <= 16'b0;
	end
	else
	begin
		rx_sof_det_out_reg <= rx_sof_det_out;
		rx_eof_det_out_reg <= rx_eof_det_out;
		rxdataout_reg <= rxdataout;
	end
end




always @(posedge dcm_refclkin)
begin
 GTPRESET_IN_1 <= GTPRESET_IN;
 GTPRESET_IN_2 <= GTPRESET_IN_1;
end


assign rst_0 = GTPRESET_IN_2;  

always @(posedge dcm_refclkin)
begin
 rst_1 <= rst_0;
 rst_2 <= rst_1;
 rst_3 <= rst_2;
end

assign rst_debounce = (rst_1 & rst_2 & rst_3);


// GTP clock buffers

IBUFDS ibufdsa (
   .I  (TILE0_REFCLK_PAD_P_IN), 
   .IB (TILE0_REFCLK_PAD_N_IN), 
   .O  (gtp_refclk)
   );

BUFG refclkout_bufg (
   .I (gtp_refclkout), 
   .O (dcm_refclkin)
   );

BUFG dcm_clk0_bufg (
   .I (dcm_clk0), 
   .O (clk0)
   );
   
BUFG dcm_clkdv_bufg (
   .I (dcm_clkdv), 
   .O (clkdv)
   );   
   
BUFG dcm_clk2x_bufg (
   .I (dcm_clk2x), 
   .O (clk2x)
   );

BUFGMUX logic_clk_bufgmux (
   .O  (logic_clk), 
   .I0 (clkdv), 
   .I1 (clk0), 
   .S  (GEN2) //1'b1)//1'b0) //GEN2= 1)
   );

BUFGMUX usrclk_bufgmux (
   .O  (usrclk), 
   .I0 (clk0), 
   .I1 (clk2x), 
   .S  (GEN2) //1'b1)//1'b0) //GEN2= 1)
   );
 
// DCM for GTP clocks   
DCM_BASE #(
   .CLKDV_DIVIDE          (2.0),
   .CLKIN_PERIOD          (6.666),
   .DLL_FREQUENCY_MODE    ("HIGH"),
   .DUTY_CYCLE_CORRECTION ("TRUE"),
   .FACTORY_JF            (16'hF0F0)
   ) 
GEN2_DCM(
   .CLK0     (dcm_clk0),             // 0 degree DCM CLK ouptput
   .CLK180   (),                     // 180 degree DCM CLK output
   .CLK270   (),                     // 270 degree DCM CLK output
   .CLK2X    (dcm_clk2x),            // 2X DCM CLK output
   .CLK2X180 (), 	             // 2X, 180 degree DCM CLK out
   .CLK90    (),                     // 90 degree DCM CLK output
   .CLKDV    (dcm_clkdv),            // Divided DCM CLK out (CLKDV_DIVIDE)
   .CLKFX    (),                     // DCM CLK synthesis out (M/D)
   .CLKFX180 (), 	             // 180 degree CLK synthesis out
   .LOCKED   (dcm_locked),           // DCM LOCK status output
   .CLKFB    (clk0),                 // DCM clock feedback   
   .CLKIN    (dcm_refclkin),         // Clock input (from IBUFG, BUFG or DCM)
   .RST      (dcm_reset)//gtp_reset)             // DCM asynchronous reset input
   ); 
   
   //LINK and Transport layer clock
  reg bufr_div2_clk_out;
   
   BUFG div2_clk_bufg (
   .I (bufr_div2_clk_out), 
   .O (div2_logic_clock)
   );

always @(posedge dcm_reset, posedge logic_clk)
begin
  if (dcm_reset)
    bufr_div2_clk_out <= 1;
  else begin
    bufr_div2_clk_out <= !bufr_div2_clk_out ;
  end
end




// GTP clock assignments
assign	gtp_txusrclk  = usrclk;
assign	gtp_txusrclk2 = logic_clk;
assign	gtp_rxusrclk  = usrclk;
assign	gtp_rxusrclk2 = logic_clk;



OOB_control OOB_control_i 
    (
  .clk		      		(logic_clk),
 	.reset		      	(gtp_reset),
 	.link_reset			  (1'b0),
 	.rx_locked			  (TILE0_PLLLKDET_OUT),
 	.tx_datain			  (tx_data_in),		    // User datain port
  .tx_chariskin     (tx_charisk_in),
 	.tx_dataout			  (txdata),		        // outgoing GTP data
 	.tx_charisk			  (tx_charisk),          
	.rx_charisk			  (rxcharisk),                             
 	.rx_datain			  (rxdata),           // incoming GTP data 
 	.rx_dataout			  (rxdataout),        // User dataout port
 	.rx_charisk_out	  (rx_charisk_out),   // User charisk port 	
 	.linkup           (linkup),
	.gen2             (GEN2),
	.rxreset			    (rxreset),
 	.txcomstart			  (txcomstart),
 	.txcomtype			  (txcomtype),
 	.rxstatus			    (rxstatus),
 	.rxelecidle			  (rxelecidle0),
 	.txelecidle			  (txelecidle),
 	.rxbyteisaligned	(RXBYTEISALIGNED0), 	
 	.CurrentState_out (CurrentState_out),
 	.align_det_out    (align_det_out),
 	.sync_det_out     (sync_det_out),
 	.rx_sof_det_out   (rx_sof_det_out),
 	.rx_eof_det_out   (rx_eof_det_out),
  .send_align_count_out      (align_count)
    );

speed_neg_control snc(

	.clk        			(dcm_refclkin),
	.reset      			(system_reset),
	.link_reset 			(1'b 0),
	.mgt_reset  			(speed_neg_rst),
	.linkup     			(linkup),
	.daddr      			(daddr),   //7                     
	.den        			(den),
	.di         			(di),     //16
	.do         			(do),     //16
	.drdy       			(drdy),
	.dwe        			(dwe),
	.gtp_lock   			(TILE0_PLLLKDET_OUT),
	.state_out  			(state_out), 
	.gen_value  			(GEN2)       
);


//instantiate on GTP tile(two transceivers)

GTP_DUAL # 
    (
        //_______________________ Simulation-Only Attributes __________________

        .SIM_GTPRESET_SPEEDUP        (SIM_GTPRESET_SPEEDUP),
        .SIM_PLL_PERDIV2             (SIM_PLL_PERDIV2),

        //___________________________ Shared Attributes _______________________

        //---------------------- Tile and PLL Attributes ----------------------

        .CLK25_DIVIDER               (6), 
        .CLKINDC_B                   ("TRUE"),   
        .OOB_CLK_DIVIDER             (6),
        .OVERSAMPLE_MODE             ("FALSE"),
        .PLL_DIVSEL_FB               (2),
        .PLL_DIVSEL_REF              (1),
        .PLL_TXDIVSEL_COMM_OUT       (1),// 1), //2 for GEN1 and 1 for GEN2
        .TX_SYNC_FILTERB             (1),


        //______________________ Transmit Interface Attributes ________________

        //----------------- TX Buffering and Phase Alignment ------------------   

        .TX_BUFFER_USE_0            ("TRUE"),
        .TX_XCLK_SEL_0              ("TXOUT"),
        .TXRX_INVERT_0              (5'b00000),       

        .TX_BUFFER_USE_1            ("TRUE"),
        .TX_XCLK_SEL_1              ("TXOUT"),
        .TXRX_INVERT_1              (5'b00000),        

        //------------------- TX Serial Line Rate settings --------------------   

        .PLL_TXDIVSEL_OUT_0         (1),//1 ),//2),//2 for GEN1 and 1 for GEN2

        .PLL_TXDIVSEL_OUT_1         (1),//1),//2), 

        //------------------- TX Driver and OOB signalling --------------------  

         .TX_DIFF_BOOST_0           ("TRUE"),

         .TX_DIFF_BOOST_1           ("TRUE"),

        //---------------- TX Pipe Control for PCI Express/SATA ---------------

        .COM_BURST_VAL_0            (4'b0101),

        .COM_BURST_VAL_1            (4'b0101),

        //_______________________ Receive Interface Attributes ________________

        //---------- RX Driver,OOB signalling,Coupling and Eq.,CDR ------------  

        .AC_CAP_DIS_0               ("FALSE"),
        .OOBDETECT_THRESHOLD_0      (3'b111), 
        .PMA_CDR_SCAN_0             (27'h6c08040), 
        .PMA_RX_CFG_0               (25'h0dce111),
        .RCV_TERM_GND_0             ("FALSE"),
        .RCV_TERM_MID_0             ("TRUE"),
        .RCV_TERM_VTTRX_0           ("TRUE"),
        .TERMINATION_IMP_0          (50),

        .AC_CAP_DIS_1               ("FALSE"),
        .OOBDETECT_THRESHOLD_1      (3'b111), 
        .PMA_CDR_SCAN_1             (27'h6c08040), 
        .PMA_RX_CFG_1               (25'h0dce111),  
        .RCV_TERM_GND_1             ("FALSE"),
        .RCV_TERM_MID_1             ("TRUE"),
        .RCV_TERM_VTTRX_1           ("TRUE"),
        .TERMINATION_IMP_1          (50),

        .TERMINATION_CTRL           (5'b10100),
        .TERMINATION_OVRD           ("FALSE"),

        //------------------- RX Serial Line Rate Settings --------------------   

        .PLL_RXDIVSEL_OUT_0         (1),//2),//2 for GEN1 and 1 for GEN2
        .PLL_SATA_0                 ("FALSE"),

        .PLL_RXDIVSEL_OUT_1         (1),
        .PLL_SATA_1                 ("FALSE"),


        //------------------------- PRBS Detection ----------------------------  

        .PRBS_ERR_THRESHOLD_0       (32'h00000008),

        .PRBS_ERR_THRESHOLD_1       (32'h00000008),

        //------------------- Comma Detection and Alignment -------------------  

        .ALIGN_COMMA_WORD_0         (2),
        .COMMA_10B_ENABLE_0         (10'b1111111111),
        .COMMA_DOUBLE_0             ("FALSE"),
        .DEC_MCOMMA_DETECT_0        ("TRUE"),
        .DEC_PCOMMA_DETECT_0        ("TRUE"),
        .DEC_VALID_COMMA_ONLY_0     ("FALSE"),
        .MCOMMA_10B_VALUE_0         (10'b1010000011),
        .MCOMMA_DETECT_0            ("TRUE"),
        .PCOMMA_10B_VALUE_0         (10'b0101111100),
        .PCOMMA_DETECT_0            ("TRUE"),
        .RX_SLIDE_MODE_0            ("PCS"),

        .ALIGN_COMMA_WORD_1         (2),
        .COMMA_10B_ENABLE_1         (10'b1111111111),
        .COMMA_DOUBLE_1             ("FALSE"),
        .DEC_MCOMMA_DETECT_1        ("TRUE"),
        .DEC_PCOMMA_DETECT_1        ("TRUE"),
        .DEC_VALID_COMMA_ONLY_1     ("FALSE"),
        .MCOMMA_10B_VALUE_1         (10'b1010000011),
        .MCOMMA_DETECT_1            ("TRUE"),
        .PCOMMA_10B_VALUE_1         (10'b0101111100),
        .PCOMMA_DETECT_1            ("TRUE"),
        .RX_SLIDE_MODE_1            ("PCS"),


        //------------------- RX Loss-of-sync State Machine -------------------  

        .RX_LOSS_OF_SYNC_FSM_0      ("FALSE"),
        .RX_LOS_INVALID_INCR_0      (8),
        .RX_LOS_THRESHOLD_0         (128),

        .RX_LOSS_OF_SYNC_FSM_1      ("FALSE"),
        .RX_LOS_INVALID_INCR_1      (8),
        .RX_LOS_THRESHOLD_1         (128),

        //------------ RX Elastic Buffer and Phase alignment ports ------------   

        .RX_BUFFER_USE_0            ("TRUE"),
        .RX_XCLK_SEL_0              ("RXREC"),

        .RX_BUFFER_USE_1            ("TRUE"),
        .RX_XCLK_SEL_1              ("RXREC"),

        //--------------------- Clock Correction Attributes -------------------   

        .CLK_CORRECT_USE_0          ("TRUE"),
        .CLK_COR_ADJ_LEN_0          (4),
        .CLK_COR_DET_LEN_0          (4),
        .CLK_COR_INSERT_IDLE_FLAG_0 ("FALSE"),
        .CLK_COR_KEEP_IDLE_0        ("FALSE"),
        .CLK_COR_MAX_LAT_0          (18),
        .CLK_COR_MIN_LAT_0          (16),
        .CLK_COR_PRECEDENCE_0       ("TRUE"),
        .CLK_COR_REPEAT_WAIT_0      (0),
        .CLK_COR_SEQ_1_1_0          (10'b0110111100),
        .CLK_COR_SEQ_1_2_0          (10'b0001001010),
        .CLK_COR_SEQ_1_3_0          (10'b0001001010),
        .CLK_COR_SEQ_1_4_0          (10'b0001111011),
        .CLK_COR_SEQ_1_ENABLE_0     (4'b1111),
        .CLK_COR_SEQ_2_1_0          (10'b0000000000),
        .CLK_COR_SEQ_2_2_0          (10'b0000000000),
        .CLK_COR_SEQ_2_3_0          (10'b0000000000),
        .CLK_COR_SEQ_2_4_0          (10'b0000000000),
        .CLK_COR_SEQ_2_ENABLE_0     (4'b0000),
        .CLK_COR_SEQ_2_USE_0        ("FALSE"),
        .RX_DECODE_SEQ_MATCH_0      ("TRUE"),

        .CLK_CORRECT_USE_1          ("TRUE"),
        .CLK_COR_ADJ_LEN_1          (4),
        .CLK_COR_DET_LEN_1          (4),
        .CLK_COR_INSERT_IDLE_FLAG_1 ("FALSE"),
        .CLK_COR_KEEP_IDLE_1        ("FALSE"),
        .CLK_COR_MAX_LAT_1          (18),
        .CLK_COR_MIN_LAT_1          (16),
        .CLK_COR_PRECEDENCE_1       ("TRUE"),
        .CLK_COR_REPEAT_WAIT_1      (0),
        .CLK_COR_SEQ_1_1_1          (10'b0110111100),
        .CLK_COR_SEQ_1_2_1          (10'b0001001010),
        .CLK_COR_SEQ_1_3_1          (10'b0001001010),
        .CLK_COR_SEQ_1_4_1          (10'b0001111011),
        .CLK_COR_SEQ_1_ENABLE_1     (4'b1111),
        .CLK_COR_SEQ_2_1_1          (10'b0000000000),
        .CLK_COR_SEQ_2_2_1          (10'b0000000000),
        .CLK_COR_SEQ_2_3_1          (10'b0000000000),
        .CLK_COR_SEQ_2_4_1          (10'b0000000000),
        .CLK_COR_SEQ_2_ENABLE_1     (4'b0000),
        .CLK_COR_SEQ_2_USE_1        ("FALSE"),
        .RX_DECODE_SEQ_MATCH_1      ("TRUE"),

        //-------------------- Channel Bonding Attributes ---------------------   

        .CHAN_BOND_1_MAX_SKEW_0     (7),
        .CHAN_BOND_2_MAX_SKEW_0     (7),
        .CHAN_BOND_LEVEL_0          (CHAN_BOND_LEVEL_0),
        .CHAN_BOND_MODE_0           (CHAN_BOND_MODE_0),
        .CHAN_BOND_SEQ_1_1_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_2_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_0   (4'b0000),
        .CHAN_BOND_SEQ_2_1_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_0   (4'b0000),
        .CHAN_BOND_SEQ_2_USE_0      ("FALSE"),  
        .CHAN_BOND_SEQ_LEN_0        (1),
        .PCI_EXPRESS_MODE_0         ("FALSE"),     
     
        .CHAN_BOND_1_MAX_SKEW_1     (7),
        .CHAN_BOND_2_MAX_SKEW_1     (7),
        .CHAN_BOND_LEVEL_1          (CHAN_BOND_LEVEL_1),
        .CHAN_BOND_MODE_1           (CHAN_BOND_MODE_1),
        .CHAN_BOND_SEQ_1_1_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_2_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_1   (4'b0000),
        .CHAN_BOND_SEQ_2_1_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_1   (4'b0000),
        .CHAN_BOND_SEQ_2_USE_1      ("FALSE"),  
        .CHAN_BOND_SEQ_LEN_1        (1),
        .PCI_EXPRESS_MODE_1         ("FALSE"),

        //---------------- RX Attributes for PCI Express/SATA ---------------

        .RX_STATUS_FMT_0            ("SATA"),
        .SATA_BURST_VAL_0           (3'b100),
        .SATA_IDLE_VAL_0            (3'b100),
        .SATA_MAX_BURST_0           (7),
        .SATA_MAX_INIT_0            (22),
        .SATA_MAX_WAKE_0            (7),
        .SATA_MIN_BURST_0           (4),
        .SATA_MIN_INIT_0            (12),
        .SATA_MIN_WAKE_0            (4),
        .TRANS_TIME_FROM_P2_0       (16'h0060),
        .TRANS_TIME_NON_P2_0        (16'h0025),
        .TRANS_TIME_TO_P2_0         (16'h0100),

        .RX_STATUS_FMT_1            ("SATA"),
        .SATA_BURST_VAL_1           (3'b100),
        .SATA_IDLE_VAL_1            (3'b100),
        .SATA_MAX_BURST_1           (7),
        .SATA_MAX_INIT_1            (22),
        .SATA_MAX_WAKE_1            (7),
        .SATA_MIN_BURST_1           (4),
        .SATA_MIN_INIT_1            (12),
        .SATA_MIN_WAKE_1            (4),
        .TRANS_TIME_FROM_P2_1       (16'h0060),
        .TRANS_TIME_NON_P2_1        (16'h0025),
        .TRANS_TIME_TO_P2_1         (16'h0100)         
     ) 
     GTP_DUAL_0 
     (

        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK0                      (3'b000),
        .LOOPBACK1                      (3'b000),
        .RXPOWERDOWN0                   (2'b00),
        .RXPOWERDOWN1                   (2'b00),
        .TXPOWERDOWN0                   (2'b00),
        .TXPOWERDOWN1                   (2'b00),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISCOMMA0                 ({rxchariscomma0_float_i,RXCHARISCOMMA0_OUT}),
        .RXCHARISCOMMA1                 ({rxchariscomma1_float_i,RXCHARISCOMMA1_OUT}),
        .RXCHARISK0                     (rxcharisk),
        .RXCHARISK1                     (),
        .RXDEC8B10BUSE0                 (1'b1),
        .RXDEC8B10BUSE1                 (1'b1),
        .RXDISPERR0                     ({rxdisperr0_float_i,rxdisperr}),
        .RXDISPERR1                     ({rxdisperr1_float_i,RXDISPERR1_OUT}),
        .RXNOTINTABLE0                  ({rxnotintable0_float_i,RXNOTINTABLE0_OUT}),
        .RXNOTINTABLE1                  ({rxnotintable1_float_i,RXNOTINTABLE1_OUT}),
        .RXRUNDISP0                     ({rxrundisp0_float_i,RXRUNDISP0_OUT}),
        .RXRUNDISP1                     ({rxrundisp1_float_i,RXRUNDISP1_OUT}),
        //----------------- Receive Ports - Channel Bonding Ports ------------------
        .RXCHANBONDSEQ0                 (),
        .RXCHANBONDSEQ1                 (),
        .RXCHBONDI0                     (3'b000),
        .RXCHBONDI1                     (3'b000),
        .RXCHBONDO0                     (),
        .RXCHBONDO1                     (),
        .RXENCHANSYNC0                  (1'b1),
        .RXENCHANSYNC1                  (1'b1),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT0                   (),
        .RXCLKCORCNT1                   (),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED0               (RXBYTEISALIGNED0),
        .RXBYTEISALIGNED1               (),
        .RXBYTEREALIGN0                 (RXBYTEREALIGN0),
        .RXBYTEREALIGN1                 (),
        .RXCOMMADET0                    (rxcommadet0),
        .RXCOMMADET1                    (),
        .RXCOMMADETUSE0                 (1'b1),
        .RXCOMMADETUSE1                 (1'b1),
        .RXENMCOMMAALIGN0               (1'b1),
        .RXENMCOMMAALIGN1               (1'b1),
        .RXENPCOMMAALIGN0               (1'b1),
        .RXENPCOMMAALIGN1               (1'b1),
        .RXSLIDE0                       (1'b0),
        .RXSLIDE1                       (1'b0),
        //--------------------- Receive Ports - PRBS Detection ---------------------
        .PRBSCNTRESET0                  (1'b0),
        .PRBSCNTRESET1                  (1'b0),
        .RXENPRBSTST0                   (2'b00),
        .RXENPRBSTST1                   (2'b00),
        .RXPRBSERR0                     (),
        .RXPRBSERR1                     (),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA0                        (rxdata),
        .RXDATA1                        (),
        .RXDATAWIDTH0                   (1'b1),
        .RXDATAWIDTH1                   (1'b1),
        .RXRECCLK0                      (RXRECCLK0),
        .RXRECCLK1                      (),
        .RXRESET0                       (rxreset),
        .RXRESET1                       (rxreset),
        .RXUSRCLK0                      (gtp_rxusrclk),
        .RXUSRCLK1                      (gtp_rxusrclk),
        .RXUSRCLK20                     (gtp_rxusrclk2),
        .RXUSRCLK21                     (gtp_rxusrclk2),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .RXCDRRESET0                    (gtp_reset),
        .RXCDRRESET1                    (gtp_reset),
        .RXELECIDLE0                    (rxelecidle0),
        .RXELECIDLE1                    (rxelecidle1),
        .RXELECIDLERESET0               (rxelecidlereset0),
        .RXELECIDLERESET1               (rxelecidlereset1),
        .RXENEQB0                       (1'b1),
        .RXENEQB1                       (1'b1),
        .RXEQMIX0                       (2'b00),
        .RXEQMIX1                       (2'b00),
        .RXEQPOLE0                      (4'b0000),
        .RXEQPOLE1                      (4'b0000),
        .RXN0                           (RXN0_IN),
        .RXN1                           (),
        .RXP0                           (RXP0_IN),
        .RXP1                           (),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET0                    (gtp_reset),
        .RXBUFRESET1                    (gtp_reset),
        .RXBUFSTATUS0                   (),
        .RXBUFSTATUS1                   (),
        .RXCHANISALIGNED0               (),
        .RXCHANISALIGNED1               (),
        .RXCHANREALIGN0                 (),
        .RXCHANREALIGN1                 (),
        .RXPMASETPHASE0                 (1'b0),
        .RXPMASETPHASE1                 (1'b0),
        .RXSTATUS0                      (rxstatus),
        .RXSTATUS1                      (),
        //------------- Receive Ports - RX Loss-of-sync State Machine --------------
        .RXLOSSOFSYNC0                  (), //RXLOSSOFSYNC0_OUT
        .RXLOSSOFSYNC1                  (), //RXLOSSOFSYNC1_OUT
        //-------------------- Receive Ports - RX Oversampling ---------------------
        .RXENSAMPLEALIGN0               (1'b0),
        .RXENSAMPLEALIGN1               (1'b0),
        .RXOVERSAMPLEERR0               (),
        .RXOVERSAMPLEERR1               (),
        //------------ Receive Ports - RX Pipe Control for PCI Express -------------
        .PHYSTATUS0                     (),
        .PHYSTATUS1                     (),
        .RXVALID0                       (),
        .RXVALID1                       (),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        .RXPOLARITY0                    (1'b0),
        .RXPOLARITY1                    (1'b0),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (daddr),
        .DCLK                           (dcm_refclkin),//gtp_txusrclk2),
        .DEN                            (den),
        .DI                             (di),
        .DO                             (do),
        .DRDY                           (drdy),
        .DWE                            (dwe),
        //------------------- Shared Ports - Tile and PLL Ports --------------------
        .CLKIN                          (gtp_refclk),
        .GTPRESET                       (gtp_reset),
        .GTPTEST                        (4'b0000),
        .INTDATAWIDTH                   (1'b1),
        .PLLLKDET                       (TILE0_PLLLKDET_OUT),
        .PLLLKDETEN                     (1'b1),
        .PLLPOWERDOWN                   (1'b0),
        .REFCLKOUT                      (gtp_refclkout),
        .REFCLKPWRDNB                   (1'b1),
        .RESETDONE0                     (resetdone0),
        .RESETDONE1                     (resetdone1),
        .RXENELECIDLERESETB             (rxenelecidleresetb),
        .TXENPMAPHASEALIGN              (1'b0),
        .TXPMASETPHASE                  (1'b0),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXBYPASS8B10B0                 ({1'b0,1'b0}),
        .TXBYPASS8B10B1                 ({1'b0,1'b0}),
        .TXCHARDISPMODE0                ({1'b0,1'b0}),
        .TXCHARDISPMODE1                ({1'b0,1'b0}),
        .TXCHARDISPVAL0                 ({1'b0,1'b0}),
        .TXCHARDISPVAL1                 ({1'b0,1'b0}),
        .TXCHARISK0                     ({1'b0,tx_charisk}),
        .TXCHARISK1                     ({1'b0,tx_charisk}),
        .TXENC8B10BUSE0                 (1'b1),
        .TXENC8B10BUSE1                 (1'b1),
        .TXKERR0                        ({txkerr0_float_i,TXKERR0_OUT}),
        .TXKERR1                        ({txkerr1_float_i,TXKERR1_OUT}),
        .TXRUNDISP0                     ({txrundisp0_float_i,TXRUNDISP0_OUT}),
        .TXRUNDISP1                     ({txrundisp1_float_i,TXRUNDISP1_OUT}),
        //----------- Transmit Ports - TX Buffering and Phase Alignment ------------
        .TXBUFSTATUS0                   (),
        .TXBUFSTATUS1                   (),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA0                        (txdata),
        .TXDATA1                        (txdata),
        .TXDATAWIDTH0                   (1'b1),
        .TXDATAWIDTH1                   (1'b1),
        .TXOUTCLK0                      (),
        .TXOUTCLK1                      (),
        .TXRESET0                       (gtp_reset),
        .TXRESET1                       (gtp_reset),
        .TXUSRCLK0                      (gtp_txusrclk),
        .TXUSRCLK1                      (gtp_txusrclk),
        .TXUSRCLK20                     (gtp_txusrclk2),
        .TXUSRCLK21                     (gtp_txusrclk2),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXBUFDIFFCTRL0                 (3'b001),
        .TXBUFDIFFCTRL1                 (3'b001),
        .TXDIFFCTRL0                    (3'b100),
        .TXDIFFCTRL1                    (3'b100),
        .TXINHIBIT0                     (1'b0),
        .TXINHIBIT1                     (1'b0),
        .TXN0                           (TXN0_OUT),
        .TXN1                           (),
        .TXP0                           (TXP0_OUT),
        .TXP1                           (),
        .TXPREEMPHASIS0                 (3'b011),
        .TXPREEMPHASIS1                 (3'b011),
        //------------------- Transmit Ports - TX PRBS Generator -------------------
        .TXENPRBSTST0                   (2'b00),
        .TXENPRBSTST1                   (2'b00),
        //------------------ Transmit Ports - TX Polarity Control ------------------
        .TXPOLARITY0                    (1'b0),
        .TXPOLARITY1                    (1'b0),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXDETECTRX0                    (1'b0),
        .TXDETECTRX1                    (1'b0),
        .TXELECIDLE0                    (txelecidle),
        .TXELECIDLE1                    (txelecidle),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .TXCOMSTART0                    (txcomstart),
        .TXCOMSTART1                    (1'b0),
        .TXCOMTYPE0                     (txcomtype), //this is 0 for cominit/comreset/  and 1 for comwake
        .TXCOMTYPE1                     (1'b0)

     );
endmodule
