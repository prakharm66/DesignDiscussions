`timescale 1ps/1ps

module handshake_converter_tb;

    reg clk;
    reg rst;
    reg flitV;
    reg [15:0] flit;
    reg lcrdV;

    wire AValid;
    wire AReady;
    wire [2:0] ASize;
    wire [6:0] AOpc;

    handshake_converter uut (
        .flitV(flitV),
        .flit(flit),
        .lcrdV(lcrdV),
        .AValid(AValid),
        .AReady(AReady),
        .ASize(ASize),
        .AOpc(AOpc),
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task reset_dut();
    begin
        rst = 1;
        flitV = 0;
        flit = 16'h0000;
        lcrdV = 0;
        #(10);
        rst = 0;
        #(10);
    end
    endtask

    task send_credit();
    begin
        lcrdV = 1;
        #(10);
        lcrdV = 0;
        #(10);
    end
    endtask

    task send_flit(input [15:0] data);
    begin
        flit = data;
        flitV = 1;
        #(10);
        flitV = 0;
        #(10);
    end
    endtask

    initial begin
        $display("[%0t] Starting handshake_converter testbench", $time);
        // $display("time    clk rst flitV lcrdV AValid AReady ASize AOpc");
        $monitor("time: %0t   rst: %b   flitV: %b   flit: %x   lcrdV: %b   AValid: %b   AReady: %b   ASize: %b   AOpc: %b", $time, rst, flitV, flit, lcrdV, AValid, AReady, ASize, AOpc);

        reset_dut();

        // At reset release, no credits are available
        send_flit(16'hA5A5);
        if (AReady !== 0) begin
            $display("ERROR: AReady should be 0 when no credit is present at time %0t", $time);
            $stop;
        end

        // Provide one credit, then send a valid flit
        send_credit();
        if (AReady !== 1) begin
            $display("ERROR: AReady should be 1 after credit is issued at time %0t", $time);
            $stop;
        end

        send_flit(16'b101_0101010_000000); // Size=5, Opcode=0x2A
        // if (ASize !== 3'b101 || AOpc !== 7'b0101010) begin
        //     $display("ERROR: Output fields mismatch: ASize=%b AOpc=%b at time %0t", ASize, AOpc, $time);
        //     $stop;
        // end

        // Credit should be consumed, AReady should go low again
        #(10);
        if (AReady !== 0) begin
            $display("ERROR: AReady should drop to 0 after consuming one credit at time %0t", $time);
            $stop;
        end

        // Provide two credits and send two flits back-to-back
        send_credit();
        send_credit();

        send_flit(16'b011_0011001_000001);
        send_flit(16'b100_1110000_000010);

        if (AReady !== 0) begin
            $display("ERROR: AReady should be 0 after consuming two credits at time %0t", $time);
            $stop;
        end

        $display("[%0t] Testbench completed successfully", $time);
        $finish;
    end

endmodule
