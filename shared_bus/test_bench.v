
module tb();

    reg clk;
    reg rst;

    //Master 1
    //From IP
    reg M1_RW,M1_Valid; 
    reg [9:0] M1_Address;
    reg [7:0] M1_Data_to_write;
    //To arbiter
    wire M1_PSel,M1_PEnable,M1_PWrite,M1_PReady;
    wire [7:0] M1_PWData, M1_PAddress;
    wire [1:0] M1_Slave_sel;
    

    //Master 2
    //From IP
    reg M2_RW,M2_Valid; 
    reg [9:0] M2_Address;
    reg [7:0] M2_Data_to_write;
    //To arbiter
    wire M2_PSel,M2_PEnable,M2_PWrite,M2_PReady;
    wire [7:0] M2_PWData, M2_PAddress;
    wire [1:0] M2_Slave_sel;


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

    //Slave 3
    //from IP
    wire [7:0] S3_Data_in;
    reg [7:0] S3_Data_out;
    wire [7:0] S3_Addr_out;


    //from bus to slaves
    wire S1_PReady,S2_PReady,S3_PReady;
    wire S1_PSel, S2_PSel, S3_PSel;
    wire [7:0] S_PRData;

    wire s1_sel1,s2_sel1,s3_sel1;
    //Demuxing logic
    assign s1_sel1 = ~M_Slave_sel[0] && ~M_Slave_sel[1];
    assign s2_sel1 = M_Slave_sel[0] && ~M_Slave_sel[1];
    assign s3_sel1 = M_Slave_sel[1];
    
  	assign S1_PSel = s1_sel1 && M_PSel;
    assign S2_PSel = s2_sel1 && M_PSel;
    assign S3_PSel = s3_sel1 && M_PSel;
    
    //From arbiter to bus
    wire M_PSel,M_PEnable,M_PWrite;
    wire [7:0] M_PWData, M_PAddress;
    wire [1:0] M_Slave_sel;
    wire M_PReady;
  assign M_PReady = (s1_sel1 && S1_PReady) || (s2_sel1 && S2_PReady) || (s3_sel1 && S3_PReady);


    APB_Master M1(
        .PReset(rst)
        ,.Pclk(clk)
        ,.RW(M1_RW)
        ,.Valid(M1_Valid)
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

    APB_Master M2(
        .PReset(rst)
        ,.Pclk(clk)
        ,.RW(M2_RW)
        ,.Valid(M2_Valid)
        ,.Address(M2_Address)
        ,.Data_to_write(M2_Data_to_write)
        ,.PRData(S_PRData)
        ,.PReady(M2_PReady)
        ,.PSel(M2_PSel)
        ,.PEnable(M2_PEnable)
        ,.PAddress(M2_PAddress)
        ,.PWData(M2_PWData),
        .PWrite(M2_PWrite),
        .Slave_sel(M2_Slave_sel)
        );    

    //arbiter to select which maser signal goes to the bus
    bus_arbiter u_arbiter(
    .Pclk(clk),
    .M1_PSel(M1_PSel),
    .M1_PEnable(M1_PEnable),
    .M1_PWrite(M1_PWrite),
    .M1_Address(M1_PAddress),
    .M1_Slave_sel(M1_Slave_sel),
    .M1_PWData(M1_PWData),
    .M1_PReady(M1_PReady),
    .M2_PSel(M2_PSel),
    .M2_PEnable(M2_PEnable),
    .M2_PWrite(M2_PWrite),
    .M2_Address(M2_PAddress),
    .M2_Slave_sel(M2_Slave_sel),
    .M2_PWData(M2_PWData),
    .M2_PReady(M2_PReady),
    .PSel(M_PSel),
    .PEnable(M_PEnable),
    .PWrite(M_PWrite),
    .PAddress(M_PAddress),
    .PWData(M_PWData),
    .Slave_sel(M_Slave_sel),
    .PRData(S_PRData),
    .PReady(M_PReady)
);    

    APB_Slave S1(
        .PReset(rst)
        ,.Pclk(clk)
        ,.Data_out(S1_Data_out)
        ,.Data_in(S1_Data_in)
    //    ,.PRData(S_PRData)
        ,.PReady(S1_PReady)
        ,.PSel(S1_PSel)
        ,.PEnable(M_PEnable)
        ,.PAddress(M_PAddress)
        ,.PWData(M_PWData)
        ,.Address(S1_Addr_out)
        ,.PWrite(M_PWrite));

    APB_Slave S2(
        .PReset(rst)
        ,.Pclk(clk)
        ,.Data_out(S2_Data_out)
        ,.Data_in(S2_Data_in)
    //    ,.PRData(S_PRData)
        ,.PReady(S2_PReady)
        ,.PSel(S2_PSel)
        ,.PEnable(M_PEnable)
        ,.PAddress(M_PAddress)
        ,.PWData(M_PWData)
        ,.Address(S2_Addr_out)
        ,.PWrite(M_PWrite));    

    APB_Slave S3(
        .PReset(rst)
        ,.Pclk(clk)
        ,.Data_out(S3_Data_out)
        ,.Data_in(S3_Data_in)
    //    ,.PRData(S_PRData)
        ,.PReady(S3_PReady)
        ,.PSel(S3_PSel)
        ,.PEnable(M_PEnable)
        ,.PAddress(M_PAddress)
        ,.PWData(M_PWData)
        ,.Address(S3_Addr_out)
        ,.PWrite(M_PWrite));    

    always #5 clk=~clk;

    integer i;
    initial begin

        clk = 1'b0;

        #27 rst = 1'b1;
        #47 rst = 1'b0;
        

        for (i=0;i<10;i++) begin
            #60 M1_Valid = 1'b1;
            M1_Address = {i[1:0],i[7:0]};
            M1_RW = i[1];
            M1_Data_to_write = ~i[7:0];
            S1_Data_out = 10-i;
            S2_Data_out = 20-i;
            S3_Data_out = 30-i;
            #30 M1_Valid = 1'b0;

            #30 M2_Valid = 1'b1;
          M2_Address = {i[1:0],4'b1111,i[3:0]}; //M2 address will have F in between
            M2_RW = i[1];
            M2_Data_to_write = ~i[7:0]+8'h10;
            // S1_Data_out = 10-i;
            // S2_Data_out = 20-i;
            // S3_Data_out = 30-i;
            #30 M2_Valid = 1'b0;
        end


        #100 $finish;
    end

    initial begin
        $monitor("M1_PSel:%b, M1_Valid:%b, M2_PSel:%b, M2_Valid:%b \ni: %d, reset: %b, M_PSel:%b, M_PEnable:%b, M_PWrite:%b,S1_PSel:%b, S2_PSel:%b, S3_PSel:%b,,S1_PReady:%b, S2_PReady:%b, S3_PReady:%b",M1_PSel,M1_Valid, M2_PSel,M2_Valid, i, rst, M_PSel, M_PEnable, M_PWrite, S1_PSel, S2_PSel, S3_PSel, S1_PReady, S2_PReady, S3_PReady);
        // $monitor("Time : %d, reset: %b, Valid: %b, M1_RW: %b, M1_PSel:%b, M1_PEnable:%b, M1_PWrite:%b,S1_PSel:%b, S2_PSel:%b, S3_PSel:%b,,S1_PReady:%b, S2_PReady:%b, S3_PReady", $time, rst, Valid, M1_RW, M1_PSel, M1_PEnable, M1_PWrite, S1_PSel, S2_PSel, S3_PSel, S1_PReady, S2_PReady, S3_PReady);
        
            end

    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0,tb);
    end        

endmodule