library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity add_constComplex_rst is
	port (
		rst_i : in std_logic;
		clk_i : in std_logic;
		rst_o : out std_logic
	);
end add_constComplex_rst;

architecture Behavioral of add_constComplex_rst is
	signal rst_sync_m1_s, rst_sync_s : std_logic;
begin
    -- reset fpga_clk => processing_clk
    process(clk_i) begin
        if rising_edge(clk_i) then
            rst_sync_m1_s <= rst_i;
            rst_sync_s <= rst_sync_m1_s;
            rst_o <= rst_sync_s;
        end if;
    end process;                                    
end Behavioral;
