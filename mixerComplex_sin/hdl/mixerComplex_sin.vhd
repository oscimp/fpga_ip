---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/09/14
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mixerComplex_sin is
	generic (
		NCO_SIZE : natural := 16;
		DATA_IN_SIZE : natural := 16;
		DATA_OUT_SIZE: natural := 16
	);
	port (
		-- ADC interface
		data_en_i : in std_logic;
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		data_i_i: in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i: in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		-- NCO interface
		nco_i_i : in std_logic_vector(NCO_SIZE-1 downto 0);
		nco_q_i : in std_logic_vector(NCO_SIZE-1 downto 0);
		nco_en_i : in std_logic;
		nco_rst_i : in std_logic;
		nco_clk_i : in std_logic;
		-- next
		data_en_o : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic;
		data_i_o : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_q_o : out std_logic_vector(DATA_OUT_SIZE-1 downto 0)
	);
end mixerComplex_sin;

architecture Behavioral of mixerComplex_sin is
	-- input latches
	signal nco_i_s   : signed(NCO_SIZE-1 downto 0);
	signal nco_q_s   : signed(NCO_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	signal data_i_s  : signed(DATA_IN_SIZE-1 downto 0);
	signal data_q_s  : signed(DATA_IN_SIZE-1 downto 0);
	-- multiplication
	constant MULT_SIZE        : natural := NCO_SIZE + DATA_IN_SIZE;
	signal res_i_s, res_q_s   : signed(MULT_SIZE-1 downto 0);
	signal res_i2_s, res_q2_s : signed(MULT_SIZE-1 downto 0);
	signal res2_i_s, res2_q_s  : signed(MULT_SIZE-1 downto 0);
	-- output latches
	signal data_i_out_s, data_q_out_s : std_logic_vector(MULT_SIZE-1 downto 0);
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	process(nco_clk_i)
	begin
		if rising_edge(nco_clk_i) then
			if nco_rst_i = '1' then
				nco_i_s <= (others => '0');
				nco_q_s <= (others => '0');
			elsif nco_en_i = '1' then
				nco_i_s <= signed(nco_i_i);
				nco_q_s <= signed(nco_q_i);
			else
				nco_i_s <= nco_i_s;
				nco_q_s <= nco_q_s;
			end if;
		end if;
	end process;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				data_i_s  <= (others => '0');
				data_q_s  <= (others => '0');
				data_en_s <= '0';
			elsif data_en_i = '1' then
				data_i_s  <= signed(data_i_i);
				data_q_s  <= signed(data_q_i);
				data_en_s <= '1';
			else
				data_i_s  <= data_i_s;
				data_q_s  <= data_q_s;
				data_en_s <= '0';
			end if;
		end if;
	end process;

	res_i_s <= nco_i_s * data_i_s;
	res_i2_s <= nco_q_s * data_q_s;

	res_q_s <= data_i_s * nco_q_s;
	res_q2_s <= data_q_s * nco_i_s;

	res2_i_s <= res_i_s - res_i2_s;
	res2_q_s <= res_q_s + res_q2_s;

	data_i_out_s <= std_logic_vector(res2_i_s);
	data_q_out_s <= std_logic_vector(res2_q_s);

	resize_inst: entity work.mixerComplex_redim
	generic map (SIGNED_FORMAT => true,
		IN_SZ => MULT_SIZE, OUT_SZ => DATA_OUT_SIZE
	)
	port map (clk_i => data_clk_i, rst_i => data_rst_i,
		data_en_i => data_en_s,
		data_i_i => data_i_out_s, data_q_i => data_q_out_s,
		data_en_o => data_en_o, data_i_o => data_i_o, data_q_o => data_q_o
	);

end Behavioral;
