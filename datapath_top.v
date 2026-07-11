module datapath_top (
    input clk,
    input reset_n,
    
    // Giao tiếp với CPU
    input [21:0] cpu_addr,        // Địa chỉ 22-bit nâng cấp cho SDRAM
    input [15:0] cpu_data_in,      // Dữ liệu từ CPU ghi vào
    output [15:0] cpu_data_out,    // Dữ liệu trả về cho CPU
    
    // Giao tiếp với SDRAM (thông qua sdram Interface/IP Core)
    input [15:0] sdram_data_out,    // Dữ liệu nạp từ SDRAM vào
    output [15:0] sdram_data_in,    // Dữ liệu ghi ngược xuống SDRAM
    output [21:0] sdram_addr_ext,   // Địa chỉ gửi tới SDRAM (22-bit)
    
    // Tín hiệu điều khiển từ FSM (Controller)
    input cache_we,               // Ghi vào Data RAM
    input tag_we,                 // Ghi vào Tag RAM
    input status_we,              // Ghi vào Valid/Dirty bit
    input sel_addr,               // Chọn địa chỉ: 0-CPU, 1-OldTag (WriteBack)
    input set_dirty,              // Set bit Dirty khi Write Hit
    input clear_dirty,            // Xóa bit Dirty khi vừa nạp mới
    
    // Tín hiệu phản hồi về FSM (Controller)
    output hit_or_miss,           // Kết quả so sánh Tag
    output dirty_bit_in           // Trạng thái bẩn/sạch của dòng hiện tại
);

    // Các đường dây (wires) kết nối nội bộ
    wire [11:0] tag_from_cache;
    wire [11:0] tag_cpu;
    wire [9:0]  index;
    wire [15:0] data_from_cache;
    wire valid_bit;
	 wire cpu_we_select = (tag_we == 1'b0);

    // 1. Module xử lý địa chỉ: Tách Tag/Index và chọn địa chỉ ra ngoài
    address_logic addr_unit (
        .cpu_addr(cpu_addr),
        .cache_tag(tag_from_cache),
        .sel_addr(sel_addr),
        .tag_to_comp(tag_cpu),
        .index(index),
        .sdram_addr_ext(sdram_addr_ext)
    );

    // 2. Module lưu trữ: Data RAM, Tag RAM và các bit trạng thái
    cache_memory mem_unit (
        .clk(clk),
		  .reset_n(reset_n),
        .index(index),
        .tag_in(tag_cpu),
        .data_in(cpu_we_select ? cpu_data_in : sdram_data_out), // Chọn nguồn dữ liệu ghi vào cache
        .cache_we(cache_we),
        .tag_we(tag_we),
        .status_we(status_we),
        .set_dirty(set_dirty),
        .clear_dirty(clear_dirty),
        .tag_out(tag_from_cache),
        .data_out(data_from_cache),
        .valid_out(valid_bit),
        .dirty_out(dirty_bit_in)
    );

    // 3. Module so sánh: Kiểm tra Hit hay Miss
    comparator comp_unit (
        .tag_cpu(tag_cpu),
        .tag_cache(tag_from_cache),
        .valid(valid_bit),
        .hit_or_miss(hit_or_miss)
    );

    // 4. Logic điều phối luồng dữ liệu (Data Path Steering)
    // Dữ liệu trả về CPU là dữ liệu từ Cache
    assign cpu_data_out = data_from_cache;
    
    // Dữ liệu ghi xuống SDRAM là dữ liệu cũ từ Cache (khi Write Back)
    assign sdram_data_in = data_from_cache;

    // Logic phụ trợ: Nếu đang trong chu kỳ nạp từ SDRAM thì lấy sdram_data_out, 
    // nếu CPU ghi trực tiếp thì lấy cpu_data_in.
    // Tín hiệu này có thể lấy từ trạng thái của FSM hoặc kết hợp cache_we.

endmodule