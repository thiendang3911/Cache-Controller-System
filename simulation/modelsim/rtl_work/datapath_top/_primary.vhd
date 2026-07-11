library verilog;
use verilog.vl_types.all;
entity datapath_top is
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        cpu_addr        : in     vl_logic_vector(21 downto 0);
        cpu_data_in     : in     vl_logic_vector(15 downto 0);
        cpu_data_out    : out    vl_logic_vector(15 downto 0);
        sdram_data_out  : in     vl_logic_vector(15 downto 0);
        sdram_data_in   : out    vl_logic_vector(15 downto 0);
        sdram_addr_ext  : out    vl_logic_vector(21 downto 0);
        cache_we        : in     vl_logic;
        tag_we          : in     vl_logic;
        status_we       : in     vl_logic;
        sel_addr        : in     vl_logic;
        set_dirty       : in     vl_logic;
        clear_dirty     : in     vl_logic;
        hit_or_miss     : out    vl_logic;
        dirty_bit_in    : out    vl_logic
    );
end datapath_top;
