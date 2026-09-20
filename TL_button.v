module TL_button (
    input  wire clk,
    input  wire rst_n,
    input  wire btn_raw,
    output reg  o_edge
);

    // Synchronizer
    reg ff1;
    reg ff2;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            ff1 <= 1'b1;
            ff2 <= 1'b1;
        end
        else begin
            ff1 <= btn_raw;
            ff2 <= ff1;
        end
    end

    // 20 ms debounce at 27 MHz
    reg        btn_debounce;
    reg [19:0] cnt_debounce;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cnt_debounce <= 20'd0;
            btn_debounce <= 1'b1;
        end
        else begin
            if (ff2 != btn_debounce) begin
                if (cnt_debounce < 20'd539999)
                    cnt_debounce <= cnt_debounce + 1'b1;
                else begin
                    btn_debounce <= ff2;
                    cnt_debounce <= 20'd0;
                end
            end
            else begin
                cnt_debounce <= 20'd0;
            end
        end
    end

    // Falling-edge detection
    // Button is active-low
    reg btn_pre;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            btn_pre <= 1'b1;
            o_edge  <= 1'b0;
        end
        else begin
            btn_pre <= btn_debounce;

            if (~btn_debounce && btn_pre)
                o_edge <= 1'b1;
            else
                o_edge <= 1'b0;
        end
    end

endmodule