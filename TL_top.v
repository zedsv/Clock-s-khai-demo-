module TL_top (
    input wire clk_50m,
    input wire rst_n,

    input wire btn_set,
    input wire btn_up,
    input wire btn_down,
    input wire btn_alarm,
    input wire btn_stop,

    output wire [6:0] seg0,
    output wire [3:0] sel,

    output wire buzzer_out,
    output wire red_led
);

    // =========================================================
    // 50 MHz -> 27 MHz clock
    // =========================================================

    wire clk_27m;

    clk_wiz_0 u_clk_wiz (
        .clk_in1  (clk_50m),
        .clk_out1 (clk_27m)
    );


    // =========================================================
    // BUTTON EDGES
    // =========================================================

    wire set_edge;
    wire up_edge;
    wire down_edge;
    wire alarm_edge;
    wire stop_edge;


    // SET
    TL_button u_btn_set (
        .clk     (clk_27m),
        .rst_n   (rst_n),
        .btn_raw (btn_set),
        .o_edge  (set_edge)
    );


    // UP
    TL_button u_btn_up (
        .clk     (clk_27m),
        .rst_n   (rst_n),
        .btn_raw (btn_up),
        .o_edge  (up_edge)
    );


    // DOWN
    TL_button u_btn_down (
        .clk     (clk_27m),
        .rst_n   (rst_n),
        .btn_raw (btn_down),
        .o_edge  (down_edge)
    );


    // ALARM
    TL_button u_btn_alarm (
        .clk     (clk_27m),
        .rst_n   (rst_n),
        .btn_raw (btn_alarm),
        .o_edge  (alarm_edge)
    );


    // STOP
    TL_button u_btn_stop (
        .clk     (clk_27m),
        .rst_n   (rst_n),
        .btn_raw (btn_stop),
        .o_edge  (stop_edge)
    );


    // =========================================================
    // BUTTON FEEDBACK
    // =========================================================

    wire button_press;

    assign button_press =
           set_edge
         | up_edge
         | down_edge
         | alarm_edge
         | stop_edge;


    // =========================================================
    // TIME
    // =========================================================

    wire [24:0] cnt_time;
    wire [5:0]  sec;
    wire [5:0]  min;
    wire [5:0]  hour;

    wire [5:0] hour_set;
    wire [5:0] min_set;

    wire time_set;


    TL_sec_min_hour u_time (
        .clk      (clk_27m),
        .rst_n    (rst_n),

        .time_set (time_set),
        .hour_set (hour_set),
        .min_set  (min_set),

        .cnt      (cnt_time),
        .sec      (sec),
        .min      (min),
        .hours    (hour)
    );


    // =========================================================
    // CONTROL
    // =========================================================

    wire [5:0] alarm_hour_set;
    wire [5:0] alarm_min_set;

    wire [2:0] mode;

    wire alarm_active;
    wire alarm_start;


    TL_control u_control (
        .clk             (clk_27m),
        .rst_n           (rst_n),

        .i_set_edge      (set_edge),
        .i_up_edge       (up_edge),
        .i_down_edge     (down_edge),
        .i_alarm_edge    (alarm_edge),
        .i_stop_edge     (stop_edge),

        .i_min           (min),
        .i_hour          (hour),
        .i_sec           (sec),

        .hour_set        (hour_set),
        .min_set         (min_set),

        .alarm_hour_set  (alarm_hour_set),
        .alarm_min_set   (alarm_min_set),

        .time_set        (time_set),
        .mode            (mode),

        .alarm_active    (alarm_active),
        .alarm_start     (alarm_start)
    );


    // =========================================================
    // DISPLAY
    // =========================================================

    TL_display u_display (
        .clk            (clk_27m),
        .rst_n          (rst_n),

        .min            (min),
        .hour           (hour),

        .hour_set       (hour_set),
        .min_set        (min_set),

        .alarm_hour_set (alarm_hour_set),
        .alarm_min_set  (alarm_min_set),

        .mode           (mode),

        .seg0           (seg0),
        .sel            (sel),
        .red_led        (red_led)
    );


    // =========================================================
    // BUZZER
    // =========================================================

    TL_buzzer u_buzzer (
        .clk          (clk_27m),
        .rst_n        (rst_n),

        .alarm_start  (alarm_start),
        .alarm_active (alarm_active),

        .button_press (button_press),
        .stop         (stop_edge),

        .buzzer_out   (buzzer_out)
    );

endmodule