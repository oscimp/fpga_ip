library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fft_transfert is 
	generic (
		ADDR_SIZE : natural := 10;
		DATA_SIZE : natural := 32
	);
	port (
		-- Syscon signals
		clk_i		: in std_logic;
		rst_i		: in std_logic;
		transmit_en_o : in std_logic;
		done_transmit_o : out std_logic;
		-- in
		res_re_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		res_im_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		res_addr_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
		-- results
		res_re_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_im_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_en_o : out std_logic
	);
end entity;
Architecture fft_transfert_1 of fft_transfert is
	signal result_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal transmit_en_s, old_tx_en_s : std_logic;
	signal tx_en_s : std_logic;
begin
	res_re_o <= res_re_i;
	res_im_o <= res_im_i;
	res_addr_o <= result_addr_s;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				result_addr_s <= (others => '0');
				res_en_o <= '0';
				done_transmit_o <= '0';
			else
				result_addr_s <= result_addr_s;
				res_en_o <= '0';
				done_transmit_o <= '0';
				tx_en_s <= tx_en_s;
				if transmit_en_o = '1' and old_tx_en_s = '0' then
					tx_en_s <= '1';
				end if;
				if (transmit_en_o = '1' and old_tx_en_s = '0') or tx_en_s = '1' then
					res_en_o <= '1';
					result_addr_s <= std_logic_vector(unsigned(result_addr_s)
							+ 1);
					if result_addr_s = (ADDR_SIZE-1 downto 0 => '1') then
						done_transmit_o <= '1';
						tx_en_s <= '0';
					end if;
				else
					result_addr_s <= (others => '0');
				end if;
				old_tx_en_s <= transmit_en_o;
			end if;
		end if;
	end process;

end architecture fft_transfert_1;

