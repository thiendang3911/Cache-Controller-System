module DE2_Cache_Tester (
    input wire CLOCK_50,    // Pin N2 (Xung clock 50 MHz trên kit DE2)
    input wire [1:1] KEY,   // Pin G26 (Nút nhấn làm tín hiệu Reset chân thấp)
     
    output wire [7:7] LEDG, // LEDG[7] báo tín hiệu HIT
    output wire [1:0] LEDR, // LEDR[0] báo tín hiệu MISS, LEDR[1] báo trạng thái DIRTY

    // Giao tiếp trực tiếp với chip SDRAM vật lý trên kit DE2 (Gán Pin thực tế)
    output wire [11:0] DRAM_ADDR,  // Bus địa chỉ SDRAM vật lý (12 bits)
    output wire [1:0]  DRAM_BA,    // Bank Address (2 bits)
    inout  wire [15:0] DRAM_DQ,    // Bus dữ liệu hai chiều SDRAM (16 bits)
    output wire        DRAM_RAS_N, // Row Address Strobe
    output wire        DRAM_CAS_N, // Column Address Strobe
    output wire        DRAM_WE_N,  // Write Enable của SDRAM
    output wire        DRAM_CLK,   // Xung Clock cấp riêng cho chip SDRAM ngoài
    output wire        DRAM_CKE,   // Clock Enable
    output wire        DRAM_CS_N,  // Chip Select
    output wire        DRAM_LDQM,  // Low-byte Data Mask
    output wire        DRAM_UDQM   // High-byte Data Mask
);

    // Khai báo các dây nối nội bộ (Internal Wires)
    // Tín hiệu điều khiển ảo phát ra từ IP Core ISSP (Tổng: 40 bits)
    wire [39:0] issp_source;
    
    wire cpu_rd;               // 1 bit  (issp_source[39])
    wire cpu_wr;               // 1 bit  (issp_source[38])
    wire [21:0] cpu_addr;      // 22 bits (issp_source[37:16])
    wire [15:0] cpu_data_in;   // 16 bits (issp_source[15:0])

    // Tín hiệu phản hồi ảo đưa vào IP Core ISSP (Tổng: 17 bits)
    wire [16:0] issp_probe;
    
    wire [15:0] cpu_data_out;  // 16 bits (issp_probe[16:1])
    wire cpu_wait;            // 1 bit  (issp_probe[0])

    // Đường kết nối chuẩn SDRAM Interface phát ra từ lõi Cache
    wire sdram_rd_en, sdram_wr_en;
    wire sdram_ready;
    wire [21:0] cache_sdram_addr;
    wire [15:0] sdram_data_from_cache;
    wire [15:0] sdram_data_to_cache;
     
    // Tín hiệu thể hiện hiển thị lên LED vật lý của Kit DE2
    wire hit_or_miss_wire;
    wire dirty_bit_wire;
    assign LEDG[7] = hit_or_miss_wire;
    assign LEDR[0] = ~hit_or_miss_wire;
    assign LEDR[1] = dirty_bit_wire;

    // 1. Ánh xạ dữ liệu tách/ghép từ IP Core ISSP
    assign cpu_rd      = issp_source[39];
    assign cpu_wr      = issp_source[38];
    assign cpu_addr    = issp_source[37:16];
    assign cpu_data_in = issp_source[15:0];

    assign issp_probe  = {cpu_data_out, cpu_wait};
	 
	 // 2. Khởi tạo IP Core ISSP (CPU Ảo)
    issp issp_inst (
        .probe  (issp_probe),   
        .source (issp_source)   
    );

    // 3. Khởi tạo khối lõi Hệ thống Cache (DUT)
    cache_system_top cache_core (
        .clk(CLOCK_50),
        .reset_n(KEY[1]),
        
        // Luồng CPU ảo (ISSP)
        .cpu_rd(cpu_rd),
        .cpu_wr(cpu_wr),
        .cpu_addr(cpu_addr),
        .cpu_data_in(cpu_data_in),
        .cpu_data_out(cpu_data_out),
        .cpu_wait(cpu_wait),
        
        // Luồng kết nối Interface đổi tên đồng bộ sang SDRAM
        .sdram_ready(sdram_ready), 
        .sdram_data_out(sdram_data_to_cache),  // Đọc từ bộ nhớ ngoài vào Cache
        .sdram_data_in(sdram_data_from_cache), // Ghi ngược từ Cache xuống bộ nhớ ngoài
        .sdram_addr_ext(cache_sdram_addr),
        .sdram_rd_en(sdram_rd_en),
        .sdram_wr_en(sdram_wr_en),
          
        // Kết nối tín hiệu lên LED thông báo
        .hit_or_miss(hit_or_miss_wire),
        .dirty_bit_in(dirty_bit_wire)
    );

    // 4. Khởi tạo Khối Điều Khiển SDRAM Cứng Vật Lý (SDRAM Controller IP Core)
    // Lớp điều khiển này đóng vai trò dịch các tín hiệu đơn giản của Cache
    // (`sdram_rd_en`, `sdram_wr_en`,...) thành các chu kỳ timing chuẩn của chip SDRAM trên board.
    // Bus dữ liệu DQ hai chiều (inout) và đệm 3 trạng thái sẽ được xử lý tự động trong khối IP này.
    
    sdram_controller_ip sdram_ctrl_inst (
        // Giao tiếp với mạch Cache lõi bên trong FPGA
        .clk          (CLOCK_50),
        .reset_n      (KEY[1]),
        .addr         (cache_sdram_addr),       // Nhận địa chỉ 22-bit mở rộng từ Cache
        .rd_en        (sdram_rd_en),            // Nhận xung cho phép đọc từ Cache
        .wr_en        (sdram_wr_en),            // Nhận xung cho phép ghi từ Cache
        .data_in      (sdram_data_from_cache),  // Nhận luồng dữ liệu Write-Back
        .data_out     (sdram_data_to_cache),    // Trả luồng dữ liệu đọc được về cho Cache
        .ready        (sdram_ready),            // Trả tín hiệu báo bận/sẵn sàng về cho Cache FSM
        
        // Giao tiếp trực tiếp ra chân vật lý của chip SDRAM ngoài board DE2
        .DRAM_ADDR    (DRAM_ADDR),
        .DRAM_BA      (DRAM_BA),
        .DRAM_DQ      (DRAM_DQ),
        .DRAM_RAS_N   (DRAM_RAS_N),
        .DRAM_CAS_N   (DRAM_CAS_N),
        .DRAM_WE_N    (DRAM_WE_N),
        .DRAM_CLK     (DRAM_CLK),
        .DRAM_CKE     (DRAM_CKE),
        .DRAM_CS_N    (DRAM_CS_N),
        .DRAM_LDQM    (DRAM_LDQM),
        .DRAM_UDQM    (DRAM_UDQM)
    );

endmodule