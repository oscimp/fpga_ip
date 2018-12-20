---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity shifterReal is 
	generic (
		DATA_IN_SIZE : natural := 32;
		DATA_OUT_SIZE : natural := 16
	);
	port (
		-- input data
		data_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_eof_i: in std_logic;
		data_clk_i: in std_logic;
		data_rst_i: in std_logic;
		-- for the next component
		data_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_rst_o : out std_logic;
		data_clk_o : out std_logic
	);
end entity;
Architecture shifterReal_1 of shifterReal is
	signal data_s, data_next_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
begin
	data_o <= data_s;
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	gt_size : if DATA_IN_SIZE < DATA_OUT_SIZE generate
		data_next_s <= data_i & (DATA_OUT_SIZE - DATA_IN_SIZE - 1 downto 0 => '0');
	end generate;
	lt_size : if DATA_IN_SIZE > DATA_OUT_SIZE generate
		data_next_s <= data_i(DATA_IN_SIZE-1 downto DATA_IN_SIZE-DATA_OUT_SIZE);
    end generate;

    eq_size : if DATA_IN_SIZE = DATA_OUT_SIZE generate
        data_next_s <= data_i;
    end generate;


	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			data_s <= data_s;
			data_en_o <= '0';
			data_eof_o <= '0';
			if data_en_i = '1' then
				data_s <= data_next_s;
				data_en_o <= '1';
				data_eof_o <= data_eof_i;
			end if;
		end if;
	end process;
end architecture shifterReal_1;

