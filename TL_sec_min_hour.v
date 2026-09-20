module TL_sec_min_hour (
    input wire clk,
    input wire rst_n,

    input wire       time_set,
    input wire [5:0] hour_set,
    input wire [5:0] min_set,

    output reg [24:0] cnt,
    output reg [5:0]  sec,
    output reg [5:0]  min,
    output reg [5:0]  hours
);

    // 27 MHz clock
    // 1 second = 27,000,000 clock cycles

    always @(posedge clk or negedge rst_n) begin

        if (~rst_n) begin
            cnt   <= 25'd0;
            sec   <= 6'd0;
            min   <= 6'd0;
            hours <= 6'd0;
        end

        else if (time_set) begin
            // Load new time
            cnt   <= 25'd0;
            sec   <= 6'd0;
            min   <= min_set;
            hours <= hour_set;
        end

        else begin

            if (cnt < 25'd26999999) begin
                cnt <= cnt + 1'b1;
            end

            else begin
                cnt <= 25'd0;

                // Seconds
                if (sec < 6'd59) begin
                    sec <= sec + 1'b1;
                end

                else begin
                    sec <= 6'd0;

                    // Minutes
                    if (min < 6'd59) begin
                        min <= min + 1'b1;
                    end

                    else begin
                        min <= 6'd0;

                        // Hours
                        if (hours < 6'd23)
                            hours <= hours + 1'b1;
                        else
                            hours <= 6'd0;
                    end
                end
            end
        end
    end

endmodule