library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity windowReal_logic is
	generic (
		DATA_SIZE : natural := 32;
		COEFF_ADDR_SIZE : natural := 8;
		SHIFT : natural := 16;
		COEFF_SIZE : natural := 16
	);
	port (
		clk_i : in std_logic;
		cpu_clk_i : in std_logic;
		reset : in std_logic;
		-- input
		data_en_i : in std_logic;
		data_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		-- output
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		-- coeff
		coeff_en_i : in std_logic;
		coeff_addr_i : in std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
		coeff_i : in std_logic_vector(COEFF_SIZE-1 downto 0)
	);
end windowReal_logic;

architecture Behavioral of windowReal_logic is
	constant MULT_SIZE : natural := COEFF_SIZE+DATA_SIZE;
	constant MULT_RESIZE : natural := MULT_SIZE-1;
	-- input latch --
	signal data_in_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_in_en_s : std_logic;
	-- coeff
	signal coeff_s, coeff_next_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_addr_s : std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
	-- reset
	signal rst_s : std_logic;
	-- input latch
	signal data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	-- mult
	signal mult_res_s : std_logic_vector(MULT_SIZE-1 downto 0);
	signal mult_res_resize_s : std_logic_vector(MULT_RESIZE-1 downto 0);
	signal mult_res_scale_s : std_logic_vector(DATA_SIZE-1 downto 0);
	-- output
	signal data_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
begin

	-- latch data first to match RAM latency for next input
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				data_in_s <= (others => '0');
				data_in_en_s <= '0';
			else
				data_in_s <= (others => '0');
				data_in_en_s <= data_en_i;
				if data_en_i = '1' then
					data_in_s <= data_i;
				end if;
			end if;
		end if;
	end process;
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				data_s <= (others => '0');
				data_en_s <= '0';
				coeff_s <= (others => '0');
			else
				data_s <= data_s;
				data_en_s <= data_in_en_s;
				coeff_s <= coeff_s;
				if data_in_en_s = '1' then
					data_s <= data_in_s;
					coeff_s <= coeff_next_s;
				end if;
			end if;
		end if;
	end process;

	-- update RAM for each new data_en_i
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				coeff_addr_s <= (others => '0');
			else
				coeff_addr_s <= coeff_addr_s;
				if data_en_i = '1' then
					coeff_addr_s <= std_logic_vector(
							unsigned(coeff_addr_s) + 1);
				end if;
			end if;
		end if;
	end process;


	mult_res_s <= std_logic_vector(signed(data_s) * signed(coeff_s));
	mult_res_resize_s <= mult_res_s(MULT_RESIZE-1 downto 0);
	--mult_res_scale_s <= mult_res_resize_s srl 15;
	--mult_res_scale_s <= std_logic_vector(shift_right(signed(mult_res_resize_s),
	--16));
	--	mult_res_resize_s(MULT_RESIZE-1 downto MULT_RESIZE-DATA_SIZE);
	--mult_res_scale_s <= mult_res_s(MULT_SIZE-2 downto MULT_SIZE-DATA_SIZE-1);
	mult_res_scale_s <= mult_res_s(SHIFT+DATA_SIZE-1 downto SHIFT);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				data_eof_o <= '0';
			else
				data_eof_o <= '0';
				if data_en_s = '1' then
					if coeff_addr_s = (COEFF_ADDR_SIZE-1 downto 0 => '0') then
						data_eof_o <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				data_out_s <= (others => '0');
				data_en_o <= '0';
			else
				data_out_s <= data_out_s;
				data_en_o <= data_en_s;
				if data_en_s = '1' then
					data_out_s <= mult_res_scale_s;
				end if;
			end if;
		end if;
	end process;

	data_o <=  data_out_s;

	ram1 : entity work.windowReal_ram
    generic map (DATA => COEFF_SIZE, ADDR => COEFF_ADDR_SIZE)
	port map (clk_a => cpu_clk_i, clk_b => clk_i, 
	-- input
	we_a => coeff_en_i, addr_a => coeff_addr_i,
	din_a => coeff_i, dout_a => open,
	-- output
	we_b => '0', addr_b => coeff_addr_s,
	din_b => (COEFF_SIZE-1 downto 0 => '0'), dout_b => coeff_next_s);

end Behavioral;

