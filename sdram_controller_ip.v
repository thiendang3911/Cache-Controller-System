module sdram_controller_ip (
    // Giao tiếp với mạch Cache lõi bên trong FPGA
    input wire clk,
    input wire reset_n,
    input wire [21:0] addr,       // Địa chỉ mở rộng từ Cache
    input wire rd_en,            // Xung cho phép đọc từ Cache
    input wire wr_en,            // Xung cho phép ghi từ Cache
    input wire [15:0] data_in,   // Luồng dữ liệu Write-Back từ Cache
    output reg [15:0] data_out,  // Luồng dữ liệu đọc trả về Cache
    output reg ready,            // Tín hiệu báo sẵn sàng về Cache FSM
    
    // Giao tiếp trực tiếp ra chân vật lý của chip SDRAM trên board DE2
    output reg [11:0] DRAM_ADDR,
    output reg [1:0]  DRAM_BA,
    inout  wire [15:0] DRAM_DQ,
    output reg        DRAM_RAS_N,
    output reg        DRAM_CAS_N,
    output reg        DRAM_WE_N,
    output wire       DRAM_CLK,
    output reg        DRAM_CKE,
    output reg        DRAM_CS_N,
    output wire       DRAM_LDQM,
    output wire       DRAM_UDQM
);

    // Cấp clock và giữ mặt nạ dữ liệu luôn mở (Cho phép truy cập cả 2 byte)
    assign DRAM_CLK  = clk;
    assign DRAM_LDQM = 1'b0; 
    assign DRAM_UDQM = 1'b0;

    // Quản lý Bus hai chiều DQ bằng Tri-state buffer tích hợp nội bộ
    reg ledr_write_mode;
    assign DRAM_DQ = ledr_write_mode ? data_in : 16'bz;

    // Bộ đếm chu kỳ để tạo độ trễ vật lý (Penalty Latency)
    reg [2:0] cycle_cnt;
    
    // Khai báo các trạng thái nạp/đọc của SDRAM
    localparam STATE_IDLE  = 2'b00;
    localparam STATE_WAIT  = 2'b01;
    localparam STATE_DONE  = 2'b10;
    reg [1:0] current_state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state   <= STATE_IDLE;
            cycle_cnt       <= 0;
            ready           <= 0;
            data_out        <= 16'h0000;
            ledr_write_mode <= 0;
            
            // Thiết lập trạng thái nghỉ mặc định cho chip SDRAM (NOP command)
            DRAM_CS_N  <= 1'b0;
            DRAM_CKE   <= 1'b1;
            DRAM_RAS_N <= 1'b1;
            DRAM_CAS_N <= 1'b1;
            DRAM_WE_N  <= 1'b1;
            DRAM_ADDR  <= 12'h000;
            DRAM_BA    <= 2'b00;
        end else begin
            case (current_state)
                STATE_IDLE: begin
                    ready <= 0;
                    if (rd_en || wr_en) begin
                        current_state <= STATE_WAIT;
                        cycle_cnt     <= 3; // Ép độ trễ CAS Latency = 3 chu kỳ clock vật lý
                        
                        // Phân rã địa chỉ 22-bit của Cache thành cấu hình SDRAM:
                        // 2 bits Bank Address, 12 bits Row/Column Address
                        DRAM_BA   <= addr[21:20];
                        DRAM_ADDR <= addr[11:0];
                        
                        if (wr_en) begin
                            ledr_write_mode <= 1; // Mở cổng đệm đẩy dữ liệu ra DQ
                            // Lệnh GHI vật lý (WRITE Command: CS=0, RAS=1, CAS=0, WE=0)
                            DRAM_RAS_N <= 1'b1; DRAM_CAS_N <= 1'b0; DRAM_WE_N <= 1'b0;
                        end else begin
                            ledr_write_mode <= 0; // Đóng cổng đệm, chuyển DQ sang nhận
                            // Lệnh ĐỌC vật lý (READ Command: CS=0, RAS=1, CAS=0, WE=1)
                            DRAM_RAS_N <= 1'b1; DRAM_CAS_N <= 1'b0; DRAM_WE_N <= 1'b1;
                        end
                    end else begin
                        // Trạng thái không kích hoạt (Command NOP)
                        DRAM_RAS_N <= 1'b1; DRAM_CAS_N <= 1'b1; DRAM_WE_N <= 1'b1;
                        ledr_write_mode <= 0;
                    end
                end

                STATE_WAIT: begin
                    // Duy trì trạng thái NOP trong khi đợi chip nhớ ngoài đáp ứng timing
                    DRAM_RAS_N <= 1'b1; DRAM_CAS_N <= 1'b1; DRAM_WE_N <= 1'b1;
                    if (cycle_cnt > 1) begin
                        cycle_cnt <= cycle_cnt - 1;
                    end else begin
                        current_state <= STATE_DONE;
                        ready         <= 1; // Báo cờ Sẵn sàng về cho Cache FSM
                        if (!ledr_write_mode) begin
                            data_out <= DRAM_DQ; // "Chụp" dữ liệu thực tế từ chip SDRAM ngoài vào
                        end
                    end
                end

                STATE_DONE: begin
                    ready           <= 0;
                    ledr_write_mode <= 0;
                    current_state   <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule