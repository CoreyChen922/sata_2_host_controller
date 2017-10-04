`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
//  File name   : sata_test.v
//  Note        : This is a synthesisable module test logic for Sata host 
//                controller and interface between SATA 
//                controller and microblaze system
//  Test/Verification Environment
//  Dependencies   : Nil
///////////////////////////////////////////////////////////////////////////////


module sata_test(
    input             CLK,
    input             RESET,
    output reg        CTRL_READ_EN,
    output reg        CTRL_WRITE_EN,
    output reg [4:0]  CTRL_ADDR_REG,
    output reg [31:0] CTRL_DATA_OUT,
    input      [31:0] CTRL_DATA_IN,
    input             SATA_WR_HOLD_IN,
    input             SATA_RD_HOLD_IN,
    output reg        DMA_RQST_OUT,
    input      [31:0] DMA_RX_DATA_IN,
    output reg        DMA_RX_REN_OUT,
    output     [31:0] DMA_TX_DATA_OUT,
    output reg        DMA_TX_WEN_OUT,
    
    input      [31:0] MB_ADRESS,
    input             MB_CS,
    input             MB_RNW,
    input      [31:0] MB_DATA_IN,
    output reg [31:0] MB_DATA_OUT,
    input             MB_CLK,
    input             MB_RESET,
    input             GTP_RESET_IN,
    output            SATA_RESET_OUT,
    input             INTERRUPT_IN,
    input             DMA_TERMINATED,
    input             R_ERR,
    input             ILLEGAL_STATE,
    input             LINKUP,
    output            MB_RD_ACK,
    output reg        RX_FIFO_RESET_OUT,  
    output reg        TX_FIFO_RESET_OUT   
    );

  parameter cmd_reg               =  8'd1        ;
  parameter ctrl_reg              =  8'd2        ;
  parameter feature_reg           =  8'd3        ;
  parameter stuts_reg             =  8'd4        ;
  parameter head_reg              =  8'd5        ;
  parameter error_reg             =  8'd6        ;
  parameter lba_low               =  8'd7        ;
  parameter lba_mid               =  8'd8        ;
  parameter lba_high              =  8'd9        ;
  parameter sect_count            =  8'd10       ;
  parameter data_reg              =  8'd11       ;
  

 
  //for trasmition test logic
  //wire          tx_fifo_empty;
  //wire          tx_fifo_prog_empty;
  

  reg [5:0]     test_logic_state;
  //reg [31:0]    tx_data;
  //reg           tx_data_wr_en;
  
  reg           test_button_down_int;
  reg    [31:0] read_count;
  reg    [31:0] sector_count;
  reg    [15:0] counter_5us;
  
  reg    [31:0] test_command_reg;
  reg    [31:0] test_sector_count_reg;
  wire   [31:0] test_status_reg;
  reg    [31:0] test_reset_reg;
  
  reg    [31:0] test_lba_addr_low_reg;
  reg    [31:0] test_lba_addr_high_reg;
  
  
  wire   [31:0] test_lba_low_reg;
  wire   [31:0] test_lba_mid_reg;
  wire   [31:0] test_lba_high_reg;
  
  reg    [31:0] throughput_count;
  reg           throughput_count_en;
  
  reg           cmd_en;
  reg           controller_reset;
  reg           error;
  reg           reset_controller;
  reg     [4:0] reset_count;
  reg           reset_counten;
  wire          tx_ram_wr_en;
  reg           tx_ram_rd_en;
  reg           rx_ram_wr_port_en;
  wire          rx_ram_rd_en;
  wire   [31:0] rx_ram_wr_addr;
  wire   [31:0] rx_ram_dout;
  reg           mb_cs_delayed;
  reg           mb_rnw_delayed;
  reg     [7:0] error_count;
  reg           error_from_SSD;
  reg    [31:0] timeout_count;
  reg           timeout_count_en;
  reg           timeout_count_reset;
  reg           cmd_en_1;
  reg           cmd_en_2;

  
    
 
  wire          mb_wr_en;
  wire          mb_rd_en; 
  
  /*
  parameter         wait_for_ROK_sent      = 4'b0000, 
                    read_cmd_reg           = 4'b0001,
                    read_ctrl_reg          = 4'b0010,
                    read_feature_reg       = 4'b0011, 
                    read_stuts_reg         = 4'b0100,
                    read_head_reg          = 4'b0101, 
                    read_error_reg         = 4'b0110,
                    read_lba_low           = 4'b0111,
                    read_lba_mid           = 4'b1000,
                    read_lba_high          = 4'b1001,
                    read_sect_count        = 4'b1010,
                    read_data_reg          = 4'b1011,
                    check_for_ROK_sent_low = 4'b1100; 
  */
  parameter         wait_for_BSY_0           = 6'h 0,
                    write_feature_reg        = 6'h 1, 
                    write_device_reg         = 6'h 2, 
                    write_LBA_low_reg        = 6'h 3, 
                    write_LBA_mid_reg        = 6'h 4, 
                    write_LBA_high_reg       = 6'h 5, 
                    write_sector_cnt_reg     = 6'h 6, 
                    write_cmd_reg            = 6'h 7, 
                    read_busy_bit            = 6'h 8,
                    check_for_BSY_1          = 6'h 9,    
                    //read_cmd_reg             = 6'h A,
                    //read_ctrl_reg            = 6'h B,
                    //read_feature_reg         = 6'h C,
                    //read_stuts_reg           = 6'h D,
                    //read_head_reg            = 6'h E,
                    //read_error_reg           = 6'h F,
                    //read_lba_low             = 6'h 10,
                    //read_lba_mid             = 6'h 11,
                    //read_lba_high            = 6'h 12,
                    //read_sect_count          = 6'h 13,
                    //read_data_reg            = 6'h 14,
                    last_state               = 6'h 15,
                    read_data_reg_con        = 6'h 16,
                    write_ctrl_reg           = 6'h 17,
                    write_data_reg_con       = 6'h 18,
                    read_DMA                 = 6'h 19,
                    write_DMA                = 6'h 1A,
                    sector_count_check       = 6'h 1B,
                    
                    set_reset                = 6'h A,
                    clear_reset              = 6'h B,
                    wait_for_5us             = 6'h C,
                    check_for_BSY_2          = 6'h D,
                    wait_for_cmd             = 6'h E,
                    read_busy_bit_after_write_DMA = 6'h F,
                    check_for_BSY_3          = 6'h 10,
                    wait_for_linkup          = 6'h 11,
                    last_state_2             = 6'h 12,
                    last_state_3             = 6'h 13,
                    last_state_4             = 6'h 14;

                    
                
  parameter [31:0]  FIS_DW1               = 32'h 00EC8027, //32'h 00618027, //32'h01500027,
                    FIS_DW2               = 32'h A0000000, //32'h 08030201, //32'h00000001,
                    FIS_DW3               = 32'h 00000000, //32'h 08070605, //32'h00000000,
                    FIS_DW4               = 32'h 00000000, //32'h 0000000a, //32'h00000001,
                    FIS_DW5               = 32'h 00000000; //32'h 00000000; //32'h00000000;
                    
                    

  
  assign mb_rd_en = MB_CS && MB_RNW;
  assign mb_wr_en = MB_CS && !MB_RNW;
  assign MB_RD_ACK = (mb_cs_delayed && mb_rnw_delayed);
  
  //sata reset generation
  //assign SATA_RESET_OUT = GTP_RESET_IN || test_reset_reg[0] || MB_RESET || controller_reset;
  assign SATA_RESET_OUT = GTP_RESET_IN || test_reset_reg[0] || controller_reset;
  
  //delaying MB_RNW for read acknowledgement
  always @(posedge MB_CLK, posedge MB_RESET)
  begin
    if (MB_RESET) begin
      mb_rnw_delayed <= 1'b 0;
      mb_cs_delayed  <= 1'b 0;
    end
    else begin
      mb_rnw_delayed <= MB_RNW;
      mb_cs_delayed  <= MB_CS;
    end
  end
  
  //MB read operation 
  always @(posedge MB_CLK, posedge MB_RESET)
  begin
    if (MB_RESET) begin
      MB_DATA_OUT <= 32'h 0;
    end
    else begin
      if (mb_rd_en) begin
        casex(MB_ADRESS)
          32'h 80000004: begin
            MB_DATA_OUT <= test_command_reg;
          end
          32'h 80000008: begin
            MB_DATA_OUT <= test_sector_count_reg;
          end
          32'h 8000000C: begin
            MB_DATA_OUT <= test_status_reg;
          end
          32'h 80000010: begin
            MB_DATA_OUT <= throughput_count;
          end
          32'h 80000014: begin
            MB_DATA_OUT <= test_lba_addr_low_reg;
          end
          32'h 80000018: begin
            MB_DATA_OUT <= test_lba_addr_high_reg;
          end
          32'h 8002xxxx: begin
            MB_DATA_OUT <= rx_ram_dout;
          end
          default: begin
            MB_DATA_OUT <= 32'h 0;
          end
        endcase
      end
    end
  end
    
  //MB write operation
  always @(posedge MB_CLK, posedge MB_RESET)
  begin
    if (MB_RESET) begin
      test_command_reg       <= 32'h 0;
      test_sector_count_reg  <= 32'h 1;
      test_lba_addr_low_reg  <= 32'h 0;
      test_lba_addr_high_reg <= 32'h 0;
      test_reset_reg         <= 32'h 0;
    end
    else begin
      if (mb_wr_en) begin
        case(MB_ADRESS)
          32'h 80000000: begin
            test_reset_reg <= MB_DATA_IN;
          end
          32'h 80000004: begin
            test_command_reg <= MB_DATA_IN;
          end
          32'h 80000008: begin
            test_sector_count_reg <= MB_DATA_IN ;
          end
          32'h 80000014: begin
            test_lba_addr_low_reg <= MB_DATA_IN ;
          end
          32'h 80000018: begin
            test_lba_addr_high_reg <= MB_DATA_IN ;
          end
        endcase
      end
    end
  end
  
  //generating cmd_en to start a sata command
  always @(posedge MB_CLK, posedge MB_RESET)
  begin
    if (MB_RESET) begin
      cmd_en <= 0;
    end
    else begin
      if (mb_wr_en && (MB_ADRESS == 32'h 80000004)) begin
        cmd_en <= 1;
      end
      //else if (((test_logic_state == last_state) && !error && !error_from_SSD) || RESET || (error_count >= 8'h1F)) begin
      else if (((test_logic_state == last_state) && !error && !error_from_SSD) || (error_count >= 8'h1F)) begin
        cmd_en <= 0;
      end
      else begin
        cmd_en <= cmd_en;
      end
    end
  end
            

  //synchronising cmd_en
  always @(posedge CLK, posedge RESET)
  begin
    if (RESET) begin
      cmd_en_1 <= 0;
      cmd_en_2 <= 0;
    end
    else begin
      cmd_en_1 <= cmd_en;
      cmd_en_2 <= cmd_en_1;
    end
  end  

  assign test_status_reg[0] = cmd_en;
  assign test_status_reg[1] = error;
  assign test_status_reg[2] = error_from_SSD;
  
  
  //LBA address to HDD LBA register mapping
  assign test_lba_low_reg[7:0]  = test_lba_addr_low_reg[7:0];
  assign test_lba_mid_reg[7:0]  = test_lba_addr_low_reg[15:8];
  assign test_lba_high_reg[7:0] = test_lba_addr_low_reg[23:16];
  assign test_lba_low_reg[15:8] = test_lba_addr_low_reg[31:24];
  assign test_lba_mid_reg[15:8] = test_lba_addr_high_reg[7:0];
  assign test_lba_high_reg[15:8] = test_lba_addr_high_reg[15:8];
  
  

  
  //throughput counter process
  always @(posedge CLK, posedge RESET)
  begin
    if (RESET) begin    
      throughput_count <= 32'h 0;
    end
    else begin
      if (test_logic_state ==  write_cmd_reg) begin
        throughput_count <=  32'h 0;
      end
      else if (throughput_count_en) begin
        throughput_count <= throughput_count + 1;
      end
      else begin
        throughput_count <= throughput_count;
      end
    end
  end
  
  //timeout-count counter process
  always @(posedge CLK, posedge RESET)
  begin
    if (RESET) begin    
      timeout_count <= 32'h 0;
    end
    else begin
      if (timeout_count_reset ==  1) begin
        timeout_count <=  32'h 0;
      end
      else if (timeout_count_en) begin
        timeout_count <= timeout_count + 1;
      end
      else begin
        timeout_count <= timeout_count;
      end
    end
  end
  
  
  
  //resetting controller
  always @(posedge MB_CLK, posedge MB_RESET)
  begin
    if (MB_RESET) begin
      controller_reset <= 0;
      reset_count      <= 5'h 0;
      reset_counten    <= 0;
    end
    else begin
    
      if (reset_controller) begin
        reset_counten <= 1;
        controller_reset <= 0;
      end
      else if (reset_count == 5'h 8) begin
        controller_reset <= 1;
        reset_counten    <= 1;
      end
      else if (reset_count == 5'h 1F) begin
        controller_reset <= 0;
        reset_counten    <= 0;
      end
      else begin
        reset_counten    <= reset_counten;
        controller_reset <= controller_reset;
      end
      
      
      //count for controller reset reset
      if (reset_counten) begin
        reset_count <= reset_count + 1;
      end
      else begin
        reset_count <= 5'd0;
      end
      
    end
  end
  
  //assign controller_reset = ((reset_count >= 4'h 5) && (reset_count <= 4'h F))? 1 : 0;
  
        
  //main test state machine.
  always @(posedge CLK, posedge MB_RESET)
  begin
    if (MB_RESET) begin  
      CTRL_WRITE_EN    <= 0;
      CTRL_READ_EN     <= 0;
      CTRL_ADDR_REG    <= 5'h 0;
      test_logic_state <= wait_for_cmd;
      read_count       <= 32'h0;
      DMA_RQST_OUT     <= 0;
      sector_count     <= 32'h0;
      throughput_count_en <= 0;
      reset_controller    <= 0;
      error               <= 0;
      tx_ram_rd_en        <= 0;
      rx_ram_wr_port_en   <= 0;
      RX_FIFO_RESET_OUT   <= 0;
      TX_FIFO_RESET_OUT   <= 0;
      error_count         <= 8'h 0;
      error_from_SSD      <= 0;
      timeout_count_en    <= 0;
      timeout_count_reset <= 1;
      counter_5us         <= 16'h 0;
      CTRL_DATA_OUT       <= 32'h 0;
      DMA_RX_REN_OUT      <= 0;
      DMA_TX_WEN_OUT      <= 0;
    end
    else begin
      case (test_logic_state)

        wait_for_cmd: begin
          if (cmd_en_2) begin
            test_logic_state <= wait_for_linkup;
            timeout_count_en <= 1;
            timeout_count_reset <= 1;
            error            <= 0;
          end
          else begin
            test_logic_state <= wait_for_cmd;
            error_count <= 8'h 0;
            timeout_count_reset <= 0;
          end
        end 
        
        wait_for_linkup: begin
          timeout_count_reset <= 0;
          if (LINKUP) begin
            test_logic_state <= set_reset;
            //test_logic_state  <= wait_for_BSY_0;
            counter_5us       <= 16'hFFFF;
            RX_FIFO_RESET_OUT <= 1;
            TX_FIFO_RESET_OUT <= 1;
          end
          else if ((timeout_count == 32'h 000FFFFF)) begin
              test_logic_state <= last_state;
              timeout_count_en <= 0;
              reset_controller <= 1;
              error            <= 1;
          end
          else if ((timeout_count == 32'h 000FFFFE)) begin
              test_logic_state <= wait_for_linkup;
              reset_controller <= 1;
              error            <= 1;
          end
          else if ((timeout_count == 32'h 000FFFFD)) begin
              test_logic_state <= wait_for_linkup;
              reset_controller <= 1;
              error            <= 1;
              error_count      <= error_count + 1;
          end
          else begin
            test_logic_state <= wait_for_linkup;
          end
        end
        
        set_reset: begin         //device reset                                        
          CTRL_READ_EN      <= 1'b 0;                                           
          CTRL_WRITE_EN     <= 1'b 1;                                           
          CTRL_ADDR_REG     <= 5'h 2;             //control register
          CTRL_DATA_OUT      <= {24'b 0,8'h 04};   
          test_logic_state  <= wait_for_5us;
          counter_5us       <= 'd376;   //5us
          error             <= 0;
        end
                  
        wait_for_5us: begin
          counter_5us <= counter_5us -1;
          CTRL_READ_EN      <= 1'b 0;                                           
          CTRL_WRITE_EN     <= 1'b 0; 
          if (counter_5us == 'd0) begin
            test_logic_state  <= clear_reset;
          end
          else begin
            test_logic_state  <= wait_for_5us;
          end
        end
        
        clear_reset: begin
          CTRL_READ_EN      <= 1'b 0;                                           
          CTRL_WRITE_EN     <= 1'b 1;                                           
          CTRL_ADDR_REG     <= 5'h 2;             //control register
          CTRL_DATA_OUT      <= {24'b 0,8'h 00};   
          test_logic_state  <= wait_for_BSY_0;
          //counter_5us       <= 16'hFFFF;
          timeout_count_en    <= 1;
          timeout_count_reset <= 1;
        end  
          
        wait_for_BSY_0: begin
          timeout_count_reset <= 0;
          //counter_5us <= counter_5us -1;
          CTRL_READ_EN      <= 1'b 1;
          CTRL_WRITE_EN     <= 1'b 0;      
          CTRL_ADDR_REG     <= 5'h 4;
          RX_FIFO_RESET_OUT <= 0;
          TX_FIFO_RESET_OUT <= 0;
          if (timeout_count == 32'h 000FFFFF) begin
            test_logic_state  <= last_state;
            reset_controller  <= 1;
            timeout_count_en  <= 0;
            error             <= 1;
          end
          else if (timeout_count == 32'h 000FFFFE) begin
            test_logic_state  <= wait_for_BSY_0;
            reset_controller  <= 1;
            error             <= 1;
          end
          else if (timeout_count == 32'h 000FFFFD) begin
            test_logic_state  <= wait_for_BSY_0;
            reset_controller  <= 1;
            error             <= 1;
            error_count       <= error_count + 1;
          end
          else if(CTRL_DATA_IN[7] == 1'b0)begin
            test_logic_state <= write_feature_reg;
            timeout_count_en <= 0;
          end
          else begin
            test_logic_state <= wait_for_BSY_0; 
          end            
        end
        
//        check_for_BSY_2: begin
//          CTRL_READ_EN      <= 1'b 1;              
//          CTRL_WRITE_EN     <= 1'b 0;              
//          CTRL_ADDR_REG     <= 5'h 4;
//          if(CTRL_DATA_IN[7] == 1'b1)begin
//            test_logic_state <= check_for_BSY_2;
//          end
//          else begin
//            test_logic_state <= write_feature_reg;
//          end        
//        end

        write_feature_reg: begin                                                
          CTRL_READ_EN      <= 1'b 0;                                           
          CTRL_WRITE_EN     <= 1'b 1;                                           
          CTRL_ADDR_REG     <= 5'h 3;                                           
          CTRL_DATA_OUT     <= 32'h0;                                          
          test_logic_state  <= write_device_reg;                                
        end                                                                     
        write_device_reg: begin                                                 
          CTRL_READ_EN      <= 1'b 0;                                           
          CTRL_WRITE_EN     <= 1'b 1;                                           
          CTRL_ADDR_REG     <= 5'h 5;               
          CTRL_DATA_OUT     <= {24'b 0,8'h E0};   
          test_logic_state  <= write_LBA_low_reg;
        end        
        write_LBA_low_reg: begin
          CTRL_READ_EN      <= 1'b 0;              
          CTRL_WRITE_EN     <= 1'b 1;              
          CTRL_ADDR_REG     <= 5'h 7;               
          CTRL_DATA_OUT     <= test_lba_low_reg; //32'h 0;    
          test_logic_state  <= write_LBA_mid_reg;
        end
        write_LBA_mid_reg: begin
          CTRL_READ_EN      <= 1'b 0;               
          CTRL_WRITE_EN     <= 1'b 1;               
          CTRL_ADDR_REG     <= 5'h 8;               
          CTRL_DATA_OUT     <= test_lba_mid_reg; //32'h 0;             
          test_logic_state  <= write_LBA_high_reg;        
        end
        write_LBA_high_reg:begin
           CTRL_READ_EN      <= 1'b 0;              
           CTRL_WRITE_EN     <= 1'b 1;              
           CTRL_ADDR_REG     <= 5'h 9;              
           CTRL_DATA_OUT     <= test_lba_high_reg; //32'h 0;            
           test_logic_state  <= write_sector_cnt_reg;   
        end
        write_sector_cnt_reg: begin
           CTRL_READ_EN      <= 1'b 0;              
           CTRL_WRITE_EN     <= 1'b 1;              
           CTRL_ADDR_REG     <= 5'h A;              
           CTRL_DATA_OUT     <= test_sector_count_reg;           //no. of sectors
           sector_count      <= test_sector_count_reg;
           test_logic_state  <= write_cmd_reg;         
        end
        write_cmd_reg: begin
          CTRL_READ_EN      <= 1'b 0;              
                      
          CTRL_ADDR_REG     <= 5'h 1;
          error_from_SSD    <= 0;
          error             <= 0;          
          
          //CTRL_DATA_OUT      <= {24'b0,8'hEC}; test_logic_state  <= read_busy_bit; //Identify Device
          //CTRL_DATA_OUT      <= {24'b0,8'h24}; test_logic_state  <= read_busy_bit; //PIO read
          //CTRL_DATA_OUT      <= {24'b0,8'h34}; test_logic_state  <= read_busy_bit; //PIO write
          if (test_command_reg == 32'h1) begin
            CTRL_DATA_OUT      <= {24'b0,8'h25}; 
            DMA_RQST_OUT <= 1; 
            test_logic_state <= read_DMA;//DMA read
            throughput_count_en <= 1;
            CTRL_WRITE_EN     <= 1'b 1;  
          end
          else if (test_command_reg == 32'h2) begin
            CTRL_DATA_OUT      <= {24'b0,8'h35}; 
            //CTRL_DATA_OUT      <= {24'b0,8'hCA}; 
            DMA_RQST_OUT <= 1; 
            test_logic_state <= write_DMA;//DMA write
            throughput_count_en <= 1;
            CTRL_WRITE_EN     <= 1'b 1; 
            tx_ram_rd_en      <= 1'b 1;
          end
          else begin
            CTRL_WRITE_EN     <= 1'b 0; 
            test_logic_state <= last_state;
            throughput_count_en <= 0;
          end
        end
        //PIO rcv data
        read_busy_bit: begin
          CTRL_READ_EN      <= 1'b 1;              
          CTRL_WRITE_EN     <= 1'b 0;              
          CTRL_ADDR_REG     <= 5'h 4;
          test_logic_state  <= check_for_BSY_1;
        end
        check_for_BSY_1: begin
          CTRL_READ_EN      <= 1'b 1;              
          CTRL_WRITE_EN     <= 1'b 0;              
          CTRL_ADDR_REG     <= 5'h 4;
          if(CTRL_DATA_IN[7] == 1'b1)begin
            test_logic_state <= check_for_BSY_1;
          end
          else begin
            read_count       <= 32'h0;
            CTRL_READ_EN      <= 1'b 0;
            CTRL_WRITE_EN      <= 1'b 0;
            //test_logic_state <= read_data_reg_con;
            test_logic_state <= write_data_reg_con;
            
          end        
        end 
        
        write_data_reg_con: begin
          if (SATA_WR_HOLD_IN)begin
            CTRL_WRITE_EN     <= 0;
            CTRL_ADDR_REG    <= data_reg;
            test_logic_state <= write_data_reg_con;
            read_count       <= read_count;
            CTRL_DATA_OUT    <= CTRL_DATA_OUT;
          end
          else begin
            if (read_count < 32'h200) begin
              test_logic_state <= write_data_reg_con;
              CTRL_WRITE_EN     <= 1;
              CTRL_ADDR_REG    <= data_reg;
              read_count       <= read_count + 4;
              CTRL_DATA_OUT    <= read_count;
            end
            else begin
              test_logic_state <= sector_count_check;
              sector_count     <= sector_count - 1;
              CTRL_READ_EN     <= 1'b 1;
              CTRL_WRITE_EN    <= 0;
              CTRL_ADDR_REG    <= 5'h 4;
              read_count       <= 32'h0;
              CTRL_DATA_OUT    <= 32'h0;
            end
          end
        end
        
        sector_count_check: begin
          if (sector_count == 0) begin
            test_logic_state <= last_state;
          end
          else begin
            test_logic_state <= read_busy_bit;
          end
        end

        read_data_reg_con: begin
          if (SATA_RD_HOLD_IN)begin
            CTRL_READ_EN     <= 0;
            CTRL_ADDR_REG    <= data_reg;
            test_logic_state <= read_data_reg_con;
            read_count       <= read_count;
          end
          else begin
            if (read_count < {test_sector_count_reg << 1, 8'h00}) begin
              test_logic_state <= read_data_reg_con;
              CTRL_READ_EN     <= 1;
              CTRL_ADDR_REG    <= data_reg;
              read_count       <= read_count + 4;
            end
            else begin
              test_logic_state <= last_state;
              CTRL_READ_EN     <= 0;
              CTRL_ADDR_REG    <= data_reg;
              read_count       <= 32'h0;
            end
          end
        end
        
        read_DMA: begin
          if (R_ERR || ILLEGAL_STATE) begin
              test_logic_state <= last_state;
              CTRL_READ_EN     <= 0;
              CTRL_WRITE_EN    <= 0;
              DMA_RX_REN_OUT   <= 0;
              read_count       <= 32'h0;
              //DMA_TX_DATA_OUT  <= 32'h0;
              error            <= 1;
              error_count      <= error_count + 1;
          end
          else if (SATA_RD_HOLD_IN) begin
            DMA_RX_REN_OUT   <= 0;
            CTRL_READ_EN     <= 0;
            CTRL_WRITE_EN    <= 0;
            
            if ((throughput_count == 32'h 00FFFFFF)) begin
              test_logic_state <= last_state;
              error            <= 1;
              error_count      <= error_count + 1;
            end
            else if ((read_count == {test_sector_count_reg << 1, 8'h00})) begin
              test_logic_state <= read_busy_bit_after_write_DMA;
            end
            else begin
              test_logic_state <= read_DMA;
            end
            
            read_count       <= read_count;
          end
          else begin
            if (read_count < {test_sector_count_reg << 1, 8'h00}) begin
              test_logic_state  <= read_DMA;
              DMA_RX_REN_OUT    <= 1;
              CTRL_READ_EN      <= 0;
              CTRL_WRITE_EN     <= 0;
              read_count        <= read_count + 4;
              rx_ram_wr_port_en <= 1;
            end
            else begin
              test_logic_state <= read_busy_bit_after_write_DMA;
              DMA_RX_REN_OUT   <= 0;
              CTRL_READ_EN     <= 0;
              CTRL_WRITE_EN    <= 0;
              //read_count       <= 0;
            end
          end
        end
        
        write_DMA: begin
          if (DMA_TERMINATED) begin
            test_logic_state <= read_busy_bit_after_write_DMA;
            CTRL_READ_EN     <= 0;
            CTRL_WRITE_EN    <= 0;
            DMA_TX_WEN_OUT   <= 0;
            read_count       <= 32'h0;
            //DMA_TX_DATA_OUT  <= 32'h0;
          end
          else if (R_ERR || ILLEGAL_STATE) begin
              test_logic_state <= last_state;
              CTRL_READ_EN     <= 0;
              CTRL_WRITE_EN    <= 0;
              DMA_TX_WEN_OUT   <= 0;
              read_count       <= 32'h0;
              //DMA_TX_DATA_OUT  <= 32'h0;
              error            <= 1;
              error_count      <= error_count + 1;
          end
          else if (SATA_WR_HOLD_IN)begin
            CTRL_WRITE_EN      <= 0;
            DMA_TX_WEN_OUT     <= 0;
            if ((throughput_count == 32'h 00FFFFFF)) begin
              test_logic_state <= last_state;
              error            <= 1;
              error_count      <= error_count + 1;
            end
            else begin
              test_logic_state   <= write_DMA;
            end
            read_count         <= read_count;
            //DMA_TX_DATA_OUT    <= DMA_TX_DATA_OUT;
          end
          else if (read_count < ({test_sector_count_reg << 1, 8'h00})) begin
            test_logic_state <= write_DMA;
            CTRL_WRITE_EN    <= 0;
            DMA_TX_WEN_OUT   <= 1;
            read_count       <= read_count + 4;
            //DMA_TX_DATA_OUT  <= read_count;
          end
          else begin
            test_logic_state <= read_busy_bit_after_write_DMA;
            CTRL_READ_EN     <= 0;
            CTRL_WRITE_EN    <= 0;
            DMA_TX_WEN_OUT   <= 0;
            //DMA_TX_DATA_OUT  <= 32'h0;
            tx_ram_rd_en     <= 0;
            timeout_count_en <= 1;
            timeout_count_reset <= 1;
          end
        end
        
        read_busy_bit_after_write_DMA: begin
          timeout_count_reset  <= 0;
          CTRL_READ_EN      <= 1'b 1;              
          CTRL_WRITE_EN     <= 1'b 0;              
          CTRL_ADDR_REG     <= 5'h 4;
          test_logic_state  <= check_for_BSY_3;
        end
        
        
        check_for_BSY_3: begin
          CTRL_READ_EN      <= 1'b 1;              
          CTRL_WRITE_EN     <= 1'b 0;              
          CTRL_ADDR_REG     <= 5'h 4;
          if ((timeout_count == 32'h 000FFFFF)) begin
              test_logic_state <= last_state;
              error            <= 1;
              error_count      <= error_count + 1;
              timeout_count_en <= 0;
          end
          else if(CTRL_DATA_IN[7] == 1'b1)begin
            test_logic_state <= check_for_BSY_3;
          end
          else begin
            read_count       <= 32'h0;
            CTRL_READ_EN     <= 1'b 0;
            CTRL_WRITE_EN    <= 1'b 0;
            test_logic_state <= last_state;
            error_from_SSD   <= CTRL_DATA_IN[0];
            if (CTRL_DATA_IN[0] == 1) begin
              error_count      <= error_count + 1;
            end
            else begin
              error_count      <= error_count;
            end
          end        
        end 
        
        last_state: begin
          CTRL_READ_EN        <= 0;
          CTRL_WRITE_EN       <= 0;
          CTRL_ADDR_REG       <= 5'h 0;
          test_logic_state    <= last_state_2;
          throughput_count_en <= 0;
          read_count          <= 32'h 0;
          reset_controller    <= 0;
          tx_ram_rd_en        <= 0;
          rx_ram_wr_port_en   <= 0;
          timeout_count_en    <= 0;
        end
                
        last_state_2: begin
          CTRL_READ_EN        <= 0;
          CTRL_WRITE_EN       <= 0;
          CTRL_ADDR_REG       <= 5'h 0;
          test_logic_state    <= last_state_3;
          throughput_count_en <= 0;
          read_count          <= 32'h 0;
          reset_controller    <= 0;
          tx_ram_rd_en        <= 0;
          rx_ram_wr_port_en   <= 0;
        end
        
        last_state_3: begin
          CTRL_READ_EN        <= 0;
          CTRL_WRITE_EN       <= 0;
          CTRL_ADDR_REG       <= 5'h 0;
          test_logic_state    <= last_state_4;
          throughput_count_en <= 0;
          read_count          <= 32'h 0;
          reset_controller    <= 0;
          tx_ram_rd_en        <= 0;
          rx_ram_wr_port_en   <= 0;
        end
        
        last_state_4: begin
          CTRL_READ_EN        <= 0;
          CTRL_WRITE_EN       <= 0;
          CTRL_ADDR_REG       <= 5'h 0;
          test_logic_state    <= wait_for_cmd;
          throughput_count_en <= 0;
          read_count          <= 32'h 0;
          reset_controller    <= 0;
          tx_ram_rd_en        <= 0;
          rx_ram_wr_port_en   <= 0;
        end
        
        default: begin
          CTRL_READ_EN        <= 0;
          CTRL_WRITE_EN       <= 0;
          CTRL_ADDR_REG       <= 5'h 0;
          test_logic_state    <= wait_for_cmd;
          throughput_count_en <= 0;
          read_count          <= 32'h 0;
          reset_controller    <= 0;
          tx_ram_rd_en        <= 0;
          rx_ram_wr_port_en   <= 0;
        end
      endcase
    end    
  end //always
  
  assign tx_ram_wr_en = ((MB_ADRESS[31:16] == 'h8001) && (MB_CS == 1)) ? 1 : 0;
  
  TEST_TX_DP_RAM TX_RAM (
    .clka   (MB_CLK),            // input clka
    .ena    (tx_ram_wr_en),      // input ena
    .wea    (mb_wr_en),          // input [0 : 0] wea
    .addra  (MB_ADRESS[12:2]),   // input [10 : 0] addra
    .dina   (MB_DATA_IN),        // input [31 : 0] dina
    .clkb   (CLK),               // input clkb
    .enb    (tx_ram_rd_en),      // input enb
    .addrb  (read_count[12:2]),  // input [10 : 0] addrb
    .doutb  (DMA_TX_DATA_OUT)    // output [31 : 0] doutb
  );
 
  assign rx_ram_rd_en   = ((MB_ADRESS[31:16] == 'h8002) && (mb_rd_en == 1)) ? 1 : 0;
  assign rx_ram_wr_addr = read_count - 4;
  
  TEST_TX_DP_RAM RX_RAM (
    .clka   (CLK),                   // input clka
    .ena    (rx_ram_wr_port_en),     // input ena
    .wea    (DMA_RX_REN_OUT),        // input [0 : 0] wea
    .addra  (rx_ram_wr_addr[12:2]),  // input [10 : 0] addra
    .dina   (DMA_RX_DATA_IN),        // input [31 : 0] dina
    .clkb   (MB_CLK),                // input clkb
    .enb    (rx_ram_rd_en),          // input enb
    .addrb  (MB_ADRESS[12:2]),       // input [10 : 0] addrb
    .doutb  (rx_ram_dout)            // output [31 : 0] doutb
  );

endmodule
