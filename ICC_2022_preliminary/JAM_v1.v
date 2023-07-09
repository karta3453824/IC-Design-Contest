module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

integer i;

parameter  Find_pt      = 0,
           Find_min     = 1,
           Reverse_list = 2,
           Got_cost     = 3,
           cal          = 4, 
           Output       = 5;

reg [2:0] state;
reg [2:0] change_pt;
reg [2:0] min_pt;

reg [2:0] arr[0:7]; 

reg [2:0] counter;
reg [3:0] counter_2;
reg [2:0] x0, x1, x2, x3, x4, x5, x6, x7;

reg [9:0] total_cost;

reg last_signal;

always@(*) begin
    x0 = arr[0]; x1 = arr[1]; x2 = arr[2]; x3 = arr[3]; x4 = arr[4]; x5 = arr[5]; x6 = arr[6]; x7 = arr[7];
end

always@(*) begin
    W = counter;
    J = arr[counter];
end
     
always@(posedge CLK) begin
    if(RST) begin
        for(i = 0; i <= 7; i = i + 1)
            arr[i] <= i;

        change_pt <= 3'd6; min_pt <= 3'd7; counter <= 3'd7;
        MatchCount <= 0; MinCost <= 10'd1023; Valid <= 0; total_cost <= 0;
        last_signal <= 0;
    end

    else begin
        case(state)
            Find_pt: begin
                if(arr[change_pt] < arr[change_pt+1])
                    state <= Find_min;
                
                else if(change_pt != 0) begin
                    change_pt <= change_pt - 1;
                    min_pt <= min_pt - 1;
                    counter <= counter - 1;
                end

                else begin
                    state <= cal;  //last permutation
                    last_signal <= 1;
                end
            end

            Find_min: begin
                if(counter != 7) begin
                    if(arr[min_pt+1] > arr[change_pt] && arr[min_pt+1] < arr[min_pt])
                        min_pt <= min_pt + 1;
                    counter <= counter + 1;
                end

                else begin
                    arr[change_pt] <= arr[min_pt];
                    arr[min_pt] <= arr[change_pt];
                    state <= Reverse_list;
                    counter <= 0;
                end
            end

            Reverse_list: begin
                case(change_pt)
                    0: begin
                        for(i=1; i<=7; i=i+1)
                            arr[8-i] <= arr[0+i];
                    end
                    
                    1: begin
                        for(i=1; i<=6; i=i+1)
                            arr[8-i] <= arr[1+i];
                    end
                    
                    2: begin
                        for(i=1; i<=5; i=i+1)
                            arr[8-i] <= arr[2+i];
                    end
                    
                    3: begin
                        for(i=1; i<=4; i=i+1)
                            arr[8-i] <= arr[3+i];
                    end
                    
                    4: begin
                        for(i=1; i<=3; i=i+1)
                            arr[8-i] <= arr[4+i];
                    end
                    
                    5: begin
                        for(i=1; i<=2; i=i+1)
                            arr[8-i] <= arr[5+i];
                    end
                endcase

                state <= Got_cost;
                counter <= 0;
                total_cost <= 0;
                counter_2 <= 0;
            end

            Got_cost: begin
                if(counter_2 <= 8) begin
                    counter <= (counter == 7) ? counter : counter + 1;
                    state <= (counter_2 == 8) ? cal : Got_cost;

                    if(counter_2 >= 1)
                        total_cost <= total_cost + Cost;
                end
            end

            cal: begin
                if(total_cost < MinCost) begin
                    MinCost <= total_cost;
                    MatchCount <= 4'd1;
                end

                else if(total_cost == MinCost)
                    MatchCount <= MatchCount + 1;
                
                change_pt <= 3'd6;
				min_pt <= 3'd7;
				counter <= 3'd7; 

                state <= (last_signal == 1) ? Output : Find_pt;
            end

            Output:
                Valid <= 1;
        endcase
    end
end

always@(posedge CLK) begin
    if(RST)
        counter_2 <= 4'd0;
    
    else if(state == Got_cost)
        counter_2 <= counter_2 + 1;
end

endmodule


