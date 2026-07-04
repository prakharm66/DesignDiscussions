module tb_latency_monitor();


    parameter Id_Width = 2;
    reg clk,rst;

    reg [Id_Width-1:0] Req_TrId, Rsp_TrId;
    reg Req_Vld, Rsp_Vld, Req_Rdy, Rsp_Rdy;
   
    logic [Id_Width-1:0] free_ids[$]; //Ids which are free to be used for new transactions
    logic [Id_Width-1:0] active_ids[$]; //Ids which are currently active

    active_tr_latency_count #(.Id_Width(Id_Width)) dut(
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

task automatic Send_request(input logic [Id_Width-1:0] TrId);
    @(posedge clk) begin
        Req_TrId = TrId;
        Req_Vld = 1'b1;
    end

    @(posedge clk) begin
        Req_Vld = 1'b0;
    end
endtask

task automatic Accept_request(input logic [Id_Width-1:0] TrId);
    @(posedge clk) begin
        Rsp_TrId = TrId;
        Rsp_Vld = 1'b1;
    end

    @(posedge clk) begin
        Rsp_Vld = 1'b0;
    end
endtask


    reg [Id_Width-1:0] new_id_to_send;
    reg [Id_Width-1:0] new_id_to_accept;
    int random_idx_free, random_idx_active;
    reg add_req=1'b0,add_rsp=1'b0;

    // Fill the free id queue with all possible transaction IDs at the beginning of simulation
    initial begin
        for (int i=0 ; i< 2**Id_Width ; i++) begin
            free_ids.push_back(i[Id_Width-1:0]);
        end
    end

    initial begin
        
        $monitor (" %d, ReqVld %b, ReqTrId %d, RspVld %b, RspTrId %d ,\n  TrActive %b,  TrCnt1 %d, TrCnt2 %d , TrCnt3 %d , TrCnt4 %d, AvgLat %d, TotalLat %d, NumActive %d, total_trn %d",$time
        ,Req_Vld, Req_TrId, Rsp_Vld, Rsp_TrId, 
        dut.Tr_Active, dut.Tr_Cnt[0], dut.Tr_Cnt[1], dut.Tr_Cnt[2], dut.Tr_Cnt[3], dut.avg_transactions_latency, dut.big_counter, dut.num_of_active_transactions , dut.total_transactions             
        );

        //Rdy always 1
        Req_Rdy = 1'b1;
        Rsp_Rdy = 1'b1;
        Req_Vld = 1'b0;
        Rsp_Vld = 1'b0;
        Req_TrId = {Id_Width{1'b0}};
        Rsp_TrId = {Id_Width{1'b0}};

        //reset sequence
        rst = 1'b1;
        #30 rst = 1'b0;

        //sending the transactions
        for (int j =0 ; j<200; j++) begin
            #10;
            fork
                begin
                    if (free_ids.size() && $urandom_range(0,1) ) begin //if there are free Ids, then send transaction
                        random_idx_free = $urandom_range(0, free_ids.size()-1);
                        new_id_to_send = free_ids[random_idx_free];
                        free_ids.delete(random_idx_free);
                        $display("%d would be sent",new_id_to_send);
                        Send_request(new_id_to_send);   
                        add_req=1'b1; 
                    end
                end

                begin
                    if (active_ids.size() && $urandom_range(0,1) ) begin //if there are active Ids, then accept transaction
                        random_idx_active = $urandom_range(0, active_ids.size()-1);
                        new_id_to_accept = active_ids[random_idx_active];
                        active_ids.delete(random_idx_active);
                        $display("%d would be accepted",new_id_to_accept);
                        Accept_request(new_id_to_accept);
                        add_rsp=1'b1;
                    end
                end
            join

            #1;//wait for sometime before adding

            if (add_req) begin    
                active_ids.push_back(new_id_to_send);
                add_req=1'b0;
            end

            if (add_rsp) begin
                free_ids.push_back(new_id_to_accept);
                add_rsp=1'b0;
            end
            $display("-------------------------");

        end


        // //First Cycle
        // #10 Send_request( {Id_Width{1'b0}} );
        // //Second Cycle
        // #10 fork
        //     Send_request(2'b01);
        //     Accept_request(2'b00);
        // join

        // //Third Cycle
        // #10 Send_request(2'b10);
        
        // //Fourth Cycle
        // #10 fork
        //     Send_request(2'b11);
        //     Accept_request(2'b10);
        // join

        // //Fifth Cycle
        // #10 fork
        //     Send_request(2'b00);
        //     Accept_request(2'b11);
        // join

        // //Sixth Cycle

        // #10 fork 
        //     Send_request (2'b00);
        //     Accept_request (2'b11);
        // join

        // //Seventh Cycle
        // #10 Accept_request (2'b00);

        // //Eigth Cycle
        // #10 Accept_request (2'b01);

        #20 $finish;

    end

initial begin
    $dumpfile("tb_latency_monitor.vcd");
    $dumpvars(0, tb_latency_monitor);
end



endmodule
