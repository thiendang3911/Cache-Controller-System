`timescale 1ns / 1ps

module cache_system_top_tb;

    // 1. Khai báo tín hiệu
    reg clk;
    reg reset_n;

    // Giao tiếp CPU
    reg cpu_rd;
    reg cpu_wr;
    reg [21:0] cpu_addr;
    reg [15:0] cpu_data_in;
    wire [15:0] cpu_data_out;
    wire cpu_wait;

    // Giao tiếp SDRAM
    reg sdram_ready;
    reg [15:0] sdram_data_out;
    wire [15:0] sdram_data_in;
    wire [21:0] sdram_addr_ext;
    wire sdram_rd_en;
    wire sdram_wr_en;
    
    // Tín hiệu Debug ra LED vật lý
    wire hit_or_miss;
    wire dirty_bit_in;
    wire [2:0] tb_current_state;
    assign tb_current_state = DUT.cache_ctrl_inst.current_state;

    // 2. Khởi tạo DUT (Device Under Test)
    cache_system_top DUT (
        .clk(clk),
        .reset_n(reset_n),
        
        .cpu_rd(cpu_rd),
        .cpu_wr(cpu_wr),
        .cpu_addr(cpu_addr),
        .cpu_data_in(cpu_data_in),
        .cpu_data_out(cpu_data_out),
        .cpu_wait(cpu_wait),
        
        .sdram_ready(sdram_ready),
        .sdram_data_out(sdram_data_out),
        .sdram_data_in(sdram_data_in),
        .sdram_addr_ext(sdram_addr_ext),
        .sdram_rd_en(sdram_rd_en),
        .sdram_wr_en(sdram_wr_en),
        
        .hit_or_miss(hit_or_miss),
        .dirty_bit_in(dirty_bit_in)
    );

    // 3. Tạo xung Clock chu kỳ 20ns (50MHz)
    always #10 clk = ~clk;

    // 4. Khối giả lập phản hồi của SDRAM
    always @(posedge clk) begin
        if (!reset_n) begin
            sdram_ready <= 0;
            sdram_data_out <= 16'h0000;
        end else begin
            if (!sdram_rd_en && !sdram_wr_en) begin
                sdram_ready <= 0;
            end
            
            // Giả lập trễ nạp dữ liệu từ SDRAM (Trễ 2 chu kỳ clock = 40ns)
            if (sdram_rd_en && !sdram_ready) begin
                #40; 
                sdram_ready <= 1;
                sdram_data_out <= {8'h00, sdram_addr_ext[7:0], 4'h1}; 
            end
            
            // Giả lập trễ ghi ngược dữ liệu xuống SDRAM (Trễ 2 chu kỳ clock = 40ns)
            if (sdram_wr_en && !sdram_ready) begin
                #40; 
                sdram_ready <= 1;
                $display("[%0t] SDRAM: Da hoan tat luu dong du lieu BAN %h xuong dia chi %h", $time, sdram_data_in, sdram_addr_ext);
            end
        end
    end
    // 5. Các Task hỗ trợ giả lập luồng CPU
    // Cập nhật hiển thị mã trạng thái FSM tương ứng trong lệnh in ra màn hình
    task cpu_read_request(input [21:0] addr);
        begin
            @ (posedge clk);
            cpu_rd = 1;
            cpu_addr = addr;
            
            @ (posedge clk);
            cpu_rd = 0; 
            
            wait(cpu_wait == 0); 
            @ (posedge clk);
            $display("[%0t] CPU READ: Dia chi %h -> Du lieu: %h | State hien tai: %0d", $time, addr, cpu_data_out, tb_current_state);
        end
    endtask

    task cpu_write_request(input [21:0] addr, input [15:0] data);
        begin
            @ (posedge clk);
            cpu_wr = 1;
            cpu_addr = addr;
            cpu_data_in = data;
            
            @ (posedge clk);
            cpu_wr = 0;
            
            wait(cpu_wait == 0);
            @ (posedge clk);
            $display("[%0t] CPU WRITE: Ghi thanh cong %h vao dia chi %h | State hien tai: %0d", $time, data, addr, tb_current_state);
        end
    endtask

    // 6. Kịch bản kiểm thử đồng bộ tuyến tính
    initial begin
        clk = 0;
        reset_n = 0;
        cpu_rd = 0;
        cpu_wr = 0;
        cpu_addr = 0;
        cpu_data_in = 0;

        $display("==================================================");
        $display("   BAT DAU KIEM THU CACHE SYSTEM");
        $display("==================================================");

        #30 reset_n = 1;
        #20;

        // KỊCH BẢN 1: Read Miss (Địa chỉ 0x000001)
        $display("\n--- KICH BAN 1: READ MISS ---");
        cpu_read_request(22'h00_0001);

        // KỊCH BẢN 2: Read Hit (Đọc lại chính địa chỉ 0x000001)
        $display("\n--- KICH BAN 2: READ HIT ---");
        cpu_read_request(22'h00_0001);

        // KỊCH BẢN 3: Write Hit (Ghi 0xAAAA vào 0x000001, tạo dòng Dirty)
        $display("\n--- KICH BAN 3: WRITE HIT (Bat co Dirty) ---");
        cpu_write_request(22'h00_0001, 16'hAAAA);

        // KỊCH BẢN 4: Conflict Miss & Write-Back (Đọc địa chỉ 0x040001 để trục xuất dòng bẩn)
        $display("\n--- KICH BAN 4: CONFLICT MISS & WRITE-BACK ---");
        cpu_read_request(22'h04_0001);

        #100;
        $display("\n==================================================");
        $display("   MO PHONG KET THUC!");
        $display("==================================================");
        $stop;
    end

endmodule