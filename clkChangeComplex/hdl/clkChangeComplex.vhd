library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.all;

entity clkChangeComplex is
	generic (
		DATA_SIZE : natural := 16
	);
	port (
		-- input
		data_i_i   : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i   : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i  : in std_logic;
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		-- output
		data_i_o   : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o   : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o  : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic;

		-- data fo FIFO
		m00_axis_aclk   : in std_logic;
		m00_axis_tdata  : out std_logic_vector((2*DATA_SIZE)-1 downto 0);
		m00_axis_tready : in std_logic;
		m00_axis_tvalid : out std_logic;
		m00_aclk_en     : out std_logic;
		-- from FIFO to data
		s00_axis_aclk   : in std_logic;
		s00_axis_reset  : in std_logic;
		s00_axis_tdata  : in std_logic_vector((2*DATA_SIZE) - 1 downto 0);
		s00_axis_tready : out std_logic;
		s00_axis_tvalid : in std_logic
	);
end clkChangeComplex;

architecture Behavioral of clkChangeComplex is
	signal data_in_s : std_logic_vector((2*DATA_SIZE)-1 downto 0);
begin
	m00_axis_tdata <= data_q_i & data_i_i;
	m00_axis_tvalid <= data_en_i;
	m00_aclk_en <= '1';

	data_clk_o <= s00_axis_aclk;

	data_rst_o <= s00_axis_reset;

	process(s00_axis_aclk) begin
		if rising_edge(s00_axis_aclk) then
			data_en_o <= s00_axis_tvalid;
			s00_axis_tready <= '1';
			if (s00_axis_reset = '1') then
				s00_axis_tready <= '0';
				data_in_s <= (others => '0');
			elsif (s00_axis_tvalid = '1') then
				data_in_s <= s00_axis_tdata;
			else
				data_in_s <= data_in_s;
			end if;
		end if;
	end process;

	data_q_o <= data_in_s((2*DATA_SIZE)-1 downto 1 * DATA_SIZE);
	data_i_o <= data_in_s((1*DATA_SIZE)-1 downto 0 * DATA_SIZE);

end Behavioral;

