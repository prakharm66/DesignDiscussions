`timescale 1ps/

module dataless_filter(
    AOpcode,
    AValid,
    Clk,
    IsDataless
);

input [6:0] AOpcode;
input AValid;
input Clk;  

output IsDataless;

//Opcodes which needs to be filtered out
// CleanInvalid:        0,00,x9
// CleanInvalidPopa:    1,00,xD 
// Makeinvalid:         0,00,xA
// CleanShared:         0,00,x8
// CleanSharedPersist:  0,10,x7
// CleaSharedPersistSep:0,01,x3
// CleanUnique:         0,00,xB
// makeunique:          0,00,xC
// Evict:               0,00,xD
// StashOnceUnique:     0,10,x3
// StashOnceSepUnique:  1,00,x8
// StashOnceShared:     0,10,x2
// StashOnceSepShared:  1,00,x7 

wire matched;
assign matched = (AOpcode == 7'h09) || (AOpcode == 7'h0D) || (AOpcode == 7'h0A) || (AOpcode == 7'h08) || (AOpcode == 7'h27) || (AOpcode == 7'h13) || (AOpcode == 7'h0B) || (AOpcode == 7'h0C) || (AOpcode == 7'h0D) || (AOpcode == 7'h23) || (AOpcode == 7'h18) || (AOpcode == 7'h27);

always @(poseedge clk) begin
    if (AValid) begin
        IsDataless <= matched;
    end else begin
        IsDataless <= 0;
    end
end

endmodule