module TL_display (
    input wire clk,
    input wire rst_n,

    input wire [5:0] min,
    input wire [5:0] hour,

    input wire [5:0] hour_set,
    input wire [5:0] min_set,

    input wire [5:0] alarm_hour_set,
    input wire [5:0] alarm_min_set,

    input wire [2:0] mode,

    output reg [6:0] seg0,
    output reg [3:0] sel,
    output reg       red_led
);

    // Blink: 0.5s ON / 0.5s OFF
    reg [24:0] cnt_blink;
    reg        blink_on;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cnt_blink <= 25'd0;
            blink_on  <= 1'b1;
        end
        else if (mode == 3'd0) begin
            cnt_blink <= 25'd0;
            blink_on  <= 1'b1;
        end
        else begin
            if (cnt_blink < 25'd13499999)
                cnt_blink <= cnt_blink + 1'b1;
            else begin
                cnt_blink <= 25'd0;
                blink_on  <= ~blink_on;
            end
        end
    end

    // Red LED: alarm setting modes only
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            red_led <= 1'b0;
        else if ((mode == 3'd3) || (mode == 3'd4))
            red_led <= blink_on;
        else
            red_led <= 1'b0;
    end

    // Select display value
    reg [5:0] display_hour;
    reg [5:0] display_min;

    always @(*) begin
        case (mode)
            3'd0: begin
                display_hour = hour;
                display_min  = min;
            end

            3'd1: begin
                display_hour = hour_set;
                display_min  = min;
            end

            3'd2: begin
                display_hour = hour_set;
                display_min  = min_set;
            end

            3'd3,
            3'd4: begin
                display_hour = alarm_hour_set;
                display_min  = alarm_min_set;
            end

            default: begin
                display_hour = hour;
                display_min  = min;
            end
        endcase
    end

    // Split digits
    reg [3:0] hour_ten;
    reg [3:0] hour_unit;
    reg [3:0] min_ten;
    reg [3:0] min_unit;

    always @(*) begin
        hour_ten  = display_hour / 10;
        hour_unit = display_hour % 10;
        min_ten   = display_min / 10;
        min_unit  = display_min % 10;
    end

    // 4-digit scan
    reg [14:0] cnt_scan;
    reg [1:0]  digit;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cnt_scan <= 15'd0;
            digit    <= 2'd0;
        end
        else begin
            if (cnt_scan < 15'd26999)
                cnt_scan <= cnt_scan + 1'b1;
            else begin
                cnt_scan <= 15'd0;

                if (digit < 2'd3)
                    digit <= digit + 1'b1;
                else
                    digit <= 2'd0;
            end
        end
    end

    // Digit select + blink
    reg [3:0] number;

    always @(*) begin
        sel    = 4'b0000;
        number = 4'd0;

        case (digit)
            2'd0: begin
                sel    = 4'b1000;
                number = hour_ten;
            end

            2'd1: begin
                sel    = 4'b0100;
                number = hour_unit;
            end

            2'd2: begin
                sel    = 4'b0010;
                number = min_ten;
            end

            2'd3: begin
                sel    = 4'b0001;
                number = min_unit;
            end

            default: begin
                sel    = 4'b0000;
                number = 4'd0;
            end
        endcase

        if (~blink_on) begin
            // Set hour
            if ((mode == 3'd1) &&
                ((digit == 2'd0) || (digit == 2'd1)))
                sel = 4'b0000;

            // Set minute
            else if ((mode == 3'd2) &&
                     ((digit == 2'd2) || (digit == 2'd3)))
                sel = 4'b0000;

            // Alarm hour
            else if ((mode == 3'd3) &&
                     ((digit == 2'd0) || (digit == 2'd1)))
                sel = 4'b0000;

            // Alarm minute
            else if ((mode == 3'd4) &&
                     ((digit == 2'd2) || (digit == 2'd3)))
                sel = 4'b0000;
        end
    end

    // 7-segment decoder
    // seg0[6:0] = A B C D E F G
    // 0 = ON, 1 = OFF

    always @(*) begin
        case (number)
            4'd0: seg0 = 7'b1000000;
            4'd1: seg0 = 7'b1111001;
            4'd2: seg0 = 7'b0100100;
            4'd3: seg0 = 7'b0110000;
            4'd4: seg0 = 7'b0011001;
            4'd5: seg0 = 7'b0010010;
            4'd6: seg0 = 7'b0000010;
            4'd7: seg0 = 7'b1111000;
            4'd8: seg0 = 7'b0000000;
            4'd9: seg0 = 7'b0010000;
            default: seg0 = 7'b1111111;
        endcase
    end

endmodule