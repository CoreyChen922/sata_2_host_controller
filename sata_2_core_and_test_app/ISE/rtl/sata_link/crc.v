//----------------------------------------------------------------------------------------------------------\
// CRC module for data[31:0] , crc[31:0]=1+x^1+x^2+x^4+x^5+x^7+x^8+x^10+x^11+x^12+x^16+x^22+x^23+x^26+x^32; |
//----------------------------------------------------------------------------------------------------------/
module crc(
   input  [31:0] data_in ,
   input         crc_en  ,
   output [31:0] crc_out ,
   input         rst     ,
   output reg [31:0] lfsr_c  ,
   output reg     CRC_cal_ip,
   input         clk     );
 
   reg    [31:0] lfsr_q;
   
   assign crc_out = lfsr_q;
 
   always @(*) 
   begin
      lfsr_c[0]  = lfsr_q[0]   ^ lfsr_q[6]   ^ lfsr_q[9]   ^ lfsr_q[10]  ^ lfsr_q[12]  ^ 
                   lfsr_q[16]  ^ lfsr_q[24]  ^ lfsr_q[25]  ^ lfsr_q[26]  ^ lfsr_q[28]  ^ 
                   lfsr_q[29]  ^ lfsr_q[30]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[6]  ^ data_in[9]  ^ data_in[10] ^ data_in[12] ^ 
                   data_in[16] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ 
                   data_in[29] ^ data_in[30] ^ data_in[31] ;
      lfsr_c[1]  = lfsr_q[0]   ^ lfsr_q[1]   ^ lfsr_q[6]   ^ lfsr_q[7]   ^ lfsr_q[9]   ^ 
                   lfsr_q[11]  ^ lfsr_q[12]  ^ lfsr_q[13]  ^ lfsr_q[16]  ^ lfsr_q[17]  ^ 
                   lfsr_q[24]  ^ lfsr_q[27]  ^ lfsr_q[28]  ^ 
                   data_in[0]  ^ data_in[1]  ^ data_in[6]  ^ data_in[7]  ^ data_in[9]  ^ 
                   data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ 
                   data_in[24] ^ data_in[27] ^ data_in[28] ;
      lfsr_c[2]  = lfsr_q[0]   ^ lfsr_q[1]   ^ lfsr_q[2]   ^ lfsr_q[6]   ^ lfsr_q[7]   ^ 
                   lfsr_q[8]   ^ lfsr_q[9]   ^ lfsr_q[13]  ^ lfsr_q[14]  ^ lfsr_q[16]  ^ 
                   lfsr_q[17]  ^ lfsr_q[18]  ^ lfsr_q[24]  ^ lfsr_q[26]  ^ lfsr_q[30]  ^ 
                   lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[1]  ^ data_in[2]  ^ data_in[6]  ^ data_in[7]  ^ 
                   data_in[8]  ^ data_in[9]  ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ 
                   data_in[17] ^ data_in[18] ^ data_in[24] ^ data_in[26] ^ data_in[30] ^ 
                   data_in[31] ;
      lfsr_c[3]  = lfsr_q[1]   ^ lfsr_q[2]   ^ lfsr_q[3]   ^ lfsr_q[7]   ^ lfsr_q[8]   ^ 
                   lfsr_q[9]   ^ lfsr_q[10]  ^ lfsr_q[14]  ^ lfsr_q[15]  ^ lfsr_q[17]  ^ 
                   lfsr_q[18]  ^ lfsr_q[19]  ^ lfsr_q[25]  ^ lfsr_q[27]  ^ lfsr_q[31]  ^ 
                   data_in[1]  ^ data_in[2]  ^ data_in[3]  ^ data_in[7]  ^ data_in[8]  ^ 
                   data_in[9]  ^ data_in[10] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ 
                   data_in[18] ^ data_in[19] ^ data_in[25] ^ data_in[27] ^ data_in[31] ;
      lfsr_c[4]  = lfsr_q[0]   ^ lfsr_q[2]   ^ lfsr_q[3]   ^ lfsr_q[4]   ^ lfsr_q[6]   ^ 
                   lfsr_q[8]   ^ lfsr_q[11]  ^ lfsr_q[12]  ^ lfsr_q[15]  ^ lfsr_q[18]  ^ 
                   lfsr_q[19]  ^ lfsr_q[20]  ^ lfsr_q[24]  ^ lfsr_q[25]  ^ lfsr_q[29]  ^ 
                   lfsr_q[30]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[2]  ^ data_in[3]  ^ data_in[4]  ^ data_in[6]  ^ 
                   data_in[8]  ^ data_in[11] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ 
                   data_in[19] ^ data_in[20] ^ data_in[24] ^ data_in[25] ^ data_in[29] ^ 
                   data_in[30] ^ data_in[31] ;
      lfsr_c[5]  = lfsr_q[0]   ^ lfsr_q[1]   ^ lfsr_q[3]   ^ lfsr_q[4]   ^ lfsr_q[5]   ^ 
                   lfsr_q[6]   ^ lfsr_q[7]   ^ lfsr_q[10]  ^ lfsr_q[13]  ^ lfsr_q[19]  ^ 
                   lfsr_q[20]  ^ lfsr_q[21]  ^ lfsr_q[24]  ^ lfsr_q[28]  ^ lfsr_q[29]  ^ 
                   data_in[0]  ^ data_in[1]  ^ data_in[3]  ^ data_in[4]  ^ data_in[5]  ^ 
                   data_in[6]  ^ data_in[7]  ^ data_in[10] ^ data_in[13] ^ data_in[19] ^ 
                   data_in[20] ^ data_in[21] ^ data_in[24] ^ data_in[28] ^ data_in[29] ;
      lfsr_c[6]  = lfsr_q[1]   ^ lfsr_q[2]   ^ lfsr_q[4]   ^ lfsr_q[5]   ^ lfsr_q[6]   ^ 
                   lfsr_q[7]   ^ lfsr_q[8]   ^ lfsr_q[11]  ^ lfsr_q[14]  ^ lfsr_q[20]  ^ 
                   lfsr_q[21]  ^ lfsr_q[22]  ^ lfsr_q[25]  ^ lfsr_q[29]  ^ lfsr_q[30]  ^ 
                   data_in[1]  ^ data_in[2]  ^ data_in[4]  ^ data_in[5]  ^ data_in[6]  ^ 
                   data_in[7]  ^ data_in[8]  ^ data_in[11] ^ data_in[14] ^ data_in[20] ^ 
                   data_in[21] ^ data_in[22] ^ data_in[25] ^ data_in[29] ^ data_in[30] ;
      lfsr_c[7]  = lfsr_q[0]   ^ lfsr_q[2]   ^ lfsr_q[3]   ^ lfsr_q[5]   ^ lfsr_q[7]   ^ 
                   lfsr_q[8]   ^ lfsr_q[10]  ^ lfsr_q[15]  ^ lfsr_q[16]  ^ lfsr_q[21]  ^ 
                   lfsr_q[22]  ^ lfsr_q[23]  ^ lfsr_q[24]  ^ lfsr_q[25]  ^ lfsr_q[28]  ^ 
                   lfsr_q[29]  ^ 
                   data_in[0]  ^ data_in[2]  ^ data_in[3]  ^ data_in[5]  ^ data_in[7]  ^ 
                   data_in[8]  ^ data_in[10] ^ data_in[15] ^ data_in[16] ^ data_in[21] ^ 
                   data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[28] ^ 
                   data_in[29] ;
      lfsr_c[8]  = lfsr_q[0]   ^ lfsr_q[1]   ^ lfsr_q[3]   ^ lfsr_q[4]   ^ lfsr_q[8]   ^ 
                   lfsr_q[10]  ^ lfsr_q[11]  ^ lfsr_q[12]  ^ lfsr_q[17]  ^ lfsr_q[22]  ^ 
                   lfsr_q[23]  ^ lfsr_q[28]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[1]  ^ data_in[3]  ^ data_in[4]  ^ data_in[8]  ^ 
                   data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[17] ^ data_in[22] ^ 
                   data_in[23] ^ data_in[28] ^ data_in[31] ;
      lfsr_c[9]  = lfsr_q[1]   ^ lfsr_q[2]   ^ lfsr_q[4]   ^ lfsr_q[5]   ^ lfsr_q[9]   ^ 
                   lfsr_q[11]  ^ lfsr_q[12]  ^ lfsr_q[13]  ^ lfsr_q[18]  ^ lfsr_q[23]  ^ 
                   lfsr_q[24]  ^ lfsr_q[29]  ^ 
                   data_in[1]  ^ data_in[2]  ^ data_in[4]  ^ data_in[5]  ^ data_in[9]  ^ 
                   data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[18] ^ data_in[23] ^ 
                   data_in[24] ^ data_in[29] ;
      lfsr_c[10] = lfsr_q[0]   ^ lfsr_q[2]   ^ lfsr_q[3]   ^ lfsr_q[5]   ^ lfsr_q[9]   ^ 
                   lfsr_q[13]  ^ lfsr_q[14]  ^ lfsr_q[16]  ^ lfsr_q[19]  ^ lfsr_q[26]  ^ 
                   lfsr_q[28]  ^ lfsr_q[29]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[2]  ^ data_in[3]  ^ data_in[5]  ^ data_in[9]  ^ 
                   data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[19] ^ data_in[26] ^ 
                   data_in[28] ^ data_in[29] ^ data_in[31] ;
      lfsr_c[11] = lfsr_q[0]   ^ lfsr_q[1]   ^ lfsr_q[3]   ^ lfsr_q[4]   ^ lfsr_q[9]   ^ 
                   lfsr_q[12]  ^ lfsr_q[14]  ^ lfsr_q[15]  ^ lfsr_q[16]  ^ lfsr_q[17]  ^ 
                   lfsr_q[20]  ^ lfsr_q[24]  ^ lfsr_q[25]  ^ lfsr_q[26]  ^ lfsr_q[27]  ^ 
                   lfsr_q[28]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[1]  ^ data_in[3]  ^ data_in[4]  ^ data_in[9]  ^ 
                   data_in[12] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ 
                   data_in[20] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ 
                   data_in[28] ^ data_in[31] ;
      lfsr_c[12] = lfsr_q[0]   ^ lfsr_q[1]   ^ lfsr_q[2]   ^ lfsr_q[4]   ^ lfsr_q[5]   ^ 
                   lfsr_q[6]   ^ lfsr_q[9]   ^ lfsr_q[12]  ^ lfsr_q[13]  ^ lfsr_q[15]  ^ 
                   lfsr_q[17]  ^ lfsr_q[18]  ^ lfsr_q[21]  ^ lfsr_q[24]  ^ lfsr_q[27]  ^ 
                   lfsr_q[30]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[1]  ^ data_in[2]  ^ data_in[4]  ^ data_in[5]  ^ 
                   data_in[6]  ^ data_in[9]  ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ 
                   data_in[17] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ 
                   data_in[30] ^ data_in[31] ;
      lfsr_c[13] = lfsr_q[1]   ^ lfsr_q[2]   ^ lfsr_q[3]   ^ lfsr_q[5]   ^ lfsr_q[6]   ^ 
                   lfsr_q[7]   ^ lfsr_q[10]  ^ lfsr_q[13]  ^ lfsr_q[14]  ^ lfsr_q[16]  ^ 
                   lfsr_q[18]  ^ lfsr_q[19]  ^ lfsr_q[22]  ^ lfsr_q[25]  ^ lfsr_q[28]  ^ 
                   lfsr_q[31]  ^ 
                   data_in[1]  ^ data_in[2]  ^ data_in[3]  ^ data_in[5]  ^ data_in[6]  ^ 
                   data_in[7]  ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ 
                   data_in[18] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28] ^ 
                   data_in[31] ;
      lfsr_c[14] = lfsr_q[2]   ^ lfsr_q[3]   ^ lfsr_q[4]   ^ lfsr_q[6]   ^ lfsr_q[7]   ^ 
                   lfsr_q[8]   ^ lfsr_q[11]  ^ lfsr_q[14]  ^ lfsr_q[15]  ^ lfsr_q[17]  ^ 
                   lfsr_q[19]  ^ lfsr_q[20]  ^ lfsr_q[23]  ^ lfsr_q[26]  ^ lfsr_q[29]  ^ 
                   data_in[2]  ^ data_in[3]  ^ data_in[4]  ^ data_in[6]  ^ data_in[7]  ^ 
                   data_in[8]  ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ 
                   data_in[19] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29] ;
      lfsr_c[15] = lfsr_q[3]   ^ lfsr_q[4]   ^ lfsr_q[5]   ^ lfsr_q[7]   ^ lfsr_q[8]   ^ 
                   lfsr_q[9]   ^ lfsr_q[12]  ^ lfsr_q[15]  ^ lfsr_q[16]  ^ lfsr_q[18]  ^ 
                   lfsr_q[20]  ^ lfsr_q[21]  ^ lfsr_q[24]  ^ lfsr_q[27]  ^ lfsr_q[30]  ^ 
                   data_in[3]  ^ data_in[4]  ^ data_in[5]  ^ data_in[7]  ^ data_in[8]  ^ 
                   data_in[9]  ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ 
                   data_in[20] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30] ;
      lfsr_c[16] = lfsr_q[0]   ^ lfsr_q[4]   ^ lfsr_q[5]   ^ lfsr_q[8]   ^ lfsr_q[12]  ^ 
                   lfsr_q[13]  ^ lfsr_q[17]  ^ lfsr_q[19]  ^ lfsr_q[21]  ^ lfsr_q[22]  ^ 
                   lfsr_q[24]  ^ lfsr_q[26]  ^ lfsr_q[29]  ^ lfsr_q[30]  ^ 
                   data_in[0]  ^ data_in[4]  ^ data_in[5]  ^ data_in[8]  ^ data_in[12] ^ 
                   data_in[13] ^ data_in[17] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ 
                   data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30] ;
      lfsr_c[17] = lfsr_q[1]   ^ lfsr_q[5]   ^ lfsr_q[6]   ^ lfsr_q[9]   ^ lfsr_q[13]  ^ 
                   lfsr_q[14]  ^ lfsr_q[18]  ^ lfsr_q[20]  ^ lfsr_q[22]  ^ lfsr_q[23]  ^ 
                   lfsr_q[25]  ^ lfsr_q[27]  ^ lfsr_q[30]  ^ lfsr_q[31]  ^ 
                   data_in[1]  ^ data_in[5]  ^ data_in[6]  ^ data_in[9]  ^ data_in[13] ^ 
                   data_in[14] ^ data_in[18] ^ data_in[20] ^ data_in[22] ^ data_in[23] ^ 
                   data_in[25] ^ data_in[27] ^ data_in[30] ^ data_in[31] ;
      lfsr_c[18] = lfsr_q[2]   ^ lfsr_q[6]   ^ lfsr_q[7]   ^ lfsr_q[10]  ^ lfsr_q[14]  ^ 
                   lfsr_q[15]  ^ lfsr_q[19]  ^ lfsr_q[21]  ^ lfsr_q[23]  ^ lfsr_q[24]  ^ 
                   lfsr_q[26]  ^ lfsr_q[28]  ^ lfsr_q[31]  ^ 
                   data_in[2]  ^ data_in[6]  ^ data_in[7]  ^ data_in[10] ^ data_in[14] ^ 
                   data_in[15] ^ data_in[19] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ 
                   data_in[26] ^ data_in[28] ^ data_in[31] ;
      lfsr_c[19] = lfsr_q[3]   ^ lfsr_q[7]   ^ lfsr_q[8]   ^ lfsr_q[11]  ^ lfsr_q[15]  ^ 
                   lfsr_q[16]  ^ lfsr_q[20]  ^ lfsr_q[22]  ^ lfsr_q[24]  ^ lfsr_q[25]  ^ 
                   lfsr_q[27]  ^ lfsr_q[29]  ^ 
                   data_in[3]  ^ data_in[7]  ^ data_in[8]  ^ data_in[11] ^ data_in[15] ^ 
                   data_in[16] ^ data_in[20] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ 
                   data_in[27] ^ data_in[29] ;
      lfsr_c[20] = lfsr_q[4]   ^ lfsr_q[8]   ^ lfsr_q[9]   ^ lfsr_q[12]  ^ lfsr_q[16]  ^ 
                   lfsr_q[17]  ^ lfsr_q[21]  ^ lfsr_q[23]  ^ lfsr_q[25]  ^ lfsr_q[26]  ^ 
                   lfsr_q[28]  ^ lfsr_q[30]  ^ 
                   data_in[4]  ^ data_in[8]  ^ data_in[9]  ^ data_in[12] ^ data_in[16] ^ 
                   data_in[17] ^ data_in[21] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ 
                   data_in[28] ^ data_in[30] ;
      lfsr_c[21] = lfsr_q[5]   ^ lfsr_q[9]   ^ lfsr_q[10]  ^ lfsr_q[13]  ^ lfsr_q[17]  ^ 
                   lfsr_q[18]  ^ lfsr_q[22]  ^ lfsr_q[24]  ^ lfsr_q[26]  ^ lfsr_q[27]  ^ 
                   lfsr_q[29]  ^ lfsr_q[31]  ^ 
                   data_in[5]  ^ data_in[9]  ^ data_in[10] ^ data_in[13] ^ data_in[17] ^ 
                   data_in[18] ^ data_in[22] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ 
                   data_in[29] ^ data_in[31] ;
      lfsr_c[22] = lfsr_q[0]   ^ lfsr_q[9]   ^ lfsr_q[11]  ^ lfsr_q[12]  ^ lfsr_q[14]  ^ 
                   lfsr_q[16]  ^ lfsr_q[18]  ^ lfsr_q[19]  ^ lfsr_q[23]  ^ lfsr_q[24]  ^ 
                   lfsr_q[26]  ^ lfsr_q[27]  ^ lfsr_q[29]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[9]  ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ 
                   data_in[16] ^ data_in[18] ^ data_in[19] ^ data_in[23] ^ data_in[24] ^ 
                   data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ;
      lfsr_c[23] = lfsr_q[0]   ^ lfsr_q[1]   ^ lfsr_q[6]   ^ lfsr_q[9]   ^ lfsr_q[13]  ^ 
                   lfsr_q[15]  ^ lfsr_q[16]  ^ lfsr_q[17]  ^ lfsr_q[19]  ^ lfsr_q[20]  ^ 
                   lfsr_q[26]  ^ lfsr_q[27]  ^ lfsr_q[29]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[1]  ^ data_in[6]  ^ data_in[9]  ^ data_in[13] ^ 
                   data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ 
                   data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ;
      lfsr_c[24] = lfsr_q[1]   ^ lfsr_q[2]   ^ lfsr_q[7]   ^ lfsr_q[10]  ^ lfsr_q[14]  ^ 
                   lfsr_q[16]  ^ lfsr_q[17]  ^ lfsr_q[18]  ^ lfsr_q[20]  ^ lfsr_q[21]  ^ 
                   lfsr_q[27]  ^ lfsr_q[28]  ^ lfsr_q[30]  ^ 
                   data_in[1]  ^ data_in[2]  ^ data_in[7]  ^ data_in[10] ^ data_in[14] ^ 
                   data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^ 
                   data_in[27] ^ data_in[28] ^ data_in[30] ;
      lfsr_c[25] = lfsr_q[2]   ^ lfsr_q[3]   ^ lfsr_q[8]   ^ lfsr_q[11]  ^ lfsr_q[15]  ^ 
                   lfsr_q[17]  ^ lfsr_q[18]  ^ lfsr_q[19]  ^ lfsr_q[21]  ^ lfsr_q[22]  ^ 
                   lfsr_q[28]  ^ lfsr_q[29]  ^ lfsr_q[31]  ^ 
                   data_in[2]  ^ data_in[3]  ^ data_in[8]  ^ data_in[11] ^ data_in[15] ^ 
                   data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ 
                   data_in[28] ^ data_in[29] ^ data_in[31] ;
      lfsr_c[26] = lfsr_q[0]   ^ lfsr_q[3]   ^ lfsr_q[4]   ^ lfsr_q[6]   ^ lfsr_q[10]  ^ 
                   lfsr_q[18]  ^ lfsr_q[19]  ^ lfsr_q[20]  ^ lfsr_q[22]  ^ lfsr_q[23]  ^ 
                   lfsr_q[24]  ^ lfsr_q[25]  ^ lfsr_q[26]  ^ lfsr_q[28]  ^ lfsr_q[31]  ^ 
                   data_in[0]  ^ data_in[3]  ^ data_in[4]  ^ data_in[6]  ^ data_in[10] ^ 
                   data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[23] ^ 
                   data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[31] ;
      lfsr_c[27] = lfsr_q[1]   ^ lfsr_q[4]   ^ lfsr_q[5]   ^ lfsr_q[7]   ^ lfsr_q[11]  ^ 
                   lfsr_q[19]  ^ lfsr_q[20]  ^ lfsr_q[21]  ^ lfsr_q[23]  ^ lfsr_q[24]  ^ 
                   lfsr_q[25]  ^ lfsr_q[26]  ^ lfsr_q[27]  ^ lfsr_q[29]  ^ 
                   data_in[1]  ^ data_in[4]  ^ data_in[5]  ^ data_in[7]  ^ data_in[11] ^ 
                   data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ 
                   data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[29] ;
      lfsr_c[28] = lfsr_q[2]   ^ lfsr_q[5]   ^ lfsr_q[6]   ^ lfsr_q[8]   ^ lfsr_q[12]  ^ 
                   lfsr_q[20]  ^ lfsr_q[21]  ^ lfsr_q[22]  ^ lfsr_q[24]  ^ lfsr_q[25]  ^ 
                   lfsr_q[26]  ^ lfsr_q[27]  ^ lfsr_q[28]  ^ lfsr_q[30]  ^ 
                   data_in[2]  ^ data_in[5]  ^ data_in[6]  ^ data_in[8]  ^ data_in[12] ^ 
                   data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ 
                   data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[30] ;
      lfsr_c[29] = lfsr_q[3]   ^ lfsr_q[6]   ^ lfsr_q[7]   ^ lfsr_q[9]   ^ lfsr_q[13]  ^ 
                   lfsr_q[21]  ^ lfsr_q[22]  ^ lfsr_q[23]  ^ lfsr_q[25]  ^ lfsr_q[26]  ^ 
                   lfsr_q[27]  ^ lfsr_q[28]  ^ lfsr_q[29]  ^ lfsr_q[31]  ^ 
                   data_in[3]  ^ data_in[6]  ^ data_in[7]  ^ data_in[9]  ^ data_in[13] ^ 
                   data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ 
                   data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[31] ;
      lfsr_c[30] = lfsr_q[4]   ^ lfsr_q[7]   ^ lfsr_q[8]   ^ lfsr_q[10]  ^ lfsr_q[14]  ^ 
                   lfsr_q[22]  ^ lfsr_q[23]  ^ lfsr_q[24]  ^ lfsr_q[26]  ^ lfsr_q[27]  ^ 
                   lfsr_q[28]  ^ lfsr_q[29]  ^ lfsr_q[30]  ^ 
                   data_in[4]  ^ data_in[7]  ^ data_in[8]  ^ data_in[10] ^ data_in[14] ^ 
                   data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ 
                   data_in[28] ^ data_in[29] ^ data_in[30] ;
      lfsr_c[31] = lfsr_q[5]   ^ lfsr_q[8]   ^ lfsr_q[9]   ^ lfsr_q[11]  ^ lfsr_q[15]  ^ 
                   lfsr_q[23]  ^ lfsr_q[24]  ^ lfsr_q[25]  ^ lfsr_q[27]  ^ lfsr_q[28]  ^ 
                   lfsr_q[29]  ^ lfsr_q[30]  ^ lfsr_q[31]  ^ 
                   data_in[5]  ^ data_in[8]  ^ data_in[9]  ^ data_in[11] ^ data_in[15] ^ 
                   data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[28] ^ 
                   data_in[29] ^ data_in[30] ^ data_in[31] ;

   end // always
   
   always @(posedge clk, posedge rst) 
   begin
      if(rst)
      begin
        CRC_cal_ip <= 1'b 0 ;
        lfsr_q     <= 32'h 52325032 ;       
      end 
//    else if (CRC_cal_ip) begin     
//      CRC_cal_ip <= crc_en ;
//      lfsr_q     <= lfsr_c ;
//    end 
      else if (crc_en) begin
        lfsr_q     <= lfsr_c ;  //32'h 52325032 ;
        CRC_cal_ip <= 1'b 1;    
      end 
      else begin
        CRC_cal_ip <= 1'b 0 ;
        lfsr_q     <= lfsr_q ;
      end
   end // always
endmodule                                                                             