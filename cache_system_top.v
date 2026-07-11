module cache_system_top (
    input wire clk,
    input wire reset_n,
    
    // Tín hiệu giao tiếp với CPU
    input wire cpu_rd,               // Tín hiệu yêu cầu đọc từ CPU
    input wire cpu_wr,               // Tín hiệu yêu cầu ghi từ CPU
    input wire [21:0] cpu_addr,      // Địa chỉ CPU yêu cầu (22-bit)
    input wire [15:0] cpu_data_in,   // Dữ liệu CPU muốn ghi
    output wire [15:0] cpu_data_out, // Dữ liệu trả về cho CPU
    output wire cpu_wait,            // Tín hiệu báo CPU tạm dừng (stall)
    
    // Tín hiệu giao tiếp với Main Memory (SDRAM Interface / IP Core)
    input wire sdram_ready,           // Tín hiệu báo SDRAM đã sẵn sàng
    input wire [15:0] sdram_data_out, // Dữ liệu đọc từ SDRAM lên Cache
    output wire [15:0] sdram_data_in, // Dữ liệu từ Cache ghi ngược xuống SDRAM
    output wire [21:0] sdram_addr_ext,// Địa chỉ cấp cho SDRAM
    output wire sdram_rd_en,          // Tín hiệu cho phép đọc SDRAM
    output wire sdram_wr_en,          // Tín hiệu cho phép ghi SDRAM
    
    // Tín hiệu thông báo trên DE2 Kit
    output wire hit_or_miss,
    output wire dirty_bit_in
);

    // Khai báo các tín hiệu kết nối nội bộ (Control Signals)
    wire cache_we;
    wire tag_we;
    wire status_we;
    wire sel_addr;
    wire set_dirty;
    wire clear_dirty;

    // Khởi tạo Module Điều Khiển (FSM Controller)
    controller cache_ctrl_inst (
        .clk(clk),
        .reset_n(reset_n),
        
        // Giao tiếp CPU
        .cpu_rd(cpu_rd),
        .cpu_wr(cpu_wr),
        .cpu_wait(cpu_wait),
        
        // Phản hồi từ Datapath
        .hit_or_miss(hit_or_miss),
        .dirty_bit_in(dirty_bit_in),
        
        // Giao tiếp SDRAM
        .sdram_ready(sdram_ready),       // Ánh xạ đường sẵn sàng từ SDRAM ngoại vi
        .sdram_rd_en(sdram_rd_en),       // Lệnh đọc SDRAM phát ra từ FSM
        .sdram_wr_en(sdram_wr_en),       // Lệnh ghi SDRAM phát ra từ FSM
        
        // Tín hiệu điều khiển Datapath
        .cache_we(cache_we),
        .tag_we(tag_we),
        .status_we(status_we),
        .sel_addr(sel_addr),
        .set_dirty(set_dirty),
        .clear_dirty(clear_dirty)
    );

    // Khởi tạo Module Đường dẫn dữ liệu (Datapath)
    datapath_top cache_dp_inst (
        .clk(clk),
        .reset_n(reset_n),
        
        // Giao tiếp CPU
        .cpu_addr(cpu_addr),
        .cpu_data_in(cpu_data_in),
        .cpu_data_out(cpu_data_out),
        
        // Giao tiếp SDRAM
        .sdram_data_out(sdram_data_out), // Luồng dữ liệu nạp từ SDRAM vào Cache Data RAM
        .sdram_data_in(sdram_data_in),   // Luồng dữ liệu trục xuất từ Cache xuống SDRAM
        .sdram_addr_ext(sdram_addr_ext), // Luồng địa chỉ định tuyến ra bộ nhớ chính
        
        // Tín hiệu điều khiển từ FSM (Controller)
        .cache_we(cache_we),
        .tag_we(tag_we),
        .status_we(status_we),
        .sel_addr(sel_addr),
        .set_dirty(set_dirty),
        .clear_dirty(clear_dirty),
        
        // Phản hồi về FSM (Controller)
        .hit_or_miss(hit_or_miss),
        .dirty_bit_in(dirty_bit_in)
    );

endmodule