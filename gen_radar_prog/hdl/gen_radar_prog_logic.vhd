---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity gen_radar_prog_logic is
	generic (
		DATA_SIZE : natural := 16;
		BURST_SIZE : natural := 1024
	);
	port (
		-- Syscon signals
		clk       	: in std_logic ;
		reset      	: in std_logic ;
		switch_o	: out std_logic;
		switchn_o   : out std_logic;
		-- axi
		rxoff_i		: in std_logic_vector(15 downto 0);
		txon_i 		: in std_logic_vector(15 downto 0);
		point_period_i : in std_logic_vector(15 downto 0);
		--processing
		data_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i	: in std_logic;
		data_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o	: out std_logic;
		data_eof_o	: out std_logic
	);
end gen_radar_prog_logic;

architecture Behavioral of gen_radar_prog_logic is
	signal switch_time : integer range 0 to 2**16-1;
	signal switch_rxoff: integer range 0 to 2**16-1;
	signal switch_rxtx : integer range 0 to 2**16-1;

	signal ct : natural range 0 to 2**16-1;
	signal switch_s : std_logic;
	signal switch_tx: std_logic;
	signal point_per_nat_s : natural range 0 to 2**16-1;
	
	signal data_i_s, data_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	signal cpt_s, cpt_next_s : natural range 0 to 2**16-1;
	signal restart_switch_s : std_logic;
	-- comm
	--signal addr_s : std_logic_vector(1 downto 0);
	--signal write_en_s, read_en_s : std_logic;
begin

	switch_rxoff <= to_integer(unsigned(rxoff_i));
	switch_rxtx <= to_integer(unsigned(rxoff_i)+unsigned(txon_i));
	switch_time <= to_integer(unsigned(rxoff_i) + unsigned(rxoff_i)+unsigned(txon_i));

	data_i_o <= data_i_s;	
	data_q_o <= data_q_s;	
	data_en_o <= data_en_s;

    switch_o <= not switch_s;
	switchn_o<= switch_tx; -- switch_s;  cas des deux signaux inverses simplement


	point_per_nat_s <= to_integer(unsigned(point_period_i));

	process(clk, reset)
	begin
		if reset = '1' then
			data_i_s <= (others => '0');
			data_q_s <= (others => '0');
			data_en_s <= '0';
			data_eof_o <= '0';
		elsif rising_edge(clk) then
			data_i_s <= data_i_s;
			data_q_s <= data_q_s;
			data_en_s <= '0';
			data_eof_o <= '0';
			if cpt_s < point_per_nat_s and switch_s = '0' and data_en_i = '1' then
				data_i_s <= data_i_i;
				data_q_s <= data_q_i;
				data_en_s <= data_en_i;
				if cpt_s = point_per_nat_s -1 then
					data_eof_o <= '1';
				end if;
			end if;
		end if;
	end process;
	
	process(clk, reset)
	begin
		if reset = '1' then
			switch_s <= '1';
			switch_tx<= '0';
			ct <= 1;
		elsif rising_edge(clk) then
			switch_s <= switch_s;
			switch_tx <= switch_tx;
			ct <= ct;
			if switch_s = '0' then
				if restart_switch_s = '1' then
					switch_s <= '1';
					ct <= 1;
				end if;
			else
				if ct>switch_rxoff and ct<switch_rxtx then
				--if ct>=switch_rxoff and ct<switch_rxtx then
					switch_tx <= '1';
				else
					switch_tx <= '0';
				end if;
				if ct < switch_time then
					ct <= ct + 1;
				else
					ct <= 0;
					switch_s <= '0';
				end if;
			end if;
		end if;
	end process;

	restart_switch_s <= '1' when cpt_s = point_per_nat_s-1 else '0';
	cpt_next_s <= cpt_s + 1 when switch_s = '0' and cpt_s < point_per_nat_s-1
				else 0;

	process(clk, reset)
	begin
		if reset = '1' then
			cpt_s <= 0;
		elsif rising_edge(clk) then
			if data_en_s = '1' then
				cpt_s <= cpt_next_s;
			end if;
		end if;
	end process;

end Behavioral;
