---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/05/25
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity shifterReal_dyn_comm is 
    generic(
        id            : natural := 1;
        wb_size       : natural := 16;
		SHFT_ADDR_SZ  : natural := 4;
		DEFAULT_SHIFT : natural := 16
    );
    port (
		-- Syscon signals
		reset       : in std_logic ;
		clk         : in std_logic ;
		-- comm signals
		addr_i      : in std_logic_vector(1 downto 0);
		wr_en_i     : in std_logic ;
		writedata_i : in std_logic_vector( wb_size-1 downto 0);
		rd_en_i     : in std_logic ;
		readdata_o  : out std_logic_vector( wb_size-1 downto 0);
		shift_val_o : out std_logic_vector(SHFT_ADDR_SZ-1 downto 0)
    );
end entity shifterReal_dyn_comm;

Architecture bhv of shifterReal_dyn_comm is
	constant REG_ID        : std_logic_vector := "00";
	constant REG_SHIFT_VAL : std_logic_vector := "01";
	signal shift_val_s     : std_logic_vector(SHFT_ADDR_SZ-1 downto 0);
	signal readdata_s      : std_logic_vector(wb_size-1 downto 0);
	signal readdata_next_s : std_logic_vector(wb_size-1 downto 0);
begin
	readdata_o <= readdata_s;
	shift_val_o <= shift_val_s;
	-- manage register
	write_bloc : process(clk)
	begin
		 if rising_edge(clk) then
		 	if reset = '1' then 
				shift_val_s <= std_logic_vector(to_unsigned(DEFAULT_SHIFT, SHFT_ADDR_SZ));
			elsif wr_en_i = '1' and addr_i = REG_SHIFT_VAL then
				shift_val_s <= writedata_i(SHFT_ADDR_SZ-1 downto 0);
			else
				shift_val_s <= shift_val_s;
			end if;
		 end if;
	end process write_bloc;

	read_async_bloc: process(shift_val_s, addr_i) begin
		case addr_i is
		when REG_ID =>
			readdata_next_s <= std_logic_vector(to_unsigned(id,wb_size));
		when REG_SHIFT_VAL =>
			readdata_next_s <= (wb_size-1 downto SHFT_ADDR_SZ => '0')&shift_val_s;
		when others =>
			readdata_next_s <= (others => '1');
		end case;
	end process;

	read_bloc : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				readdata_s <= (others => '0');
			elsif (rd_en_i = '1') then
				readdata_s <= readdata_next_s;
			else
				readdata_s <= readdata_s;
			end if;
		end if;
	end process read_bloc;

end architecture bhv;

