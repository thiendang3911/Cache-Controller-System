module address_logic (
    input [21:0] cpu_addr,      // Địa chỉ 22-bit từ CPU
    input [11:0] cache_tag, 		// Tag cũ đọc từ Cache
    input sel_addr,             // Điều khiển từ FSM (0: CPU, 1: Write Back)
    output [11:0] tag_to_comp,
    output [9:0] index,
    output [21:0] sdram_addr_ext // Địa chỉ gửi ra bộ nhớ ngoài
);
    assign index = cpu_addr[9:0];
    assign tag_to_comp = cpu_addr[21:10];
    
    // Mux chọn địa chỉ: Nếu Write Back, dùng Tag cũ + Index hiện tại
    assign sdram_addr_ext = (sel_addr == 1'b0) ? cpu_addr : {cache_tag, index};
endmodule