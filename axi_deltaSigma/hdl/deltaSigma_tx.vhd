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

entity deltaSigma_tx is
	generic(
		C_SLOT_WIDTH	: integer := 32 --;	-- Width of one Slot
	);
	port(
		clk		: in  std_logic; 	-- System clock 
		resetn		: in  std_logic; 	-- System reset
		enable		: in  Boolean;		-- Enable TX
		bit_left_o  : out std_logic;
		bit_right_o  : out std_logic;

		bclk		: in  std_logic;	-- Bit Clock
		frame_sync	: in  std_logic;	-- Frame Sync

		ack		: out std_logic;	-- Request new Slot Data
		stb		: in std_logic;	-- Request new Slot Data
		data_left	: in  std_logic_vector(C_SLOT_WIDTH-1 downto 0); -- Slot Data in
		data_right	: in  std_logic_vector(C_SLOT_WIDTH-1 downto 0)	 -- Slot Data in
	);
end deltaSigma_tx;

architecture Behavioral of deltaSigma_tx is
	signal left_data_int, right_data_int : std_logic_vector(C_SLOT_WIDTH-1 downto 0);
	signal reset_int : Boolean;
	signal rst_s : std_logic;
	signal enable_int : Boolean;

	signal bit_sync : std_logic;
	signal frame_sync_int : std_logic;
	signal frame_sync_int_d1 : std_logic;

	signal bclk_d1 : std_logic;

	component deltaSigma is
	generic (
		NB_BIT : integer := 32
	);
	port (
		clk_i  : in std_logic;
		rst_i  : in std_logic;
		trig_i : in std_logic;
		data_i : in std_logic_vector(NB_BIT-1 downto 0);
		dac_o  : out std_logic
	);
	end component deltaSigma;

	signal left_dac_s, right_dac_s : std_logic;
	signal data_left_shift_s : std_logic_vector(C_SLOT_WIDTH-1 downto 0);
	signal data_right_shift_s : std_logic_vector(C_SLOT_WIDTH-1 downto 0);

begin

	reset_int <= resetn = '0' or not enable;
	rst_s <= '1' when reset_int else '0';

	process (clk)
	begin
		if rising_edge(clk) then
			if resetn = '0' then
				bclk_d1 <= '0';
				frame_sync_int_d1 <= '0';
			else
				bclk_d1 <= bclk;
				frame_sync_int_d1 <= frame_sync_int;
			end if;
		end if;
	end process;

	bit_sync <= (bclk xor bclk_d1) and not bclk;
	frame_sync_int <= frame_sync and bit_sync;

	ack <= '1' when frame_sync_int_d1 = '1' and enable_int else '0';

	data_left_shift_s <= data_left xor x"80000000";
	data_right_shift_s <= data_right xor x"80000000";

	serialize_data: process(clk)
	begin
		if rising_edge(clk) then
			if reset_int then
				left_data_int  <= (others => '0');
				right_data_int <= (others => '0');
			elsif bit_sync = '1' then
				if frame_sync_int = '1' then
					left_data_int <= data_left_shift_s(C_SLOT_WIDTH-1 downto 0);
					right_data_int <= data_right_shift_s(C_SLOT_WIDTH-1 downto 0);
				else
					right_data_int <= right_data_int;
					left_data_int <= left_data_int;
				end if;
			end if;
		end if;
	end process serialize_data;

	left_deltaSigma_inst : deltaSigma
	port map (clk_i => clk, rst_i => rst_s,
		trig_i => bit_sync, data_i => left_data_int,
		dac_o => left_dac_s
	);
	right_deltaSigma_inst : deltaSigma
	port map (clk_i => clk, rst_i => rst_s,
		trig_i => bit_sync, data_i => right_data_int,
		dac_o => right_dac_s
	);

	bit_left_o <= left_dac_s when enable_int else '0';
	bit_right_o <= right_dac_s when enable_int else '0';

	enable_sync: process (clk)
	begin
		if rising_edge(clk) then
			if reset_int then
				enable_int <= False;
			else
				if enable and frame_sync_int = '1' and stb = '1' then
					enable_int <= True;
				elsif not enable then
					enable_int <= False;
				end if;
			end if;
		end if;
	end process;

end Behavioral;
