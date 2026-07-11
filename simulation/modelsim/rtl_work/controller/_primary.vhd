library verilog;
use verilog.vl_types.all;
entity controller is
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        cpu_rd          : in     vl_logic;
        cpu_wr          : in     vl_logic;
        hit_or_miss     : in     vl_logic;
        dirty_bit_in    : in     vl_logic;
        sdram_ready     : in     vl_logic;
        cache_we        : out    vl_logic;
        tag_we          : out    vl_logic;
        status_we       : out    vl_logic;
        sel_addr        : out    vl_logic;
        set_dirty       : out    vl_logic;
        clear_dirty     : out    vl_logic;
        cpu_wait        : out    vl_logic;
        sdram_rd_en     : out    vl_logic;
        sdram_wr_en     : out    vl_logic
    );
end controller;
