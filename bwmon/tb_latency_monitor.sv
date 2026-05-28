module tb_latency_monitor();

    reg clk,rst;

    reg [1:0] Req_TrId, Rsp_TrId;
    reg Req_Vld, Rsp_Vld, Req_Rdy, Rsp_Rdy;

    active_tr_latency_count dut(
        .clk(clk),
        .rst(rst),
        .Req_TrId(Req_TrId),
        .Req_Vld(Req_Vld),
        .Req_Rdy(Req_Rdy),
        .Rsp_TrId(Rsp_TrId),
        .Rsp_Vld(Rsp_Vld),
        .Rsp_Rdy(Rsp_Rdy)
    );

    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;

task Send_request([1:0] TrId);
    
    @(posedge clk) 
    begin
        Req_TrId = TrId;
        Req_Vld = 1'b1;
    end

    @(posedge clk)
    begin
        Req_Vld = 1'b0;
    end
endtask 

task Accept_request([1:0] TrId);
    
    @(posedge clk) 
    begin
        Rsp_TrId = TrId;
        Rsp_Vld = 1'b1;
    end

    @(posedge clk)
    begin
        Rsp_Vld = 1'b0;
    end
endtask 

    initial begin
        
        $monitor (" %d, ReqVld %b, ReqTrId %d, RspVld %b, RspTrId %d ,\n  TrActive %b,  TrCnt1 %d, TrCnt2 %d , TrCnt3 %d , TrCnt4 %d",$time
        ,Req_Vld, Req_TrId, Rsp_Vld, Rsp_TrId, 
        dut.Tr_Active, dut.Tr_Cnt[0], dut.Tr_Cnt[1], dut.Tr_Cnt[2], dut.Tr_Cnt[3]              
        );

        //Rdy always 1
        Req_Rdy = 1'b1;
        Rsp_Rdy = 1'b1;
        Req_Vld = 1'b0;
        Rsp_Vld = 1'b0;
        Req_TrId = 2'b00;
        Rsp_TrId = 2'b00;

        //reset sequence
        rst = 1'b1;
        #30 rst = 1'b0;

        //sending the transactions

        //First Cycle
        #10 Send_request( 2'b00 );
        
        //Second Cycle
        #10 fork
            Send_request(2'b01);
            Accept_request(2'b00);
        join

        //Third Cycle
        #10 Send_request(2'b10);
        
        //Fourth Cycle
        #10 fork
            Send_request(2'b11);
            Accept_request(2'b10);
        join

        //Fifth Cycle
        #10 fork
            Send_request(2'b00);
            Accept_request(2'b11);
        join

        //Sixth Cycle

        #10 fork 
            Send_request (2'b00);
            Accept_request (2'b11);
        join

        //Seventh Cycle
        #10 Accept_request (2'b00);

        //Eigth Cycle
        #10 Accept_request (2'b01);

        #20 $finish;

    end

initial begin
    $dumpfile("tb_latency_monitor.vcd");
    $dumpvars(0, tb_latency_monitor);
end



endmodule
