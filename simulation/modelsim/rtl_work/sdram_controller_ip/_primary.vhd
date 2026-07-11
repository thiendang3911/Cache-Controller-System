library verilog;
use verilog.vl_types.all;
entity sdram_controller_ip is
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        addr            : in     vl_logic_vector(21 downto 0);
        rd_en           : in     vl_logic;
        wr_en           : in     vl_logic;
        data_in         : in     vl_logic_vector(15 downto 0);
        data_out        : out    vl_logic_vector(15 downto 0);
        ready           : out    vl_logic;
        DRAM_ADDR       : out    vl_logic_vector(11 downto 0);
        DRAM_BA         : out    vl_logic_vector(1 downto 0);
        DRAM_DQ         : inout  vl_logic_vector(15 downto 0);
        DRAM_RAS_N      : out    vl_logic;
        DRAM_CAS_N      : out    vl_logic;
        DRAM_WE_N       : out    vl_logic;
        DRAM_CLK        : out    vl_logic;
        DRAM_CKE        : out    vl_logic;
        DRAM_CS_N       : out    vl_logic;
        DRAM_LDQM       : out    vl_logic;
        DRAM_UDQM       : out    vl_logic
    );
end sdram_controller_ip;
