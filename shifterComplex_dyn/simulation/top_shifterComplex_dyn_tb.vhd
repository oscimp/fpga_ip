library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity top_shifterComplex_dyn_tb is
end entity top_shifterComplex_dyn_tb;

architecture RTL of top_shifterComplex_dyn_tb is
	constant DATA_IN_SIZE : natural := 32;
	constant DATA_OUT_SIZE : natural := 16;
	constant MAX_SHIFT : natural := DATA_IN_SIZE - DATA_OUT_SIZE;
	constant ADDR_SIZE : natural := natural(ceil(log2(real(MAX_SHIFT))));

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;
	--
	signal start_prod : std_logic;

	-- new
	signal data_in_en_s, data_out_en_s : std_logic;
	signal data_in_i_s, data_in_q_s : std_logic_vector(DATA_IN_SIZE-1 downto 0);
	signal data_out_i_s, data_out_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal state_s : std_logic;
	signal shift_val_s : std_logic_vector(ADDR_SIZE-1 downto 0);
begin

	shift_dyn_inst : Entity work.shifterComplex_dyn_logic
	generic map (
		DATA_FORMAT => "signed",
		MAX_SHIFT => MAX_SHIFT,
		ADDR_SZ => ADDR_SIZE,
		DATA_OUT_SIZE => DATA_OUT_SIZE,
		DATA_IN_SIZE => DATA_IN_SIZE
	)
	port map (
		-- Syscon signals
		rst_i		=> reset,
		clk_i		=> clk,
		shift_val_i => shift_val_s,
		-- input data
		data_i_i	=> data_in_i_s,
		data_q_i	=> data_in_q_s,
		data_en_i	=> data_in_en_s,
		-- for the next component
		data_i_o	=> data_out_i_s,
		data_q_o	=> data_out_q_s,
		data_en_o	=> data_out_en_s
	);

	-- generate data flow
	data_propagation : process(clk, reset)
	begin
		if (reset = '1') then
			shift_val_s <= (others => '0');
			data_in_i_s <= std_logic_vector(to_signed(-5, DATA_IN_SIZE));
			data_in_q_s <= std_logic_vector(to_unsigned(512, DATA_IN_SIZE));
			data_in_en_s <= '0';
			state_s <= '0';
		elsif rising_edge(clk) then
			shift_val_s <= shift_val_s;
			data_in_i_s <= data_in_i_s;
			data_in_q_s <= data_in_q_s;
			data_in_en_s <= '0';
			if state_s = '0' then
				if start_prod = '1' then
					data_in_en_s <= '1';
					state_s <= '1';
				end if;
			else
				if data_out_en_s = '1' then
					shift_val_s <= std_logic_vector(unsigned(shift_val_s)+1);
					data_in_en_s <= '1';
				end if;
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
