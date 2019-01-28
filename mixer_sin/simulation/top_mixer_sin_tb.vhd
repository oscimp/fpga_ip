library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_mixer_sin_tb is
end entity top_mixer_sin_tb;

architecture RTL of top_mixer_sin_tb is
	function to_string(sv: std_logic_vector) return string is
		use std.TextIO.all;
		variable bv: bit_vector(sv'range) := to_bitvector(sv);
		variable lp: line;
	begin
		write(lp, bv);
		return lp.all;
	end;

	signal reset : std_logic;
    CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;

	constant DATA_SIZE : natural := 16;
	constant NCO_SIZE : natural := 16;

	signal data_en_s, nco_en_s : std_logic;
	signal nco_i_s, nco_q_s : std_logic_vector(NCO_SIZE-1 downto 0);
	signal data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal result_i_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal result_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal result_en_s : std_logic;
begin
	conv_inst : entity work.mixer_sin 
	generic map (
		NCO_SIZE => NCO_SIZE,
		DATA_SIZE => DATA_SIZE
	)
	port map (
		-- Syscon signals
		--processing_rst_i => reset,
		-- input data
		data_en_i => data_en_s,
		data_rst_i => reset,
		data_clk_i	   => clk,
		data_i => data_s,
		-- NCO
		nco_i_i  => nco_i_s,
		nco_q_i  => nco_q_s,
		nco_rst_i => reset,
		nco_en_i  => nco_en_s,
		nco_clk_i  => clk,
		-- output data
		data_clk_o => open,
		data_i_o  => result_i_s,
		data_q_o  => result_q_s,
		data_rst_o => open,
		data_en_o => result_en_s
	);

	nco_i_s <= x"7fff";
	nco_q_s <= x"8000";

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				data_s <= (others => '0');
				data_en_s <= '0';
			else
				data_s <= std_logic_vector(signed(data_s)+1);
				data_en_s <= '1';
			end if;
		end if;
	end process;

    stimulis : process
    begin
	reset <= '0';
	nco_en_s <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
    wait for 10 ns;
	wait until rising_edge(clk);
	nco_en_s <= '1';
	wait until rising_edge(clk);
	nco_en_s <= '0';
    wait for 10 us;
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

end architecture RTL;
