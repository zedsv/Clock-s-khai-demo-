module TL_control (
    input wire clk,
    input wire rst_n,

    input wire i_set_edge,
    input wire i_up_edge,
    input wire i_down_edge,
    input wire i_alarm_edge,
    input wire i_stop_edge,

    input wire [5:0] i_min,
    input wire [5:0] i_hour,
    input wire [5:0] i_sec,

    output reg [5:0] hour_set,
    output reg [5:0] min_set,

    output reg [5:0] alarm_hour_set,
    output reg [5:0] alarm_min_set,

    output reg       time_set,
    output reg [2:0] mode,

    output reg       alarm_active,
    output reg       alarm_start
);

    // Prevent repeated alarm trigger during the same second
    reg alarm_triggered;
    reg [29:0] cnt_timeout;

    always @(posedge clk or negedge rst_n) begin

        if (~rst_n) begin

            mode <= 3'd0;

            hour_set <= 6'd0;
            min_set  <= 6'd0;

            alarm_hour_set <= 6'd0;
            alarm_min_set  <= 6'd0;

            time_set <= 1'b0;

            alarm_active    <= 1'b0;
            alarm_start     <= 1'b0;
            alarm_triggered <= 1'b0;

            cnt_timeout <= 30'd0;
        end

        else begin

            // Default: one-clock pulse
            time_set    <= 1'b0;
            alarm_start <= 1'b0;

            // Clear alarm trigger lock after second changes
            if (i_sec != 6'd0)
                alarm_triggered <= 1'b0;


            // =====================================================
            // ALARM TRIGGER
            // =====================================================

            if ((mode == 3'd0) &&
                (i_hour == alarm_hour_set) &&
                (i_min  == alarm_min_set) &&
                (i_sec  == 6'd0) &&
                (~alarm_triggered) &&
                (~i_stop_edge)) begin

                alarm_active    <= 1'b1;
                alarm_start     <= 1'b1;
                alarm_triggered <= 1'b1;
            end


            // =====================================================
            // TIMEOUT 30s
            // =====================================================

            if (mode == 3'd0) begin

                cnt_timeout <= 30'd0;

            end
            else begin

                // Reset timeout when setting button is pressed
                if (i_set_edge ||
                    i_up_edge ||
                    i_down_edge ||
                    i_alarm_edge) begin

                    cnt_timeout <= 30'd0;

                end
                else begin

                    // 27 MHz x 30s = 810,000,000 clocks
                    if (cnt_timeout < 30'd809999999) begin

                        cnt_timeout <= cnt_timeout + 1'b1;

                    end
                    else begin

                        cnt_timeout <= 30'd0;

                        // SET timeout
                        if ((mode == 3'd1) ||
                            (mode == 3'd2)) begin

                            time_set <= 1'b1;
                            mode     <= 3'd0;

                        end

                        // ALARM timeout
                        else if ((mode == 3'd3) ||
                                 (mode == 3'd4)) begin

                            mode <= 3'd0;

                        end

                    end
                end
            end


            // =====================================================
            // SET BUTTON
            // =====================================================

            if (i_set_edge) begin

                case (mode)

                    // NORMAL -> SET HOUR
                    3'd0: begin
                        mode     <= 3'd1;
                        hour_set <= i_hour;
                        min_set  <= i_min;
                    end

                    // SET HOUR -> SET MINUTE
                    3'd1: begin
                        mode <= 3'd2;
                    end

                    // SET MINUTE -> NORMAL
                    3'd2: begin
                        mode     <= 3'd0;
                        time_set <= 1'b1;
                    end

                    default: begin
                        mode <= 3'd0;
                    end

                endcase
            end


            // =====================================================
            // ALARM BUTTON
            // =====================================================

            else if (i_alarm_edge) begin

                case (mode)

                    // NORMAL -> ALARM HOUR
                    3'd0: begin
                        mode <= 3'd3;
                    end

                    // ALARM HOUR -> ALARM MINUTE
                    3'd3: begin
                        mode <= 3'd4;
                    end

                    // ALARM MINUTE -> NORMAL
                    3'd4: begin
                        mode <= 3'd0;
                    end

                    default: begin
                        mode <= 3'd0;
                    end

                endcase
            end


            // =====================================================
            // UP BUTTON
            // =====================================================

            else if (i_up_edge) begin

                case (mode)

                    // Set current hour
                    3'd1: begin
                        if (hour_set < 6'd23)
                            hour_set <= hour_set + 1'b1;
                        else
                            hour_set <= 6'd0;
                    end

                    // Set current minute
                    3'd2: begin
                        if (min_set < 6'd59)
                            min_set <= min_set + 1'b1;
                        else
                            min_set <= 6'd0;
                    end

                    // Set alarm hour
                    3'd3: begin
                        if (alarm_hour_set < 6'd23)
                            alarm_hour_set <= alarm_hour_set + 1'b1;
                        else
                            alarm_hour_set <= 6'd0;
                    end

                    // Set alarm minute
                    3'd4: begin
                        if (alarm_min_set < 6'd59)
                            alarm_min_set <= alarm_min_set + 1'b1;
                        else
                            alarm_min_set <= 6'd0;
                    end

                    default: begin
                    end

                endcase
            end


            // =====================================================
            // DOWN BUTTON
            // =====================================================

            else if (i_down_edge) begin

                case (mode)

                    // Set current hour
                    3'd1: begin
                        if (hour_set > 6'd0)
                            hour_set <= hour_set - 1'b1;
                        else
                            hour_set <= 6'd23;
                    end

                    // Set current minute
                    3'd2: begin
                        if (min_set > 6'd0)
                            min_set <= min_set - 1'b1;
                        else
                            min_set <= 6'd59;
                    end

                    // Set alarm hour
                    3'd3: begin
                        if (alarm_hour_set > 6'd0)
                            alarm_hour_set <= alarm_hour_set - 1'b1;
                        else
                            alarm_hour_set <= 6'd23;
                    end

                    // Set alarm minute
                    3'd4: begin
                        if (alarm_min_set > 6'd0)
                            alarm_min_set <= alarm_min_set - 1'b1;
                        else
                            alarm_min_set <= 6'd59;
                    end

                    default: begin
                    end

                endcase
            end


            // =====================================================
            // STOP BUTTON
            // =====================================================

            else if (i_stop_edge) begin
                alarm_active <= 1'b0;
            end

        end
    end

endmodule