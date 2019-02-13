library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_mean_vector_tb is
end entity top_mean_vector_tb;

architecture RTL of top_mean_vector_tb is
	constant DATA_SIZE : natural := 32;
	constant FRAME_LENGTH : natural := 8;
	constant UPDATE_LENGTH : natural := 60;

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;

	signal data_in_en_s, data_out_en_s : std_logic;
	signal data_in_eof_s, data_out_eof_s : std_logic;
	signal data_in_i_s, data_in_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_out_i_s, data_out_q_s : std_logic_vector(DATA_SIZE-1 downto 0);

	signal start_prod : std_logic;

	signal cpt_s : natural range 0 to FRAME_LENGTH-1;
	signal cpt2_s : natural range 0 to UPDATE_LENGTH-1;

	constant SIM_ITER : natural := 1;
	constant SIM_SHIFT: natural := 0;
	
	constant MAX_NB_ACCUM : natural := 32;
	-- 2^ACCUM_SIZE => NB_ACCUM (in fact 0 -> NB_ACCUM-1 but ...)
    constant ACCUM_SIZE : natural := natural(ceil(log2(real(MAX_NB_ACCUM))));
    -- we need to describe the shift size
    -- divide by 1024 is >> 10 => 10 must be used with 2^4 = 16
    constant SHIFT_SIZE : natural := natural(ceil(log2(real(ACCUM_SIZE))));

    signal nb_iter_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
    signal nb_iter_sync_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
    signal shift_val_s : std_logic_vector(SHIFT_SIZE-1 downto 0);
    signal shift_val_sync_s : std_logic_vector(SHIFT_SIZE-1 downto 0);

begin

	mult_const_inst : Entity work.mean_vector_axi_logic
	generic map (
		ADDR_SIZE => 10,
		ACCUM_SIZE => ACCUM_SIZE,
		SHIFT_SIZE => SHIFT_SIZE,
		DATA_SIZE => 32
	)
	port map (
		-- Syscon signals
		clk_i 	=> clk,
		rst_i	=> reset,
		-- config
		shift_val_i => shift_val_sync_s,
		nb_iter_i => nb_iter_sync_s,
		-- input data
		data_i_i			=> data_in_i_s,
		data_q_i			=> data_in_q_s,
		data_en_i			=> data_in_en_s,
		data_eof_i			=> data_in_eof_s,
		-- output data
		data_i_o			=> data_out_i_s,
		data_q_o			=> data_out_q_s,
		data_en_o			=> data_out_en_s,
		data_eof_o			=> data_out_eof_s
	);

	-- generate data flow
	data_propagation : process(clk, reset)
	begin
		if (reset = '1') then
			data_in_i_s <= (others => '0');
			data_in_q_s <= (others => '0');
			data_in_en_s <= '0';
			data_in_eof_s <= '0';
			cpt_s <= 0;
			cpt2_s <= 0;
			shift_val_s <= (others => '0');
			shift_val_sync_s <= (others => '0');
			nb_iter_s <= (ACCUM_SIZE-1 downto 1 => '0') & '1';
			nb_iter_sync_s <= (ACCUM_SIZE-1 downto 1 => '0') & '1';
			nb_iter_s <= std_logic_vector(to_unsigned(SIM_ITER, ACCUM_SIZE));
			nb_iter_sync_s <= std_logic_vector(to_unsigned(SIM_ITER, ACCUM_SIZE));
			shift_val_s <= std_logic_vector(to_unsigned(SIM_SHIFT, SHIFT_SIZE));
			shift_val_sync_s <= std_logic_vector(to_unsigned(SIM_SHIFT, SHIFT_SIZE));
		elsif rising_edge(clk) then
			data_in_i_s <= data_in_i_s;
			data_in_q_s <= data_in_q_s;
			data_in_en_s <= '0';
			data_in_eof_s <= '0';
			cpt_s <= cpt_s;
			cpt2_s <= cpt2_s;
			shift_val_s <= shift_val_s;
			shift_val_sync_s <= shift_val_s;
			nb_iter_s <= nb_iter_s;
			nb_iter_sync_s <= nb_iter_s;
			if start_prod = '1' then
				if cpt_s < FRAME_LENGTH-1 then
					cpt_s <= cpt_s + 1;
				else
					cpt_s <= 0;
					data_in_eof_s <= '1';
					--if (cpt2_s < unsigned(nb_iter_s) * 3) then
					--	cpt2_s <= cpt2_s + 1;
					--else
					--	cpt2_s <= 0;
					--	nb_iter_s <= 
					--		nb_iter_s(ACCUM_SIZE-2 downto 0) & nb_iter_s(ACCUM_SIZE-1);
					--	shift_val_s <= std_logic_vector(unsigned(shift_val_s) + 1);
					--end if;
				end if;

				data_in_i_s <= std_logic_vector(to_unsigned(cpt_s, DATA_SIZE)); 
				data_in_q_s <= std_logic_vector(to_unsigned(cpt_s, DATA_SIZE)); 
				data_in_en_s <= '1';
			end if;
		end if;
	end process; 

    stimulis : process
    begin
	start_prod <= '0';
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
    wait for 10 ns;
    wait for 10 ns;
    wait for 10 ns;
	wait until rising_edge(clk);
	start_prod <= '1';
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
	wait for 1 ms;
    assert false report "End of test" severity error;
    end process stimulis;
    
    clockp : process
    begin
        clk <= '1';
        wait for HALF_PERIODE;
        clk <= '0';
        wait for HALF_PERIODE;
    end process clockp;
    
end architecture RTL;
