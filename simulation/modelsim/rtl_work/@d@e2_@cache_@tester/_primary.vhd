library verilog;
use verilog.vl_types.all;
entity DE2_Cache_Tester is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(0 downto 0);
        LEDG            : out    vl_logic_vector(0 downto 0);
        LEDR            : out    vl_logic_vector(1 downto 0);
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
end DE2_Cache_Tester;
