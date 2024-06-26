module ControlUnit ( 
    input [7:0] T, input [7:0] D ,input I, input [7:0] B, 
    output  LDAC, CLRAC, INRAC,LDAR,RriteMem,LDDR,LDIR,INRPC,CLRSC,
    output [0:2] s, 
    output AND,ADD,LDA,CMA,OR,INC
); 
// AC 
AC_Control my_ac ( 
    .T(T), 
    .D(D), 
    .I(I), 
    .B(B), 
    .LD(LDAC), 
    .CLR(CLRAC), 
    .INR(INRAC) 
); 
//AR 
AR_Control ar(
.I(I),
.T(T),
.D(D),
.LD(LDAR)
) ; 
 //DR OUT
 DR_Control dr ( 
 .T(T),
 .D(D),
 .Load(LDDR)
); 
 //IR
IR_Control  ir ( 
 .T(T),
 .load(LDIR)
); 
 //PC 
 PC_Control  pc ( 
 .T(T),
 .D(D),
 .I(I),
 .INR(INRPC)
); 
//RAM 
 MEM_Control mem ( 
 .I(I), 
 .T(T),  
 .D(D), 
 .R(RriteMem) 
); 
// SC 
SC_Control  sc ( 
 .T(T),
 .D(D),
 .I(I),
 .CLR(CLRSC)
); 
// controlBus 
wire [7:0]x; 
CommonBus_Control commanBus( 
.x(x),  
.D(D), 
.T(T), 
.I(I) 
); 
Selections SELECT( 
    .x(x), 
    .s(s) 
); 
ALU_CONTROL alu ( 
.B(B),  
.D(D), 
.T(T), 
.I(I),
.AND(AND),
.ADD(ADD),
.LDA(LDA),
.CMA(CMA),
.OR(OR),
.INC(INC) 
); 
endmodule 
//  AC_Control 
module AC_Control ( 
    input [7:0] T, input [7:0] D ,input I, input [7:0] B, 
    output  LD,CLR,INR 
); 
assign LD= (T[5]  & (D[0]|D[1]|D[2]) ) | ((D[7] & !I & T[3]) &B[2]) | (D[5]&T[5])|((D[7] & !I & T[3])&B[0]); //B[9]
assign CLR = (D[7] & !I & T[3]) & B[3]; //B[11]
assign INR =0;  //B[5]
endmodule 
//   AR_Control 
module AR_Control(LD, T, D, I); 
 input  I; 
 input [7:0] T, D; 
 output LD; 
 assign LD =((~D[7]) & I & T[3]) | T[2] |T[0];
endmodule 
//   DR_Control 
module DR_Control ( 
    Load,  T, D 
); 
input [7:0] T,D; 
 output Load ; 
 assign Load = (T[4] &(D[0] | D[1] | D[2] )) | (D[5]&T[4]) ; 
endmodule 
// IR_Control 
module IR_Control ( 
    load, T 
); 
input [7:0] T; 
output load; 
assign load=T[1]; 
endmodule 
// PC_Control 
module PC_Control ( 
    I, D, T,INR 
); 
input I; 
input [7:0] T, D; 
output  INR; 
assign INR=(T[1]); 
endmodule 
//CommonBus_Control 
module CommonBus_Control(x, D, T, I); 
 input  I; 
 input [7:0] T, D; 
 output [7:0] x;  
 assign x[0]=0; 
 assign x[1] = (D[4] & T[4]) | (D[5] & T[5]);  //AR  
 assign x[2] = (D[5] & T[4]) | T[0];  //PC  
 assign x[3] = (T[6] & D[6]) |(T[5] & D[2]);     //DR  
 assign x[4] = (D[3] & T[4]);     //AC  
 assign x[5] = T[2] ;   
 assign x[6] =0;       
 assign x[7] = T[1] | ((~D[7]) & I & T[3]) | ((D[0] | D[1] | D[2] |D[6]) & T[4]) | (D[5]&T[4]);   // M[AR]   
endmodule 
////////////////////////
module Selections ( 
 input [7:0]x, 
 output [2:0]s 
); 
assign s[0]=x[1] | x[3] | x[5] | x[7]; 
assign s[1]=x[2] | x[3] | x[6] | x[7]; 
assign s[2]=x[4] | x[5] | x[6] | x[7]; 
endmodule 
// ram_control 
module MEM_Control( 
 input  I, 
 input [7:0] T, D, 
 output wire R 
); 
 assign R = (T[1]) | (~D[7] & I & T[3]) | ((D[2] | D[1] | D[0]) & T[4]) | (D[5]&T[4]);  
