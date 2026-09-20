module TL_buzzer (
    input wire clk,
    input wire rst_n,

    input wire alarm_start,
    input wire alarm_active,
    input wire button_press,
    input wire stop,

    output reg buzzer_out
);

    // 2 kHz tone
    localparam [12:0] TONE_COUNT_MAX = 13'd6749;

    // 0.5 second
    localparam [23:0] HALF_SEC_COUNT_MAX = 24'd13499999;

    // 0.1 second
    localparam [21:0] BUTTON_COUNT_MAX = 22'd2699999;

    reg [12:0] cnt_tone;
    reg [23:0] cnt_alarm;
    reg [21:0] cnt_button;

    reg alarm_on_phase;
    reg button_beep;


    always @(posedge clk or negedge rst_n) begin

        if (~rst_n) begin

            cnt_tone       <= 13'd0;
            cnt_alarm      <= 24'd0;
            cnt_button     <= 22'd0;

            alarm_on_phase <= 1'b0;
            button_beep    <= 1'b0;

            buzzer_out     <= 1'b0;

        end

        else begin

            // --------------------------------
            // Start button feedback
            // --------------------------------
            if (button_press) begin
                cnt_button  <= 22'd0;
                button_beep <= 1'b1;
            end

            else if (button_beep) begin

                if (cnt_button < BUTTON_COUNT_MAX)
                    cnt_button <= cnt_button + 1'b1;

                else begin
                    cnt_button  <= 22'd0;
                    button_beep <= 1'b0;
                end
            end

            else begin
                cnt_button <= 22'd0;
            end


            // --------------------------------
            // STOP alarm
            // --------------------------------
            if (stop) begin

                cnt_tone       <= 13'd0;
                cnt_alarm      <= 24'd0;
                alarm_on_phase <= 1'b0;

                // Do not clear button_beep here
                buzzer_out <= 1'b0;
            end


            // --------------------------------
            // Start alarm
            // --------------------------------
            else if (alarm_start) begin

                cnt_tone       <= 13'd0;
                cnt_alarm      <= 24'd0;
                alarm_on_phase <= 1'b1;

                buzzer_out <= 1'b0;
            end


            // --------------------------------
            // Alarm running
            // --------------------------------
            else if (alarm_active) begin

                if (alarm_on_phase) begin

                    // Generate 2 kHz
                    if (cnt_tone < TONE_COUNT_MAX) begin
                        cnt_tone <= cnt_tone + 1'b1;
                    end
                    else begin
                        cnt_tone   <= 13'd0;
                        buzzer_out <= ~buzzer_out;
                    end


                    // 0.5 second ON
                    if (cnt_alarm < HALF_SEC_COUNT_MAX) begin
                        cnt_alarm <= cnt_alarm + 1'b1;
                    end
                    else begin
                        cnt_alarm      <= 24'd0;
                        cnt_tone       <= 13'd0;
                        alarm_on_phase <= 1'b0;
                        buzzer_out     <= 1'b0;
                    end

                end

                else begin

                    // 0.5 second OFF
                    buzzer_out <= 1'b0;
                    cnt_tone   <= 13'd0;

                    if (cnt_alarm < HALF_SEC_COUNT_MAX) begin
                        cnt_alarm <= cnt_alarm + 1'b1;
                    end
                    else begin
                        cnt_alarm      <= 24'd0;
                        cnt_tone       <= 13'd0;
                        alarm_on_phase <= 1'b1;
                    end
                end
            end


            // --------------------------------
            // Button beep
            // --------------------------------
            else if (button_beep) begin

                cnt_alarm <= 24'd0;

                if (cnt_tone < TONE_COUNT_MAX) begin
                    cnt_tone <= cnt_tone + 1'b1;
                end
                else begin
                    cnt_tone   <= 13'd0;
                    buzzer_out <= ~buzzer_out;
                end
            end


            // --------------------------------
            // OFF
            // --------------------------------
            else begin

                cnt_tone       <= 13'd0;
                cnt_alarm      <= 24'd0;
                alarm_on_phase <= 1'b0;

                buzzer_out <= 1'b0;
            end
        end
    end

endmodule