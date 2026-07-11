library verilog;
use verilog.vl_types.all;
entity address_logic is
    port(
        cpu_addr        : in     vl_logic_vector(21 downto 0);
        cache_tag       : in     vl_logic_vector(11 downto 0);
        sel_addr        : in     vl_logic;
        tag_to_comp     : out    vl_logic_vector(11 downto 0);
        index           : out    vl_logic_vector(9 downto 0);
        sdram_addr_ext  : out    vl_logic_vector(21 downto 0)
    );
end address_logic;
