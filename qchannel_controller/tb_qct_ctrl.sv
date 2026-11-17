`include "qch_controller.sv"
module tb_qch_ctrl();

logic qreqn;
logic qacceptn=1;
logic qactive=0;
logic qdeny=0;

logic clk,rst;

always #5 clk = ~clk;

initial begin
    clk=0;
    rst=1;
    #30 rst=0;
end

qch_controller #(.HYST_COUNT(4'b0111)) dut (
    .QReqn(qreqn),
    .QAcceptn(qacceptn),
    .QActive(qactive),
    .QDeny(qdeny),
    .clk(clk),
    .rst(rst)
);


always_comb begin
    if (qreqn==1'b0)
         qacceptn=1'b0;    
end


initial begin
    $monitor("Time=%0t, QReqn=%b, QAcceptn=%b, QActive=%b, QDeny=%b, rst=%b, hyst_cnt=%d, curr_state=%d",$time,qreqn,qacceptn,qactive,qdeny,rst,dut.hyst_counter,dut.current_state);
    #1000 $finish;
end

endmodule
