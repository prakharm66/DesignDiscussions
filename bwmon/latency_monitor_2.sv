module active_tr_cnt_global_cnt #(parameter Id_Width = 2)(
     //clk and reset
    clk,
    rst,

    //input protocol signals
    Req_TrId,
    Req_Vld,
    Req_Rdy,
    Rsp_TrId,
    Rsp_Vld,
    Rsp_Rdy
);

 // parameter Id_Width = 2; //width of transaction ID, can be changed as per protocol

    input [Id_Width-1:0] Req_TrId;
    input [Id_Width-1:0] Rsp_TrId;
    input Req_Vld;
    input Rsp_Vld;
    input Req_Rdy;
    input Rsp_Rdy;

    input clk;
    input rst;

    wire start; //it tells if transaction has arrived
    wire done; //it tells if transaction has completed

    assign start = Req_Vld & Req_Rdy;
    assign done = Rsp_Vld & Rsp_Rdy;

    reg [31:0] global_counter;
    reg [31:0] tr_start [2**Id_Width-1:0] ;
    reg latency_of_tr;

    always @(posedge clk) begin
        if (rst)
            global_counter = 0;
        else
        begin
            global_counter = global_counter + 1;
            for (integer i=0;i<2**Id_Width;i=i+1) 
            begin
                if (rst)
                    tr_start[i] = 0;
                else if (start && Req_TrId==i)
                    tr_start[i] = global_counter;
            end

            if (done) begin
                latency_of_tr = global_counter - tr_start[Rsp_TrId];
                $display("For TrId %d, latency was %d",Rsp_TrId,latency_of_tr); 
            end
        end
    end


    
endmodule