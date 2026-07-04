// I am assuming that the ID used in protocol,TriD would be unique for Unique transactions
// there can be max 4 active transactions, and hence 2 bit TrId
// There is one channel for both read and write request and 1 channel for read and write response
// The protocol is valid ready based, each channel having different valid ready

// this is simulation time monitor, no outputs
//I am assuming that max latency of a transaction can be 16 cycles so that would come in 4 bit counter

module active_tr_latency_count #(parameter Id_Width = 2)
(
    
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

    reg [ 2**Id_Width-1 :0] Tr_Active ; //Active signals to tell which transaction is active
    reg [ 3 :0] Tr_Cnt [2**Id_Width-1:0]; // counters of four bit, one for each TrId

    //for simulation monitoring
    wire [3:0] TrCnt1 = Tr_Cnt[0];
    wire [3:0] TrCnt2 = Tr_Cnt[1];
    wire [3:0] TrCnt3 = Tr_Cnt[2];    
    wire [3:0] TrCnt4 = Tr_Cnt[3];    

    wire start; //it tells if transaction has arrived
    wire done; //it tells if transaction has completed

    assign start = Req_Vld & Req_Rdy;
    assign done = Rsp_Vld & Rsp_Rdy;

    integer i,j;
    always @(posedge clk) begin
        if (rst) begin
            Tr_Active  = {2**Id_Width{1'b0}}; // all transaction inactive at reset
            for (i=0 ; i< 2**Id_Width ; i+=1)
                 Tr_Cnt[i] = 4'b0000;
        end

        else begin
            if (start) begin
                Tr_Active[Req_TrId] = 1'b1;
            end

            if (done) begin
                Tr_Active[Rsp_TrId] = 1'b0;
            end

            for ( j=0 ; j<2**Id_Width ; j++) begin
                Tr_Cnt[j] = (Tr_Active[j]==0) ? 4'b0000 : Tr_Cnt[j]+1'b1;
            end

        end
             
    end 


    reg [4*2**Id_Width-1:0] big_counter;
    reg [2**Id_Width-1:0] num_of_active_transactions;
    wire [5:0] avg_transactions_latency;
    reg [9:0] total_transactions; 

    assign avg_transactions_latency = (total_transactions==0) ? 6'b000000 : big_counter/ total_transactions;

    always @(posedge clk) begin
        if (rst) begin
            big_counter = 0;
            num_of_active_transactions = 0;
            total_transactions = 0;    
        end
        else begin
            big_counter = big_counter + num_of_active_transactions;
            num_of_active_transactions = num_of_active_transactions + start - done;
            total_transactions = total_transactions + start;
        end
        //     if (done)
        //         big_counter = big_counter - avg_transactions_latency;
        // end    
    end



endmodule    



