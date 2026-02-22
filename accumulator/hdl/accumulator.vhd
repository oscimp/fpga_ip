library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

Entity accumulator is 
	generic (
		NB_ACCUM : natural := 8
	);
	port 
	(
		-- input data
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;
		-- for the next component
		data_clk_o	: out std_logic;
		data_rst_o	: out std_logic
	);
end entity accumulator;

Architecture accumulator_1 of accumulator is
	constant CPT_SZ : natural := natural(ceil(log2(real(NB_ACCUM))));

	signal cpt : natural range 0 to NB_ACCUM-1;
	signal cpt_s : std_logic_vector(CPT_SZ-1 downto 0);

begin
	data_rst_o <= data_rst_i;

	cpt_s <= std_logic_vector(to_unsigned(cpt, CPT_SZ));
	--data_clk_o <= cpt_s(CPT_SZ-1);

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				cpt <= 0;
			else
				cpt <= cpt;
				if cpt < NB_ACCUM-1 then
					cpt <= cpt + 1;
				else
					cpt <= 0;
				end if;
				if 2*cpt < NB_ACCUM-1 then
					data_clk_o <= '1';
				else
					data_clk_o <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture accumulator_1;
