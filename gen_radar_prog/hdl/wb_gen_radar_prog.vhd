---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_gen_radar_prog is 
    generic(
        id        : natural := 1;
		NB_POINT  : natural := 16;
		RXOFF : natural := 2;   -- exprime' en cycle
		TXON: natural := 8;     -- idem
        wb_size   : natural := 16 -- Data port size for wishbone
    );
    port 
    (
		-- Syscon signals
		reset     : in std_logic ;
		clk       : in std_logic ;
		-- Wishbone signals
		wbs_add       : in std_logic_vector(1 downto 0);
		wbs_write     : in std_logic ;
		wbs_writedata : in std_logic_vector( wb_size-1 downto 0);
		wbs_read     : in std_logic ;
		wbs_readdata  : out std_logic_vector( wb_size-1 downto 0);
		rx_off_o	: out std_logic_vector(15 downto 0);
		tx_on_o		: out std_logic_vector(15 downto 0);
		point_period_o : out std_logic_vector(15 downto 0)
    );
end entity wb_gen_radar_prog;


-----------------------------------------------------------------------
Architecture wb_gen_radar_prog_1 of wb_gen_radar_prog is
-----------------------------------------------------------------------
	constant REG_ID     : std_logic_vector(1 downto 0) := "00";
	constant REG_POINT_PERIOD : std_logic_vector(1 downto 0) :="01";
	constant REG_RXOFF : std_logic_vector(1 downto 0) :="10";
	constant REG_TXON  : std_logic_vector(1 downto 0) :="11";
	signal point_pos_s : std_logic_vector(15 downto 0);
	signal readdata_s : std_logic_vector(wb_size-1 downto 0);
	signal rx_off_s, tx_on_s : std_logic_vector(15 downto 0);
begin
	wbs_readdata <= readdata_s;
	point_period_o <= point_pos_s;
	tx_on_o <= tx_on_s;
	rx_off_o <= rx_off_s;
	-- manage register
	write_bloc : process(clk, reset)   -- write DEPUIS l'iMx
	begin
		 if reset = '1' then 
			point_pos_s <= std_logic_vector(to_unsigned(NB_POINT, 16));
			rx_off_s <= std_logic_vector(to_unsigned(RXOFF, 16));
			tx_on_s <= std_logic_vector(to_unsigned(TXON, 16));
		 elsif rising_edge(clk) then
			point_pos_s <= point_pos_s;
			tx_on_s <= tx_on_s;
			rx_off_s <= rx_off_s;
			if (wbs_write = '1' ) then
				case wbs_add is
				when REG_POINT_PERIOD =>
					point_pos_s <= wbs_writedata(15 downto 0);
				when REG_RXOFF =>
					rx_off_s <= wbs_writedata(15 downto 0);
				when REG_TXON =>
					tx_on_s <= wbs_writedata(15 downto 0);
				when others =>
				end case;
			  end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk, reset)
	begin
		if reset = '1' then
			readdata_s <= (others => '0');
		elsif rising_edge(clk) then
			readdata_s <= readdata_s;
			if (wbs_read = '1') then
				case wbs_add is
				when REG_ID =>
					 readdata_s <= std_logic_vector(to_unsigned(id,wb_size));
				when REG_POINT_PERIOD =>
					readdata_s <= (wb_size-1 downto 16 => '0')&point_pos_s;
				when REG_RXOFF =>
					readdata_s <= (wb_size-1 downto 16 => '0')&rx_off_s;
				when REG_TXON =>
					readdata_s <= (wb_size-1 downto 16 => '0')&tx_on_s;
				end case;
			end if;
		end if;
	end process read_bloc;

end architecture wb_gen_radar_prog_1;

