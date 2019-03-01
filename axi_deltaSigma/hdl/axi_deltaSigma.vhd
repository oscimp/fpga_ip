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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.deltaSigma_controller;

library work;
use work.pl330_dma_fifo;
use work.axi_ctrlif;

entity axi_deltaSigma is
	generic
	(
		-- ADD USER GENERICS BELOW THIS LINE ---------------
		SLOT_WIDTH		: integer := 32;
		-- ADD USER GENERICS ABOVE THIS LINE ---------------

		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol parameters, do not add to or delete
		C_S00_AXI_DATA_WIDTH	: integer			:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer			:= 4
	);
	port
	(
		-- Serial Data interface
		data_clk_i		: in  std_logic;
		bit_left_o		: out std_logic;
		bit_right_o		: out std_logic;

		--PL330 DMA TX interface
		dma_req_tx_aclk    : in  std_logic;
		dma_req_tx_rstn    : in  std_logic;
		dma_req_tx_davalid : in  std_logic;
		dma_req_tx_datype  : in  std_logic_vector(1 downto 0);
		dma_req_tx_daready : out std_logic;
		dma_req_tx_drvalid : out std_logic;
		dma_req_tx_drtype  : out std_logic_vector(1 downto 0);
		dma_req_tx_drlast  : out std_logic;
		dma_req_tx_drready : in  std_logic;

		-- AXI bus interface
		s00_axi_aclk		: in  std_logic;
		s00_axi_aresetn		: in  std_logic;
		s00_axi_awaddr		: in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awvalid		: in  std_logic;
		s00_axi_wdata		: in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb		: in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid		: in  std_logic;
		s00_axi_bready		: in  std_logic;
		s00_axi_araddr		: in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arvalid		: in  std_logic;
		s00_axi_rready		: in  std_logic;
		s00_axi_arready		: out std_logic;
		s00_axi_rdata		: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp		: out std_logic_vector(1 downto 0);
		s00_axi_rvalid		: out std_logic;
		s00_axi_wready		: out std_logic;
		s00_axi_bresp		: out std_logic_vector(1 downto 0);
		s00_axi_bvalid		: out std_logic;
		s00_axi_awready		: out std_logic;
    	s00_axi_awprot  : in  std_logic_vector(2 downto 0);
    	s00_axi_arprot  : in  std_logic_vector(2 downto 0)

	);
end entity axi_deltaSigma;

architecture Behavioral of axi_deltaSigma is

------------------------------------------
-- Signals for user logic slave model s/w accessible register example
------------------------------------------
signal deltaSigma_reset			: std_logic;
signal tx_fifo_reset			: std_logic;
signal tx_enable			: Boolean;
signal tx_data_left			: std_logic_vector(31 downto 0);
signal tx_data_right		: std_logic_vector(31 downto 0);
signal tx_ack				: std_logic;
signal tx_stb				: std_logic;

signal const_1      		: std_logic;

signal bclk_div_rate		: natural range 0 to 255;
signal lrclk_div_rate		: natural range 0 to 255;

signal DELTASIGMA_RESET_REG		: std_logic_vector(31 downto 0);
signal DELTASIGMA_CONTROL_REG		: std_logic_vector(31 downto 0);
signal DELTASIGMA_CLK_CONTROL_REG	: std_logic_vector(31 downto 0);

constant FIFO_AWIDTH		: integer := integer(ceil(log2(real(8))));

-- Audio samples FIFO
constant RAM_ADDR_WIDTH			: integer := 7;
type RAM_TYPE is array (0 to (2**RAM_ADDR_WIDTH - 1)) of std_logic_vector(31 downto 0);

signal drain_tx_dma			: std_logic;

