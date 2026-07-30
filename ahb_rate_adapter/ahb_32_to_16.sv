`define NO_TRAN 4'h0
`define ADDRESS_IN 4'h1
`define DATA_FIRST 4'h2
`define DATA_SECOND 4'h3

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
output [15:0] HWData_out;
// output reg [16:0] HRData_in;
//output [2:0] HBurst_out;

assign HWrite_out = HWrite_in;

reg [15:0] addr_new;
reg [15:0] addr_next;
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
                next_state =(HSel_in)? `ADDRESS_IN:`NO_TRAN; 
                HSel_out = 1'b0;
                HTrans_out = 2'b00;
            end

            `ADDRESS_IN: begin
                next_state = (HReady_out)?`DATA_FIRST:`ADDRESS_IN;
                addr_new = HAddr_in;
                addr_next = HAddr_in + 16'h2;
                //wdata_new = HWData_in[15:0];
                //wdata_second = HWData_in[31:16];
                HSel_out = 1'b1;
                HReady_in = HReady_out;
                HTrans_out = HTrans_in;
            end

            `DATA_FIRST: begin
                next_state = (HReady_out)?`DATA_SECOND:`DATA_FIRST;
                addr_new = addr_next;
                wdata_new = HWData_in[15:0];
                wdata_second = HWData_in[31:16];  
                HSel_out = 1'b1; 
                HReady_in = 1'b0;
                HTrans_out = 2'b11; 
            end

            `DATA_SECOND: begin
              next_state = (HSel_in) ? `DATA_FIRST : `NO_TRAN;
                addr_new = HAddr_in;
                addr_next = HAddr_in + 16'h2;
                wdata_new = wdata_second;
                HSel_out = 1'b1;
                HReady_in = 1'b1;
                HTrans_out = (HSel_in) ? HTrans_in : 2'b0;

            end

            default: 
                next_state =  `NO_TRAN;
    endcase
end

endmodule
