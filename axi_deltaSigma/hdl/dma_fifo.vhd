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
use ieee.numeric_std.all;

entity dma_fifo is
	generic (
		FIFO_AWIDTH : integer := 3;
		FIFO_DWIDTH : integer := 32
	);
	port (
		clk		: in  std_logic;
		resetn		: in  std_logic;
		fifo_reset	: in  std_logic;

		-- Write port
		in_stb		: in  std_logic;
		in_ack		: out std_logic;
		in_data		: in  std_logic_vector(FIFO_DWIDTH-1 downto 0);

		-- Read port
		out_stb		: out std_logic;	
		out_ack		: in  std_logic;
		out_data_left	: out std_logic_vector(FIFO_DWIDTH-1 downto 0);
		out_data_right	: out std_logic_vector(FIFO_DWIDTH-1 downto 0)
	);
end;

architecture imp of dma_fifo is

	constant FIFO_MAX		: natural := 2**FIFO_AWIDTH;
	type MEM is array (0 to (FIFO_MAX/2)-1) of std_logic_vector(FIFO_DWIDTH - 1 downto 0);
	signal data_fifo_left	: MEM;
	signal data_fifo_right	: MEM;
	signal wr_addr_s		: unsigned(FIFO_AWIDTH-1 downto 0);
	signal wr_addr_cnt		: natural range 0 to FIFO_MAX-1;
	signal rd_addr_s		: unsigned(FIFO_AWIDTH-2 downto 0);
	signal rd_addr_cnt			: natural range 0 to FIFO_MAX-1;
	signal not_full, not_empty	: Boolean;

begin
	in_ack <= '1' when not_full else '0';

	out_stb <= '1' when not_empty else '0';
	out_data_left <= data_fifo_left(to_integer(rd_addr_s));
	out_data_right <= data_fifo_right(to_integer(rd_addr_s));

	fifo_data: process (clk) is
	begin
		if rising_edge(clk) then
			if not_full then
				if wr_addr_s(0) = '0' then
					data_fifo_left(to_integer(wr_addr_s(FIFO_AWIDTH-1 downto 1))) <= in_data;
				end if;
				if wr_addr_s(0) = '1' then
					data_fifo_right(to_integer(wr_addr_s(FIFO_AWIDTH-1 downto 1))) <= in_data;
				end if;
			end if;
		end if;
	end process;

	wr_addr_s <= to_unsigned(wr_addr_cnt, FIFO_AWIDTH);
	rd_addr_s <= to_unsigned(rd_addr_cnt, FIFO_AWIDTH)(FIFO_AWIDTH-1 downto 1);

	fifo_ctrl: process (clk) is
		variable free_cnt : integer range 0 to FIFO_MAX;
	begin
		if rising_edge(clk) then
			if (resetn = '0') or (fifo_reset = '1') then
				wr_addr_cnt <= 0;
				rd_addr_cnt <= 0;
				free_cnt := FIFO_MAX;
				not_empty <= False;
				not_full <= True;
			else
				if in_stb = '1' and not_full then
					wr_addr_cnt <= (wr_addr_cnt + 1) mod (FIFO_MAX);
					free_cnt := free_cnt - 1;
				end if;

				if out_ack = '1' and not_empty then
					rd_addr_cnt <= (rd_addr_cnt + 2) mod (FIFO_MAX);
					free_cnt := free_cnt + 2;
				end if;

				not_full <= not (free_cnt = 0 );
				not_empty <= not (free_cnt >= FIFO_MAX-1);
			end if;
		end if;
	end process;
end;