signal wr_data : std_logic_vector(31 downto 0);
signal rd_data : std_logic_vector(31 downto 0);
signal wr_addr : integer range 0 to 3;
signal rd_addr : integer range 0 to 3;
signal wr_stb : std_logic;
signal rd_ack : std_logic;
signal tx_fifo_stb : std_logic;
begin

	const_1 <= '1';

	tx_fifo_stb <= '1' when wr_addr = 3 and wr_stb = '1' else '0';

	tx_fifo: entity pl330_dma_fifo
		generic map(
			RAM_ADDR_WIDTH => FIFO_AWIDTH,
			FIFO_DWIDTH => 32,
			FIFO_DIRECTION => 0
		)
		port map (
			clk => s00_axi_aclk,
			resetn => s00_axi_aresetn,
			fifo_reset => tx_fifo_reset,
			enable => tx_enable,

			in_data => wr_data,
			in_stb => tx_fifo_stb,

			out_ack => tx_ack,
			out_stb => tx_stb,
			out_data_left => tx_data_left,
			out_data_right => tx_data_right,

			dclk => dma_req_tx_aclk,
			dresetn => dma_req_tx_rstn,
			davalid => dma_req_tx_davalid,
			daready => dma_req_tx_daready,
			datype => dma_req_tx_datype,
			drvalid => dma_req_tx_drvalid,
			drready => dma_req_tx_drready,
			drtype => dma_req_tx_drtype,
			drlast => dma_req_tx_drlast
		);

	ctrl : entity deltaSigma_controller
		generic map (
			C_SLOT_WIDTH => SLOT_WIDTH
		)
		port map (
			clk => s00_axi_aclk,
			resetn => s00_axi_aresetn,

			data_clk => data_clk_i,

			tx_enable => tx_enable,
			tx_ack => tx_ack,
			tx_stb => tx_stb,
			tx_data_left => tx_data_left,
			tx_data_right => tx_data_right,

			bit_left_o => bit_left_o,
			bit_right_o => bit_right_o,

			bclk_div_rate => bclk_div_rate,
			lrclk_div_rate => lrclk_div_rate
		);

	deltaSigma_reset		<= DELTASIGMA_RESET_REG(0);
	tx_fifo_reset	<= DELTASIGMA_RESET_REG(1);
	tx_enable		<= DELTASIGMA_CONTROL_REG(0) = '1';
	bclk_div_rate	<= to_integer(unsigned(DELTASIGMA_CLK_CONTROL_REG(7 downto 0)));
	lrclk_div_rate	<= to_integer(unsigned(DELTASIGMA_CLK_CONTROL_REG(23 downto 16)));

	ctrlif: entity axi_ctrlif
		generic map (
			C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH,
			C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
			C_NUM_REG => 4
		)
		port map(
			s_axi_aclk		=> s00_axi_aclk,
			s_axi_aresetn	=> s00_axi_aresetn,
			s_axi_awaddr	=> s00_axi_awaddr,
			s_axi_awvalid	=> s00_axi_awvalid,
			s_axi_wdata		=> s00_axi_wdata,
			s_axi_wstrb		=> s00_axi_wstrb,
			s_axi_wvalid	=> s00_axi_wvalid,
			s_axi_bready	=> s00_axi_bready,
			s_axi_araddr	=> s00_axi_araddr,
			s_axi_arvalid	=> s00_axi_arvalid,
			s_axi_rready	=> s00_axi_rready,
			s_axi_arready	=> s00_axi_arready,
			s_axi_rdata		=> s00_axi_rdata,
			s_axi_rresp		=> s00_axi_rresp,
			s_axi_rvalid	=> s00_axi_rvalid,
			s_axi_wready	=> s00_axi_wready,
			s_axi_bresp		=> s00_axi_bresp,
			s_axi_bvalid	=> s00_axi_bvalid,
			s_axi_awready	=> s00_axi_awready,

			rd_addr			=> rd_addr,
			rd_data			=> rd_data,
			rd_ack		=> rd_ack,
			rd_stb			=> const_1,

			wr_addr			=> wr_addr,
			wr_data			=> wr_data,
			wr_ack			=> const_1,
			wr_stb			=> wr_stb
		);

	process(rd_addr, DELTASIGMA_CONTROL_REG, DELTASIGMA_CLK_CONTROL_REG)
	begin
		case rd_addr is
			when 1 => rd_data <=  DELTASIGMA_CONTROL_REG and x"00000003";
			when 2 => rd_data <=  DELTASIGMA_CLK_CONTROL_REG and x"00ff00ff";
			when others => rd_data <= (others => '0');
		end case;
	end process;

	process(s00_axi_aclk) is
	begin
		if rising_edge(s00_axi_aclk) then
			if s00_axi_aresetn = '0' then
				DELTASIGMA_RESET_REG <= (others => '0');
				DELTASIGMA_CONTROL_REG <= (others => '0');
				DELTASIGMA_CLK_CONTROL_REG <= (others => '0');
			else
				-- Auto-clear the Reset Register bits
				DELTASIGMA_RESET_REG(0) <= '0';
				DELTASIGMA_RESET_REG(1) <= '0';
				DELTASIGMA_RESET_REG(2) <= '0';
				if wr_stb = '1' then
					case wr_addr is
						when 0 => DELTASIGMA_RESET_REG <= wr_data;
						when 1 => DELTASIGMA_CONTROL_REG <= wr_data;
						when 2 => DELTASIGMA_CLK_CONTROL_REG <= wr_data;
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;

end Behavioral;
