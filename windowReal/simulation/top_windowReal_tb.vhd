library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_windowReal_tb is
end entity top_windowReal_tb;

architecture RTL of top_windowReal_tb is
	function to_string(sv: std_logic_vector) return string is
		--use std.TextIO.all;
		variable bv: bit_vector(sv'range) := to_bitvector(sv);
		variable lp: line;
	begin
		write(lp, bv);
		return lp.all;
	end;
	file final_result_file: text open write_mode is "./result.txt";

	signal reset : std_logic;
    CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
    CONSTANT SLOW_PERIODE : time := 10.0 ns;  -- Half clock period
	signal clk : std_logic;

	constant COEFF_ADDR_SIZE : natural := 11;
	constant COEFF_SIZE : natural := 21;
	constant SHIFT : natural := 20;
	constant DATA_SIZE : natural := 30;
	constant DATA_ADDR_SIZE : natural := 11;

	signal coeff_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_addr_s : std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
	signal coeff_en_s : std_logic;

	signal data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	signal result_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal result_en_s : std_logic;
	signal result_eof_s : std_logic;
	--misc
	signal sl_clk_s, slow_clk : std_logic;
	signal generate_en_s : std_logic;
	-- ram for data
	signal read_data_val_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal read_data_addr_s : std_logic_vector(10 downto 0);
	signal read_data_en_s : std_logic;
	signal end_read_s : std_logic;
	signal prop_data_addr_s : std_logic_vector(10 downto 0);
	signal tick_s : std_logic;
begin
	conv_inst : entity work.windowReal_logic 
	generic map (
		COEFF_SIZE => COEFF_SIZE,
		SHIFT => SHIFT,
		COEFF_ADDR_SIZE => COEFF_ADDR_SIZE,
		DATA_SIZE => DATA_SIZE
	)
	port map (
		-- Syscon signals
		clk_i => clk,
		cpu_clk_i => clk,
		reset => reset,
		-- input data
		data_i => data_s,
		data_en_i => data_en_s,
		-- coeff
		coeff_en_i => coeff_en_s,
		coeff_addr_i => coeff_addr_s,
		coeff_i => coeff_s,
		-- output data
		data_o  => result_s,
		data_en_o => result_en_s,
		data_eof_o => result_eof_s
	);

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				data_en_s <= '0';
				prop_data_addr_s <= (others => '0');
			else
				data_en_s <= '0';
				prop_data_addr_s <= prop_data_addr_s;
				if (end_read_s and generate_en_s) = '1' then
					if tick_s = '1' then
						prop_data_addr_s <= 
							std_logic_vector(unsigned(prop_data_addr_s)+1);
						data_en_s <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

    stimulis : process
    begin
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	--wait until rising_edge(sl_clk_s);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
    wait for 10 ns;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
    wait for 10 us;
	wait until rising_edge(generate_en_s);
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
	wait until result_eof_s = '1';
	wait until rising_edge(result_eof_s);
	wait until rising_edge(result_eof_s);
--   wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
    assert false report "End of test" severity error;
    end process stimulis;
    
    clockp : process
    begin
        clk <= '1';
        wait for HALF_PERIODE;
        clk <= '0';
        wait for HALF_PERIODE;
    end process clockp;

    --slow_clockp : process
    --begin
    --    sl_clk_s <= '1';
    --    wait for SLOW_PERIODE;
    --    sl_clk_s <= '0';
    --    wait for SLOW_PERIODE;
    --end process slow_clockp;

	-- read coeff for fir16 LUT
	read_coeff : entity work.readFromFile
	generic map(
		DATA_SIZE => COEFF_SIZE,
		ADDR_SIZE => COEFF_ADDR_SIZE,
		filename => "/nfs/zc706/share/hanning2p20.dat"
		--filename => "./testC/coeff.dat"
	)
	port map (
		reset => reset,
		clk => clk,
		sl_clk_i => sl_clk_s,
		--fichier => vectors,
		start_read_i => '1',
		data_o => coeff_s,
		addr_o => coeff_addr_s,
		data_en_o => coeff_en_s,
		end_of_read_o => generate_en_s
	);
	
	read_data_i : entity work.readFromFile
    generic map(
        DATA_SIZE => DATA_SIZE,
        ADDR_SIZE => 11,
        filename =>
        "../out_diff1.dat"
    )
    port map (
        reset => reset,
        clk => clk,
        sl_clk_i => sl_clk_s,
        --fichier => datas,
        start_read_i => '1',
        data_o => read_data_val_s,
        addr_o => read_data_addr_s,
        data_en_o => read_data_en_s,
        end_of_read_o => end_read_s
    );

	ram_i : entity work.ram_storage16
    generic map(
        DATA => DATA_SIZE,
        ADDR => 11
    )
    port map (
        clk_a => clk,
        clk_b => clk,
        -- input datas
        we_a => read_data_en_s,
        din_a => read_data_val_s,
        addr_a => read_data_addr_s,
        dout_a => open,
        -- output
        we_b => '0',
        addr_b => prop_data_addr_s,
        din_b => (DATA_SIZE-1 downto 0 => '0'),
        dout_b => data_s
    );



	clk_divider : process(clk, reset)
		variable tt : natural range 0 to 1;
	begin
		if reset = '1' then
			sl_clk_s <= '0';
			tick_s <= '0';
			tt := 0;
		elsif rising_edge(clk) then
			sl_clk_s <= '0';
			tick_s <= '0';
			if tt = 1 then
				sl_clk_s <= '1';
				tick_s <= '1';
				tt := 0;
			else
				tt := tt+1;
			end if;
		end if;
	end process;

	store_result : process(clk, reset)
		variable lp: line;
		variable pv: Std_Logic;
	begin
		if (reset = '1') then
		elsif rising_edge(clk) then
			if (result_en_s) = '1' then
				write(lp, integer'image(to_integer(signed(result_s))));
				writeline(final_result_file, lp);
			end if;
		end if;
	end process; 
end architecture RTL;
