---------------------------------------------------------------------------
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2018/11/30
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
USE std.textio.ALL;

entity top_data_subtop_tb is
end entity top_data_subtop_tb;

architecture RTL of top_data_subtop_tb is

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
   	signal clk : std_logic;

	constant DATA_SIZE : natural := 32;
	constant ADDR_SIZE : natural := 6;
	constant AXI_SIZE : natural := 32;

	-- data gen
	signal start_prod_s : std_logic := '0';

	signal busy_s : std_logic;
	signal result_s : std_logic_vector(AXI_SIZE-1 downto 0);
	signal read_i_s, read_q_s : std_logic_vector(15 downto 0);
	signal result_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_i_s : std_logic_vector(15 downto 0);
	signal wr_i_s, wr_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s : std_logic;

	signal state_s : std_logic;

	type  read_state is (IDLE, WAIT_END, READ, WAIT1, WAIT2);
	signal state_read_s : read_state;
	signal data_next_s : std_logic_vector(AXI_SIZE-1 downto 0);
	signal data_next_en_s : std_logic;
begin

	dut : entity work.dataComplex_to_ram_subtop
	generic map(
		USE_EOF => false,
		INPUT_SIZE => DATA_SIZE,
		DATA_SIZE => DATA_SIZE,
		WR_ADDR_SIZE => 5,
		RD_ADDR_SIZE => ADDR_SIZE
	)
	port map(
		cpu_clk_i => clk, cpu_rst_i => reset,
		data_clk_i => clk, data_rst_i => reset,
		start_acq_i => start_prod_s, busy_o => busy_s,
		data_o => result_s, result_addr_i => result_addr_s,
		data_i_i => wr_i_s, data_q_i => wr_q_s,
		data_en_i => data_en_s, data_eof_i => '0');
	
	use16: if DATA_SIZE = 16 generate
		wr_i_s <= data_i_s;
		wr_q_s <= std_logic_vector(unsigned(data_i_s) + 100);
		read_i_s <= data_next_s(AXI_SIZE-1 downto AXI_SIZE-16);
		read_q_s <= data_next_s(15 downto 0);
	end generate use16;
	use32: if DATA_SIZE = 32 generate
		wr_i_s <= data_i_s &
			std_logic_vector(unsigned(data_i_s) + 100);
		wr_q_s <= std_logic_vector(unsigned(data_i_s) + 200) &
			std_logic_vector(unsigned(data_i_s) + 300);
		read_i_s <= data_next_s(AXI_SIZE-1 downto AXI_SIZE-16);
		read_q_s <= data_next_s(15 downto 0);
	end generate use32;
	use64: if DATA_SIZE = 64 generate
		wr_i_s <= data_i_s &
			std_logic_vector(unsigned(data_i_s) + 100) &
			std_logic_vector(unsigned(data_i_s) + 200) &
			std_logic_vector(unsigned(data_i_s) + 300);
		wr_q_s <= std_logic_vector(unsigned(data_i_s) + 400) &
			std_logic_vector(unsigned(data_i_s) + 500) &
			std_logic_vector(unsigned(data_i_s) + 600) &
			std_logic_vector(unsigned(data_i_s) + 700);
		read_i_s <= data_next_s(AXI_SIZE-1 downto AXI_SIZE-16);
		read_q_s <= data_next_s(15 downto 0);
	end generate use64;
	
	process(clk) begin
		if rising_edge(clk) then
			data_en_s <= '0';
			if reset = '1' then
				state_s <= '0';
				data_i_s <= (others => '0');
			else
				data_i_s <= data_i_s;
				state_s <= state_s;
				if (state_s = '0') then
					if (busy_s ) = '1' then
						state_s <= '1';
					end if;
				else
					data_i_s <= std_logic_vector(unsigned(data_i_s) + 1);
					data_en_s <= '1';
				end if;
			end if;
		end if;
	end process;


	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				state_read_s <= IDLE;
				result_addr_s <= (others => '0');
				data_next_en_s <= '0';
				data_next_s <= (others => '0');
			else
				state_read_s <= state_read_s;
				result_addr_s <= result_addr_s;
				data_next_en_s <= '0';
				data_next_s <= data_next_s;
				case (state_read_s) is
				when IDLE =>
					if (busy_s = '1') then
						state_read_s <= WAIT_END;
						result_addr_s <= (others => '0');
					end if;
				when WAIT_END =>
					if busy_s = '0' then
						state_read_s <= READ;
					end if;
				when READ =>
					result_addr_s <= std_logic_vector(unsigned(result_addr_s) + 1);
					data_next_s <= result_s;
					data_next_en_s <= '1';
					if unsigned(result_addr_s) = (2**ADDR_SIZE)-1 then
						state_read_s <= IDLE;
					else
						state_read_s <= WAIT1;
					end if;
				when WAIT1 =>
					state_read_s <= WAIT2;
				when WAIT2 =>
					state_read_s <= READ;
				end case;
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
	start_prod_s <= '1';
	wait until rising_edge(clk);
	start_prod_s <= '0';
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
