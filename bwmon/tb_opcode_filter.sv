module tb_opcode_filter();

    reg [6:0] opcode;
    wire flag;
    integer var,i;


    // Instantiate the opcode_filter with a specific OPCODE_SELECT value
    opcode_filter #(.OPCODE_SELECT(16'hFFFF)) dut (
        .opcode(opcode),
        .flag(flag)
    );

    initial begin

        $monitor("Time: %0t, Opcode: %h, Flag: %b", $time, opcode, flag);

        for (i=0 ; i<25 ; i++) begin
            var = $random;
            opcode = var[6:0];
            #10;
        end

        $finish;
    end

endmodule