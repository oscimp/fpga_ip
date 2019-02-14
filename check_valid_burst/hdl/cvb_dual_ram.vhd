library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cvb_dual_ram is
generic (
	DATA	 : integer := 72;
	ADDR	 : integer := 10
);
port (
	clk_i    : in std_logic;
	rst_i    : in std_logic;

	w_switch_i : in std_logic;
	w_en_i   : in std_logic;
	w_addr_i : in std_logic_vector(ADDR-1 downto 0);
	w_din_i  : in std_logic_vector(DATA-1 downto 0); 
	r_switch_i : in std_logic;
	r_addr_i : in std_logic_vector(ADDR-1 downto 0);
	r_dout_o : out std_logic_vector(DATA-1 downto 0)   
);
end entity;

architecture bhv of cvb_dual_ram is
	constant NB_RAM : natural := 2;
	type data_tab is array (natural range <>)
            of std_logic_vector(DATA-1 downto 0);

	-- read
	signal r_select_s : std_logic;
	signal r_data_s : data_tab(NB_RAM-1 downto 0);
	-- write
	signal w_select_s : std_logic;
	signal we_s : std_logic_vector(NB_RAM-1 downto 0);

begin

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				w_select_s <= '0';
				r_select_s <= '0';
			else
				w_select_s <= w_select_s;
				r_select_s <= r_select_s;
				if w_switch_i = '1' then
					w_select_s <= not w_select_s;
				end if;
				if r_switch_i = '1' then
					r_select_s <= not r_select_s;
				end if;
			end if;
		end if;
	end process;


	we_s <= '0'&w_en_i when w_select_s = '0' else w_en_i&'0';
	r_dout_o <= r_data_s(0) when r_select_s = '0' else r_data_s(1);


	ram_loop: for i in 0 to NB_RAM-1 generate
		cvb_ram_inst : entity work.cvb_ram
		generic map (DATA => DATA, ADDR => ADDR)
		port map (clk_a => clk_i, clk_b => clk_i,
			we_a => we_s(i), addr_a => w_addr_i, din_a => w_din_i,
			dout_a => open,
			we_b => '0', addr_b => r_addr_i, din_b => (DATA-1 downto 0 => '0'),
			dout_b => r_data_s(i)
		);
	end generate ram_loop;	

end architecture bhv;
