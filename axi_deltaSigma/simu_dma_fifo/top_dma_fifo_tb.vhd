library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
USE std.textio.ALL;

entity top_dma_fifo_tb is
end entity top_dma_fifo_tb;

architecture RTL of top_dma_fifo_tb is

	signal reset, rstn : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
   	signal clk : std_logic;

	signal start_prod_s : std_logic;

	signal fifo_rst : std_logic;
	signal fifo_in_stb_s, fifo_in_ack_s : std_logic;
	signal fifo_in_data_s : std_logic_vector(31 downto 0);
	signal fifo_out_stb_s, fifo_out_ack_s : std_logic;
	signal fifo_out_data_left_s : std_logic_vector(31 downto 0);
	signal fifo_out_data_right_s : std_logic_vector(31 downto 0);

	signal data_right_s : std_logic_vector(31 downto 0);
	signal data_left_s : std_logic_vector(31 downto 0);
begin
	rstn <= not reset;

	dma_fifo_inst: entity work.dma_fifo
	generic map (FIFO_AWIDTH => 8, FIFO_DWIDTH => 32)
	port map (clk => clk, resetn => rstn,
		fifo_reset => fifo_rst,

		in_stb => fifo_in_stb_s, in_ack => fifo_in_ack_s,
		in_data => fifo_in_data_s,
		out_stb => fifo_out_stb_s, out_ack => fifo_out_ack_s,
		out_data_left => fifo_out_data_left_s,
		out_data_right => fifo_out_data_right_s
	);

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				fifo_in_stb_s <= '0';
				fifo_in_data_s <= (others => '0');
			elsif start_prod_s = '1' and fifo_in_ack_s = '1' then
					fifo_in_data_s <= std_logic_vector(
							unsigned(fifo_in_data_s) + 1);
					fifo_in_stb_s <= '1';
			else
				fifo_in_stb_s <= '0';
				fifo_in_data_s <= fifo_in_data_s;
			end if;
		end if;
	end process;

	process(clk)
		variable ready_v : std_logic;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				fifo_out_ack_s <= '0';
				data_left_s <= (others => '0');
				data_right_s <= (others => '0');
			else
				if (fifo_in_ack_s = '0') then
					ready_v := '1';
				elsif (fifo_out_stb_s = '0') then
					ready_v := '0';
				else
					ready_v := ready_v;
				end if;

				if ready_v = '1' then
					data_left_s <= fifo_out_data_left_s;
					data_right_s <= fifo_out_data_right_s;
					fifo_out_ack_s <= '1';
				else
					data_left_s <= data_left_s;
					data_right_s <= data_right_s;
					fifo_out_ack_s <= '0';
				end if;
			end if;
		end if;
	end process;
					



    stimulis : process
    begin
	start_prod_s <= '0';
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
    wait for 10 ns;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	start_prod_s <= '1';
    wait for 10 us;
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