endmodule 
// rest of instruction_control 
module ALU_CONTROL ( 
 T, D, I,B ,
AND,ADD,LDA,CMA,OR,INC
); 
input  I; 
input [7:0] T, D ; 
input [7:0] B; 
output AND,ADD,LDA,CMA,OR,INC  ; 
assign AND= D[0] & T[5]; 
assign ADD= D[1] & T[5]; 
assign LDA= D[2] & T[5]; 
assign CMA= (D[7] & !I & T[3]) & B[2]; 
assign OR= D[5]& T[5];    
assign INC=  (D[7] & !I & T[3]) & B[0];         
endmodule 
// sc_Control 
module SC_Control ( 
   T, D, I,CLR 
); 
input  I; 
input [7:0] T, D; 
output  CLR; 
 
assign CLR=((D[7] & ~I & T[3])|((D[0]|D[1]|D[2]|(D[5]))&T[5]));

//assign INR=~((D[3]|D[4])&T[4])|(D[7] & ~I & T[3])|((D[0]|D[1]|D[2]|D[5])&T[5]) |(D[6]&T[6]);

endmodule
 //////////////////////////////////////////////////////////////
module AC_Reg( 
    input INR,clk ,LD,CLR
    
    ,input[7:0] in 
    ,output reg [7:0] out_ac 
    
) ; 

initial begin 
     out_ac=8'hac; 
 
 end 
 

    always @(posedge clk ) begin 
         if(CLR) begin out_ac<=8'b0; end
         else if (LD) begin out_ac <=in; end
         else if (INR) begin  out_ac<=out_ac+1; end
 
    end
endmodule
 ///////////////////////////////////////
 module AR_Reg( 
     input clk ,LD
     ,input[3:0] in 
     ,output reg [3:0] out_ar 
 ) ; 
 initial begin 
     out_ar=4'h0; 
 end 
     always @(posedge clk ) begin 
          if (LD) begin out_ar <=in; end
        
     
     end
 endmodule
 //////////////////////////////////
 module DR_Reg( 
     input clk ,Load
     
     ,input[7:0] in 
     ,output reg [7:0] out_dr 
 ) ; 
  
 initial begin 
     out_dr=8'h63; 
 end 
     always @(posedge clk ) begin 
          if (Load) begin out_dr <=in; end
      
     end
 endmodule
 //////////////////////
 module IR_Reg( 
     input clk ,load
     ,input[7:0] in 
     ,output reg [7:0] out_ir
 ) ; 
  
  initial begin 
     out_ir=8'h0; 
 end 
     always @(posedge clk ) begin 
       
        if (load) begin out_ir <=in; end
 
     
    
     end
  
  
 endmodule
 ////////////////////////////
 module PC_Reg( 
     input INR,clk 
     
     ,input[3:0] in 
     ,output reg [3:0] out_pc 
 ) ; 
  
 initial begin 
     out_pc=4'h0; 
 end 
     always @(posedge clk ) begin 
     if (INR) begin out_pc<=out_pc+1; end
   
     end
 endmodule
 ////////////////////////////////////////////////
 module RAM_8x4bit (         
     input wire R, 
    
     input wire [3:0] addr,   
     input wire [7:0] data_in ,
     output reg [7:0] data_out   
 ); 
 
 reg [7:0] ram [0:15];  // 16 memory locations and one location 8 bit 
 
 
// assign AND= D[0] & T[5]; 
// assign ADD= D[1] & T[5]; 
// assign LDA= D[2] & T[5]; 
// assign CMA= (D[7] & !I & T[3]) & B[2]; 
// assign OR= D[5]& T[5];   
  
     initial begin 
     // Initialize memory array with desired values 
     ram[0]  = 8'h0C;  //00001100   AND 
     ram[1]  = 8'h13;  //00010011   ADD             the firt 4 DR   and 3 after go to  decoder 
     ram[2]  = 8'h24;  //00100100   LDA    
     ram[3]  = 8'h56;  //01010110   OR
     ram[4]  = 8'h78;  //01111000   CLA       //B[11] ==> B[3]
     ram[5]  = 8'h74;  //01110100   CMA       //B[9]  ==>B[2]
     ram[6]  = 8'h71;  //01110001   INC      //B[5]  ==>B[0]
     ram[7]  = 8'h07; 
     ram[8]  = 8'h08; 
     ram[9]  = 8'h09; 
     ram[10] = 8'h1B;  
     ram[11] = 8'h0B; 
     ram[12] = 8'h1C; 
     ram[13] = 8'h0D; 
     ram[14] = 8'h0E;  
     ram[15] = 8'h0F; 
 end 
  
 always @ (*) 
 begin 
     if (R) 
         data_out <= ram[addr]; // Read data from memory  
     // Write data to memory  
 end 
 endmodule
 //////////////////////////////////
