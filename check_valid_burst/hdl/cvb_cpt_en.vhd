library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cvb_cpt_en is
generic (
	DATA	 : integer := 72;
	ADDR	 : integer := 10
);
port (
	clk_i    : in std_logic;
	rst_i    : in std_logic;

	data_en_i 	: in std_logic;
	data_eof_i 	: in std_logic;

	data_en_o : out std_logic;
	data_eof_o : out std_logic;
	data_addr_o : out std_logic_vector(ADDR-1 downto 0)
);
end entity;

architecture bhv of cvb_cpt_en is
	-- synchro with frame
	signal ready_s : std_logic;
	signal data_en_s : std_logic;
	signal data_eof_s : std_logic;
	-- counter RAM
	signal addr_s, addr_next_s : std_logic_vector(ADDR-1 downto 0);
begin
	data_en_o <= data_en_s;
	data_addr_o <= addr_s;
	data_eof_o <= data_eof_s;

	-- just to be sure do not start somewhere in a frame
	data_en_s <= data_en_i and ready_s;
	data_eof_s <= data_eof_i and ready_s;
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				ready_s <= '0';
			else
				ready_s <= ready_s;
				if data_eof_i = '1' then
					ready_s <= '1';
				end if;
			end if;
		end if;
	end process;

	addr_next_s <= std_logic_vector(unsigned(addr_s)+1);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			addr_s <= addr_s;
			if data_en_s = '1' then
				addr_s <= addr_next_s;
			end if;
			if (rst_i or data_eof_s) = '1' then
				addr_s <= (others => '0');
			end if;
		end if;
	end process;

end architecture bhv;
