library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_prnGenerator_tb is
end entity top_prnGenerator_tb;

architecture RTL of top_prnGenerator_tb is
	file final_result_file: text open write_mode is "./result.txt";

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;

	signal prnGenerator_s : std_logic;
	signal tick_s : std_logic;

	constant mask_s : std_logic_vector(7 downto 0) := x"41";
	signal data_s : std_logic_vector(7 downto 0);
	signal lfsr_s, lfsr_next_s : std_logic_vector(7 downto 0) := (others => '1');
	signal xor_s : std_logic;
begin

	data_s <= lfsr_s and mask_s;
	xor_s <= xor data_s;
	lfsr_next_s <= lfsr_s(6 downto 0) & xor_s;

	process(clk) begin
		lfsr_s <= lfsr_next_s;
	end process;

	DUT : entity work.prnGenerator
	generic map (PERIOD_LEN => 1, BIT_LEN => 7, BIT_NUM => 1)
    port map (
		clk => clk, reset => reset,
		tick_i => tick_s,
		prnGenerator_o => prnGenerator_s
	);

    stimulis : process
    begin
	reset <= '1';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	tick_s <= '1';
	reset <= '0';
	reset <= '0';
    wait for 10 ns;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
    wait for 10 us;
    assert false report "End of test" severity error;
    end process stimulis;

    store_result : process(clk, reset)
        variable lp: line;
        variable pv: Std_Logic;
    begin
        if (reset = '1') then
        elsif rising_edge(clk) then
			if (tick_s = '1') then
				if (prnGenerator_s = '1' ) then
					write(lp, character'('1'));
				else
					write(lp, character'('0'));
				end if;
            	writeline(final_result_file, lp);
			end if;
        end if;
    end process;

    
    clockp : process
    begin
        clk <= '1';
        wait for HALF_PERIODE;
        clk <= '0';
        wait for HALF_PERIODE;
    end process clockp;

end architecture RTL;
