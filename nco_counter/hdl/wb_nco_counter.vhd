---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2015/04/08
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_nco_counter is 
    generic(
		COUNTER_SIZE : natural := 28;
		DEFAULT_RST_ACCUM_VAL : natural := 25;
		LUT_SIZE : natural := 10;
        id        : natural := 1;
        wb_size   : natural := 16 -- Data port size for wishbone
    );
    port 
    (
		-- Syscon signals
		reset     : in std_logic ;
		clk       : in std_logic ;
		-- Wishbone signals
		--step_scale_i : in std_logic_vector(LUT_SIZE-1 downto 0);
		wbs_add       : in std_logic_vector(2 downto 0);
		wbs_write     : in std_logic ;
		wbs_writedata : in std_logic_vector( wb_size-1 downto 0);
		wbs_read     : in std_logic ;
		wbs_readdata  : out std_logic_vector( wb_size-1 downto 0);
		max_accum_o : out std_logic_vector(COUNTER_SIZE-1 downto 0);
		enable_o      : out std_logic;
		pinc_sw_o 		: out std_logic;
		poff_sw_o 		: out std_logic;
		cpt_off_o	: out std_logic_vector(LUT_SIZE-1 downto 0);
		cpt_step_o : out std_logic_vector(COUNTER_SIZE-1 downto 0)
    );
end entity wb_nco_counter;


-----------------------------------------------------------------------
Architecture wb_nco_counter_1 of wb_nco_counter is
-----------------------------------------------------------------------
	constant REG_ID          : std_logic_vector := "000";
	constant REG_POFF 	     : std_logic_vector :="001";
	constant REG_CTRL 	     : std_logic_vector :="010";
	constant REG_PINC_L 	 : std_logic_vector :="011";
	constant REG_PINC_H 	 : std_logic_vector :="100";
	constant REG_MAX_ACCUM_L : std_logic_vector :="101";
    constant REG_MAX_ACCUM_H : std_logic_vector :="110";
    constant REG_CTRL2       : std_logic_vector :="111";
	signal max_accum_s  : std_logic_vector(63 downto 0);
	signal max_accum_low_s : std_logic_vector(31 downto 0);
	signal cpt_step_s 	: std_logic_vector(63 downto 0);
	signal cpt_step_low_s : std_logic_vector(31 downto 0);
	signal cpt_off_s 	: std_logic_vector(31 downto 0);
	signal poff_sw_s	: std_logic;
	signal pinc_sw_s	: std_logic;
	signal readdata_s 	: std_logic_vector(wb_size-1 downto 0);
	signal enable_s		: std_logic;
begin
	wbs_readdata <= readdata_s;
	max_accum_o <= max_accum_s(COUNTER_SIZE-1 downto 0);
	cpt_step_o <= cpt_step_s(COUNTER_SIZE-1 downto 0);
	cpt_off_o <= cpt_off_s(LUT_SIZE-1 downto 0);
	pinc_sw_o <= pinc_sw_s;
	poff_sw_o <= poff_sw_s;
	enable_o <= enable_s;
	-- manage register
	write_bloc : process(clk)   -- write DEPUIS l'iMx
	begin
		 if rising_edge(clk) then
			if reset = '1' then 
				cpt_step_s <= (63 downto 1 => '0')&'1';
				cpt_step_low_s <= (others => '0');
				cpt_off_s <= (others => '0');
				pinc_sw_s <= '1';
				poff_sw_s <= '1';
				enable_s <= '1';
				max_accum_s <= std_logic_vector(
						to_unsigned(DEFAULT_RST_ACCUM_VAL, 64));
				max_accum_low_s <= (others => '0');
		 	else
				cpt_step_s <= cpt_step_s;
				cpt_step_low_s <= cpt_step_low_s;
				cpt_off_s <= cpt_off_s;
				pinc_sw_s <= pinc_sw_s;
				poff_sw_s <= poff_sw_s;
				enable_s <= enable_s;
				max_accum_s <= max_accum_s;
				max_accum_low_s <= max_accum_low_s;
				if (wbs_write = '1' ) then
					case wbs_add is
					when REG_MAX_ACCUM_L =>
						max_accum_low_s <= wbs_writedata;
					when REG_MAX_ACCUM_H =>
                            max_accum_s <= wbs_writedata&max_accum_low_s;
					when REG_PINC_L =>
						cpt_step_low_s <= wbs_writedata;
					when REG_PINC_H =>
						cpt_step_s <= wbs_writedata & cpt_step_low_s;
					when REG_POFF =>
						cpt_off_s <= wbs_writedata;
					when REG_CTRL =>
						pinc_sw_s <= wbs_writedata(0);
						poff_sw_s <= wbs_writedata(1);
					when REG_CTRL2 =>
						enable_s <= wbs_writedata(0);
					when others =>
					end case;
				end if;
			end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				readdata_s <= (others => '0');
			else
				readdata_s <= readdata_s;
				if (wbs_read = '1') then
					case wbs_add is
					when REG_ID =>
						 readdata_s <= std_logic_vector(to_unsigned(id,wb_size));
						--readdata_s <= 
						--	(wb_size-1 downto LUT_SIZE => '0')&step_scale_i;
					when REG_PINC_L =>
						readdata_s <= cpt_step_s(31 downto 0);
					when REG_PINC_H =>
						readdata_s <= cpt_step_s(63 downto 32);
					when REG_POFF =>
						readdata_s <= cpt_off_s;
					when REG_CTRL =>
						readdata_s <= (wb_size-1 downto 2 => '0')&poff_sw_s&pinc_sw_s;
					when REG_CTRL2 =>
						readdata_s <= (wb_size-1 downto 1 => '0')&enable_s;
					when others =>
						readdata_s <= (others => '0');
					end case;
				end if;
			end if;
		end if;
	end process read_bloc;

end architecture wb_nco_counter_1;

