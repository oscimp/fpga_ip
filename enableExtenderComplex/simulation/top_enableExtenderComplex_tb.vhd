library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_enableExtenderComplex_tb is
end entity top_enableExtenderComplex_tb;

architecture RTL of top_enableExtenderComplex_tb is
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period

	constant DATA_SIZE : natural := 16;
	signal data_en_i_s, data_rst_i_s, data_clk_i_s, data_eof_i_s, data_en_o_s, data_rst_o_s, data_clk_o_s, data_eof_o_s : std_logic;
	signal data_i_i_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_q_i_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_i_o_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_q_o_s : std_logic_vector(DATA_SIZE-1 downto 0);

	signal start_prod : std_logic;
	constant MAX_CNT : natural := 16;
	signal cpt_s : natural range 0 to MAX_CNT-1;

begin
	tb_inst: Entity work.enableExtenderComplex
	generic map (
		DATA_SIZE => DATA_SIZE
	)
	port map (
		data_i_i => data_i_i_s,
		data_q_i => data_q_i_s,
		data_en_i => data_en_i_s,
		data_rst_i => data_rst_i_s,
		data_clk_i => data_clk_i_s,
		data_eof_i => data_eof_i_s,
		data_i_o => data_i_o_s,
		data_q_o => data_q_o_s,
		data_en_o => data_en_o_s,
		data_rst_o => data_rst_o_s,
		data_clk_o => data_clk_o_s
	);

	-- generate data flow
	data_propagation : process(data_clk_i_s, data_rst_i_s)
	begin
		if (data_rst_i_s = '1') then
			data_i_i_s <= (others => '0');
			data_q_i_s <= (others => '0');
			data_en_i_s <= '0';
			data_eof_i_s <= '0';
			cpt_s <= 0;
		elsif rising_edge(data_clk_i_s) then
			cpt_s <= cpt_s;
			data_en_i_s <= '0';
			data_eof_i_s <= '0';
			data_i_i_s <= data_i_i_s;
			data_q_i_s <= data_q_i_s;
			if start_prod = '1' then
				if cpt_s < MAX_CNT-1 then
					cpt_s <= cpt_s + 1;
				else
					cpt_s <= 0;
					data_i_i_s <= std_logic_vector(to_unsigned(cpt_s, DATA_SIZE));
					data_q_i_s <= std_logic_vector(to_unsigned(cpt_s, DATA_SIZE));
					data_i_i_s <= std_logic_vector(unsigned(data_i_i_s) +1);
					data_q_i_s <= std_logic_vector(unsigned(data_q_i_s) +1);
					data_en_i_s <= '1';
					data_eof_i_s <= '0';
				end if;
			end if;
		end if;
	end process; 

	stimulis : process
	begin
	start_prod <= '0';
	data_rst_i_s <= '0';
	wait until rising_edge(data_clk_i_s);
	data_rst_i_s <= '1';
	wait until rising_edge(data_clk_i_s);
	wait until rising_edge(data_clk_i_s);
	wait until rising_edge(data_clk_i_s);
	data_rst_i_s <= '0';
	wait for 10 ns;
	wait until rising_edge(data_clk_i_s);
	wait until rising_edge(data_clk_i_s);
	start_prod <= '1';
	wait for 50 us;
	assert false report "End of test" severity error;
	end process stimulis;
	
	clockp : process
	begin
		data_clk_i_s <= '1';
		wait for HALF_PERIODE;
		data_clk_i_s <= '0';
		wait for HALF_PERIODE;
	end process clockp;
	
end architecture RTL;
