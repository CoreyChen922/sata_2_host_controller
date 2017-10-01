
//Device: Virtex-5 LXT
//Design Name: speed_neg_control
//Purpose:
// This module handles the SATA Gen1/Gen2 speed negotiation

/*
Speed negotiation is accomplished by changing the internal shared phase-locked loop (PLL)
divider settings of the GTP transceiver during runtime to eliminate the need for reconfiguration.
The dynamic reconfiguration port (DRP) allows access to the internal attributes of the GTP
transceiver through a simple bus interface.

Below are the DRP and setting for Gen1
Attribute 		DRP Address 	Value
PLL_RXDIVSEL_OUT_0[0] 	0X46[[2] 	1
PLL_RXDIVSEL_OUT_1[0] 	0X0A[0] 	1
PLL_TXDIVSEL_OUT_0[0] 	0X45[15] 	1
PLL_TXDIVSEL_OUT_1[0] 	0X05[4] 	1

Below are the DRP and setting for Gen2
Attribute 		DRP Address 	Value
PLL_RXDIVSEL_OUT_0[0] 	0X46[[2] 	0
PLL_RXDIVSEL_OUT_1[0] 	0X0A[0] 	0
PLL_TXDIVSEL_OUT_0[0] 	0X45[15] 	0
PLL_TXDIVSEL_OUT_1[0] 	0X05[4] 	0
*/

