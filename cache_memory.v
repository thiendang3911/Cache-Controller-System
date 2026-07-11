module cache_memory (
    input clk,
	 input reset_n,
    input [9:0] index,
    input [11:0] tag_in,
    input [15:0] data_in,
    input cache_we, tag_we, status_we,
    input set_dirty, clear_dirty, 
    output [11:0] tag_out,
    output [15:0] data_out,
    output valid_out, dirty_out
);
    // 1. Khai báo Valid và Dirty bits bằng thanh ghi (vẫn dùng LABs vì dung lượng nhỏ)
    reg [1023:0] v_bits;
    reg [1023:0] d_bits;

    // Xuất trạng thái hiện tại dựa trên Index
    assign valid_out = v_bits[index];
    assign dirty_out = d_bits[index];

    // 2. Gọi module Data RAM (M4K) tạo từ MegaWizard
    data_ram_1024x16 my_data_ram (
        .address (index),
        .clock   (clk),
        .data    (data_in),
        .wren    (cache_we),
        .q       (data_out)
    );

    // 3. Gọi module Tag RAM (M4K) tạo từ MegaWizard
    tag_ram_1024x12 my_tag_ram (
        .address (index),
        .clock   (clk),
        .data    (tag_in),
        .wren    (tag_we),
        .q       (tag_out)
    );

    // 4. Logic cập nhật bit trạng thái (Valid, Dirty)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            v_bits <= {1024{1'b0}};  // ← Reset toàn bộ về 0
            d_bits <= {1024{1'b0}};  // ← Reset toàn bộ về 0
        end else if (status_we) begin
            v_bits[index] <= 1'b1;
            if (set_dirty)
                d_bits[index] <= 1'b1;
            else if (clear_dirty)
                d_bits[index] <= 1'b0;
        end
    end
endmodule