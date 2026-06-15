
module spi_master (
    input        clk,
    input        rst,
    input        start,
    input  [1:0] mode,      // {CPOL, CPHA}
    input  [7:0] data_in,
    output reg   mosi,
    output reg   sclk,
    output reg   cs,
    output reg   done
);

wire cpol = mode[1];
wire cpha = mode[0];

reg [2:0] bit_cnt;
reg [7:0] shift_reg;
reg [3:0] clk_div;
reg       busy;

wire sclk_en = (clk_div == 4);
wire leading_edge  = sclk_en && busy && (sclk ==  cpol);
wire trailing_edge = sclk_en && busy && (sclk == ~cpol);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mosi      <= 0;
        sclk      <= 0;
        cs        <= 1;
        done      <= 0;
        bit_cnt   <= 0;
        shift_reg <= 0;
        clk_div   <= 0;
        busy      <= 0;
    end else begin
        done <= 0;

        if (start && !busy) begin
            busy      <= 1;
            cs        <= 0;
            shift_reg <= data_in;
            bit_cnt   <= 0;
            clk_div   <= 0;
            sclk      <= cpol;     

            // CPHA=0: Truyền bit đầu tiên ngay khi CS xuống
            if (!cpha)
                mosi <= data_in[7];
        end

        if (busy) begin
            clk_div <= clk_div + 1;

            if (sclk_en) begin
                clk_div <= 0;
                sclk    <= ~sclk;
            end

            // MODE 0 & MODE 2
            if (!cpha && trailing_edge) begin
                if (bit_cnt == 7) begin
                    busy <= 0;
                    cs   <= 1;
                    done <= 1;
                end else begin
                    shift_reg <= {shift_reg[6:0], 1'b0};
                    mosi      <= shift_reg[6];
                end
                bit_cnt <= bit_cnt + 1;
            end

            // MODE 1 & MODE 3
            if (cpha && leading_edge) begin
                mosi      <= shift_reg[7];
                shift_reg <= {shift_reg[6:0], 1'b0};
                if (bit_cnt == 7) begin
                    busy <= 0;
                    cs   <= 1;
                    done <= 1;
                end
                bit_cnt <= bit_cnt + 1;
            end
        end

    end
end

endmodule