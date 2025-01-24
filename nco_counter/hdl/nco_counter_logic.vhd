---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2015/04/08
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
USE std.textio.ALL;

entity nco_counter_logic is
	generic (
		TEST : boolean := false;
		RESET_ACCUM : boolean := false;
		LUT_SIZE : natural := 10;
		COUNTER_SIZE : natural := 32;
		DATA_SIZE : natural := 16;
		MAX_TRIG : natural := 1
	);
	port (
		cpu_clk_i : in std_logic;
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- configuration (wishbone)
		enable_i    : in std_logic;
		sync_i  : in std_logic;
		max_accum_i : in std_logic_vector(COUNTER_SIZE-1 downto 0);
		cpt_off_i : in std_logic_vector(LUT_SIZE-1 downto 0) := (others => '0');
		cpt_inc_i : in std_logic_vector(COUNTER_SIZE-1 downto 0) := (others => '0');
		trigger_o : out std_logic;
		-- next
		--step_scale_o : out std_logic_vector(LUT_SIZE-1 downto 0);
		cos_o : out std_logic_vector(DATA_SIZE -1 downto 0);
		sin_o : out std_logic_vector(DATA_SIZE -1 downto 0);
		saw_i_o : out std_logic_vector(DATA_SIZE -1 downto 0);
		saw_q_o : out std_logic_vector(DATA_SIZE -1 downto 0);
		triangle_i_o : out std_logic_vector(DATA_SIZE -1 downto 0);
		triangle_q_o : out std_logic_vector(DATA_SIZE -1 downto 0);
		sin_fake_o : out std_logic;
		wave_en_o : out std_logic;
		cos_fake_o : out std_logic
	);
end nco_counter_logic;

architecture Behavioral of nco_counter_logic is
	signal counter_next_s, counter_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal counter_sin_s : std_logic_vector(COUNTER_SIZE-1 downto 0);

	signal counter_scale_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal counter_sin_scale_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal counter_sin_off_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal counter_cos_off_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal triangle_sin_off_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal triangle_cos_off_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal triangle_dir_sin : std_logic;
	signal triangle_dir_cos : std_logic;
	signal sin_next, cos_next : std_logic;
	signal cos_s, sin_s : std_logic_vector(15 downto 0);
	-- synchro
	file final_result_file: text open write_mode is "./toto.txt";
	signal cos_scale_del_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal cos_del_s : std_logic_vector(COUNTER_SIZE-1 downto 0);

	signal int_rst_s : std_logic;

	-- reset accum
	signal rst_accum_s : std_logic := '0';
	signal cpt_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
	-- trigger
	signal trig_cpt_s : natural range 0 to MAX_TRIG;
	signal counter_old_s, reinit_counter_s : std_logic;
	constant sin_static_offset_s : unsigned(COUNTER_SIZE-2 downto 0) := '1' & (COUNTER_SIZE-3 downto 0 => '0');
