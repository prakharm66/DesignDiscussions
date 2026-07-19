`define NO_TRAN 4'h0
`define FIRST_HALF 4'h1
`define SECOND_HALF 4'h2

module ahb_32_to_16_bridge(
    clk,
    rst,
    HAddr_in,
    HTrans_in,
    HSize_in,
    HWrite_in,
    HReady_in,
    HSel_in,
    HWData_in,
    // HRData_in,
    // HBurst_in,
    HAddr_out,
    HTrans_out,
    HSize_out,
    HWrite_out,
    HReady_out,
    HSel_out,
    HWData_out
    // HRData_out
  //  HBurst_out
);
input clk;
input rst;
input [15:0] HAddr_in;
input [1:0] HTrans_in;
input [2:0] HSize_in;
input HWrite_in;
input HReady_out;
input HSel_in;
input [31:0] HWData_in;
// input [31:0] HRData_out;
//input [2:0] HBurst_in;
output [15:0] HAddr_out;
output reg [1:0] HTrans_out;
output [2:0] HSize_out;
output HWrite_out;
output reg HReady_in;
output reg HSel_out;
output reg [15:0] HWData_out;
// output reg [16:0] HRData_in;
//output [2:0] HBurst_out;

assign HWrite_out = HWrite_in;

reg [15:0] addr_new;
reg [15:0] wdata_new;
reg [3:0] state;
reg [3:0] next_state;
reg [15:0] wdata_second;

assign HAddr_out = addr_new;
assign HWData_out = wdata_new;
assign HSize_out = (HSize_in==2'b10)? 2'b01 : HSize_in;

always @(posedge clk) begin
    if (rst) begin
        state = `NO_TRAN;
    end
    else begin
        state = next_state;
    end    
end

always @(*) begin
    case (state)
            `NO_TRAN: begin
                next_state =(HSel_in)? `FIRST_HALF:`NO_TRAN; 
                HSel_out = 1'b0;
                HTrans_out = 2'b00;
            end

            `FIRST_HALF: begin
                next_state = (HReady_out)?`SECOND_HALF:`FIRST_HALF;
                addr_new = HAddr_in;
                wdata_new = HWData_in[15:0];
                wdata_second = HWData_in[31:16];
                HSel_out = 1'b1;
                HReady_in = 1'b0;
                HTrans_out = HTrans_in;
            end

            `SECOND_HALF: begin
                next_state = (HReady_out)?((HSel_in)? `FIRST_HALF:`NO_TRAN):`SECOND_HALF;
                addr_new = HAddr_in + 16'h2; 
                wdata_new = wdata_second;  
                HSel_out = 1'b1; 
                HReady_in = HReady_out;
                HTrans_out = 2'b11; 
            end

            default: 
                next_state =  `NO_TRAN;
    endcase
end

endmodule
