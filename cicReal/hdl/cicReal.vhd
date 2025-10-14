---------------------------------------------------------------------------
-- (c) Copyright: FemtoEngineering
-- Author : Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date : 2024/04/15
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity cicReal is
	generic (
		ID: natural := 1;
		BIT_PRUNING : boolean := true;
		data_signed: boolean := true;
		DECIMATE_FACTOR : natural := 8;
		DIFFERENTIAL_DELAY : natural := 1;
		ORDER : natural := 3;
		DATA_IN_SIZE  : natural := 16;
		DATA_OUT_SIZE : natural := 23
	);
	port (
		-- input data
		data_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_clk_i: in std_logic;
		data_rst_i: in std_logic;
		-- for the next component
		data_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic
	);
end cicReal;

architecture arch_imp of cicReal is
begin

	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	cic_top_inst : entity work.cicReal_top
	generic map (
		BIT_PRUNING => BIT_PRUNING,
		data_signed => data_signed,
		DECIMATE_FACTOR => DECIMATE_FACTOR,
		DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY,
		ORDER => ORDER,
		DATA_IN_SIZE => DATA_IN_SIZE,
		DATA_OUT_SIZE => DATA_OUT_SIZE
	)
	port map (
		-- Syscon signals
		clk			=> data_clk_i,
		reset		=> data_rst_i,
		-- input data
		data_i		=> data_i,
		data_en_i	=> data_en_i,
		-- for the next component
		data_o		=> data_o,
		data_en_o	=> data_en_o
	);

end arch_imp;
