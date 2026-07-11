library verilog;
use verilog.vl_types.all;
entity cache_memory is
    port(
        clk             : in     vl_logic;
        index           : in     vl_logic_vector(9 downto 0);
        tag_in          : in     vl_logic_vector(11 downto 0);
        data_in         : in     vl_logic_vector(15 downto 0);
        cache_we        : in     vl_logic;
        tag_we          : in     vl_logic;
        status_we       : in     vl_logic;
        set_dirty       : in     vl_logic;
        clear_dirty     : in     vl_logic;
        tag_out         : out    vl_logic_vector(11 downto 0);
        data_out        : out    vl_logic_vector(15 downto 0);
        valid_out       : out    vl_logic;
        dirty_out       : out    vl_logic
    );
end cache_memory;
