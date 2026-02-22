library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_add_constComplex is 
    generic(
		DEFAULT_OFFSET_I : natural := 0;
		DEFAULT_OFFSET_Q : natural := 0;
		FORMAT         : string := "signed";
		DATA_SIZE      : natural := 16;
        id             : natural := 1;
        wb_size        : natural := 16 -- Data port size for wishbone
    );
    port (
		-- Syscon signals
		reset         : in std_logic;
		clk           : in std_logic;
		-- Wishbone signals
		wbs_add       : in std_logic_vector(2 downto 0);
		wbs_write     : in std_logic;
		wbs_writedata : in std_logic_vector(wb_size-1 downto 0);
		wbs_read      : in std_logic;
		wbs_readdata  : out std_logic_vector(wb_size-1 downto 0);
		offset_i_o      : out std_logic_vector(DATA_SIZE-1 downto 0);
		offset_q_o      : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity wb_add_constComplex;


-----------------------------------------------------------------------
Architecture wb_add_constComplex_1 of wb_add_constComplex is
-----------------------------------------------------------------------
	constant REG_ID       : std_logic_vector := "000";
	constant REG_OFFSET_I_L : std_logic_vector := "001";
	constant REG_OFFSET_I_H : std_logic_vector := "010";
	constant REG_OFFSET_Q_L : std_logic_vector := "011";
	constant REG_OFFSET_Q_H : std_logic_vector := "100";
	signal offset_i_l_s     : std_logic_vector(wb_size-1 downto 0);
	signal offset_q_l_s     : std_logic_vector(wb_size-1 downto 0);
	signal offset_i_s       : std_logic_vector((2*wb_size)-1 downto 0);
	signal offset_q_s       : std_logic_vector((2*wb_size)-1 downto 0);
	signal readdata_s     : std_logic_vector(wb_size-1 downto 0);

begin
	lt_eq_size: if DATA_SIZE <= wb_size * 2 generate
		offset_i_o <= offset_i_s(DATA_SIZE-1 downto 0);
		offset_q_o <= offset_q_s(DATA_SIZE-1 downto 0);
	end generate lt_eq_size;

	gt_size : if DATA_SIZE > wb_size * 2 generate
		signed_prod: if FORMAT = "signed" generate
			offset_i_o <= std_logic_vector(resize(signed(offset_i_s), DATA_SIZE));
			offset_q_o <= std_logic_vector(resize(signed(offset_q_s), DATA_SIZE));
		end generate signed_prod;
		unsigned_prod: if FORMAT /= "signed" generate
			offset_i_o <= std_logic_vector(resize(unsigned(offset_i_s), DATA_SIZE));
			offset_q_o <= std_logic_vector(resize(unsigned(offset_q_s), DATA_SIZE));
		end generate unsigned_prod;
	end generate gt_size;

	-- manage register
	write_bloc : process(clk, reset)
	begin
		if reset = '1' then 
			offset_i_l_s <= (others => '0');
			offset_q_l_s <= (others => '0');
			offset_i_s <= std_logic_vector(to_unsigned(DEFAULT_OFFSET_I, 2*wb_size));
			offset_q_s <= std_logic_vector(to_unsigned(DEFAULT_OFFSET_Q, 2*wb_size));
		elsif rising_edge(clk) then
			offset_i_l_s <= offset_i_l_s;
			offset_q_l_s <= offset_q_l_s;
			offset_i_s <= offset_i_s;
			offset_q_s <= offset_q_s;
			if (wbs_write = '1' ) then
				case wbs_add is
				when REG_OFFSET_I_L =>
					offset_i_l_s <= wbs_writedata;
				when REG_OFFSET_I_H =>
					offset_i_s <= wbs_writedata & offset_i_l_s;
				when REG_OFFSET_Q_L =>
					offset_q_l_s <= wbs_writedata;
				when REG_OFFSET_Q_H =>
					offset_q_s <= wbs_writedata & offset_q_l_s;
				when others =>
				end case;
			  end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk, reset)
	begin
		if reset = '1' then
			wbs_readdata <= (others => '0');
		elsif rising_edge(clk) then
			if (wbs_read = '1') then
				wbs_readdata <= readdata_s;
			end if;
		end if;
	end process read_bloc;

	r_b: process(wbs_add, offset_i_s, offset_q_s) begin
		case wbs_add is
		when REG_ID =>
			readdata_s <= std_logic_vector(to_unsigned(id,wb_size));
		when REG_OFFSET_I_L =>
			readdata_s <= offset_i_s(wb_size-1 downto 0);
		when REG_OFFSET_I_H =>
			readdata_s <= offset_i_s((2*wb_size)-1 downto wb_size);
		when REG_OFFSET_Q_L =>
			readdata_s <= offset_q_s(wb_size-1 downto 0);
		when REG_OFFSET_Q_H =>
			readdata_s <= offset_q_s((2*wb_size)-1 downto wb_size);
		when others =>
			readdata_s <= (others => '1');
		end case;
	end process r_b;

end architecture wb_add_constComplex_1;