`timescale 1 ns / 1 ps 


module speed_neg_control (

  input  wire        clk,        //clock
  input  wire        reset,      // reset
  input  wire        link_reset,
  output reg         mgt_reset,  //GTP reset request
  input  wire        linkup,     // SATA link established
  output reg   [6:0] daddr,      //DRP address                     
  output reg         den,        //DRP enable
  output reg  [15:0] di,         //DRP data in
  input  wire [15:0] do,         //DRP data out
  input  wire        drdy,       //DRP ready
  output reg         dwe,        //DRP write enable
  input  wire        gtp_lock,   //GTP locked
  output wire  [4:0] state_out,
  output reg         gen_value  
);
	

	parameter	[4:0] 	IDLE		= 5'h00;
	parameter	[4:0] 	READ_GEN2  	= 5'h01;
	parameter	[4:0] 	WRITE_GEN2  	= 5'h02;
	parameter	[4:0] 	COMPLETE_GEN2  	= 5'h03;
	parameter	[4:0] 	PAUSE1_GEN2  	= 5'h04;
	parameter	[4:0] 	READ1_GEN2  	= 5'h05;
	parameter	[4:0] 	WRITE1_GEN2  	= 5'h06;
	parameter	[4:0] 	COMPLETE1_GEN2  = 5'h07;
	parameter	[4:0] 	RESET 	 	= 5'h08;
	parameter	[4:0] 	WAIT_GEN2   	= 5'h09;
	parameter	[4:0] 	READ_GEN1  	= 5'h0A;
	parameter	[4:0] 	WRITE_GEN1  	= 5'h0B;
	parameter	[4:0] 	COMPLETE_GEN1  	= 5'h0C;
	parameter	[4:0] 	PAUSE_GEN1 	= 5'h0D;
	parameter	[4:0] 	READ1_GEN1  	= 5'h0E;
	parameter	[4:0] 	WRITE1_GEN1  	= 5'h0F;
	parameter	[4:0] 	COMPLETE1_GEN1  = 5'h10;
	parameter	[4:0] 	RESET_GEN1  	= 5'h11;
	parameter	[4:0] 	WAIT_GEN1   	= 5'h12;
	parameter	[4:0] 	LINKUP 		= 5'h13;


	reg  [4:0] state;
	reg [31:0] linkup_cnt;
	reg [15:0] drp_reg;
	reg [15:0] reset_cnt;
	reg  [3:0] pause_cnt;

assign state_out = state;

always @ (posedge clk or posedge reset)
begin
  if(reset)
  begin
    state <= IDLE;
    daddr <= 7'b0;
    di    <= 8'b0;
    den   <= 1'b0;
    dwe   <= 1'b0;
    drp_reg <= 16'b0;
    linkup_cnt <= 32'h0;
    gen_value <= 1'b1;
    reset_cnt <= 16'b0000000000000000;
    mgt_reset <= 1'b0;
    pause_cnt <= 4'b0000;

  end
  else
  begin
  	case(state)
      	IDLE:  begin
              	if(gtp_lock)
			begin
			daddr <= 7'h46;
                	den   <= 1'b1;
                	gen_value    <= 1'b1; //GEN2
                	state      <= READ_GEN2;        
			end
			else
			begin
			    state <= IDLE;
			end
             end
      READ_GEN2: begin
               if(drdy)
               begin
                 drp_reg <= do;
                 den   <= 1'b0;
                 state <= WRITE_GEN2;
               end
               else
               begin
                 state <= READ_GEN2;
               end
             end
      WRITE_GEN2: begin
               di  <= drp_reg ;  //this actually takes care of all the bits that I should have to change.
               di[2] <= 1'b0;
               den <= 1'b1;
               dwe <= 1'b1;
               state <= COMPLETE_GEN2;
             end
      COMPLETE_GEN2: begin
               if(drdy)
               begin
                 dwe   <= 1'b0;
                 den   <= 1'b0;
                 state <= PAUSE1_GEN2;
               end
               else
               begin
                 state <= COMPLETE_GEN2;
               end
             end
      PAUSE1_GEN2: begin
               if(pause_cnt == 4'b1111)
               begin
                 dwe   <= 1'b0;
                 den   <= 1'b1;
                 daddr <= 7'h45;
                 pause_cnt <= 4'b0000;
                 state <= READ1_GEN2;
               end
               else
               begin
                 pause_cnt <= pause_cnt + 1'b1;
                 state <= PAUSE1_GEN2;
               end
             end           
      READ1_GEN2: begin
               if(drdy)
               begin
                 drp_reg <= do;
                 den   <= 1'b0;
                 state <= WRITE1_GEN2;
               end
               else
               begin
                 state <= READ1_GEN2;
               end
             end
      WRITE1_GEN2: begin
               di  <= drp_reg;  
               di[15] <= 1'b0;
               den <= 1'b1;
               dwe <= 1'b1;
               state <= COMPLETE1_GEN2;
             end
      COMPLETE1_GEN2: begin
               if(drdy)
               begin
                 dwe   <= 1'b0;
                 den   <= 1'b0;
                 state <= RESET;
               
               end
               else
               begin
                 state <= COMPLETE1_GEN2;
               end
             end
     
      RESET: begin
               if(reset_cnt == 16'b00001111)
               begin
                 reset_cnt <= reset_cnt + 1'b1;
                 state <= RESET;
                 mgt_reset <= 1'b1;
               end
               else if(reset_cnt == 16'b0000000000011111)
               begin
                 reset_cnt <= 16'b00000000;
                 mgt_reset <= 1'b0;
                 state <= WAIT_GEN2;
               end
               else
               begin
                 reset_cnt <= reset_cnt + 1'b1;
                 state <= RESET;
               end
             end
      WAIT_GEN2:  begin //f
               if(linkup)
               begin
                 linkup_cnt <= 32'h0;
                 state <= LINKUP;
               end
               else
               begin
		if(gtp_lock)
		begin
		`ifdef SIM 
		   if(linkup_cnt == 32'h000007FF) //for simulation only
		 `else					  
                   if(linkup_cnt == 32'h00080EB4) // Duration allows four linkup tries
		`endif 
                   begin
                     linkup_cnt <= 32'h0;
                     daddr <= 7'h46;
                     den   <= 1'b1;
                     gen_value <= 1'b0; //this is Gen1
                     state      <= READ_GEN1;
			  //state <= WAIT_GEN2;  //MD don't switch back and forth to see if this improves the linkup situation
                   end
                   else
                   begin
                     linkup_cnt <= linkup_cnt + 1'b1;
                     state <= WAIT_GEN2;
                   end
					  end
					  else
					  begin
					    state <= WAIT_GEN2;
					  end
               end

             end
      READ_GEN1: begin
               if(drdy)
               begin
                 drp_reg <= do;
                 den   <= 1'b0;
                 state <= WRITE_GEN1;
               end
               else
               begin
                 state <= READ_GEN1;
               end
             end
      WRITE_GEN1: begin
               di  <= drp_reg;  //this actually takes care of all the bits that I should have to change.//appears the comm doesn't change. changed bit 9 to never switch.
               di[2] <=  1'b1;
               den <= 1'b1;
               dwe <= 1'b1;
               state <= COMPLETE_GEN1;
             end
      COMPLETE_GEN1: begin
               if(drdy)
               begin
                 dwe   <= 1'b0;
                 den   <= 1'b0;
                 state <= PAUSE_GEN1;
               end
               else
               begin
                 state <= COMPLETE_GEN1;
               end
             end
     PAUSE_GEN1: begin
               if(pause_cnt == 4'b1111)
               begin
                 dwe   <= 1'b0;
                 den   <= 1'b1;
                 daddr <= 7'h45;
                 pause_cnt <= 4'b0000;
                 state <= READ1_GEN1;
               end
               else
               begin
                 pause_cnt <= pause_cnt + 1'b1;
                 state <= PAUSE_GEN1;
               end
             end 
      READ1_GEN1: begin
               if(drdy)
               begin
                 drp_reg <= do;
                 den   <= 1'b0;
                 state <= WRITE1_GEN1;
               end
               else
               begin
                 state <= READ1_GEN1;
               end
             end
      WRITE1_GEN1: begin
               di  <= drp_reg;  //
               di[15] <= 1'b1;
               den <= 1'b1;
               dwe <= 1'b1;
               state <= COMPLETE1_GEN1;
             end
      COMPLETE1_GEN1: begin
               if(drdy)
               begin
                 dwe   <= 1'b0;
                 den   <= 1'b0;
                 state <= RESET_GEN1;
               
               end
               else
               begin
                 state <= COMPLETE1_GEN1;
               end
             end
     
      RESET_GEN1: begin
               if(reset_cnt == 16'b00001111)
               begin
                 reset_cnt <= reset_cnt + 1'b1;
                 state <= RESET_GEN1;
                 mgt_reset <= 1'b1;
               end
               else if(reset_cnt == 16'h001F)
               begin
                 reset_cnt <= 16'b00000000;
                 mgt_reset <= 1'b0;
                 state <= WAIT_GEN1;
               end
               else
               begin
                 reset_cnt <= reset_cnt + 1'b1;
                 state <= RESET_GEN1;
               end
             end
      WAIT_GEN1:  begin
               if(linkup)
               begin
                 linkup_cnt <= 32'h0;
                 state <= LINKUP;
               end
               else
               begin
		if(gtp_lock)
		begin
		`ifdef SIM 
		   if(linkup_cnt == 32'h000007FF) //for simulation only
		 `else					  
                   if(linkup_cnt == 32'h00080EB4) //// Duration allows four linkup tries
		`endif 
                   begin
                     linkup_cnt <= 32'h0;
                     daddr <= 7'h46;
                     den   <= 1'b1;
                     state <= READ_GEN2; // after elapsed time the linkup resumes to Gen2
                   end
                   else
                   begin
                     linkup_cnt <= linkup_cnt + 1'b1;
                     state <= WAIT_GEN1;
                   end
		 end
		 else
		  begin
		    state <= WAIT_GEN1;
		  end
               end

             end                         
     LINKUP: begin
     		if (linkup)
               		state <= LINKUP;
               	else
                   begin
                     linkup_cnt <= 32'h0;
                     daddr <= 7'h46;
                     den   <= 1'b1;
                     state <= READ_GEN2; // after elapsed time the linkup resumes to Gen2
                   end               		
             end 

     default: begin
                state <= IDLE;
                daddr <= 7'b0;
                di    <= 8'b0;
                den   <= 1'b0;
                dwe   <= 1'b0;
                drp_reg <= 16'b0;
                linkup_cnt <= 32'h0;
                gen_value <= 1'b1;
                reset_cnt <= 8'b00000000;
                mgt_reset <= 1'b0;
                pause_cnt <= 4'b0000;
              end 
    endcase
  end

end

endmodule
