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

    //Slave 1
    //from IP
    reg [7:0] S1_Data;
    wire [7:0] S1_PRData;

    //from bus
    wire S1_PReady;

    APB_Master M1(
        .PReset(rst)
        ,.Pclk(clk)
        ,.RW(M1_RW)
        ,.Valid(Valid)
        ,.Address(M1_Address)
        ,.Data_to_write(M1_Data_to_write)
        ,.PRData(S1_PRData)
        ,.PReady(S1_PReady)
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
        ,.Data_out(S1_Data)
        ,.PRData(S1_PRData)
        ,.PReady(S1_PReady)
        ,.PSel(M1_PSel)
        ,.PEnable(M1_PEnable)
        ,.PAddress(M1_PAddress)
        ,.PWData(M1_PWData)
        ,.PWrite(M1_PWrite));

    always #5 clk=~clk;

    initial begin

        clk = 1'b0;

        #27 rst = 1'b1;
        #47 rst = 1'b0;
        

        #23 Valid = 1'b1;
        M1_Address = 8'h66;
        M1_RW = 1'b1;
        M1_Data_to_write = 8'h33;
        S1_Data = 8'h66;

        #40 Valid = 1'b0;

        #20 Valid = 1'b1;
        M1_Address = 8'h33;
        M1_RW = 1'b0;
        M1_Data_to_write = 8'h55;
        S1_Data = 8'h44;

        #40 $finish;
    end

    initial begin
        $monitor("Time : %d, reset: %b, Valid: %b, M1_RW: %b, M1_PSel:%b, M1_PEnable:%b, M1_PWrite:%b, S1_PReady:%b", $time, rst, Valid, M1_RW, M1_PSel, M1_PEnable, M1_PWrite, S1_PReady);
        
            end

endmodule