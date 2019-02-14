library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity cvb_gen_new_flow is 
	generic (
		ADDR : natural := 1024;
		DATA : natural := 8
	);
	port (
		clk_i	 	: in std_logic;
		rst_i	 	: in std_logic;
		-- from cpu
		cpt_max_i 	: in std_logic_vector(ADDR-1 downto 0);
		-- start
		start_i 	: in std_logic;
		-- ram
		ram_i_i 	: in std_logic_vector(DATA-1 downto 0);
		ram_q_i 	: in std_logic_vector(DATA-1 downto 0);
		ram_addr_o 	: out std_logic_vector(ADDR-1 downto 0);
		-- next
		data_i_o 	: out std_logic_vector(DATA-1 downto 0);
		data_q_o 	: out std_logic_vector(DATA-1 downto 0);
		data_eof_o 	: out std_logic;
		data_en_o 	: out std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture cvb_gen_new_flow_1 of cvb_gen_new_flow is
---------------------------------------------------------------------------
	signal ram_addr_s : std_logic_vector(ADDR-1 downto 0);
	signal ram_addr_next_s : std_logic_vector(ADDR-1 downto 0);
	signal data_en_s, data_en_next_s : std_logic;
	signal data_eof_s : std_logic;
	signal busy_s : std_logic;
	-- propagation
	signal data_i_s : std_logic_vector(DATA-1 downto 0);
	signal data_q_s : std_logic_vector(DATA-1 downto 0);
	signal need_rst_s : std_logic;
begin
	data_i_o <= data_i_s;
	data_q_o <= data_q_s;
	ram_addr_o <= ram_addr_s;

	-- used because RAM out is delayed by one cycle
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data_en_o <= '0';
				data_eof_o <= '0';
				data_i_s <= (others => '0');
				data_q_s <= (others => '0');
			else
				data_eof_o <= data_eof_s;
				data_en_o <= data_en_s;
				data_i_s <= data_i_s;
				data_q_s <= data_q_s;
				if data_en_s = '1' then
					data_i_s <= ram_i_i;
					data_q_s <= ram_q_i;
				end if;
			end if;
		end if;
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			busy_s <= busy_s;
			if start_i = '1' then
				busy_s <= '1';
			end if;
			if (need_rst_s or rst_i) = '1' then
				busy_s <= '0';
			end if;
		end if;
	end process;
				


	need_rst_s <= '1' when unsigned(ram_addr_s) = unsigned(cpt_max_i) else
					'0';
	ram_addr_next_s <= std_logic_vector(unsigned(ram_addr_s)+1);
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			ram_addr_s <= ram_addr_s;
			data_en_s <= '0';
			if (start_i or busy_s) = '1' then
				ram_addr_s <= ram_addr_next_s;
				data_en_s <= '1';
			end if;
			if (rst_i or need_rst_s) = '1' then
				ram_addr_s <= (others => '0');
			end if;
		end if;
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			data_eof_s <= '0';
			if need_rst_s = '1' then
				data_eof_s <= '1';
			end if;
		end if;
	end process;
				
end architecture cvb_gen_new_flow_1;

