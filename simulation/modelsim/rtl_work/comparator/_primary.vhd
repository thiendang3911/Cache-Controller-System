library verilog;
use verilog.vl_types.all;
entity comparator is
    port(
        tag_cpu         : in     vl_logic_vector(11 downto 0);
        tag_cache       : in     vl_logic_vector(11 downto 0);
        valid           : in     vl_logic;
        hit_or_miss     : out    vl_logic
    );
end comparator;
