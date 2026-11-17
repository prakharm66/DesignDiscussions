typedef enum logic [2:0]
{ Q_RUN = 3'b110,
  Q_REQUEST = 3'b010,
  Q_STOPPED = 3'b000,
  Q_EXIT = 3'b100,
  Q_DENIED = 3'b011,
  Q_CONTINUE = 3'b111
} qch_ctrl_state;

module qch_controller(
    QReqn,
    QAcceptn,
    QActive,
    QDeny,
    clk,
    rst
);

    parameter HYST_COUNT  = 4'b0001;

    output logic QReqn=1;
    input logic QAcceptn;
    input logic QActive;
    input logic QDeny;
    input logic clk;
    input logic rst;

    logic [3:0] hyst_counter = 4'b0000;

    qch_ctrl_state current_state,next_state;

    always_ff @(posedge clk ) begin
        if (rst) begin
            hyst_counter <= 4'b0000;
            current_state <= Q_RUN;
        end
        else begin
            current_state <= next_state; 
            hyst_counter <= (current_state==Q_RUN) ? hyst_counter + 1 : 4'b0000;  
        end  
    end

    always_comb begin 
        if (hyst_counter == HYST_COUNT) begin
            QReqn = 1'b0;
            hyst_counter = 4'b0000;
        end
        
    end


    always_comb begin
        case (current_state)
            Q_RUN:
                if (QReqn==0)
                    next_state = Q_REQUEST;
            
            Q_REQUEST:
                if (QAcceptn==0)
                    next_state = Q_STOPPED;
                else if (QDeny==1)
                    next_state = Q_DENIED;

            Q_DENIED:
                if (QReqn==1)
                    next_state = Q_CONTINUE;

            Q_CONTINUE:
                if (QDeny==0)
                    next_state = Q_RUN;

            Q_STOPPED:
                if (QReqn==1)        
                    next_state = Q_EXIT;

            Q_EXIT:
                if (QAcceptn==1)
                    next_state = Q_RUN;
            default:
                next_state = Q_RUN;                
        endcase
    end

endmodule