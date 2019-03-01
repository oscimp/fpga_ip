-- ***************************************************************************
-- ***************************************************************************
-- Copyright 2019 (c) OscillatorIMP Digital
-- Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
--
-- In this HDL repository, there are many different and unique modules, consisting
-- of various HDL (Verilog or VHDL) components. The individual modules are
-- developed independently, and may be accompanied by separate and unique license
-- terms.
--
-- The user should read each of these license terms, and understand the
-- freedoms and responsibilities that he or she has by using this source/core.
--
-- This core is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE.
--
-- Redistribution and use of source or resulting binaries, with or without modification
-- of this file, are permitted under one of the following two license terms:
--
--   1. The GNU General Public License version 2 as published by the
--      Free Software Foundation, which can be found in the top level directory
--      of this repository (LICENSE_GPL2), and also online at:
--      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
--
-- OR
--
--   2. An ADI specific BSD license, which can be found in the top level directory
--      of this repository (LICENSE_ADIBSD), and also on-line at:
--      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
--      This will allow to generate bit files and not release the source code,
--      as long as it attaches to an ADI device.
--
-- ***************************************************************************
-- ***************************************************************************

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.deltaSigma_clkgen;
use work.deltaSigma_tx;

entity deltaSigma_controller is
	generic(
		C_SLOT_WIDTH	: integer := 24		-- Width of one Slot
	);
	port(
		clk				: in  std_logic;	-- System clock
		resetn			: in  std_logic; 	-- System reset

		data_clk		: in  std_logic;	-- Data clock should be less than clk / 4

		tx_enable		: in  Boolean;		-- Enable TX
		tx_ack			: out std_logic;	-- Request new Slot Data
		tx_stb			: in  std_logic;	-- Request new Slot Data
		tx_data_left	: in  std_logic_vector(31 downto 0); 	-- Slot Data in
		tx_data_right	: in  std_logic_vector(31 downto 0); 	-- Slot Data in

		bit_left_o		: out std_logic;
		bit_right_o		: out std_logic;
	
		-- Runtime parameter
		bclk_div_rate		: in  natural range 0 to 255;
		lrclk_div_rate		: in  natural range 0 to 255
	);
end deltaSigma_controller;

architecture Behavioral of deltaSigma_controller is

signal enable			: Boolean;

signal cdc_sync_stage0_tick	: std_logic;
signal cdc_sync_stage1_tick	: std_logic;
signal cdc_sync_stage2_tick	: std_logic;
signal cdc_sync_stage3_tick	: std_logic;

signal BCLK_O_int		: std_logic;
signal LRCLK_O_int		: std_logic;

signal tx_bclk			: std_logic;
signal tx_tick			: std_logic;
signal tx_frame_sync		: std_logic;

signal const_1      : std_logic;
signal bclk_tick		: std_logic;

signal data_resetn : std_logic;
signal data_reset_vec : std_logic_vector(2 downto 0);

signal bit_left_s : std_logic;
signal bit_right_s : std_logic;
begin

	enable <= tx_enable;

	const_1 <= '1';
	process (data_clk, resetn)
	begin
		if resetn = '0' then
			data_reset_vec <= (others => '1');
		elsif rising_edge(data_clk) then
			data_reset_vec(2 downto 1) <= data_reset_vec(1 downto 0);
			data_reset_vec(0) <= '0';
		end if;
	end process;

	data_resetn <= not data_reset_vec(2);

	-- Generate tick signal in the DATA_CLK_I domain
	process (data_clk)
	begin
		if rising_edge(data_clk) then
			cdc_sync_stage0_tick <= not cdc_sync_stage0_tick;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			cdc_sync_stage1_tick <= cdc_sync_stage0_tick;
			cdc_sync_stage2_tick <= cdc_sync_stage1_tick;
			cdc_sync_stage3_tick <= cdc_sync_stage2_tick;
		end if;
	end process;

	tx_tick <= cdc_sync_stage2_tick xor cdc_sync_stage3_tick;

	bit_left_o <= bit_left_s;
	bit_right_o <= bit_right_s;


	clkgen: entity deltaSigma_clkgen
	port map(
		clk => clk,
		resetn => resetn,
		enable => enable,
		tick => tx_tick,

		bclk_div_rate => bclk_div_rate,
		lrclk_div_rate => lrclk_div_rate,

		frame_sync => tx_frame_sync,

		bclk => tx_bclk
	);

	tx: entity deltaSigma_tx
		generic map (
			C_SLOT_WIDTH => C_SLOT_WIDTH
		)
		port map (
			clk => clk,
			resetn => resetn,
			enable => tx_enable,
			bit_left_o => bit_left_s,
			bit_right_o => bit_right_s,

			frame_sync => tx_frame_sync,
			bclk => tx_bclk,

			ack => tx_ack,
			stb => tx_stb,
			data_left => tx_data_left,
			data_right => tx_data_right
		);

end Behavioral;
