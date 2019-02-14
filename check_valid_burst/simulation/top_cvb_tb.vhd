library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_cvb_tb is
end entity top_cvb_tb;

architecture RTL of top_cvb_tb is
	signal reset : std_logic;
    CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;

	function to_string(sv: std_logic_vector) return string is
		--use std.TextIO.all;
		variable bv: bit_vector(sv'range) := to_bitvector(sv);
		variable lp: line;
	begin
		write(lp, bv);
		return lp.all;
	end;
	file final_result_file: text open write_mode is "./result.txt";


	constant ADDR_SIZE : natural := 10;
	constant DATA_SIZE : natural := 16;
	constant ACCUM_SIZE : natural := 32;
	constant RAM_ADDR_SIZE : natural := ADDR_SIZE + 3;

	-- config --
	signal start_mean_offset_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal max_allowed_val_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
	signal cpt_max_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	-- write from file to RAM --
	signal write_i_s, write_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal write_addr_s : std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	signal write_en_s : std_logic;
	signal write_end_s : std_logic;
	-- read for flow generation --
	signal start_read_s : std_logic;
	signal read_i_s, read_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal read_addr_s : std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	signal read_en_s : std_logic;
	signal read_end_s : std_logic;
	-- input --
	signal data_i_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	signal data_eof_s : std_logic;
	-- output --
	signal result_i_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal result_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal result_en_s : std_logic;
	signal result_eof_s : std_logic;
--	--misc
	signal generate_en_s : std_logic;
	signal cpt_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal cpt2_s : std_logic_vector(2 downto 0);
	signal wait_a_bit : std_logic;
begin
	
	start_mean_offset_s <= '0'&(ADDR_SIZE-2 downto 0 => '1');
	max_allowed_val_s <= x"000186A0";
	cpt_max_s <= (ADDR_SIZE-1 downto 0 => '1');

	--start_mean_offset_s <= (ADDR_SIZE-1 downto 3 => '0') & (2 downto 0 => '1');
	--max_allowed_val_s <= (ACCUM_SIZE-1 downto 4 => '0') & (3 downto 0 => '1');
	--cpt_max_s <= (ADDR_SIZE-1 downto 4 => '0') & (3 downto 0 => '1');


	cvb_logic_inst : entity work.cvb_logic
	generic map (DATA_SIZE => DATA_SIZE, ADDR_SIZE => ADDR_SIZE,
		ACCUM_SIZE => ACCUM_SIZE)
	port map (clk_i => clk, reset => reset,
		-- input
		data_en_i => data_en_s, data_eof_i => data_eof_s,
		data_i_i => read_i_s, data_q_i => read_q_s,
        -- output
		data_i_o  => result_i_s, data_q_o => result_q_s,
		data_en_o => result_en_s, data_eof_o => result_eof_s,
        start_mean_offset_i => start_mean_offset_s,
        max_allowed_val_i => max_allowed_val_s,
        cpt_max_i => cpt_max_s
    );

	read_en_s <= data_en_s;
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				data_en_s <= '0';
				data_eof_s <= '1'; -- just to unlock block
				cpt_s <= (others => '0');
				read_addr_s <= (others => '0');
				read_end_s <= '0';
				wait_a_bit <= '0';
				cpt2_s <= (others => '0');
			else
				data_en_s <= '0';
				data_eof_s <= '0';
				read_addr_s <= read_addr_s;
				wait_a_bit <= wait_a_bit;
				cpt2_s <= cpt2_s;
				read_end_s <= read_end_s;
				if write_end_s = '1' and read_end_s = '0' then
					if (wait_a_bit = '0') then
						data_en_s <= '1';
						cpt_s <= std_logic_vector(unsigned(cpt_s) + 1);
						read_addr_s <= std_logic_vector(unsigned(read_addr_s) + 1);
						if (cpt_s = (ADDR_SIZE-1 downto 0 => '1')) then
						--if (unsigned(cpt_s) = 1023) then
							data_eof_s <= '1';
							cpt_s <= (others => '0');
							wait_a_bit <= '1';
							cpt2_s <= std_logic_vector(unsigned(cpt2_s)+1);
							if (cpt2_s = "100") then
								read_end_s <= '1';
							end if;
						end if;
					else
						if (cpt_s = (ADDR_SIZE-1 downto 3 => '0') & "001") then
							wait_a_bit <= '0';
							cpt_s <= (others => '0');
						else
							cpt_s <= std_logic_vector(unsigned(cpt_s) + 1);
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

    stimulis : process
    begin
	start_read_s <= '0';
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
    wait for 10 ns;
	wait until rising_edge(clk);
	start_read_s <= '1';
	wait until rising_edge(clk);
	generate_en_s <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until read_end_s = '1';
    wait for 10 us;
    wait for 10 us;

   wait for 10 us;
    wait for 10 us;
    wait for 10 us;
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

--	-- read coeff for fir16 LUT

	read_coeff : entity work.readComplexFromFile
    generic map(DATA_SIZE => DATA_SIZE, ADDR_SIZE => RAM_ADDR_SIZE,
        filename_re => "./genOracle/input_oracle_sin.dat",
        filename_im => "./genOracle/input_oracle_cos.dat")
    port map (reset => reset, clk => clk, sl_clk_i => clk,
        --fichier => datas,
        start_read_i => start_read_s,
        data_re_o => write_i_s,
        data_im_o => write_q_s,
        addr_o => write_addr_s,
        data_en_o => write_en_s,
        end_of_read_o => write_end_s
	);

	ram_i : entity work.cvb_ram
    generic map(DATA => DATA_SIZE, ADDR => RAM_ADDR_SIZE)
    port map (clk_a => clk, clk_b => clk,
        we_a => write_en_s, din_a => write_i_s,
        addr_a => write_addr_s, dout_a => open,
        we_b => '0', addr_b => read_addr_s,
        din_b => (DATA_SIZE-1 downto 0 => '0'),
        dout_b => read_i_s);
	ram_q : entity work.cvb_ram
    generic map(DATA => DATA_SIZE, ADDR => RAM_ADDR_SIZE)
    port map (clk_a => clk, clk_b => clk,
        we_a => write_en_s, din_a => write_q_s,
        addr_a => write_addr_s, dout_a => open,
        we_b => '0', addr_b => read_addr_s,
        din_b => (DATA_SIZE-1 downto 0 => '0'),
        dout_b => read_q_s);

	store_result : process(clk, reset)
		variable lp: line;
		variable pv: Std_Logic;
	begin
		if (reset = '1') then
		elsif rising_edge(clk) then
			if (result_en_s) = '1' then
				write(lp, integer'image(to_integer(signed(result_i_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(result_q_s))));
				writeline(final_result_file, lp);
				if result_eof_s = '1' then
					write(lp, string'("eof"));
					writeline(final_result_file, lp);
				end if;
			end if;
		end if;
	end process; 
end architecture RTL;