module BUS_SEL ( 
      input [7:0] DR, AC, IR, RAM,  
      input [3:0] AR, PC,  
      input [2:0] s,                        
      output  [7:0] OUT                    
  ); 
      wire [7:0] mux_out;   
      // Multiplexer module for selecting bits 
      MUX_8to1 mux_8to1 ( 
          .d0(8'h0),
          .d1(AR), 
          .d2(PC), 
          .d3(DR), 
          .d4(AC), 
          .d5(IR), 
          .d6(8'h0), 
          .d7(RAM),
          .sel(s), 
          .out(OUT) 
      ); 
   
 //     always @* begin 
 //         case (s) 
 //             3'b000: OUT = AR;  // Select AR 
 //             3'b001: OUT = PC;  // Select PC 
 //             3'b010: OUT = DR;  // Select DR 
 //             3'b011: OUT = AC;  // Select AC 
 //             3'b100: OUT = IR;  // Select IR 
 //             3'b101: OUT = RAM; // Select RAM 
 //             default: OUT = 8'h00;  // Default  
 //         endcase 
 //     end 
   
  endmodule 
  
 module MUX_8to1 ( 
      input [7:0]  d0, d3, d4, d5,d6,d7, // 8-bit input data 
      input [2:0] sel, 
      input [3:0]d2, d1,                  // Selection input 
      output reg [7:0] out                   // Output data 
  ); 
   
      always @* begin 
          case (sel) 
              3'b000:out=d0; 
     3'b001:out=d1; 
     3'b010:out=d2; 
     3'b011:out=d3; 
     3'b100:out=d4; 
     3'b101:out=d5; 
     3'b110:out=d6; 
     3'b111:out=d7; 
          endcase 
      end 
   
  endmodule

//////////////////////////////////////

 /////////////////////////
 
 
 module Sequence_Counter3Bit2(CLR, clk, count);
 
     input CLR,  clk;
     
     output reg [2:0] count;
 initial begin count=3'b000; end
     always @ (posedge clk)
         begin
             if(CLR)
                 count = 3'b000;
             else 
                 count = count + 3'b001;
                 end
         
 endmodule
 
 module Decoder3x8 ( 
      input wire [2:0] A, 
      output reg [7:0] Y 
  ); 
  always @* 
  begin 
      case(A) 
          3'b000: Y = 8'b00000001; 
          3'b001: Y = 8'b00000010; 
          3'b010: Y = 8'b00000100; 
          3'b011: Y = 8'b00001000; 
          3'b100: Y = 8'b00010000; 
          3'b101: Y = 8'b00100000; 
          3'b110: Y = 8'b01000000; 
          3'b111: Y = 8'b10000000; 
          default: Y = 8'b00000000; 
      endcase 
  end          
  endmodule
 ///////////////////////
 module Alu(
      input wire AND, ADD, LDA, CMA, OR,INC,
      input wire cin,
      input wire [7:0] out_ac, 
      input wire [7:0] out_dr,
     
      output reg [7:0] result, 
      output reg cout 
  );
  initial begin 
      
       cout=0;
   end 
  always @(*)
  begin
      // AND operation
      if (AND) begin 
          result = out_ac & out_dr;
  
      end
      // ADD operation
      else if (ADD) begin
          {cout, result} = out_ac + out_dr + cin;
      end
      // LOAD operation
      else if (LDA) begin
          result = out_dr;
      
      end 
      // OR operation                                      
      else if (OR) begin
          result = out_ac | out_dr;
      
      end
      // COMPLEMENT operation
      else if (CMA) begin
          result = ~out_ac;
    
      end
        else if (INC) begin
             {cout, result}=out_ac+1;
            
          end
   
      else begin
          result = out_ac;
     
      end
      
  end
  endmodule
  
 ///////////////////////
 
 module mano_all(
  input CLK ,
  output E,
  output[7:0]MEM,IR,DR,AC,SC,
  output[3:0]AR,PC
  );
  

     
  // Inputs
  wire [7:0] T;
  wire [7:0] D;
  wire I;
  wire [7:0] B;
  reg cin;
  // Outputs
  wire LDAC, CLRAC, INRAC, LDAR, RriteMem, LDDR, LDIR, INRPC, CLRSC;
  wire [0:2] s;
  wire AND, ADD, LDA, CMA, OR,INC;
  wire [7:0] dr_data,ir_data,ram_data;
  wire [3:0] ar_data, pc_data;
  wire [7:0] adder_out;
  wire [7:0] ac_data;
  wire e_data;
  wire [7:0] out_cb;
  wire [2:0] count;
  
  initial begin cin=0; end
  // Instantiate ControlUnit module
  ControlUnit control_unit_inst (
      .T(T),
      .D(D),
      .I(ir_data[7]),
      .B(ir_data),
      .LDAC(LDAC),
      .CLRAC(CLRAC),
      .INRAC(INRAC),
      .LDAR(LDAR),
      .RriteMem(RriteMem),
      .LDDR(LDDR),
      .LDIR(LDIR),
      .INRPC(INRPC),
      .CLRSC(CLRSC),
      .s(s),
      .AND(AND),
      .ADD(ADD),
      .LDA(LDA),
      .CMA(CMA),
      .OR(OR),
      .INC(INC)
  );
  
  ///////////////////////
  // Inputs
 

  // Instantiate AC_Reg module
  AC_Reg ac_reg_inst (
      .INR(INRAC),
      .clk(CLK),
      .LD(LDAC),
      .CLR(CLRAC),
      .in(adder_out),
      .out_ac(ac_data)

  );
  
  
  
 
  
  // Inputs

  
  
  // Instantiate BUS_SEL module
  BUS_SEL bus_sel_inst (
      .DR(dr_data),
      .AC(ac_data),
      .IR(ir_data),
      .RAM(ram_data),
      .AR(ar_data),
      .PC(pc_data),
      .s(s),
      .OUT(out_cb)
  );
 
 
 // Declare signals
 // Instantiate the AR_Reg module
 AR_Reg AR_Reg_inst (
   
     .clk(CLK),
     .LD(LDAR),
     .in(out_cb[3:0]),
     .out_ar(ar_data)
 );
 
 
 // Instantiate the DR_Reg module
 DR_Reg DR_Reg_inst (
     .clk(CLK),
     .Load(LDDR),
     .in(out_cb),
     .out_dr(dr_data)
 );
 
 // Add your additional code here
 
 
 // Declare signals
 
 
 // Instantiate the IR_Reg module
 IR_Reg IR_Reg_inst (
     .clk(CLK),
     .load(LDIR),
     .in(out_cb),
     .out_ir(ir_data)
 );
 
 // Instantiate the PC_Reg module
 PC_Reg PC_Reg_inst (
     .INR(INRPC),
     .clk(CLK),
     .in(out_cb[3:0]),
     .out_pc(pc_data)
 );
 // Add your additional code here
 
 
 
 
 // Instantiate the RAM_8x4bit module
 RAM_8x4bit RAM_8x4bit_inst (
  
     .R(RriteMem),
     .addr(ar_data),
     .data_in(out_cb),
     .data_out(ram_data)
 );
 
 // Add your additional code here
 
 
 
 // Declare signals
 

 
 // Instantiate the Sequence_Counter3Bit2 module
    Sequence_Counter3Bit2 Sequence_Counter3Bit2_inst (
     .clk(CLK),
     .CLR(CLRSC),
     .count(count) /////////////////////////////////////////////////////////////
 );
 
 // Add your additional code here
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////
 // Declare signals
 
 
 
 // Instantiate the Decoder3x8 module
 Decoder3x8 Decoder3x8_inst (
     .A(count),
     .Y(T)
 );
 
  Decoder3x8 Decoder2_3x8_inst (
     .A(ir_data[6:4]),
     .Y(D)
 );
 
 // Add your additional code here
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
 // Declare signals
 

 
 
 // Instantiate the Alu module
 Alu Alu_inst (
     .AND(AND),
     .ADD(ADD),
     .LDA(LDA),
     .CMA(CMA),
     .OR(OR),
     .INC(INC),
     .cin(cin),
     .out_ac(ac_data),
     .out_dr(dr_data),
     .result(adder_out),
     .cout(e_data)
 );
 
 
   assign E=e_data;
 assign MEM=ram_data;
 assign AR=ar_data;
 assign AC=ac_data;
 assign PC=pc_data;
 assign IR=ir_data;
  assign DR=dr_data;
   assign SC=T;
 
 
 
  endmodule
