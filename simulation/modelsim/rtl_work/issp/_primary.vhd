library verilog;
use verilog.vl_types.all;
entity issp is
    port(
        probe           : in     vl_logic_vector(16 downto 0);
        source          : out    vl_logic_vector(39 downto 0)
    );
end issp;
