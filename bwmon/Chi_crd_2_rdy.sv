module handshake_converter(
 
 //These are CHI interface signals
    flitV,
    flit,
    lcrdV,

//These are bwmon interface signals
    AValid,
    AReady,
    ASize,
    AOpc,

//clk rst    
    clk,
    rst

);

    input flitV;
    input [15:0] flit;
    input lcrdV;

    input clk;
    input rst;
    
    output AValid;
    output AReady;
    output [2:0] ASize;
    output [6:0] AOpc;

    reg [7:0] CreditCounter;

    wire  IncrementCounter;
    wire  DecrementCounter;
    wire  Rdy;

    assign IncrementCounter = lcrdV;
    assign DecrementCounter = flitV & Rdy;

    // Rdy is high when CreditCounter is non-zero
    assign Rdy = |CreditCounter;

    //modifying the counter on clk edge
    always @(posedge clk)
        begin
            if (rst)
                CreditCounter <= 0;
            else
                CreditCounter <= CreditCounter + IncrementCounter - DecrementCounter;
        end

    assign AValid = flitV;
    assign AReady = Rdy;

    //assuming flit[15:13] is Size and flit[12:6] is Opcode
    assign ASize = flit[15:13] & {3{flitV}};
    assign AOpc = flit[12:6] & {7{flitV}};       


endmodule
