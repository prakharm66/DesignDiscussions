module APB_Master(
  PReset,
  Pclk,
  RW,
  Valid,
  Address,
  Data_to_write,
  Data_to_read,
  PRData,
  PReady,
  PSel,
  PEnable,
  PAddress,
  PWData,
  PWrite,
  Slave_sel
);

    input PReset;
    input Pclk;

    //input/outputs coming from the IP
    input RW,Valid;
    input [9:0] Address;
    input [7:0] Data_to_write;
    output reg [7:0] Data_to_read;

    //ports connected to the bus
    input [7:0] PRData;
    input PReady;

    output reg PSel;
    output reg PEnable;
    output reg [7:0] PAddress;
    output reg [7:0] PWData;
    output reg PWrite;
    output [1:0] Slave_sel;

    assign Slave_sel= Address[9:8];

    always @(posedge Pclk) begin
        if (PReset) begin
            PSel<=0;
            PEnable<=0;
        end

        else begin
            PWrite<= ~RW;
            if (Valid) begin
                case ({PSel,PEnable,PReady})
                3'b000,3'b001: begin
                  PSel<=1'b1;
                end
                3'b100,3'b101: begin
                  PEnable<=1'b1;
                  PAddress<=Address[7:0];
                  if (~RW) 
                    PWData<=Data_to_write;
                  if (RW)
                    Data_to_read<=PRData;  
                end
                3'b111: begin
                  PSel<=1'b0;
                  PEnable<=1'b0;
                end
                endcase
            end

        end 
    end

endmodule

module APB_Slave(
PReset,
Pclk,
PSel,
PEnable,
PAddress,
PWData,
PWrite,
PReady,
PRData,
Data_in,
Data_out,
Address,
RW
);

    //ports connected to the bus
    input PReset;
    input Pclk;
    input PSel;
    input  PEnable;
    input [7:0] PAddress;
    input [7:0] PWData;
    input PWrite;
    output reg PReady;

    //outputs going to the bus
    output reg [7:0] PRData;

    //ports connected to the Memory IP
    output reg [7:0 ]Data_in;
    input [7:0]Data_out;
    output reg [7:0] Address;
    output reg RW;

    always @(posedge Pclk) begin
        if (PReset) begin
          PReady<=0;
        end
        else begin
          if (PSel && PEnable) begin
            PReady<=1'b1;
            Address<=PAddress;
            RW<=PWrite;
            if (PWrite)
              Data_in<=PWData;
            else
              PRData<=Data_out;
          end
          else begin
            PReady<=0;
          end
        end
    end

endmodule



