library verilog;
use verilog.vl_types.all;
entity cache_system_top is
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        cpu_rd          : in     vl_logic;
        cpu_wr          : in     vl_logic;
        cpu_addr        : in     vl_logic_vector(21 downto 0);
        cpu_data_in     : in     vl_logic_vector(15 downto 0);
        cpu_data_out    : out    vl_logic_vector(15 downto 0);
        cpu_wait        : out    vl_logic;
        sdram_ready     : in     vl_logic;
        sdram_data_out  : in     vl_logic_vector(15 downto 0);
        sdram_data_in   : out    vl_logic_vector(15 downto 0);
        sdram_addr_ext  : out    vl_logic_vector(21 downto 0);
        sdram_rd_en     : out    vl_logic;
        sdram_wr_en     : out    vl_logic;
        hit_or_miss     : out    vl_logic;
        dirty_bit_in    : out    vl_logic
    );
end cache_system_top;
