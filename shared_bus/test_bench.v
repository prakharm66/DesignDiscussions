module tb();

    reg clk;
    reg rst;

    //Master 1
    //From IP
    reg M1_RW,Valid; 
    reg [9:0] M1_Address;
    reg [7:0] M1_Data_to_write;

    //From bus
    wire M1_PSel,M1_PEnable,M1_PWrite;
    wire [7:0] M1_PWData, M1_PAddress;
    wire [1:0] M1_Slave_sel;
    wire [7:0] S_PRData;

    //Slave 1
    //from IP
    wire [7:0] S1_Data_in;
    reg [7:0] S1_Data_out;
    wire [7:0] S1_Addr_out;

    //Slave 2
    //from IP
    wire [7:0] S2_Data_in;
    reg [7:0] S2_Data_out;
    wire [7:0] S2_Addr_out;


    //from bus
    wire S1_PReady;
    wire S2_PReady;
    wire S1_PSel, S2_PSel;
    wire M1_PReady;
    assign S1_PSel = M1_PSel && M1_Slave_sel[0];
    assign S2_PSel = M1_PSel && M1_Slave_sel[1];
    assign M1_PReady = (S1_PSel && S1_PReady) || (S2_PSel && S2_PReady);

    //Demuxing logic

    APB_Master M1(
        .PReset(rst)
        ,.Pclk(clk)
        ,.RW(M1_RW)
        ,.Valid(Valid)
        ,.Address(M1_Address)
        ,.Data_to_write(M1_Data_to_write)
        ,.PRData(S_PRData)
        ,.PReady(M1_PReady)
        ,.PSel(M1_PSel)
        ,.PEnable(M1_PEnable)
        ,.PAddress(M1_PAddress)
        ,.PWData(M1_PWData),
        .PWrite(M1_PWrite),
        .Slave_sel(M1_Slave_sel)
        );

    APB_Slave S1(
        .PReset(rst)
        ,.Pclk(clk)
        ,.Data_out(S1_Data_out)
        ,.Data_in(S1_Data_in)
    //    ,.PRData(S_PRData)
        ,.PReady(S1_PReady)
        ,.PSel(S1_PSel)
        ,.PEnable(M1_PEnable)
        ,.PAddress(M1_PAddress)
        ,.PWData(M1_PWData)
        ,.Address(S1_Addr_out)
        ,.PWrite(M1_PWrite));

    APB_Slave S2(
        .PReset(rst)
        ,.Pclk(clk)
        ,.Data_out(S2_Data_out)
        ,.Data_in(S2_Data_in)
    //    ,.PRData(S_PRData)
        ,.PReady(S2_PReady)
        ,.PSel(S2_PSel)
        ,.PEnable(M1_PEnable)
        ,.PAddress(M1_PAddress)
        ,.PWData(M1_PWData)
        ,.Address(S1_Addr_out)
        ,.PWrite(M1_PWrite));    

    always #5 clk=~clk;

    initial begin

        clk = 1'b0;

        #27 rst = 1'b1;
        #47 rst = 1'b0;
        

        #23 Valid = 1'b1;
        M1_Address = {2'b01,8'h66};
        M1_RW = 1'b1;
        M1_Data_to_write = 8'h33;
        S1_Data_out = 8'h22;

        #40 Valid = 1'b0;

        #60 Valid = 1'b1;
        M1_Address = {2'b01,8'h33};
        M1_RW = 1'b0;
        M1_Data_to_write = 8'h55;
        S1_Data_out = 8'h44;

        #40 Valid = 1'b0;

        #60 Valid = 1'b1;
        M1_Address = {2'b10,8'h32};
        M1_RW = 1'b0;
        M1_Data_to_write = 8'h54;
        S1_Data_out = 8'h43;

        #40 Valid = 1'b0;

        #60 Valid = 1'b1;
        M1_Address = {2'b10,8'h23};
        M1_RW = 1'b1;
        M1_Data_to_write = 8'h45;
        S1_Data_out = 8'h24;

        #100 $finish;
    end

    initial begin
        $monitor("Time : %d, reset: %b, Valid: %b, M1_RW: %b, M1_PSel:%b, M1_PEnable:%b, M1_PWrite:%b,S1_PSel:%b, S2_PSel:%b,S1_PReady:%b, S2_PReady:%b", $time, rst, Valid, M1_RW, M1_PSel, M1_PEnable, M1_PWrite, S1_PSel, S2_PSel,S1_PReady, S2_PReady);
        
            end

    //initial begin
    //   $fsdbDumpfile("waves.tsdb");
    //    $fsdbDumpvars(0,tb);
    //end        

endmodule