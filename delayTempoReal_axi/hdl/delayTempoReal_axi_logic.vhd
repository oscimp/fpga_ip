library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity delayTempoReal_axi_logic is
	generic (
		DELAY_SIZE : natural := 3;
		DATA_SIZE: natural := 18
	);
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- ctrl
		delay_i : in std_logic_vector(DELAY_SIZE-1 downto 0);
		-- in
		data_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i : in std_logic;
		data_eof_i : in std_logic := '0';
		-- out
		data_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o : out std_logic;
		data_eof_o : out std_logic
	);
end delayTempoReal_axi_logic;

architecture bhv of delayTempoReal_axi_logic is
	constant MX_NB_DEL : natural := 2**DELAY_SIZE;

	constant EQ_ZERO : std_logic_vector(DELAY_SIZE-1 downto 0) :=
							(DELAY_SIZE-1 downto 0 => '0');
	signal del_eq_zero_s : std_logic;

	signal data_in_s : std_logic_vector(DATA_SIZE+1 downto 0);
	type data_tab is array (natural range <>) of std_logic_vector(DATA_SIZE+1 downto 0);
	-- delay
	signal data_tab_s, data_tab_next_s  : data_tab(MX_NB_DEL-1 downto 0);
	-- future output
	signal data_del_s : std_logic_vector(DATA_SIZE+1 downto 0);
	-- mux
	signal mux_data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal mux_data_en_s : std_logic;
	signal mux_data_eof_s : std_logic;
begin

	data_in_s <= data_eof_i & data_en_i & data_i;

	data_tab_next_s(MX_NB_DEL-1 downto 1) <= data_tab_s(MX_NB_DEL-2 downto 0);
	data_tab_next_s(0) <= data_in_s;

	process(clk_i) begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				data_tab_s <= (others => (others => '0'));
			else
				data_tab_s <= data_tab_next_s;
			end if;
		end if;
	end process;

	data_del_s <= data_tab_s(to_integer(unsigned(delay_i)-1));

	mux_data_s <= data_del_s(DATA_SIZE-1 downto 0);
	mux_data_eof_s <= data_del_s(DATA_SIZE+1);
	mux_data_en_s <= data_del_s(DATA_SIZE);

	del_eq_zero_s <= '1' when delay_i = EQ_ZERO else '0';
	data_o <= data_i when del_eq_zero_s = '1' else mux_data_s;
	data_en_o <= data_en_i when del_eq_zero_s = '1' else mux_data_en_s;
	data_eof_o <= data_eof_i when del_eq_zero_s = '1' else mux_data_eof_s;

end bhv;

