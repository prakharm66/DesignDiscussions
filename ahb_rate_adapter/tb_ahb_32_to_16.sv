`include "ahb_32_to_16.sv"

module tb_ahb_adapter;

    reg clk;
    reg rst;
    reg [15:0] HAddr_in;
    reg [1:0] HTrans_in;
    reg [2:0] HSize_in;
    reg HWrite_in;
    reg HReady_out;
    reg HSel_in;
    reg [31:0] HWData_in;
    // reg [31:0] HRData_out;
    //reg [2:0] HBurst_in;
    wire [15:0] HAddr_out;
    wire [1:0] HTrans_out;
    wire [2:0] HSize_out;
    wire HWrite_out;
    wire HReady_in;
    wire HSel_out;
    wire [15:0] HWData_out;

ahb_32_to_16_bridge dut (
    .clk(clk),
    .rst(rst),
    .HAddr_in(HAddr_in),
    .HTrans_in(HTrans_in),
    .HSize_in(HSize_in),
    .HWrite_in(HWrite_in),
    .HReady_in(HReady_in),
    .HSel_in(HSel_in),
    .HWData_in(HWData_in),
    // HRData_in,
    // HBurst_in,
    .HAddr_out(HAddr_out),
    .HTrans_out(HTrans_out),
    .HSize_out(HSize_out),
    .HWrite_out(HWrite_out),
    .HReady_out(HReady_out),
    .HSel_out(HSel_out),
    .HWData_out(HWData_out)
    // HRData_out
  //  HBurst_out
);

task sendWrite(reg [15:0] Addr, reg[31:0] data, reg [1:0] trans);
    begin
        @(posedge clk) ;
        HSel_in = 1'b1;
        HAddr_in = Addr;
        HTrans_in = trans;
        HWrite_in = 1'b1;

        @(posedge clk);
        HWData_in = data;
   
        wait(HReady_out == 1'b1); 
        @(posedge clk);
        HAddr_in =16'b0;
        HWData_in = 32'b0;
        HTrans_in = 2'b0;
        HWrite_in = 1'b0;

        // for (integer i = 0 ; i < 5; i++) begin
        //     @(posedge clk)
        //     if (HReady_in) begin
                
        //         break;
        //     end
        //     $display("waited for ready to be true for %d cycles",i );
        // end


    end

endtask

always #5 clk = ~clk;

//reset sequence
initial begin
    #12 rst = 1'b1;
    clk = 1'b0;
    #30 rst = 1'b0;
end

initial begin

    // $monitor("format", )
    HSize_in = 3'b010;
    HReady_out = 1'b1;

    for (integer i=0; i<10; i++) begin
        sendWrite(16'h4000+i[15:0], $urandom(), 2'b01);
    end
    $finish;
end

initial begin
      $dumpfile("ahb2ahb.vcd");
      $dumpvars(0,tb_ahb_adapter);
end

endmodule
