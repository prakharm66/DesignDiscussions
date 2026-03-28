//#`include "apb_interface.v"

module bus_arbiter(
    Pclk,
    M1_PSel,
    M1_PEnable,
    M1_PWrite,
    M1_Address,
    M1_Slave_sel,
    M1_PWData,
    M1_PReady,
    M2_PSel,
    M2_PEnable,
    M2_PWrite,
    M2_Address,
    M2_Slave_sel,
    M2_PWData,
    M2_PReady,
    PSel,
    PEnable,
    PWrite,
    PAddress,
    PWData,
    Slave_sel,
    PRData,
    PReady
);
    input Pclk;
    //Master 1 signals
    input M1_PSel;
    input M1_PEnable;
    input M1_PWrite;
    input [7:0] M1_Address;
    input [1:0] M1_Slave_sel;
    input [7:0] M1_PWData;
    output M1_PReady;

    //Master 2 signals
    input M2_PSel;
    input M2_PEnable;
    input M2_PWrite;
    input [7:0] M2_Address;
    input [1:0] M2_Slave_sel;
    input [7:0] M2_PWData;
    output  M2_PReady;

    //Output signals to slaves
    output  PSel;
    output  PEnable;
    output  PWrite;
    output  [7:0] PAddress;
    output  [7:0] PWData;
    output  [1:0] Slave_sel;
    input [7:0] PRData;
    input PReady;

    // reg Bus_busy=1'b0;

    //Arbiteration Logic: 1 gets more priority

  
  	assign PSel = M1_PSel || M2_PSel;
    assign M1_PReady = M1_PSel && PReady;
    assign M2_PReady = M2_PSel && PReady ;
  
    assign PEnable = M1_PSel && M1_PEnable || M2_PSel && M2_PEnable;
    assign PWrite = M1_PSel && M1_PWrite || M2_PSel && M2_PWrite;
    assign PAddress = {8{PSel}} & ((M1_PSel)?M1_Address:M2_Address);
    assign PWData = {8{PSel}} & ((M1_PSel)?M1_PWData:M2_PWData);
    assign Slave_sel = {2{PSel}} & ((M1_PSel)?M1_Slave_sel:M2_Slave_sel);
   



    //Once a transfer starts, the bus is locked

    // always @(posedge Pclk) begin
    //     // if (Bus_busy==1'b0)  //bus is empty
    //     // begin
    //         if (M1_PSel) begin
    //             $display("Master 1 has requested");
    //             PSel<=M1_PSel;
    //             M1_PReady<=PReady;
    //             PEnable<=M1_PEnable;
    //             PWrite<=M1_PWrite;
    //             PAddress<=M1_Address;
    //             PWData<=M1_PWData;
    //             Slave_sel<=M1_Slave_sel;
                
    //             // Bus_busy<=1'b1;
    //             // M1_PReady<=PReady;
    //             // M2_PReady<=1'b0;
    //         end

    //         else if (M2_PSel) begin
    //             $display("Master 2 has requested");
    //             PSel<=M2_PSel;
    //             M2_PReady<=PReady ;
    //             PEnable<=M2_PEnable;
    //             PWrite<=M2_PWrite;
    //             PAddress<=M2_Address;
    //             PWData<=M2_PWData;
    //             Slave_sel<=M2_Slave_sel;
                
    //             // Bus_busy<=1'b1;
    //             // M2_PReady<=PReady;
    //             // M1_PReady<=1'b0;
    //         end

    //         else begin


    //         end

    //         // else if (~M1_PSel && ~M2_PSel) begin

    //         //     $display("Bus is free");
    //         //     Bus_busy<=1'b0;
    //         // end
    //     // end
    //     // else begin //bus is busy
    //     //     if (M1_PSel) 
    //     //         begin
    //     //             M1_PReady<=PReady;
    //     //             PEnable<=M1_PEnable;
    //     //             PWrite<=M1_PWrite;
    //     //             PAddress<=M1_Address;
    //     //             PWData<=M1_PWData;
    //     //             Slave_sel<=M1_Slave_sel;
    //     //         end
    //     //     else if (M2_PSel) 
    //     //         begin
    //     //             M2_PReady<=PReady ;
    //     //             PEnable<=M2_PEnable;
    //     //             PWrite<=M2_PWrite;
    //     //             PAddress<=M2_Address;
    //     //             PWData<=M2_PWData;
    //     //             Slave_sel<=M2_Slave_sel;
    //     //         end
    //     //     if (PReady)
    //     //         $display("Ready signal came from slave and bus was busy");
    //     //         Bus_busy<=1'b0;       
    //     // end
    // end 

   

endmodule