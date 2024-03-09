library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ram_to_dataReal_logic is
	generic (
		COEFF_ADDR_SIZE : natural := 8;
		COEFF_SIZE : natural := 16;
		DECIM_FACTOR_POW : natural := 1;
		EXT_TRIG : boolean := false;
		ENABLE_EACH_CLK : boolean := false
	);
	port (
		clk_i : in std_logic;
		cpu_clk_i : in std_logic;
		reset : in std_logic;
		trigger_i : in std_logic;
		-- output
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		-- coeff
		coeff_en_i : in std_logic;
		coeff_addr_i : in std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
		coeff_i : in std_logic_vector(COEFF_SIZE-1 downto 0)
	);
end ram_to_dataReal_logic;

architecture Behavioral of ram_to_dataReal_logic is
	-- coeff
	signal coeff_s, coeff_next_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_addr_s : std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
	-- reset
	signal rst_s : std_logic;
	-- mult
	signal mult_res_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	-- cpt
	signal cpt_s : std_logic_vector(DECIM_FACTOR_POW-1 downto 0);
	-- output
	signal data_out_s : std_logic_vector(COEFF_SIZE-1 downto 0);

begin
    process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				cpt_s <= std_logic_vector(to_unsigned(1, DECIM_FACTOR_POW));
			else
				cpt_s <= cpt_s;
				if ((EXT_TRIG = false) or (trigger_i = '1')) then
					if cpt_s < ((DECIM_FACTOR_POW-1 downto 0 => '1')) then
						cpt_s <= std_logic_vector(unsigned(cpt_s) + 1);
					else
						cpt_s <= std_logic_vector(to_unsigned(1, DECIM_FACTOR_POW));
					end if;
				end if;
			end if;
		end if;
	end process;

	-- latch data first to match RAM latency for next input
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				coeff_s <= (others => '0');
			else
				coeff_s <= coeff_s;
				if ((EXT_TRIG = false) or (trigger_i = '1')) then
					if cpt_s = ((DECIM_FACTOR_POW-1 downto 0 => '1')) then
						coeff_s <= coeff_next_s;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- update RAM for each new clk_i
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				coeff_addr_s <= (others => '1');
			else
				coeff_addr_s <= coeff_addr_s;
				if ((EXT_TRIG = false) or (trigger_i = '1')) then
					if cpt_s = ((DECIM_FACTOR_POW-1 downto 0 => '1')) then
						coeff_addr_s <= std_logic_vector(
								unsigned(coeff_addr_s) - 1);
					end if;
				end if;
			end if;
		end if;
	end process;

	mult_res_s <= std_logic_vector(signed(coeff_s));

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				data_eof_o <= '0';
			else
				data_eof_o <= '0';
				if ((EXT_TRIG = false) or (trigger_i = '1')) then
					if cpt_s = ((DECIM_FACTOR_POW-1 downto 0 => '1')) then
						if coeff_addr_s = ((COEFF_ADDR_SIZE-1 downto 1 => '1') &'0') then
							data_eof_o <= '1';
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				data_en_o <= '0';
				data_out_s <= (others => '0');
			else
				data_en_o <= '0';
				data_out_s <= data_out_s;
				if ((EXT_TRIG = false) or (trigger_i = '1') or (ENABLE_EACH_CLK = true)) then
					if cpt_s = ((DECIM_FACTOR_POW-1 downto 0 => '1')) then
						data_en_o <= '1';
						data_out_s <= mult_res_s;
					end if;
				end if;
			end if;
		end if;
	end process;

	data_o <=  data_out_s;

	ram1 : entity work.ram_to_dataReal_ram
	generic map (DATA => COEFF_SIZE, ADDR => COEFF_ADDR_SIZE)
	port map (clk_a => cpu_clk_i, clk_b => clk_i, 
	-- input
	we_a => coeff_en_i, addr_a => coeff_addr_i,
	din_a => coeff_i, dout_a => open,
	-- output
	we_b => '0', addr_b => coeff_addr_s,
	din_b => (COEFF_SIZE-1 downto 0 => '0'), dout_b => coeff_next_s);

end Behavioral;
