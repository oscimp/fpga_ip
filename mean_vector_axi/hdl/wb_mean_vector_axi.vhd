---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2019
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_mean_vector_axi is 
    generic(
        id        		: natural := 1;
        wb_size   		: natural := 16;
		MAX_NB_ACCUM    : natural := 1024;
		ACCUM_SIZE 		: natural := 10;
		SHIFT_SIZE 		: natural := 4
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
		shift_val_o : out std_logic_vector(SHIFT_SIZE-1 downto 0);
		nb_iter_o : out std_logic_vector(ACCUM_SIZE-1 downto 0)
    );
end entity wb_mean_vector_axi;


-----------------------------------------------------------------------
Architecture wb_mean_vector_axi_1 of wb_mean_vector_axi is
-----------------------------------------------------------------------
	constant REG_ID     	: std_logic_vector := "00";
	constant REG_SHIFT_VAL 	: std_logic_vector :="01";
	constant REG_NB_ITER 	: std_logic_vector :="10";
	signal shift_val_s 		: std_logic_vector(SHIFT_SIZE-1 downto 0);
	signal nb_iter_s 		: std_logic_vector(ACCUM_SIZE-1 downto 0);
	signal readdata_s 		: std_logic_vector(wb_size-1 downto 0);
begin
	wbs_readdata <= readdata_s;
	shift_val_o <= shift_val_s;
	nb_iter_o <= nb_iter_s;
	-- manage register
	write_bloc : process(clk, reset)   -- write DEPUIS l'iMx
	begin
		 if reset = '1' then 
			shift_val_s <= std_logic_vector(to_unsigned(ACCUM_SIZE, SHIFT_SIZE));
			nb_iter_s <= std_logic_vector(to_unsigned(MAX_NB_ACCUM-1, ACCUM_SIZE));
		 elsif rising_edge(clk) then
			shift_val_s <= shift_val_s;
			nb_iter_s <= nb_iter_s;
			if (wbs_write = '1' ) then
				case (wbs_add) is
				when REG_SHIFT_VAL =>
					shift_val_s <= wbs_writedata(SHIFT_SIZE-1 downto 0);
				when REG_NB_ITER =>
					nb_iter_s <= wbs_writedata(ACCUM_SIZE-1 downto 0);
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
				when REG_SHIFT_VAL =>
					readdata_s <= (wb_size-1 downto SHIFT_SIZE => '0')&shift_val_s;
				when REG_NB_ITER =>
					readdata_s <= (wb_size-1 downto ACCUM_SIZE => '0')&nb_iter_s;
				when others =>
					readdata_s <= (others => '0');
				end case;
			end if;
		end if;
	end process read_bloc;

end architecture wb_mean_vector_axi_1;
