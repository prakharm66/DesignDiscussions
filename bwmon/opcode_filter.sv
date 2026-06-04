module opcode_filter(opcode, flag)
;
    parameter OPCODE_SELECT = 16'h0000; //default value, can be overridden at instantiation;
 
    input [6:0] opcode;
    output flag;

    localparam OPCODE1 = 7'h00;
    localparam OPCODE2 = 7'h01;
    localparam OPCODE3 = 7'h02;
    localparam OPCODE4 = 7'h03;
    localparam OPCODE5 = 7'h04;
    localparam OPCODE6 = 7'h05;
    localparam OPCODE7 = 7'h06;
    localparam OPCODE8 = 7'h07;
    localparam OPCODE9 = 7'h08;
    localparam OPCODE10 = 7'h09;
    localparam OPCODE11 = 7'h0A;
    localparam OPCODE12 = 7'h0B;
    localparam OPCODE13 = 7'h0C;
    localparam OPCODE14 = 7'h0D;
    localparam OPCODE15 = 7'h0E;
    localparam OPCODE16 = 7'h0F;

    assign flag = ( (OPCODE_SELECT[0] && (opcode == OPCODE1)) |
                    (OPCODE_SELECT[1] && (opcode == OPCODE2)) |
                    (OPCODE_SELECT[2] && (opcode == OPCODE3)) |
                    (OPCODE_SELECT[3] && (opcode == OPCODE4)) |
                    (OPCODE_SELECT[4] && (opcode == OPCODE5)) |
                    (OPCODE_SELECT[5] && (opcode == OPCODE6)) |
                    (OPCODE_SELECT[6] && (opcode == OPCODE7)) |
                    (OPCODE_SELECT[7] && (opcode == OPCODE8)) |
                    (OPCODE_SELECT[8] && (opcode == OPCODE9)) |
                    (OPCODE_SELECT[9] && (opcode == OPCODE10)) |
                    (OPCODE_SELECT[10] && (opcode == OPCODE11)) |
                    (OPCODE_SELECT[11] && (opcode == OPCODE12)) |
                    (OPCODE_SELECT[12] && (opcode == OPCODE13)) |
                    (OPCODE_SELECT[13] && (opcode == OPCODE14)) |
                    (OPCODE_SELECT[14] && (opcode == OPCODE15)) |
                    (OPCODE_SELECT[15] && (opcode == OPCODE16))
                  );
    
endmodule