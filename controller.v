module controller (
    input clk,
    input reset_n,
    
    // Tín hiệu từ CPU
    input cpu_rd,
    input cpu_wr,
    
    // Tín hiệu từ Datapath
    input hit_or_miss,   
    input dirty_bit_in,  
    
    // Tín hiệu từ SDRAM Interface
    input sdram_ready,
    
    // Tín hiệu điều khiển Datapath
    output reg cache_we,    
    output reg tag_we,      
    output reg status_we,   
    output reg sel_addr,     //(0: CPU, 1: WriteBack)
    output reg set_dirty,   
    output reg clear_dirty, 
    
    // Tín hiệu điều khiển bên ngoài
    output reg cpu_wait,    
    output reg sdram_rd_en,
    output reg sdram_wr_en
);

    // Định nghĩa các trạng thái FSM
    localparam IDLE         = 3'b000;
    localparam COMPARE_TAG  = 3'b001;
    localparam WRITE_BACK   = 3'b010;
    localparam MEM_READ     = 3'b011;
    localparam UPDATE_CACHE = 3'b100;

    reg [2:0] current_state, next_state;

    // 1. Chuyển trạng thái
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // 2. Logic chuyển trạng thái tiếp theo (Next State Logic)
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (cpu_rd || cpu_wr) next_state = COMPARE_TAG;
                else next_state = IDLE;
            end
            
            COMPARE_TAG: begin
                if (hit_or_miss) begin
                    if (cpu_wr) next_state = UPDATE_CACHE; // Write Hit
                    else next_state = IDLE;                // Read Hit (Done)
                end else begin
                    if (dirty_bit_in) next_state = WRITE_BACK; // Miss & Dirty
                    else next_state = MEM_READ;              // Miss & Clean
                end
            end
            
            WRITE_BACK: begin
                if (sdram_ready) next_state = MEM_READ;
                else next_state = WRITE_BACK;
            end
            
            MEM_READ: begin
                if (sdram_ready) next_state = UPDATE_CACHE;
                else next_state = MEM_READ;
            end
            
            UPDATE_CACHE: begin
                next_state = IDLE; // Sau khi cập nhật xong quay về IDLE
            end
            
            default: next_state = IDLE;
        endcase
    end

    // 3. Logic tín hiệu đầu ra (Output Logic - Moore)
    always @(*) begin
        // Giá trị mặc định
        {cache_we, tag_we, status_we, sel_addr, set_dirty, clear_dirty} = 6'b000000;
        {cpu_wait, sdram_rd_en, sdram_wr_en} = 3'b000;

        case (current_state)
            IDLE: begin
                cpu_wait = 0;
            end

            COMPARE_TAG: begin
                cpu_wait = 1;
                // Logic so sánh diễn ra trong Datapath
            end

            WRITE_BACK: begin
                cpu_wait = 1;
                sel_addr = 1;     // Chọn địa chỉ cũ để ghi ngược 
                sdram_wr_en = 1;   // Kích hoạt ghi SDRAM
            end

            MEM_READ: begin
                cpu_wait = 1;
                sel_addr = 0;     // Chọn địa chỉ CPU đang yêu cầu 
                sdram_rd_en = 1;   // Kích hoạt đọc từ SDRAM
            end

            UPDATE_CACHE: begin
                cpu_wait = 1;
                status_we = 1;     
                cache_we = 1;    
                
                // Phân biệt nguồn dữ liệu dựa trên Tag_WE 
                // Nếu là Write Hit (không đổi Tag) -> set_dirty
                // Nếu là nạp mới sau Miss (có đổi Tag) -> clear_dirty
                if (hit_or_miss) begin // Write Hit path
                    tag_we = 0;
                    set_dirty = 1;  
                end else begin         // Miss path (after MEM_READ)
                    tag_we = 1;   
                    clear_dirty = 1; 
                end
            end
        endcase
    end

endmodule