---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.all;

entity syncTrigStream_logic is
	generic (
		USE_EXT_TRIG : boolean := false;
		GEN_SIZE  : natural := 32;
		DATA_SIZE : natural := 16;
		NB_SAMPLE : natural := 1024
	);
	port (
		-- Syscon signals
		clk       	: in std_logic;
		reset      	: in std_logic;
		-- pulse
		ext_trig_i  : in std_logic;
		pulse_o     : out std_logic;
		-- axi
		duty_cnt_i   : in std_logic_vector(GEN_SIZE-1 downto 0);
		period_cnt_i : in std_logic_vector(GEN_SIZE-1 downto 0);
		enable_i     : in std_logic;
		--processing
		data_en_i	: in std_logic;
		data1_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data1_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o	: out std_logic;
		data_sof_o	: out std_logic;
		data_eof_o	: out std_logic
	);
end syncTrigStream_logic;

architecture Behavioral of syncTrigStream_logic is
	-- pulse gen
	signal pulse_counter_s : unsigned(GEN_SIZE-1 downto 0);
	signal pulse_s         : std_logic;
	signal pulse_d0_s      : std_logic;
	signal pulse_d1_s      : std_logic;
	signal restart_cnt     : boolean;

	signal start_tx_s      : std_logic;
	signal end_tx_s        : boolean;
	constant CPT_SIZE      : natural := natural(ceil(log2(real(NB_SAMPLE))));
	signal cpt_data_s      : unsigned(CPT_SIZE-1 downto 0);

	signal busy_s          : std_logic;

	signal data1_i_s, data1_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data2_i_s, data2_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
begin

	pulse_o <= pulse_s;
	
	ext_trig : if USE_EXT_TRIG = true generate
		process(clk) begin
			if rising_edge(clk) then
				pulse_d1_s <= ext_trig_i;
				pulse_d0_s <= pulse_d1_s;
				pulse_s <= pulse_d0_s;
			end if;
		end process;
	end generate ext_trig;

	internal_trig: if USE_EXT_TRIG = false generate
		-- pulse generator --
		pulse_s <= enable_i when pulse_counter_s < unsigned(duty_cnt_i) else '0';
		restart_cnt <= pulse_counter_s = unsigned(period_cnt_i)-1;
		process(clk) begin
			if rising_edge(clk) then
				if restart_cnt or enable_i = '0' or reset = '1' then
					pulse_counter_s <= (others => '0');
				else
					pulse_counter_s <= pulse_counter_s + 1;
				end if;
				pulse_d0_s <= pulse_s;
	
			end if;
		end process;
	end generate internal_trig;

	-- tx
	start_tx_s <= (pulse_d0_s xor pulse_s) and pulse_d0_s;

	process(clk) begin
		if rising_edge(clk) then
			if (not busy_s or reset) = '1' then
				cpt_data_s <= (others => '0');
			elsif data_en_i = '1' then
				cpt_data_s <= cpt_data_s + 1;
			end if;
		end if;
	end process;

	end_tx_s <= cpt_data_s = NB_SAMPLE-1;

	process(clk) begin
		if rising_edge(clk) then
			if (data_en_i = '1' and end_tx_s) or (reset = '1') then
				busy_s <= '0';
			elsif start_tx_s = '1' then
				busy_s <= '1';
			end if;
		end if;
	end process;

	process(clk) begin
		if rising_edge(clk) then
			data_en_o <= '0';
			data_sof_o <= '0';
			data_eof_o <= '0';
			if (reset = '1') then
				data1_i_s <= (others => '0');
				data1_q_s <= (others => '0');
				data2_i_s <= (others => '0');
				data2_q_s <= (others => '0');
			elsif busy_s = '1' then
				if data_en_i = '1' then
					data1_i_s <= data1_i_i;
					data1_q_s <= data1_q_i;
					data2_i_s <= data2_i_i;
					data2_q_s <= data2_q_i;
					data_en_o <= '1';
					if (cpt_data_s = 0) then
						data_sof_o <= '1';
					end if;
					if (cpt_data_s = NB_SAMPLE-1) then
						data_eof_o <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	data1_i_o <= data1_i_s;
	data1_q_o <= data1_q_s;
	data2_i_o <= data2_i_s;
	data2_q_o <= data2_q_s;

end Behavioral;