begin
	int_rst_s <= (not enable_i) or rst_i or sync_i;
	-- in fact the enable signal is alwais true
	wave_en_o <= enable_i;

	counter_sin_s <=
		std_logic_vector(unsigned(counter_s)-sin_static_offset_s);
	cos_next <= counter_s(COUNTER_SIZE-1);
	sin_next <= counter_sin_s(COUNTER_SIZE-1);

	sin_cos_proc: process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				cos_fake_o <= '1';
				sin_fake_o <= '1';
			else
				cos_fake_o <= cos_next;
				sin_fake_o <= sin_next;
			end if;
		end if;
	end process sin_cos_proc;

	-- for sin waveform
	counter_next_s <= std_logic_vector(unsigned(counter_s) +
					unsigned(cpt_inc_i)) when rst_accum_s = '0' else
					(others => '0');
	cpt_sin_proc: process(clk_i)
	begin
		if rising_edge(clk_i) then
			if int_rst_s = '1' then
				counter_s <= (others => '0');
			else
				counter_s <= counter_next_s;
			end if;
		end if;
	end process cpt_sin_proc;
	counter_scale_s <= counter_s(COUNTER_SIZE-1 downto COUNTER_SIZE-LUT_SIZE);
	counter_sin_scale_s <= counter_sin_s(COUNTER_SIZE-1 downto COUNTER_SIZE-LUT_SIZE);

	use_rst_accum : if RESET_ACCUM = true generate
		process(clk_i)
		begin
			if rising_edge(clk_i) then
				if int_rst_s = '1' then
					cpt_s <= (others => '0');
					rst_accum_s <= '0';
				else
					rst_accum_s <= '0';
					if unsigned(cpt_s) = unsigned(max_accum_i)-1 then
						cpt_s <= (others => '0');
						rst_accum_s <= '1';
					else
						cpt_s <= std_logic_vector(unsigned(cpt_s) + 1);
					end if;
				end if;
			end if;
		end process;
	end generate use_rst_accum;

	reinit_counter_s <= '1' when counter_old_s = '1' and counter_s(COUNTER_SIZE-1) = '0'
					else '0';

	process(clk_i) begin
		if rising_edge(clk_i) then
			trigger_o <= '0';
			counter_old_s <= counter_s(COUNTER_SIZE-1);
			if ((reinit_counter_s or int_rst_s) = '1') then
				trig_cpt_s <= 0;
			elsif trig_cpt_s = MAX_TRIG then
				trig_cpt_s <= trig_cpt_s;
			else
				trig_cpt_s <= trig_cpt_s + 1;
				trigger_o <= '1';
			end if;
		end if;
	end process;

	-- maybe use a synchronous before ROM --
	counter_cos_off_s <= std_logic_vector(
		unsigned(counter_scale_s) + unsigned(cpt_off_i));
	counter_sin_off_s <= std_logic_vector(
		unsigned(counter_sin_scale_s) + unsigned(cpt_off_i));

	triangle_dir_sin <= counter_sin_off_s(LUT_SIZE-1);
	triangle_dir_cos <= counter_cos_off_s(LUT_SIZE-1);

	process(clk_i) begin
		if rising_edge(clk_i) then
		    if (triangle_dir_cos = '1') then
		        triangle_cos_off_s <= std_logic_vector(shift_left(signed(counter_sin_off_s), 1));
			else
			    triangle_cos_off_s <= std_logic_vector(- shift_left(signed(counter_sin_off_s), 1)-1);
			end if;
			if (triangle_dir_sin = '1') then
			    triangle_sin_off_s <= std_logic_vector(shift_left(signed(counter_cos_off_s), 1));
			else
			    triangle_sin_off_s <= std_logic_vector(- shift_left(signed(counter_cos_off_s), 1)-1);
			end if;
		end if;
	end process;

	rom_10 : if LUT_SIZE = 10 generate
	rom10_inst : entity work.nco_counter_cos_rom
	port map (
		clk => clk_i,
		addr_a => counter_cos_off_s,
		addr_b => counter_sin_off_s,
		data_a => cos_s,
		data_b => sin_s
	);
	end generate rom_10;

	rom_12 : if LUT_SIZE = 12 generate
	rom12_inst : entity work.nco_counter_cos_rom_a12_d16
	port map (
		clk => clk_i,
		addr_a => counter_cos_off_s,
		addr_b => counter_sin_off_s,
		data_a => cos_s,
		data_b => sin_s
	);
	end generate rom_12;
	rom_16 : if LUT_SIZE = 16 generate
	rom_inst : entity work.nco_counter_cos_rom_a16_d16
	port map (
		clk => clk_i,
		addr_a => counter_cos_off_s,
		addr_b => counter_sin_off_s,
		data_a => cos_s,
		data_b => sin_s
	);
	end generate rom_16;
	
	same_size: if DATA_SIZE = 16 generate
	   cos_o <= cos_s;
	   sin_o <= sin_s;
	end generate same_size;

	lt_size: if DATA_SIZE < 16 generate
	   cos_o <= cos_s(15 downto 16-DATA_SIZE);
	   sin_o <= sin_s(15 downto 16-DATA_SIZE);
	end generate lt_size;

	gt_size: if DATA_SIZE > 16 generate
		cos_o <= cos_s & (DATA_SIZE-17 downto 0 => '0');
		sin_o <= sin_s & (DATA_SIZE-17 downto 0 => '0');
	end generate gt_size;

	same_size_saw: if DATA_SIZE = LUT_SIZE generate
		saw_i_o <= counter_sin_off_s;
		saw_q_o <= counter_cos_off_s;
	end generate same_size_saw;

	lt_size_saw: if DATA_SIZE < LUT_SIZE generate
	   saw_i_o <= counter_sin_off_s(LUT_SIZE-1 downto LUT_SIZE-DATA_SIZE);
	   saw_q_o <= counter_cos_off_s(LUT_SIZE-1 downto LUT_SIZE-DATA_SIZE);
	end generate lt_size_saw;

	gt_size_saw: if DATA_SIZE > LUT_SIZE generate
		saw_i_o <= counter_sin_off_s & (DATA_SIZE-LUT_SIZE-1 downto 0 => '0');
		saw_q_o <= counter_cos_off_s & (DATA_SIZE-LUT_SIZE-1 downto 0 => '0');
	end generate gt_size_saw;

	same_size_triangle: if DATA_SIZE = LUT_SIZE generate
		triangle_i_o <= triangle_sin_off_s;
		triangle_q_o <= triangle_cos_off_s;
	end generate same_size_triangle;

	lt_size_triangle: if DATA_SIZE < LUT_SIZE generate
	   triangle_i_o <= triangle_sin_off_s(LUT_SIZE-1 downto LUT_SIZE-DATA_SIZE);
	   triangle_q_o <= triangle_cos_off_s(LUT_SIZE-1 downto LUT_SIZE-DATA_SIZE);
	end generate lt_size_triangle;

	gt_size_triangle: if DATA_SIZE > LUT_SIZE generate
		triangle_i_o <= triangle_sin_off_s & (DATA_SIZE-LUT_SIZE-1 downto 0 => '0');
		triangle_q_o <= triangle_cos_off_s & (DATA_SIZE-LUT_SIZE-1 downto 0 => '0');
	end generate gt_size_triangle;

end Behavioral;
