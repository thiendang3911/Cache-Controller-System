module comparator (
    input [11:0] tag_cpu,
    input [11:0] tag_cache,
    input valid,
    output hit_or_miss
);
    // Hit khi Tag khớp VÀ dữ liệu hợp lệ
    assign hit_or_miss = (tag_cpu == tag_cache) && (valid == 1'b1);
endmodule