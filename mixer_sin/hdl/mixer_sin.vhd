---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/09/14
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mixer_sin is
	generic (
		NCO_SIZE : natural := 16;
		DATA_SIZE : natural := 16
	);
	port (
		-- ADC interface
		data_en_i : in std_logic;
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		data_i: in std_logic_vector(DATA_SIZE-1 downto 0);
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
		data_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o : out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end mixer_sin;

architecture Behavioral of mixer_sin is
	-- input latches
	signal nco_i_s : std_logic_vector(NCO_SIZE-1 downto 0);
	signal nco_q_s : std_logic_vector(NCO_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	signal data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	-- multiplication
	constant MULT_SIZE : natural := NCO_SIZE + DATA_SIZE;
	signal res_i_s, res_q_s : std_logic_vector(MULT_SIZE-1 downto 0);
	-- output latches
	constant POST_MULT_SIZE : natural := MULT_SIZE-1;
	signal data_en_out_s : std_logic;
	signal data_i_out_s, data_q_out_s : std_logic_vector(POST_MULT_SIZE-1 downto 0);
	-- reset
	signal rst_s : std_logic;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	process(nco_clk_i)
	begin
		if rising_edge(nco_clk_i) then
			if nco_rst_i = '1' then
				nco_i_s <= (others => '0');
				nco_q_s <= (others => '0');
			else
				nco_i_s <= nco_i_s;
				nco_q_s <= nco_q_s;
				if nco_en_i = '1' then
					nco_i_s <= nco_i_i;
					nco_q_s <= nco_q_i;
				end if;
			end if;
		end if;
	end process;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if rst_s = '1' then
				data_s <= (others => '0');
				data_en_s <= '0';
			else
				data_s <= data_s;
				data_en_s <= data_en_s;
				if data_en_i = '1' then
					data_s <= data_i;
					data_en_s <= data_en_i;
				end if;
			end if;
		end if;
	end process;

	res_i_s <= std_logic_vector(signed(nco_i_s) * signed(data_s));
	res_q_s <= std_logic_vector(signed(nco_q_s) * signed(data_s));

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if rst_s = '1' then
				data_i_out_s <= (others => '0');
				data_q_out_s <= (others => '0');
				data_en_out_s <= '0';
			else
				data_i_out_s <= data_i_out_s;
				data_q_out_s <= data_q_out_s;
				data_en_out_s <= '0';
				if data_en_s = '1' then
					data_i_out_s <= res_i_s(POST_MULT_SIZE-1 downto 0);
					data_q_out_s <= res_q_s(POST_MULT_SIZE-1 downto 0);
					data_en_out_s <= '1';
				end if;
			end if;
		end if;
	end process;

	data_i_o <= data_i_out_s(POST_MULT_SIZE-1 downto POST_MULT_SIZE-DATA_SIZE);
	data_q_o <= data_q_out_s(POST_MULT_SIZE-1 downto POST_MULT_SIZE-DATA_SIZE);
	data_en_o <= data_en_out_s;

	rst_s <= data_rst_i;

end Behavioral;
